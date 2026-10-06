/**
 * Модуль 4 «Эмулятор банкомата (ATM)» — клиентская логика.
 * Страница atm.html: вставка карты → авторизация на сервере → ПИН (3 попытки) →
 * главное меню → снятие наличных / остаток (с вопросом о чеке) /
 * оплата мобильной связи (с экраном подтверждения) → чек.
 * Все операции выполняются через API /api/atm и сразу отражаются в
 * оборотной ведомости (раздел «Счета» на главной странице банка).
 *
 * Ввод работает и с экранной клавиатурой, и с физической клавиатуры ПК:
 * глобальный слушатель keydown переводит нажатия в те же вызовы handleKey().
 */
(function () {
  'use strict';

  const { api, showToast, formatDate, formatMoney } = Common;

  // -------------------------------------------------------------------------
  // Состояние
  // -------------------------------------------------------------------------
  const state = {
    bankDate: null,
    printedReceipts: 0,   // счётчик напечатанных чеков для анимации в слоте
    card: null,          // результат card-check: raw-номер, клиент, договор
    sessionId: null,
    balance: null,       // последние данные остатка (лимит/долг/доступно)
    view: null,
    pinBuffer: '',
    attemptsLeft: 3,
    keypadMode: null,    // 'pin' | 'custom-amount' | 'payment-phone' | 'payment-amount'
    pendingWithdraw: { amount: null, wantReceipt: false },
    pendingPayment: null, // { operator, phone, amount } — ждёт подтверждения
    lastReceipt: null,
    messageBack: 'insert', // куда вернуться из экрана сообщения
    customAmount: '',
    busy: false,         // защита от повторной отправки платежа
  };

  const elements = {};
  const VIEW_NAMES = [
    'insert', 'auth', 'pin', 'menu', 'withdraw', 'withdraw-receipt',
    'dispense', 'payment', 'payment-confirm', 'receipt',
    'balance-receipt', 'balance', 'message',
  ];

  const cache = {};
  function $(id) {
    if (!cache[id]) cache[id] = document.getElementById(id);
    return cache[id];
  }

  function pad2(n) {
    return String(n).padStart(2, '0');
  }

  // -------------------------------------------------------------------------
  // Навигация по экранам
  // -------------------------------------------------------------------------
  function showView(name) {
    VIEW_NAMES.forEach((viewName) => {
      const viewEl = $('view-' + viewName);
      if (!viewEl) return;
      const active = viewName === name;
      viewEl.classList.toggle('hidden', !active);
      if (!active) return;
      // Перезапуск анимации появления экрана: снимаем класс, форсируем reflow,
      // возвращаем класс — иначе повторный показ того же экрана не анимируется.
      viewEl.classList.remove('atm-view-enter');
      void viewEl.offsetWidth;
      viewEl.classList.add('atm-view-enter');
    });
    state.view = name;
  }

  /** Снять фокус с поля ввода: экран сообщения не принимает ввод с клавиатуры. */
  function blurActive() {
    const active = document.activeElement;
    if (active && active !== document.body && typeof active.blur === 'function') active.blur();
  }

  function showMessage(title, text, backTo) {
    $('message-badge').textContent = '⚠';
    $('message-title').textContent = title;
    $('message-text').textContent = text;
    state.messageBack = backTo || 'menu';
    // Экран сообщения не ввод: Enter и Esc должны закрывать его, а не
    // продолжать набор в поле, из которого он был вызван.
    setKeypadMode(null);
    blurActive();
    showView('message');
  }

  function showInfo(title, text, backTo) {
    $('message-badge').textContent = 'ℹ';
    $('message-title').textContent = title;
    $('message-text').textContent = text;
    state.messageBack = backTo || 'insert';
    setKeypadMode(null);
    blurActive();
    showView('message');
  }

  // -------------------------------------------------------------------------
  // Маскирование номера карты: на экране банкомата показываем только последние 4
  // -------------------------------------------------------------------------
  function maskAtm(cardNumber) {
    const s = String(cardNumber || '');
    return `**** **** **** ${s.slice(-4)}`;
  }

  // -------------------------------------------------------------------------
  // Клавиатура банкомата (экранная)
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
      setKeypadMode(null); // меню управляется функциональными клавишами, не полями ввода
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

  function applyBalancePatch(patch) {
    state.balance = {
      ...state.balance,
      credit_limit: patch.credit_limit,
      current_debt: patch.current_debt,
      available_balance: patch.available_balance,
    };
  }

  /**
   * Главное меню показывает только карту и клиента: лимит, задолженность
   * и доступный остаток видны исключительно на экране просмотра остатка,
   * который открывается отдельной физической клавишей.
   */
  function fillMenuBalance() {
    if (!state.balance) return;
    $('menu-card-number').textContent = state.card && state.card.masked ? state.card.masked : '—';
    $('menu-client-name').textContent = state.card ? state.card.client_name : '';
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

    // Если по текущему запросу остатка печатался чек — сообщаем об этом на экране.
    const note = $('bal-receipt-note');
    const inquiry = state.lastReceipt && state.lastReceipt.operation_type === 'ЗАПРОС ОСТАТКА';
    if (inquiry) {
      note.textContent =
        `Чек напечатан · операция № ${state.lastReceipt.operation_number} · код авторизации ${state.lastReceipt.auth_code}`;
      note.classList.remove('hidden');
    } else {
      note.textContent = '';
      note.classList.add('hidden');
    }
  }

  // -------------------------------------------------------------------------
  // Чек
  // -------------------------------------------------------------------------
  function fillReceipt(receipt) {
    const isInquiry = receipt.amount === null || receipt.amount === undefined;
    $('r-card').textContent = receipt.card;
    $('r-datetime').textContent = receipt.datetime;
    $('r-opno').textContent = String(receipt.operation_number);
    $('r-auth').textContent = receipt.auth_code;
    $('r-type').textContent = receipt.operation_type;
    $('r-amount').textContent = isInquiry ? '—' : formatMoney(receipt.amount) + ' BYN';
    $('r-avail').textContent = formatMoney(receipt.available_balance) + ' BYN';
    $('r-status').textContent = receipt.status;
    // У запроса остатка нет суммы операции — выделяем доступный остаток.
    $('r-amount-line').classList.toggle('receipt-line-key', !isInquiry);
    $('r-avail-line').classList.toggle('receipt-line-key', isInquiry);
  }

  /** 6 случайных цифр — как код авторизации на настоящем чеке. */
  function randomAuthCode() {
    return String(Math.floor(Math.random() * 1000000)).padStart(6, '0');
  }

  /**
   * Номер операции для чека о запросе остатка. Такой запрос не является
   * банковской операцией (проводок нет, записи в atm_transactions нет),
   * поэтому номер формируется на клиенте и получает префикс «З-».
   */
  function inquiryOperationNumber(bankDate) {
    const stamp = String(bankDate || '').replace(/-/g, '') || '00000000';
    const tail = String(Math.floor(Math.random() * 10000)).padStart(4, '0');
    return `З-${stamp}-${tail}`;
  }

  /**
   * Анимация выдачи чека из слота: бумага выезжает, печатается и
   * остаётся в слоте до следующего чека. Запускается при показе экрана
   * «Чек» и при запросе остатка с печатью чека.
   */
  function animateReceiptPrint() {
    const slot = $('atm-receipt-slot');
    if (!slot) return;
    state.printedReceipts += 1;
    // Счётчик в data-атрибуте: виден и в стенде, и при отладке в браузере.
    slot.dataset.printedCount = String(state.printedReceipts);

    // Перезапуск анимации: снимаем класс и форсируем reflow.
    slot.classList.remove('printing');
    void slot.offsetWidth;
    slot.classList.add('printing');
  }

  /**
   * Очистить слот выдачи чека: бумага забрана вместе с картой при выходе
   * из банкомата. Без этого чек предыдущей сессии висел бы на корпусе.
   */
  function resetReceiptSlot() {
    const slot = $('atm-receipt-slot');
    if (slot) slot.classList.remove('printing');
  }

  /** Составление чека о запросе остатка по данным /api/atm/balance. */
  function composeInquiryReceipt(data) {
    const now = new Date();
    const time = [now.getHours(), now.getMinutes(), now.getSeconds()].map(pad2).join(':');
    const bankDate = data.bank_date || state.bankDate;
    return {
      bank_name: 'ЗАО «Банк Дабрабыт»',
      atm_id: '001',
      datetime: `${formatDate(bankDate)} ${time}`,
      card: maskAtm(data.card_number || (state.card && state.card.raw_number)),
      operation_number: inquiryOperationNumber(bankDate),
      auth_code: randomAuthCode(),
      operation_type: 'ЗАПРОС ОСТАТКА',
      amount: null,
      available_balance: data.available_balance,
      status: 'УСПЕШНО',
      operator: null,
      phone: null,
    };
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
    setKeypadMode(null);
    showView('withdraw');
  }

  function pickAmount(amount) {
    state.pendingWithdraw.amount = amount;
    setKeypadMode(null);
    showView('withdraw-receipt');
  }

  function startWithdraw(wantReceipt) {
    state.pendingWithdraw.wantReceipt = wantReceipt;
    executeWithdraw();
  }

  async function executeWithdraw() {
    const amount = state.pendingWithdraw.amount;
    if (!state.sessionId || !amount) return;
    try {
      const result = await api.atmWithdraw({ session_id: state.sessionId, amount });
      applyBalancePatch(result);
      state.lastReceipt = result.receipt;
      $('dispense-amount').textContent = formatMoney(amount) + ' BYN';
      showView('dispense');
    } catch (err) {
      showMessage('Снятие невозможно', err.message, 'withdraw');
    }
  }

  function takeCash() {
    if (state.pendingWithdraw.wantReceipt && state.lastReceipt) {
      fillReceipt(state.lastReceipt);
      animateReceiptPrint();
      showView('receipt');
    } else {
      refreshBalanceSafe().then(() => {
        fillMenuBalance();
        backToMenu();
      });
    }
  }

  // -------------------------------------------------------------------------
  // Оплата мобильной связи
  // -------------------------------------------------------------------------
  function openPayment() {
    $('payment-operator').value = '';
    $('payment-phone').value = '';
    $('payment-amount').value = '';
    state.pendingPayment = null;
    setKeypadMode('payment-phone');
    showView('payment');
    $('payment-phone').focus();
  }

  /**
   * Валидация введённых данных. Сам платёж здесь НЕ отправляется:
   * по ТЗ банкомат сначала показывает экран подтверждения, и только
   * «Подтвердить» вызывает api.atmPayment.
   */
  function executePayment() {
    const operator = $('payment-operator').value;
    const phone = $('payment-phone').value.replace(/\s+/g, '');
    const amount = $('payment-amount').value.replace(',', '.').trim();

    if (!operator) {
      showMessage('Ошибка', 'Выберите оператора (МТС, А1, Life:)).', 'payment');
      return;
    }
    if (!/^\d{10}$/.test(phone)) {
      showMessage('Ошибка', 'Номер телефона должен состоять ровно из 10 цифр.', 'payment');
      return;
    }
    const amountNumber = Number(amount);
    if (!(amountNumber > 0)) {
      showMessage('Ошибка', 'Укажите корректную сумму оплаты (например, 25.00).', 'payment');
      return;
    }

    state.pendingPayment = { operator, phone, amount: amountNumber };
    $('pc-operator').textContent = operator;
    $('pc-phone').textContent = phone;
    $('pc-amount').textContent = formatMoney(amountNumber) + ' BYN';
    setKeypadMode(null);
    showView('payment-confirm');
  }

  /**
   * Возврат к экрану ввода с уже введёнными данными.
   * openPayment() здесь не вызывается намеренно: он очищает поля, и после
   * любой ошибки клиенту пришлось бы вводить всё заново.
   */
  function correctPayment() {
    showView('payment');
    setKeypadMode('payment-phone');
    const phoneEl = $('payment-phone');
    const amountEl = $('payment-amount');
    if (!phoneEl.value) phoneEl.focus();
    else if (!amountEl.value) amountEl.focus();
    else amountEl.focus();
  }

  async function confirmPayment() {
    const pending = state.pendingPayment;
    if (!pending || state.busy) return;
    state.busy = true;
    try {
      const result = await api.atmPayment({
        session_id: state.sessionId,
        operator: pending.operator,
        phone: pending.phone,
        amount: pending.amount,
      });
      applyBalancePatch(result);
      state.lastReceipt = result.receipt;
      state.pendingPayment = null;
      fillReceipt(result.receipt);
      setKeypadMode(null);
      animateReceiptPrint();
      showView('receipt'); // автоматическая печать чека
    } catch (err) {
      showMessage('Оплата невозможна', err.message, 'payment-confirm');
    } finally {
      state.busy = false;
    }
  }

  // -------------------------------------------------------------------------
  // Запрос остатка: сначала вопрос о чеке, потом сам остаток
  // -------------------------------------------------------------------------
  async function showBalanceReceiptQuestion() {
    await refreshBalanceSafe();
    setKeypadMode(null);
    showView('balance-receipt');
  }

  async function showBalance(withReceipt) {
    setKeypadMode(null);
    const data = await refreshBalanceSafe();
    if (!data) {
      showMessage('Ошибка', 'Не удалось получить остаток по счёту.', 'menu');
      return;
    }
    if (withReceipt) {
      state.lastReceipt = composeInquiryReceipt(data);
      fillReceipt(state.lastReceipt);
      animateReceiptPrint();
    }
    fillBalanceView();
    showView('balance');
  }

  async function refreshBalanceSafe() {
    try {
      return await refreshBalance();
    } catch (err) {
      showToast(err.message || 'Не удалось обновить остаток', 'error');
      return state.balance;
    }
  }

  // -------------------------------------------------------------------------
  // Вставка/извлечение карты
  // -------------------------------------------------------------------------
  function backToMenu() {
    setKeypadMode(null);
    showView('menu');
  }

  function ejectCard() {
    state.sessionId = null;
    state.card = null;
    state.balance = null;
    state.pinBuffer = '';
    state.attemptsLeft = 3;
    state.pendingWithdraw = { amount: null, wantReceipt: false };
    state.pendingPayment = null;
    state.lastReceipt = null;
    state.customAmount = '';
    setKeypadMode(null);
    resetReceiptSlot();
    $('atm-card-peek').classList.remove('inserted');
    $('atm-card-number').value = '';
    showInfo('Карта извлечена', 'Возьмите карту из слота. Спасибо за пользование банкоматом!', 'insert');
  }

  async function insertCard() {
    const raw = $('atm-card-number').value.replace(/\s+/g, '');
    if (!/^\d{16}$/.test(raw)) {
      showMessage('Ошибка', 'Введите корректный номер карты — ровно 16 цифр.', 'insert');
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
  // Обработка экранной цифровой клавиатуры
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
        else if (label === 'OK') executePayment();
        else if (/^\d$/.test(label) && value.length < 10) value += label;
        $('payment-phone').value = value;
        break;
      }
      case 'payment-amount': {
        let value = $('payment-amount').value;
        if (label === '⌫') {
          value = value.slice(0, -1);
        } else if (label === 'OK') {
          executePayment();
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
        // Без явного режима ввода цифры набирают номер карты — но только
        // на экране вставки, чтобы не «печатать» в невидимые поля.
        if (state.view !== 'insert') return;
        const input = $('atm-card-number');
        if (label === '⌫') input.value = input.value.slice(0, -1);
        else if (/^\d$/.test(label) && input.value.length < 16) input.value += label;
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
  // Физическая клавиатура ПК
  // -------------------------------------------------------------------------
  // Режимы, в которых цифра уходит в поле ввода, а не в выбор пункта меню.
  const INPUT_KEYPAD_MODES = ['pin', 'custom-amount', 'payment-phone', 'payment-amount'];
  // Метки, которые умеет обработать экранная клавиатура банкомата.
  const SCREEN_KEYS = ['0', '1', '2', '3', '4', '5', '6', '7', '8', '9', '.', '⌫', 'OK'];

  // Горячие клавиши по экранам: цифра на ПК дублирует физическую кнопку корпуса.
  const VIEW_HOTKEYS = {
    menu: {
      '1': () => openWithdraw(),
      '2': () => openPayment(),
      '3': () => ejectCard(),
      '4': () => showBalanceReceiptQuestion(),
    },
    withdraw: {
      '1': () => pickAmount(10),
      '2': () => pickAmount(20),
      '3': () => pickAmount(50),
      '4': () => pickAmount(100),
    },
    'withdraw-receipt': {
      '1': () => startWithdraw(true),
      '2': () => startWithdraw(false),
      'OK': () => startWithdraw(true),
    },
    'balance-receipt': {
      '1': () => showBalance(true),
      '2': () => showBalance(false),
      'OK': () => showBalance(true),
    },
    'payment-confirm': {
      '1': () => confirmPayment(),
      '2': () => correctPayment(),
      'OK': () => confirmPayment(),
    },
    dispense: { 'OK': () => takeCash() },
    balance: { 'OK': () => backToMenu() },
    receipt: { 'OK': () => backToMenu() },
    payment: { 'OK': () => executePayment() },
    message: { 'OK': () => closeMessage() },
  };

  /** Esc — «назад»: отмена текущего действия. */
  function goBack() {
    switch (state.view) {
      case 'pin':
      case 'menu':
        ejectCard();
        break;
      case 'withdraw':
        backToMenu();
        break;
      case 'withdraw-receipt':
        openWithdraw();
        break;
      case 'dispense':
        takeCash();
        break;
      case 'payment':
        backToMenu();
        break;
      case 'payment-confirm':
        correctPayment();
        break;
      case 'balance-receipt':
        backToMenu();
        break;
      case 'balance':
      case 'receipt':
        backToMenu();
        break;
      case 'message':
        closeMessage();
        break;
      default:
        break;
    }
  }

  /**
   * Единая точка ввода с ПК и с экрана: сначала горячие клавиши экрана,
   * затем Esc («назад»), затем экранная клавиатура.
   */
  function handleGlobalKey(label) {
    if (label === 'Esc') {
      goBack();
      return true;
    }

    const typing = INPUT_KEYPAD_MODES.indexOf(state.keypadMode) !== -1;
    const hotkeys = VIEW_HOTKEYS[state.view];
    if (!typing && hotkeys && Object.prototype.hasOwnProperty.call(hotkeys, label)) {
      hotkeys[label]();
      return true;
    }

    if (SCREEN_KEYS.indexOf(label) !== -1) {
      handleKey(label);
      return true;
    }
    return false;
  }

  /** Клавиша ПК -> метка экранной клавиатуры банкомата. */
  function pcKeyLabel(event) {
    const key = String(event.key || '');
    if (/^[0-9]$/.test(key)) return key;
    if (key === '.' || key === ',') return '.';

    const code = String(event.code || '');
    const digit = /^(?:Digit|Numpad)([0-9])$/.exec(code);
    if (digit) return digit[1];

    const map = {
      Backspace: '⌫',
      Delete: '⌫',
      Escape: 'Esc',
      Enter: 'OK',
      NumpadEnter: 'OK',
      Period: '.',
      NumpadDecimal: '.',
    };
    return map[code] || map[key] || null;
  }

  /** В фокусе поля ввода работает штатный ввод браузера — перехватывать нельзя. */
  function isTypingTarget(el) {
    if (!el || el.nodeType !== 1) return false;
    if (el.isContentEditable) return true;
    const tag = el.tagName;
    return tag === 'INPUT' || tag === 'TEXTAREA' || tag === 'SELECT';
  }

  function bindKeyboard() {
    document.addEventListener('keydown', (event) => {
      // Системные и админские сочетания (Ctrl+Alt+A и т. п.) не трогаем.
      if (event.ctrlKey || event.altKey || event.metaKey) return;

      if (isTypingTarget(event.target)) {
        // Escape работает и в поле ввода: снимаем фокус и возвращаем «назад».
        if (event.key === 'Escape' && event.target.tagName === 'INPUT') {
          event.preventDefault();
          event.target.blur();
          goBack();
        }
        return;
      }

      const label = pcKeyLabel(event);
      if (!label) return;
      // preventDefault вызывается только для реально обработанных клавиш,
      // поэтому скролл пробелом и прочие системные сочетания не ломаются.
      if (handleGlobalKey(label)) event.preventDefault();
    });
  }

  // -------------------------------------------------------------------------
  // Сообщения
  // -------------------------------------------------------------------------
  function closeMessage() {
    if (state.messageBack === 'insert') {
      $('atm-card-peek').classList.remove('inserted');
      $('atm-card-number').value = '';
      state.sessionId = null;
      state.card = null;
      state.balance = null;
      state.lastReceipt = null;
      setKeypadMode(null);
      resetReceiptSlot();
      showView('insert');
    } else if (state.messageBack === 'withdraw') {
      openWithdraw();
    } else if (state.messageBack === 'payment') {
      // Возврат с сохранением введённых данных (см. correctPayment).
      correctPayment();
    } else if (state.messageBack === 'payment-confirm') {
      showView('payment-confirm');
    } else {
      backToMenu();
    }
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
      if (event.key === 'Enter') {
        event.preventDefault();
        insertCard();
      }
    });

    // ПИН
    $('btn-pin-cancel').addEventListener('click', ejectCard);

    // Главное меню: пункты выбираются физическими кнопками корпуса.
    document.querySelectorAll('.atm-menu-key[data-menu]').forEach((btn) => {
      btn.addEventListener('click', () => {
        const action = btn.dataset.menu;
        if (action === 'withdraw') openWithdraw();
        else if (action === 'balance') showBalanceReceiptQuestion();
        else if (action === 'payment') openPayment();
      });
    });
    $('btn-eject-card').addEventListener('click', ejectCard);

    // Снятие наличных
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
    $('btn-withdraw-back').addEventListener('click', backToMenu);
    $('btn-receipt-yes').addEventListener('click', () => startWithdraw(true));
    $('btn-receipt-no').addEventListener('click', () => startWithdraw(false));

    // Выдача наличных
    $('btn-take-cash').addEventListener('click', takeCash);

    // Оплата связи
    $('payment-operator').addEventListener('change', () => {
      if ($('payment-operator').value) $('payment-phone').focus();
    });
    $('payment-phone').addEventListener('focus', () => setKeypadMode('payment-phone'));
    $('payment-amount').addEventListener('focus', () => setKeypadMode('payment-amount'));
    $('payment-phone').addEventListener('keydown', (event) => {
      if (event.key === 'Enter') {
        event.preventDefault();
        $('payment-amount').focus();
      }
    });
    $('payment-amount').addEventListener('keydown', (event) => {
      if (event.key === 'Enter') {
        event.preventDefault();
        executePayment();
      }
    });
    $('btn-pay').addEventListener('click', executePayment);
    $('btn-payment-back').addEventListener('click', backToMenu);

    // Подтверждение оплаты
    $('btn-payment-confirm').addEventListener('click', confirmPayment);
    $('btn-payment-correct').addEventListener('click', correctPayment);

    // Чек
    $('btn-take-receipt').addEventListener('click', () => {
      refreshBalanceSafe().then(() => {
        fillMenuBalance();
        backToMenu();
      });
    });

    // Запрос остатка
    $('btn-balreceipt-yes').addEventListener('click', () => showBalance(true));
    $('btn-balreceipt-no').addEventListener('click', () => showBalance(false));
    $('btn-balance-menu').addEventListener('click', backToMenu);

    // Сообщение
    $('btn-message-ok').addEventListener('click', closeMessage);

    // Физическая клавиатура ПК
    bindKeyboard();
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
  }

  if (document.readyState === 'loading') {
    document.addEventListener('DOMContentLoaded', init);
  } else {
    init();
  }
})();