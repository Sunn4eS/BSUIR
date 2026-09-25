/**
 * Модуль 4 «Эмулятор банкомата (ATM)» — клиентская логика.
 * Страница atm.html: вставка карты → авторизация на сервере → ПИН (3 попытки) →
 * главное меню → снятие наличных / остаток / оплата мобильной связи → чек.
 * Все операции выполняются через API /api/atm и сразу отражаются в
 * оборотной ведомости (раздел «Счета» на главной странице банка).
 */
(function () {
  'use strict';

  const { api, showToast, escapeHtml, formatDate, formatMoney } = Common;

  // -------------------------------------------------------------------------
  // Состояние
  // -------------------------------------------------------------------------
  const state = {
    cards: [],
    bankDate: null,
    card: null,          // результат card-check: masked-номер, клиент, договор
    sessionId: null,
    balance: null,       // последние данные остатка (лимит/долг/доступно)
    view: null,
    pinBuffer: '',
    attemptsLeft: 3,
    keypadMode: null,    // 'pin' | 'custom-amount' | 'payment-phone' | 'payment-amount'
    pendingWithdraw: { amount: null, wantReceipt: false },
    lastReceipt: null,
    messageBack: 'insert', // куда вернуться из экрана сообщения
    customAmount: '',
  };

  const elements = {};
  const VIEW_NAMES = [
    'insert', 'auth', 'pin', 'menu', 'withdraw', 'withdraw-receipt',
    'dispense', 'payment', 'receipt', 'balance', 'message',
  ];

  const cache = {};
  function $(id) {
    if (!cache[id]) cache[id] = document.getElementById(id);
    return cache[id];
  }

  // -------------------------------------------------------------------------
  // Навигация по экранам
  // -------------------------------------------------------------------------
  function showView(name) {
    VIEW_NAMES.forEach((viewName) => {
      const viewEl = $('view-' + viewName);
      if (viewEl) viewEl.classList.toggle('hidden', viewName !== name);
    });
    state.view = name;
  }

  function showMessage(title, text, backTo) {
    $('message-badge').textContent = '⚠';
    $('message-title').textContent = title;
    $('message-text').textContent = text;
    state.messageBack = backTo || 'menu';
    showView('message');
  }

  function showInfo(title, text, backTo) {
    $('message-badge').textContent = 'ℹ';
    $('message-title').textContent = title;
    $('message-text').textContent = text;
    state.messageBack = backTo || 'menu';
    showView('message');
  }

  // -------------------------------------------------------------------------
  // Маскирование номера карты: 4916 1234 5678 9010 -> 4916 **** **** 9010 (с сохранением префикса в списке)
  // -------------------------------------------------------------------------
  function maskFull(cardNumber) {
    const s = String(cardNumber);
    if (s.length !== 16) return s;
    return `${s.slice(0, 4)} **** **** ${s.slice(-4)}`;
  }

  function maskAtm(cardNumber) {
    const s = String(cardNumber);
    return `**** **** **** ${s.slice(-4)}`;
  }

  // -------------------------------------------------------------------------
  // Клавиатура банкомата
  // -------------------------------------------------------------------------
  function buildKeypad() {
    const pad = $('atm-keypad');
    pad.innerHTML = '';

    const keys = ['1', '2', '3', '4', '5', '6', '7', '8', '9', '0', '.', '⌫'];
    keys.forEach((label) => {
      const btn = document.createElement('button');
      btn.type = 'button';
      btn.className = 'key-btn' + (label === '.' ? ' key-dot hidden' : '');
      btn.dataset.key = label;
      btn.textContent = label;
      pad.appendChild(btn);
    });

    const ok = document.createElement('button');
    ok.type = 'button';
    ok.className = 'key-btn key-ok';
    ok.dataset.key = 'OK';
    ok.textContent = 'OK';
    pad.appendChild(ok);
  }

  function setKeypadMode(mode) {
    state.keypadMode = mode;
    const dot = padKey('.');
    if (dot) dot.classList.toggle('hidden', mode !== 'payment-amount');
  }

  function padKey(label) {
    return document.querySelector(`#atm-keypad .key-btn[data-key="${label}"]`);
  }

  // -------------------------------------------------------------------------
  // ПИН-код
  // -------------------------------------------------------------------------
  function renderPinDots() {
    const dots = Array.from(document.querySelectorAll('#pin-dots .pin-dot'));
    dots.forEach((dotEl, i) => {
      dotEl.classList.toggle('filled', i < state.pinBuffer.length);
    });
  }

  function resetPinScreen() {
    state.pinBuffer = '';
    renderPinDots();
    $('pin-error').textContent = '';
    $('pin-attempts').textContent = state.attemptsLeft > 0
      ? `Осталось попыток: ${state.attemptsLeft}`
      : '';
  }

  async function submitPin() {
    if (state.pinBuffer.length !== 4) return;
    const pin = state.pinBuffer;
    try {
      const result = await api.atmAuthorize({
        card_number: state.card.raw_number,
        pin,
      });
      state.sessionId = result.session_id;
      state.card.masked = result.card_number;
      state.card.client_name = result.client_name;
      state.card.contract_number = result.contract_number;
      await refreshBalance();
      fillMenuBalance();
      showView('menu');
    } catch (err) {
      const status = err.cause && err.cause.status;
      if (status === 423) {
        showMessage('Карта заблокирована', 'Карта заблокирована. Обратитесь в банк.', 'insert');
        return;
      }
      if (status === 401) {
        state.attemptsLeft -= 1;
        state.pinBuffer = '';
        renderPinDots();
        if (state.attemptsLeft <= 0) {
          showMessage('Карта заблокирована', 'Карта заблокирована (3 неверные попытки). Обратитесь в банк.', 'insert');
          return;
        }
        $('pin-error').textContent = err.message;
        $('pin-attempts').textContent = `Осталось попыток: ${state.attemptsLeft}`;
        return;
      }
      showMessage('Ошибка авторизации', err.message, 'insert');
    }
  }

  // -------------------------------------------------------------------------
  // Остаток по кредитному счёту (лимит / задолженность 2400 / доступно)
  // -------------------------------------------------------------------------
  async function refreshBalance() {
    if (!state.sessionId) return null;
    const data = await api.atmBalance({ session_id: state.sessionId });
    state.balance = data;
    return data;
  }

  function fillMenuBalance() {
    if (!state.balance) return;
    $('menu-card-number').textContent = state.card && state.card.masked ? state.card.masked : '—';
    $('menu-client-name').textContent = state.card ? state.card.client_name : '';
    $('menu-limit').textContent = formatMoney(state.balance.credit_limit) + ' BYN';
    $('menu-debt').textContent = formatMoney(state.balance.current_debt) + ' BYN';
    $('menu-available').textContent = formatMoney(state.balance.available_balance) + ' BYN';
  }

  function fillBalanceView() {
    if (!state.balance) return;
    $('bal-card-number').textContent = state.card ? state.card.masked : '—';
    $('bal-client-name').textContent = state.card ? state.card.client_name : '';
    $('bal-limit').textContent = formatMoney(state.balance.credit_limit) + ' BYN';
    $('bal-debt').textContent = formatMoney(state.balance.current_debt) + ' BYN';
    $('bal-available').textContent = formatMoney(state.balance.available_balance) + ' BYN';
    $('bal-session').textContent =
      `Кредитный счёт 2400: ${state.balance.account_number} · договор ${state.balance.contract_number}`;
  }

  // -------------------------------------------------------------------------
  // Чек
  // -------------------------------------------------------------------------
  function fillReceipt(receipt) {
    $('r-card').textContent = receipt.card;
    $('r-datetime').textContent = receipt.datetime;
    $('r-opno').textContent = String(receipt.operation_number);
    $('r-auth').textContent = receipt.auth_code;
    $('r-type').textContent = receipt.operation_type;
    $('r-amount').textContent = formatMoney(receipt.amount) + ' BYN';
    $('r-avail').textContent = formatMoney(receipt.available_balance) + ' BYN';
    $('r-status').textContent = receipt.status;
  }

  // -------------------------------------------------------------------------
  // Снятие наличных
  // -------------------------------------------------------------------------
  function openWithdraw() {
    state.customAmount = '';
    $('custom-amount-value').textContent = '0';
    $('custom-amount-block').classList.add('hidden');
    $('withdraw-available').textContent = state.balance
      ? formatMoney(state.balance.available_balance) + ' BYN'
      : '—';
    setKeypadMode('custom-amount');
    showView('withdraw');
  }

  function pickAmount(amount) {
    state.pendingWithdraw.amount = amount;
    setKeypadMode(null);
    showView('withdraw-receipt');
  }

  async function executeWithdraw() {
    const amount = state.pendingWithdraw.amount;
    if (!state.sessionId || !amount) return;
    try {
      const result = await api.atmWithdraw({ session_id: state.sessionId, amount });
      state.balance = {
        ...state.balance,
        credit_limit: result.credit_limit,
        current_debt: result.current_debt,
        available_balance: result.available_balance,
      };
      state.lastReceipt = result.receipt;
      $('dispense-amount').textContent = formatMoney(amount) + ' BYN';
      showView('dispense');
    } catch (err) {
      showMessage('Снятие невозможно', err.message, 'withdraw');
    }
  }

  // -------------------------------------------------------------------------
  // Оплата мобильной связи
  // -------------------------------------------------------------------------
  function openPayment() {
    $('payment-operator').value = '';
    $('payment-phone').value = '';
    $('payment-amount').value = '';
    setKeypadMode(null);
    showView('payment');
  }

  async function executePayment() {
    const operator = $('payment-operator').value;
    const phone = $('payment-phone').value.replace(/\s+/g, '');
    const amount = $('payment-amount').value.replace(',', '.');

    if (!operator) {
      showMessage('Ошибка', 'Выберите оператора (А1, МТС, Life).', 'payment');
      return;
    }
    if (!/^\d{10}$/.test(phone)) {
      showMessage('Ошибка', 'Номер телефона должен состоять из 10 цифр.', 'payment');
      return;
    }
    const amountNumber = Number(amount);
    if (!(amountNumber > 0)) {
      showMessage('Ошибка', 'Укажите корректную сумму оплаты (например, 25.00).', 'payment');
      return;
    }

    try {
      const result = await api.atmPayment({
        session_id: state.sessionId,
        operator,
        phone,
        amount: amountNumber,
      });
      state.balance = {
        ...state.balance,
        credit_limit: result.credit_limit,
        current_debt: result.current_debt,
        available_balance: result.available_balance,
      };
      state.lastReceipt = result.receipt;
      fillReceipt(result.receipt);
      showView('receipt'); // автоматическая печать чека
    } catch (err) {
      showMessage('Оплата невозможна', err.message, 'payment');
    }
  }

  // -------------------------------------------------------------------------
  // Вставка/извлечение карты
  // -------------------------------------------------------------------------
  function ejectCard() {
    state.sessionId = null;
    state.card = null;
    state.balance = null;
    state.pinBuffer = '';
    state.attemptsLeft = 3;
    $('atm-card-peek').classList.remove('inserted');
    $('atm-card-number').value = '';
    $('atm-card-quick').value = '';
    showInfo('Карта извлечена', 'Возьмите карту из слота. Спасибо за пользование банкоматом!', 'insert');
  }

  async function insertCard() {
    const raw = $('atm-card-number').value.replace(/\s+/g, '');
    if (!/^\d{16}$/.test(raw)) {
      showMessage('Ошибка', 'Введите корректный номер карты — 16 цифр (или выберите карту из списка).', 'insert');
      return;
    }
    try {
      const check = await api.atmCardCheck({ card_number: raw });
      state.card = {
        raw_number: raw,
        masked: check.card_number,
        last4: check.last4,
        client_name: check.client_name,
        contract_number: check.contract_number,
        pin_attempts: check.pin_attempts,
      };
      if (check.is_blocked) {
        showMessage('Карта заблокирована', 'Карта заблокирована. Обратитесь в банк.', 'insert');
        return;
      }
      if (check.contract_status !== 'ACTIVE') {
        showMessage('Договор закрыт', `Кредитный договор ${check.contract_number} не является действующим.`, 'insert');
        return;
      }
      state.attemptsLeft = Math.max(0, 3 - Number(check.pin_attempts || 0));

      $('atm-card-peek').classList.add('inserted');
      showView('auth');
      await sleep(1300); // заставка «Авторизация на сервере...»
      $('pin-client-label').textContent =
        `Карта: ${state.card.masked} · ${state.card.client_name} · договор ${state.card.contract_number}`;
      resetPinScreen();
      setKeypadMode('pin');
      showView('pin');
    } catch (err) {
      showMessage('Ошибка', err.message, 'insert');
    }
  }

  function sleep(ms) {
    return new Promise((resolve) => setTimeout(resolve, ms));
  }

  // -------------------------------------------------------------------------
  // Обработка цифровой клавиатуры
  // -------------------------------------------------------------------------
  function handleKey(label) {
    switch (state.keypadMode) {
      case 'pin': {
        if (label === '⌫') {
          state.pinBuffer = state.pinBuffer.slice(0, -1);
          renderPinDots();
        } else if (label === 'OK') {
          submitPin();
        } else if (state.pinBuffer.length < 4) {
          state.pinBuffer += label;
          renderPinDots();
          if (state.pinBuffer.length === 4) submitPin();
        }
        break;
      }
      case 'custom-amount': {
        if (label === '⌫') {
          state.customAmount = state.customAmount.slice(0, -1);
        } else if (label === 'OK') {
          confirmCustomAmount();
        } else if (/^\d$/.test(label)) {
          if (state.customAmount.length < 6) state.customAmount += label;
        }
        $('custom-amount-value').textContent = state.customAmount || '0';
        break;
      }
      case 'payment-phone': {
        let value = $('payment-phone').value;
        if (label === '⌫') value = value.slice(0, -1);
        else if (/^\d$/.test(label) && value.length < 10) value += label;
        $('payment-phone').value = value;
        break;
      }
      case 'payment-amount': {
        let value = $('payment-amount').value;
        if (label === '⌫') {
          value = value.slice(0, -1);
        } else if (label === 'OK') {
          // ничего не делаем — сумма уже введена
        } else if (label === '.') {
          if (value.indexOf('.') === -1 && value.length < 8) value += '.';
        } else if (/^\d$/.test(label) && value.length < 8) {
          if (value.indexOf('.') !== -1) {
            const decimals = value.split('.')[1] || '';
            if (decimals.length < 2) value += label;
          } else {
            value += label;
          }
        }
        $('payment-amount').value = value;
        break;
      }
      default: {
        if (label === '⌫') {
          const input = $('atm-card-number');
          input.value = input.value.slice(0, -1);
        } else if (/^\d$/.test(label)) {
          const input = $('atm-card-number');
          if (input.value.length < 16) input.value += label;
        }
      }
    }
  }

  function confirmCustomAmount() {
    const amount = Number(state.customAmount);
    if (!Number.isInteger(amount) || amount <= 0) {
      showMessage('Ошибка', 'Введите корректную целую сумму для снятия (например, 55).', 'withdraw');
      return;
    }
    pickAmount(amount);
  }

  // -------------------------------------------------------------------------
  // События
  // -------------------------------------------------------------------------
  function bindEvents() {
    $('atm-keypad').addEventListener('click', (event) => {
      const btn = event.target.closest('.key-btn');
      if (!btn || btn.disabled) return;
      handleKey(btn.dataset.key);
    });

    // Вставка карты
    $('btn-insert-card').addEventListener('click', insertCard);
    $('atm-card-number').addEventListener('keydown', (event) => {
      if (event.key === 'Enter') insertCard();
    });
    $('atm-card-quick').addEventListener('change', () => {
      const cardId = Number($('atm-card-quick').value);
      const card = state.cards.find((c) => c.id === cardId);
      if (card) $('atm-card-number').value = card.card_number;
    });

    // ПИН
    $('btn-pin-cancel').addEventListener('click', ejectCard);

    // Меню
    document.querySelectorAll('.atm-menu-btn[data-menu]').forEach((btn) => {
      btn.addEventListener('click', () => {
        const action = btn.dataset.menu;
        if (action === 'withdraw') openWithdraw();
        else if (action === 'balance') showBalanceScreen();
        else if (action === 'payment') openPayment();
      });
    });
    $('btn-eject-card').addEventListener('click', ejectCard);

    // Снятие
    document.querySelectorAll('.atm-amount-btn').forEach((btn) => {
      btn.addEventListener('click', () => pickAmount(Number(btn.dataset.amount)));
    });
    $('btn-custom-amount').addEventListener('click', () => {
      state.customAmount = '';
      $('custom-amount-value').textContent = '0';
      $('custom-amount-block').classList.remove('hidden');
      setKeypadMode('custom-amount');
    });
    $('btn-confirm-custom-amount').addEventListener('click', confirmCustomAmount);
    $('btn-withdraw-back').addEventListener('click', () => {
      setKeypadMode(null);
      showView('menu');
    });
    $('btn-receipt-yes').addEventListener('click', () => {
      state.pendingWithdraw.wantReceipt = true;
      executeWithdraw();
    });
    $('btn-receipt-no').addEventListener('click', () => {
      state.pendingWithdraw.wantReceipt = false;
      executeWithdraw();
    });

    // Выдача наличных
    $('btn-take-cash').addEventListener('click', async () => {
      if (state.pendingWithdraw.wantReceipt && state.lastReceipt) {
        fillReceipt(state.lastReceipt);
        showView('receipt');
      } else {
        await refreshBalanceSafe();
        fillMenuBalance();
        showView('menu');
      }
    });

    // Оплата связи
    $('payment-phone').addEventListener('focus', () => setKeypadMode('payment-phone'));
    $('payment-amount').addEventListener('focus', () => setKeypadMode('payment-amount'));
    $('btn-pay').addEventListener('click', executePayment);
    $('btn-payment-back').addEventListener('click', () => {
      setKeypadMode(null);
      showView('menu');
    });

    // Чек
    $('btn-take-receipt').addEventListener('click', async () => {
      await refreshBalanceSafe();
      fillMenuBalance();
      showView('menu');
    });

    // Остаток
    $('btn-balance-menu').addEventListener('click', () => {
      setKeypadMode(null);
      showView('menu');
    });

    // Сообщение
    $('btn-message-ok').addEventListener('click', () => {
      if (state.messageBack === 'insert') {
        $('atm-card-peek').classList.remove('inserted');
        $('atm-card-number').value = '';
        $('atm-card-quick').value = '';
        state.sessionId = null;
        state.card = null;
        state.balance = null;
        setKeypadMode(null);
        showView('insert');
      } else if (state.messageBack === 'withdraw') {
        openWithdraw();
      } else if (state.messageBack === 'payment') {
        openPayment();
      } else {
        setKeypadMode(null);
        showView('menu');
      }
    });
  }

  async function showBalanceScreen() {
    try {
      await refreshBalanceSafe();
      fillBalanceView();
      showView('balance');
    } catch (err) {
      showMessage('Ошибка', err.message, 'menu');
    }
  }

  async function refreshBalanceSafe() {
    try {
      await refreshBalance();
    } catch (err) {
      showToast(err.message || 'Не удалось обновить остаток', 'error');
    }
    return state.balance;
  }

  // -------------------------------------------------------------------------
  // Инициализация
  // -------------------------------------------------------------------------
  async function init() {
    buildKeypad();
    bindEvents();
    showView('insert');

    try {
      const bank = await api.getBankState();
      state.bankDate = bank.bank_date;
      $('atm-bank-date').textContent = formatDate(bank.bank_date);
    } catch (err) {
      $('atm-bank-date').textContent = '—';
    }

    try {
      state.cards = await api.getAtmCards();
      populateCardSelect();
    } catch (err) {
      showToast('Не удалось загрузить список карт: ' + err.message, 'error');
    }
  }

  function populateCardSelect() {
    const select = $('atm-card-quick');
    select.innerHTML = '<option value="">— Выберите карту из списка —</option>';
    let usable = 0;
    state.cards.forEach((card) => {
      if (card.contract_status !== 'ACTIVE' || card.is_blocked) return;
      const option = document.createElement('option');
      option.value = String(card.id);
      const blockedMark = card.is_blocked ? '⛔ ' : '';
      option.textContent =
        `${blockedMark}${maskFull(card.card_number)} · ${card.client_name} · ${card.contract_number} · PIN ${card.pin_code}`;
      select.appendChild(option);
      usable += 1;
    });
    if (usable === 0) {
      const option = document.createElement('option');
      option.value = '';
      option.textContent = 'Активных карт нет — заключите кредитный договор';
      option.disabled = true;
      select.appendChild(option);
    }
  }

  if (document.readyState === 'loading') {
    document.addEventListener('DOMContentLoaded', init);
  } else {
    init();
  }
})();