/**
 * Модуль 2 «Депозитные операции с физическими лицами» (банк «Дабрабыт»).
 * Заключение депозитных договоров, банковская дата и закрытие банковского месяца,
 * оборотная ведомость (баланс счетов), журнал проводок.
 */
(function () {
  'use strict';

  const {
    api, showToast, escapeHtml, formatDate, formatMoney, formatMoneyWithCurrency,
    ADMIN_CONFIRM_WORD, CURRENCY_RATES, addMonths,
  } = Common;

  // ---------------------------------------------------------------------------
  // Состояние
  // ---------------------------------------------------------------------------
  const state = {
    bankDate: null,
    programs: [],
    clients: [],
    contracts: [],
    accounts: [],
    flatTerms: [],
    pendingDeleteId: null,
  };

  /** Курсы валют к BYN — зеркало backend/src/config/currency.js */
  /** Слово, которое нужно ввести для подтверждения удаления договора */
  const DELETE_CONFIRM_WORD = ADMIN_CONFIRM_WORD;

  /** Слово, которое нужно ввести для подтверждения сброса базы */
  const RESET_CONFIRM_WORD = 'СБРОС';

  const elements = {
    tabsNav: document.getElementById('tabs-nav'),
    tabButtons: Array.from(document.querySelectorAll('.tab-btn')),
    sections: {
      clients: document.getElementById('section-clients'),
      contracts: document.getElementById('section-contracts'),
      credits: document.getElementById('section-credits'),
      balance: document.getElementById('section-balance'),
    },
    bankDate: document.getElementById('bank-date'),
    bankMonthSelect: document.getElementById('bank-month-select'),
    bankYearSelect: document.getElementById('bank-year-select'),
    btnSetBankDate: document.getElementById('btn-set-bank-date'),
    btnCloseMonth: document.getElementById('btn-close-month'),
    btnResetBank: document.getElementById('btn-reset-bank'),
    resetBankModal: document.getElementById('reset-bank-modal'),
    resetBankConfirmInput: document.getElementById('reset-bank-confirm-input'),
    btnResetBankConfirm: document.getElementById('btn-reset-bank-confirm'),
    btnResetBankCancel: document.getElementById('btn-reset-bank-cancel'),
    contractsTable: document.getElementById('contracts-table'),
    contractsTbody: document.getElementById('contracts-tbody'),
    contractsEmpty: document.getElementById('contracts-empty'),
    btnAddContract: document.getElementById('btn-add-contract'),
    accountsTbody: document.getElementById('accounts-tbody'),
    accountsEmpty: document.getElementById('accounts-empty'),
    contractModal: document.getElementById('contract-modal'),
    contractForm: document.getElementById('contract-form'),
    contractClient: document.getElementById('contract_client_id'),
    contractProgram: document.getElementById('contract_program_id'),
    contractTerm: document.getElementById('contract_term_months'),
    contractStartDate: document.getElementById('contract_start_date'),
    contractAmount: document.getElementById('contract_amount'),
    contractRateDisplay: document.getElementById('contract-rate-display'),
    contractAnnualRate: document.getElementById('contract_annual_rate'),
    contractCurrency: document.getElementById('contract_currency'),
    currencyHint: document.getElementById('currency-hint'),
    contractMaturityDisplay: document.getElementById('contract_maturity_date_display'),
    programHint: document.getElementById('program-hint'),
    btnCloseContractModal: document.getElementById('btn-close-contract-modal'),
    btnContractCancel: document.getElementById('btn-contract-cancel'),
    btnSaveContract: document.getElementById('btn-save-contract'),
    ledgerModal: document.getElementById('ledger-modal'),
    ledgerModalTitle: document.getElementById('ledger-modal-title'),
    ledgerModalContent: document.getElementById('ledger-modal-content'),
    btnCloseLedgerModal: document.getElementById('btn-close-ledger-modal'),
    btnLedgerClose: document.getElementById('btn-ledger-close'),
    // Удаление договора (Admin-режим)
    contractDeleteModal: document.getElementById('contract-delete-modal'),
    contractDeleteMessage: document.getElementById('contract-delete-message'),
    contractDeleteConfirmInput: document.getElementById('contract-delete-confirm-input'),
    btnContractDeleteCancel: document.getElementById('btn-contract-delete-cancel'),
    btnContractDeleteConfirm: document.getElementById('btn-contract-delete-confirm'),
  };

  // Поля ошибок формы договора: имя поля формы -> id контейнера ошибки
  const CONTRACT_ERROR_FIELDS = {
    client_id: 'error-contract_client_id',
    program_id: 'error-contract_program_id',
    term_months: 'error-contract_term_months',
    contract_number: 'error-contract_number',
    start_date: 'error-contract_start_date',
    amount: 'error-contract_amount',
    currency: 'error-contract_currency',
  };

  // ---------------------------------------------------------------------------
  // Утилиты отображения
  // ---------------------------------------------------------------------------
  function badge(status) {
    if (status === 'ACTIVE' || status === 'OPEN') {
      return '<span class="badge badge-success">Действует</span>';
    }
    if (status === 'COMPLETED') {
      return '<span class="badge badge-muted">Завершён</span>';
    }
    if (status === 'CLOSED') {
      return '<span class="badge badge-muted">Закрыт</span>';
    }
    return `<span class="badge">${escapeHtml(status)}</span>`;
  }

  function programTypeLabel(program) {
    if (program.deposit_type === 'REVOCABLE') {
      return 'отзывный · проценты ежемесячно';
    }
    return 'безотзывный · проценты в конце срока';
  }

  function clearContractErrors() {
    Object.values(CONTRACT_ERROR_FIELDS).forEach((id) => {
      const el = document.getElementById(id);
      if (el) el.textContent = '';
    });
    document.querySelectorAll('#contract-form .form-group input.invalid, #contract-form .form-group select.invalid')
      .forEach((el) => el.classList.remove('invalid'));
  }

  function showContractErrors(errors) {
    clearContractErrors();
    Object.keys(errors).forEach((field) => {
      const errorId = CONTRACT_ERROR_FIELDS[field];
      if (errorId) {
        const el = document.getElementById(errorId);
        if (el) el.textContent = errors[field];
      }
      const input = elements.contractForm.elements[field];
      if (input) input.classList.add('invalid');
    });
    const first = document.querySelector('#contract-form .form-group input.invalid, #contract-form .form-group select.invalid');
    if (first) first.focus();
  }

  function handleRequestError(err) {
    if (err.cause && err.cause.data && err.cause.data.errors) {
      showContractErrors(err.cause.data.errors);
      showToast('Исправьте ошибки в форме', 'error');
      return;
    }
    if (err.cause && (err.cause.status === 409 || err.cause.status === 400 || err.cause.status === 404)) {
      showToast(err.message, 'error');
      return;
    }
    showToast(err.message || 'Не удалось выполнить запрос к серверу', 'error');
  }

  // ---------------------------------------------------------------------------
  // Вкладки
  // ---------------------------------------------------------------------------
  function switchTab(name) {
    elements.tabButtons.forEach((btn) => {
      btn.classList.toggle('active', btn.dataset.tab === name);
    });
    Object.keys(elements.sections).forEach((key) => {
      elements.sections[key].classList.toggle('hidden', key !== name);
    });
  }

  // ---------------------------------------------------------------------------
  // Загрузка данных
  // ---------------------------------------------------------------------------
  async function loadBankState() {
    const data = await api.getBankState();
    state.bankDate = data.bank_date;
    elements.bankDate.textContent = formatDate(state.bankDate);
    populateDateControls();
  }

  // ---------------------------------------------------------------------------
  // Изменение банковской даты (месяц и год)
  // ---------------------------------------------------------------------------
  const MONTH_NAMES = [
    'Январь', 'Февраль', 'Март', 'Апрель', 'Май', 'Июнь',
    'Июль', 'Август', 'Сентябрь', 'Октябрь', 'Ноябрь', 'Декабрь',
  ];

  /** Заполняет селекты месяца/года по текущей банковской дате */
  function populateDateControls() {
    if (!state.bankDate) return;
    const currentYear = Number(state.bankDate.slice(0, 4));
    const currentMonth = Number(state.bankDate.slice(5, 7));

    elements.bankMonthSelect.innerHTML = MONTH_NAMES
      .map((name, index) => `<option value="${index + 1}">${name}</option>`)
      .join('');
    elements.bankMonthSelect.value = String(currentMonth);

    elements.bankYearSelect.innerHTML = '';
    const fromYear = currentYear - 3;
    const toYear = currentYear + 10;
    for (let year = fromYear; year <= toYear; year++) {
      const option = document.createElement('option');
      option.value = String(year);
      option.textContent = String(year);
      elements.bankYearSelect.appendChild(option);
    }
    elements.bankYearSelect.value = String(currentYear);
  }

  /** Установить банковскую дату на первое число выбранного месяца/года */
  async function setBankDate() {
    const month = elements.bankMonthSelect.value;
    const year = elements.bankYearSelect.value;
    if (!month || !year) return;

    elements.btnSetBankDate.disabled = true;
    try {
      const result = await api.setBankDate({ year: Number(year), month: Number(month) });
      state.bankDate = result.bank_date;
      elements.bankDate.textContent = formatDate(result.bank_date);
      populateDateControls();
      showToast(`Банковская дата установлена: ${formatDate(result.bank_date)}`, 'success');

      // Сообщаем другим модулям (например, кредитам) о смене банковской даты
      window.dispatchEvent(new CustomEvent('app:bank-date-changed', { detail: result }));
    } catch (err) {
      handleRequestError(err);
    } finally {
      elements.btnSetBankDate.disabled = false;
    }
  }

  async function loadPrograms() {
    state.programs = await api.getDepositPrograms();
    state.flatTerms = [];
    state.programs.forEach((program) => {
      (program.terms || []).forEach((term) => {
        state.flatTerms.push({ program_id: program.id, term_months: term.term_months });
      });
    });
  }

  async function loadClients() {
    state.clients = await api.getClients();
  }

  async function loadContracts() {
    state.contracts = await api.getContracts();
    renderContracts();
  }

  async function loadAccounts() {
    state.accounts = await api.getAccounts();
    renderAccounts();
  }

  // ---------------------------------------------------------------------------
  // Рендер договоров
  // ---------------------------------------------------------------------------
  function renderContracts() {
    const isEmpty = state.contracts.length === 0;
    elements.contractsTbody.innerHTML = '';
    elements.contractsEmpty.classList.toggle('hidden', !isEmpty);

    state.contracts.forEach((contract) => {
      const tr = document.createElement('tr');
      tr.innerHTML = `
        <td class="mono">${escapeHtml(contract.contract_number)}</td>
        <td>${escapeHtml(contract.client_name)}</td>
        <td>
          ${escapeHtml(contract.program_name)}
          <span class="muted">(${programTypeLabel(contract)})</span>
        </td>
        <td class="num">${escapeHtml(String(contract.term_months))}</td>
        <td class="num">${escapeHtml(contract.annual_rate.toFixed(2))}%</td>
        <td class="num">${escapeHtml(formatMoneyWithCurrency(contract.amount, contract.currency))}</td>
        <td class="num">${formatDate(contract.start_date)}</td>
        <td class="num">${formatDate(contract.maturity_date)}</td>
        <td class="num">${escapeHtml(formatMoneyWithCurrency(contract.accrued_interest, contract.currency))}</td>
        <td>${badge(contract.status)}</td>
        <td>
          <div class="acct-cell">
            <span class="mono" title="Депозитный (текущий) счёт">${escapeHtml(contract.deposit_account_number || '—')}</span>
            <span class="muted">депозитный</span>
          </div>
          <div class="acct-cell">
            <span class="mono" title="Процентный счёт">${escapeHtml(contract.interest_account_number || '—')}</span>
            <span class="muted">процентный</span>
          </div>
        </td>
        <td class="col-actions admin-only">
          <button type="button" class="btn btn-small btn-danger admin-only"
                  data-action="delete-contract" data-id="${contract.id}">Удалить</button>
        </td>
      `;
      elements.contractsTbody.appendChild(tr);
    });
  }

  // ---------------------------------------------------------------------------
  // Рендер баланса (оборотной ведомости)
  // ---------------------------------------------------------------------------
  function renderAccounts() {
    const isEmpty = state.accounts.length === 0;
    elements.accountsTbody.innerHTML = '';
    elements.accountsEmpty.classList.toggle('hidden', !isEmpty);

    state.accounts.forEach((account) => {
      const tr = document.createElement('tr');
      const typeLabel = account.chart_type === 'A'
        ? 'Активный (A)'
        : 'Пассивный (P)';
      tr.innerHTML = `
        <td>
          ${escapeHtml(account.name)}
          <span class="muted acct-code">${escapeHtml(account.chart_code)} · ${typeLabel}</span>
        </td>
        <td class="mono num">${escapeHtml(account.account_number)}</td>
        <td class="num">${escapeHtml(formatMoneyWithCurrency(account.debit_turnover, account.currency))}</td>
        <td class="num">${escapeHtml(formatMoneyWithCurrency(account.credit_turnover, account.currency))}</td>
        <td class="num"><strong>${escapeHtml(formatMoneyWithCurrency(account.balance, account.currency))}</strong></td>
        <td>${badge(account.status)}</td>
      `;
      elements.accountsTbody.appendChild(tr);
    });
  }

  // ---------------------------------------------------------------------------
  // Динамический расчёт даты окончания договора
  // ---------------------------------------------------------------------------

  /**
   * Прибавляет months месяцев к ISO-дате startIso и возвращает ISO-дату.
   * Логика совпадает с серверной (Postgres: date + interval 'N months'),
   * включая ограничение по последнему дню месяца: 31.01 + 1 мес. = 28.02
   * (29.02 в високосный год), 31.08 + 6 мес. = 28.02.
   */
  /**
   * Пересчитывает дату окончания договора по сроку и дате заключения.
   * Если данных не хватает (нет срока или дата введена частично) — показывает «—».
   */
  function updateMaturityDate() {
    const termMonths = Number(elements.contractTerm.value);
    const startIso = DateMask.get(elements.contractStartDate);
    if (!termMonths || termMonths <= 0 || !/^\d{4}-\d{2}-\d{2}$/.test(startIso)) {
      elements.contractMaturityDisplay.textContent = '—';
      return;
    }
    elements.contractMaturityDisplay.textContent = formatDate(addMonths(startIso, termMonths));
  }

  /** Подсказка под выбором валюты: курс к BYN и пример эквивалента суммы. */
  function updateCurrencyHint() {
    const code = elements.contractCurrency.value;
    const amount = Number(elements.contractAmount.value);
    const rate = CURRENCY_RATES[code];
    if (code === 'BYN') {
      elements.currencyHint.textContent = 'Базовая валюта банка — конвертация не требуется.';
      return;
    }
    // Курс показываем из исходного числа, а не через formatMoney: у RUB он 0.035,
    // и денежное округление превратило бы его в «0.04» — 1000 RUB выглядели бы
    // как 40 BYN вместо 35. Лишние нули в конце отбрасываем.
    const rateText = String(Number(rate.toFixed(4)));
    const equivalent = amount > 0
      ? ` Сумма ${formatMoney(amount)} ${code} ≈ ${formatMoney(amount * rate)} BYN.`
      : '';
    elements.currencyHint.textContent = `Курс: 1 ${code} = ${rateText} BYN.${equivalent}`;
  }

  // ---------------------------------------------------------------------------
  // Модальное окно заключения договора
  // ---------------------------------------------------------------------------
  async function openContractModal() {
    clearContractErrors();
    elements.contractForm.reset();
    elements.contractRateDisplay.textContent = '—';
    elements.contractAnnualRate.value = '';
    elements.programHint.textContent = '';
    elements.contractMaturityDisplay.textContent = '—';
    updateCurrencyHint();

    // Клиенты
    elements.contractClient.innerHTML = '<option value="">— Выберите клиента —</option>';
    state.clients
      .slice()
      .sort((a, b) => `${a.last_name} ${a.first_name}`.localeCompare(`${b.last_name} ${b.first_name}`))
      .forEach((client) => {
        const option = document.createElement('option');
        option.value = String(client.id);
        option.textContent = `${client.last_name} ${client.first_name} ${client.middle_name}`;
        elements.contractClient.appendChild(option);
      });

    // Программы
    elements.contractProgram.innerHTML = '<option value="">— Выберите программу —</option>';
    state.programs.forEach((program) => {
      const option = document.createElement('option');
      option.value = String(program.id);
      option.textContent = `${program.name} (${programTypeLabel(program)})`;
      elements.contractProgram.appendChild(option);
    });

    elements.contractTerm.innerHTML = '<option value="">— Выберите срок —</option>';

    // Актуальная банковская дата с сервера (гарантированно текущая, даже если
    // она менялась ранее в этой или другой вкладке).
    try {
      await loadBankState();
    } catch (err) {
      /* сервер недоступен — оставляем последнюю известную дату */
    }
    DateMask.set(elements.contractStartDate, state.bankDate);
    updateMaturityDate();

    elements.contractModal.classList.remove('hidden');
    elements.contractClient.focus();
  }

  function selectProgramTerms() {
    const programId = Number(elements.contractProgram.value);
    const program = state.programs.find((p) => p.id === programId);

    elements.contractTerm.innerHTML = '<option value="">— Выберите срок —</option>';
    elements.contractRateDisplay.textContent = '—';
    elements.contractAnnualRate.value = '';
    elements.programHint.textContent = '';
    updateMaturityDate();

    if (!program) return;

    elements.programHint.textContent = programTypeLabel(program);

    (program.terms || []).slice().sort((a, b) => a.term_months - b.term_months)
      .forEach((term) => {
        const option = document.createElement('option');
        option.value = String(term.term_months);
        option.textContent = `${term.term_months} мес.`;
        elements.contractTerm.appendChild(option);
      });
  }

  function onTermChange() {
    updateMaturityDate();
    const programId = Number(elements.contractProgram.value);
    const termMonths = Number(elements.contractTerm.value);
    const program = state.programs.find((p) => p.id === programId);
    if (!program || !termMonths) {
      elements.contractRateDisplay.textContent = '—';
      elements.contractAnnualRate.value = '';
      return;
    }
    const term = (program.terms || []).find((t) => Number(t.term_months) === termMonths);
    if (term) {
      elements.contractRateDisplay.textContent = `${term.annual_rate.toFixed(2)}% годовых`;
      elements.contractAnnualRate.value = String(term.annual_rate);
    }
  }

  async function submitContract(event) {
    event.preventDefault();

    const data = {
      client_id: elements.contractClient.value,
      program_id: elements.contractProgram.value,
      term_months: elements.contractTerm.value,
      contract_number: elements.contractForm.elements.contract_number.value,
      start_date: DateMask.get(elements.contractStartDate),
      amount: elements.contractForm.elements.amount.value,
      currency: elements.contractCurrency.value,
      annual_rate: elements.contractAnnualRate.value,
    };

    const errors = Validators.validateContract(data, { bankDate: state.bankDate, terms: state.flatTerms });
    if (Object.keys(errors).length > 0) {
      showContractErrors(errors);
      showToast('Исправьте ошибки в форме', 'error');
      return;
    }

    elements.btnSaveContract.disabled = true;
    try {
      const result = await api.createContract({
        client_id: Number(data.client_id),
        program_id: Number(data.program_id),
        term_months: Number(data.term_months),
        contract_number: data.contract_number,
        start_date: data.start_date,
        amount: Number(data.amount),
        currency: data.currency,
      });

      elements.contractModal.classList.add('hidden');
      showToast(`Договор ${result.contract.contract_number} заключён. Открыты счета: ${result.deposit_account.account_number}, ${result.interest_account.account_number}`, 'success');

      await Promise.all([loadContracts(), loadAccounts()]);

      renderLedgerOpening(result.log, result.contract);
      elements.ledgerModal.classList.remove('hidden');
    } catch (err) {
      handleRequestError(err);
    } finally {
      elements.btnSaveContract.disabled = false;
    }
  }

  // ---------------------------------------------------------------------------
  // Закрытие банковского месяца
  // ---------------------------------------------------------------------------
  async function closeMonth() {
    const confirmed = window.confirm(
      `Закрыть банковский месяц ${formatDate(state.bankDate)}? Будут выполнены расчёты по всем активным договорам, банковская дата перейдёт на следующий месяц.`
    );
    if (!confirmed) return;

    elements.btnCloseMonth.disabled = true;
    try {
      const result = await api.closeMonth();
      state.bankDate = result.bank_date;
      elements.bankDate.textContent = formatDate(result.bank_date);

      showToast(
        `Банковский месяц ${formatDate(result.closed_month)} закрыт. Обработано договоров: ${result.contracts_processed}`,
        'success'
      );

      await Promise.all([loadContracts(), loadAccounts(), loadBankState()]);

      renderLedgerMonth(result);
      elements.ledgerModal.classList.remove('hidden');

      // Уведомляем модуль кредитов о смене банковского месяца
      window.dispatchEvent(new CustomEvent('app:month-closed', { detail: result }));
    } catch (err) {
      handleRequestError(err);
    } finally {
      elements.btnCloseMonth.disabled = false;
    }
  }

  // ---------------------------------------------------------------------------
  // Рендер журнала проводок
  // ---------------------------------------------------------------------------
  function renderEntryLines(entry) {
    const rows = entry.lines.map((line) => {
      const side = line.side === 'D' ? 'Дт' : 'Кт';
      const lineCurrency = line.currency || 'BYN';
      // Для валютных операций показываем эквивалент в BYN, чтобы была видна конвертация
      const bynCell = lineCurrency !== 'BYN'
        ? `<span class="muted">≈ ${escapeHtml(formatMoneyWithCurrency(line.amountByn, 'BYN'))}</span>`
        : '';
      return `
        <tr>
          <td class="mono">${side}</td>
          <td class="mono">${escapeHtml(line.accountNumber || '—')}</td>
          <td>${escapeHtml(line.accountName || '—')}</td>
          <td class="num">
            ${escapeHtml(formatMoneyWithCurrency(line.amount, lineCurrency))}
            ${bynCell}
          </td>
        </tr>
      `;
    }).join('');

    return `
      <div class="entry-line">
        <div class="entry-line-comment">
          <span class="muted">${formatDate(entry.entryDate)}</span> — ${escapeHtml(entry.comment)}
        </div>
        <table class="entry-lines">
          <thead>
            <tr><th>Сторона</th><th>Счёт</th><th>Наименование</th><th>Сумма</th></tr>
          </thead>
          <tbody>${rows}</tbody>
        </table>
      </div>
    `;
  }

  function renderLedgerOpening(entries, contract) {
    elements.ledgerModalTitle.textContent = 'Проводки заключения договора';
    const contractBlock = `
      <div class="log-contract-header">
        Договор <span class="mono">${escapeHtml(contract.contract_number)}</span> ·
        ${escapeHtml(contract.client_name)} · ${escapeHtml(formatMoneyWithCurrency(contract.amount, contract.currency))}
      </div>
    `;
    elements.ledgerModalContent.innerHTML =
      contractBlock + entries.map(renderEntryLines).join('');
  }

  function renderLedgerMonth(result) {
    elements.ledgerModalTitle.textContent = `Журнал проводок за ${formatDate(result.closed_month)}`;

    const depositLog = result.log || [];
    const creditLog = result.credits_log || [];

    if (depositLog.length === 0 && creditLog.length === 0) {
      elements.ledgerModalContent.innerHTML =
        '<p class="modal-text">Активных договоров на закрываемую дату нет — проводки не формировались.</p>';
      return;
    }

    const renderContractLog = (contractLog, moduleLabel) => {
      const entriesHtml = contractLog.entries.map(renderEntryLines).join('');
      const contractCurrency = contractLog.currency || 'BYN';
      const sumLabel = moduleLabel === 'credit'
        ? `проценты за месяц ${formatMoney(contractLog.monthly_interest)} BYN · погашение тела ${formatMoney(contractLog.monthly_principal)} BYN`
        : `проценты за месяц ${escapeHtml(formatMoneyWithCurrency(contractLog.monthly_interest, contractCurrency))}`;
      const statusBadge = contractLog.status === 'COMPLETED' || contractLog.status === 'CLOSED'
        ? '<span class="badge badge-muted">завершён</span>'
        : '<span class="badge badge-success">действует</span>';
      return `
        <div class="log-contract">
          <div class="log-contract-header">
            <span class="log-module-tag">${moduleLabel === 'credit' ? 'Кредит' : 'Депозит'}</span>
            Договор <span class="mono">${escapeHtml(contractLog.contract_number)}</span> ·
            ${escapeHtml(contractLog.client_name)} · ${escapeHtml(contractLog.program_name)} ·
            сумма ${escapeHtml(formatMoneyWithCurrency(contractLog.amount, contractLog.currency || 'BYN'))} ·
            ${sumLabel} ·
            ${statusBadge}
          </div>
          ${entriesHtml}
        </div>
      `;
    };

    let html = '';
    if (depositLog.length > 0) {
      html += '<div class="log-module-header">Депозитные договоры</div>';
      html += depositLog.map((contractLog) => renderContractLog(contractLog, 'deposit')).join('');
    }
    if (creditLog.length > 0) {
      html += '<div class="log-module-header">Кредитные договоры</div>';
      html += creditLog.map((contractLog) => renderContractLog(contractLog, 'credit')).join('');
    }
    elements.ledgerModalContent.innerHTML = html;
  }

  // ---------------------------------------------------------------------------
  // Admin-режим и удаление договора
  // ---------------------------------------------------------------------------

  /** Открывает модальное окно подтверждения удаления договора. */
  function openContractDeleteModal(id) {
    const contract = state.contracts.find((item) => item.id === id);
    if (!contract) return;

    state.pendingDeleteId = id;
    elements.contractDeleteMessage.textContent =
      `Вы уверены, что хотите удалить договор «${contract.contract_number}» `
      + `(${contract.client_name})? Вместе с договором будут удалены его счета и все проводки. `
      + 'Это действие нельзя отменить.';
    elements.contractDeleteConfirmInput.value = '';
    elements.btnContractDeleteConfirm.disabled = true;
    elements.contractDeleteModal.classList.remove('hidden');
    elements.contractDeleteConfirmInput.focus();
  }

  function closeContractDeleteModal() {
    elements.contractDeleteModal.classList.add('hidden');
    elements.contractDeleteConfirmInput.value = '';
    elements.btnContractDeleteConfirm.disabled = true;
    state.pendingDeleteId = null;
  }

  /** Кнопка удаления активна только при точном вводе контрольного слова. */
  function checkDeleteConfirmWord() {
    const typed = elements.contractDeleteConfirmInput.value.trim().toUpperCase();
    elements.btnContractDeleteConfirm.disabled = typed !== DELETE_CONFIRM_WORD;
  }

  async function confirmContractDelete() {
    const id = state.pendingDeleteId;
    if (id === null) return;
    if (elements.contractDeleteConfirmInput.value.trim().toUpperCase() !== DELETE_CONFIRM_WORD) {
      showToast(`Введите слово ${DELETE_CONFIRM_WORD} для подтверждения`, 'error');
      return;
    }

    elements.btnContractDeleteConfirm.disabled = true;
    try {
      const result = await api.deleteContract(id);
      closeContractDeleteModal();
      await Promise.all([loadContracts(), loadAccounts()]);
      showToast(
        `Договор ${result.contract_number} удалён (счетов: ${result.deleted_accounts}, `
        + `проводок: ${result.deleted_entries})`,
        'success'
      );
    } catch (err) {
      closeContractDeleteModal();
      handleRequestError(err);
    }
  }

  // ---------------------------------------------------------------------------
  // Роль администратора: сброс банковских данных
  // ---------------------------------------------------------------------------

  function openResetBankModal() {
    elements.resetBankConfirmInput.value = '';
    elements.btnResetBankConfirm.disabled = true;
    elements.resetBankModal.classList.remove('hidden');
    elements.resetBankConfirmInput.focus();
  }

  function closeResetBankModal() {
    elements.resetBankModal.classList.add('hidden');
    elements.resetBankConfirmInput.value = '';
    elements.btnResetBankConfirm.disabled = true;
  }

  /** Кнопка сброса активна только при точном вводе контрольного слова. */
  function checkResetConfirmWord() {
    const typed = elements.resetBankConfirmInput.value.trim().toUpperCase();
    elements.btnResetBankConfirm.disabled = typed !== RESET_CONFIRM_WORD;
  }

  async function confirmResetBank() {
    if (elements.resetBankConfirmInput.value.trim().toUpperCase() !== RESET_CONFIRM_WORD) {
      showToast(`Введите слово ${RESET_CONFIRM_WORD} для подтверждения`, 'error');
      return;
    }

    elements.btnResetBankConfirm.disabled = true;
    try {
      const result = await api.resetBank();
      closeResetBankModal();
      await Promise.all([loadContracts(), loadAccounts(), loadBankState()]);
      elements.bankDate.textContent = formatDate(result.bank_date);
      // Модуль кредитов и модуль банкомата тоже должны перечитать данные
      window.dispatchEvent(new CustomEvent('app:month-closed'));
      window.dispatchEvent(new CustomEvent('app:accounts-changed'));
      const d = result.deleted;
      showToast(
        `База сброшена. Клиентов сохранено: ${result.kept_clients}. Удалено договоров: `
        + `${d.deposit_contracts + d.credit_contracts}, карт: ${d.credit_cards}, `
        + `счетов: ${d.client_accounts}, проводок: ${d.journal_entries}`,
        'success'
      );
    } catch (err) {
      closeResetBankModal();
      handleRequestError(err);
    }
  }

  // ---------------------------------------------------------------------------
  // Инициализация
  // ---------------------------------------------------------------------------
  function bindEvents() {
    elements.tabButtons.forEach((btn) => {
      btn.addEventListener('click', () => switchTab(btn.dataset.tab));
    });

    // Маска даты договора: нативный <input type="date"> не даёт набрать 29.02
    DateMask.mount(elements.contractStartDate, {
      label: 'Дата заключения договора',
      noFutureCheck: true,
    });

    elements.btnAddContract.addEventListener('click', openContractModal);
    elements.contractProgram.addEventListener('change', selectProgramTerms);
    elements.contractTerm.addEventListener('change', onTermChange);
    elements.contractStartDate.addEventListener('input', updateMaturityDate);
    elements.contractCurrency.addEventListener('change', updateCurrencyHint);
    elements.contractAmount.addEventListener('input', updateCurrencyHint);
    elements.contractForm.addEventListener('submit', submitContract);

    elements.contractsTbody.addEventListener('click', (event) => {
      const button = event.target.closest('[data-action="delete-contract"]');
      if (!button) return;
      openContractDeleteModal(Number(button.dataset.id));
    });

    elements.contractDeleteConfirmInput.addEventListener('input', checkDeleteConfirmWord);
    elements.btnContractDeleteConfirm.addEventListener('click', confirmContractDelete);
    elements.btnContractDeleteCancel.addEventListener('click', closeContractDeleteModal);
    elements.contractDeleteModal.addEventListener('click', (event) => {
      if (event.target === elements.contractDeleteModal) closeContractDeleteModal();
    });

    elements.btnCloseContractModal.addEventListener('click', () => {
      elements.contractModal.classList.add('hidden');
    });
    elements.btnContractCancel.addEventListener('click', () => {
      elements.contractModal.classList.add('hidden');
    });

    elements.btnCloseMonth.addEventListener('click', closeMonth);
    elements.btnSetBankDate.addEventListener('click', setBankDate);

    // --- Сброс банковских данных (Admin-режим) ---
    elements.btnResetBank.addEventListener('click', openResetBankModal);
    elements.btnResetBankCancel.addEventListener('click', closeResetBankModal);
    elements.resetBankConfirmInput.addEventListener('input', checkResetConfirmWord);
    elements.btnResetBankConfirm.addEventListener('click', confirmResetBank);
    elements.resetBankModal.addEventListener('click', (event) => {
      if (event.target === elements.resetBankModal) closeResetBankModal();
    });

    // Модуль кредитов удалил договор — обороты счетов изменились
    window.addEventListener('app:accounts-changed', () => {
      loadAccounts().catch(handleRequestError);
    });

    elements.btnCloseLedgerModal.addEventListener('click', () => {
      elements.ledgerModal.classList.add('hidden');
    });
    elements.btnLedgerClose.addEventListener('click', () => {
      elements.ledgerModal.classList.add('hidden');
    });

    // Закрытие модалки по клику на подложку
    [elements.contractModal, elements.ledgerModal].forEach((overlay) => {
      overlay.addEventListener('click', (event) => {
        if (event.target === overlay) overlay.classList.add('hidden');
      });
    });

    // Escape закрывает модальные окна модуля
    document.addEventListener('keydown', (event) => {
      if (event.key === 'Escape') {
        elements.contractModal.classList.add('hidden');
        elements.ledgerModal.classList.add('hidden');
        closeContractDeleteModal();
        closeResetBankModal();
      }
    });
  }

  async function init() {
    bindEvents();
    try {
      await Promise.all([loadBankState(), loadPrograms(), loadClients()]);
      await Promise.all([loadContracts(), loadAccounts()]);
    } catch (err) {
      handleRequestError(err);
    }
  }

  document.addEventListener('DOMContentLoaded', init);
})();