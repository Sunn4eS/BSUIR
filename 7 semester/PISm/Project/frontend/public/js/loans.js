/**
 * Модуль 3 «Кредитные операции с физическими лицами» (банк «Дабрабыт»).
 * Выдача кредитов (заключение кредитных договоров), график погашения,
 * расчёты при закрытии банковского месяца (интеграция с deposits.js).
 */
(function () {
  'use strict';

  const { api, showToast, escapeHtml, formatDate, formatMoney } = Common;

  // ---------------------------------------------------------------------------
  // Состояние
  // ---------------------------------------------------------------------------
  const state = {
    bankDate: null,
    programs: [],
    clients: [],
    contracts: [],
    flatTerms: [],
  };

  const elements = {
    btnAddCredit: document.getElementById('btn-add-credit'),
    creditsTbody: document.getElementById('credits-tbody'),
    creditsEmpty: document.getElementById('credits-empty'),
    creditModal: document.getElementById('credit-modal'),
    creditForm: document.getElementById('credit-form'),
    creditClient: document.getElementById('credit_client_id'),
    creditProgram: document.getElementById('credit_program_id'),
    creditTerm: document.getElementById('credit_term_months'),
    creditStartDate: document.getElementById('credit_start_date'),
    creditRateDisplay: document.getElementById('credit-rate-display'),
    creditAnnualRate: document.getElementById('credit_annual_rate'),
    programHint: document.getElementById('credit-program-hint'),
    btnCloseCreditModal: document.getElementById('btn-close-credit-modal'),
    btnCreditCancel: document.getElementById('btn-credit-cancel'),
    btnSaveCredit: document.getElementById('btn-save-credit'),
    scheduleModal: document.getElementById('schedule-modal'),
    scheduleModalTitle: document.getElementById('schedule-modal-title'),
    scheduleModalContent: document.getElementById('schedule-modal-content'),
    btnCloseScheduleModal: document.getElementById('btn-close-schedule-modal'),
    btnScheduleClose: document.getElementById('btn-schedule-close'),
    ledgerModal: document.getElementById('ledger-modal'),
    ledgerModalTitle: document.getElementById('ledger-modal-title'),
    ledgerModalContent: document.getElementById('ledger-modal-content'),
    btnCloseLedgerModal: document.getElementById('btn-close-ledger-modal'),
    btnLedgerClose: document.getElementById('btn-ledger-close'),
  };

  const CREDIT_ERROR_FIELDS = {
    client_id: 'error-credit_client_id',
    program_id: 'error-credit_program_id',
    term_months: 'error-credit_term_months',
    contract_number: 'error-credit_contract_number',
    start_date: 'error-credit_start_date',
    amount: 'error-credit_amount',
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

  function repaymentTypeLabel(program) {
    if (program.repayment_type === 'ANNUITY') {
      return 'аннуитетный платёж';
    }
    return 'проценты ежемесячно, тело — в конце срока';
  }

  function clearErrors() {
    Object.values(CREDIT_ERROR_FIELDS).forEach((id) => {
      const el = document.getElementById(id);
      if (el) el.textContent = '';
    });
    document.querySelectorAll('#credit-form .form-group input.invalid, #credit-form .form-group select.invalid')
      .forEach((el) => el.classList.remove('invalid'));
  }

  function showErrors(errors) {
    clearErrors();
    Object.keys(errors).forEach((field) => {
      const errorId = CREDIT_ERROR_FIELDS[field];
      if (errorId) {
        const el = document.getElementById(errorId);
        if (el) el.textContent = errors[field];
      }
      const input = elements.creditForm.elements[field];
      if (input) input.classList.add('invalid');
    });
    const first = document.querySelector('#credit-form .form-group input.invalid, #credit-form .form-group select.invalid');
    if (first) first.focus();
  }

  function handleRequestError(err) {
    if (err.cause && err.cause.data && err.cause.data.errors) {
      showErrors(err.cause.data.errors);
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
  // Загрузка данных
  // ---------------------------------------------------------------------------
  async function loadBankState() {
    const data = await api.getBankState();
    state.bankDate = data.bank_date;
  }

  async function loadCreditPrograms() {
    state.programs = await api.getCreditPrograms();
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

  async function loadCreditContracts() {
    state.contracts = await api.getCreditContracts();
    renderContracts();
  }

  // ---------------------------------------------------------------------------
  // Рендер кредитных договоров
  // ---------------------------------------------------------------------------
  function renderContracts() {
    const isEmpty = state.contracts.length === 0;
    elements.creditsTbody.innerHTML = '';
    elements.creditsEmpty.classList.toggle('hidden', !isEmpty);

    state.contracts.forEach((contract) => {
      const tr = document.createElement('tr');
      tr.innerHTML = `
        <td class="mono">${escapeHtml(contract.contract_number)}</td>
        <td>${escapeHtml(contract.client_name)}</td>
        <td>
          ${escapeHtml(contract.program_name)}
          <span class="muted">(${repaymentTypeLabel(contract)})</span>
        </td>
        <td class="num">${escapeHtml(String(contract.term_months))}</td>
        <td class="num">${escapeHtml(contract.annual_rate.toFixed(2))}%</td>
        <td class="num">${formatMoney(contract.amount)}</td>
        <td class="num">${formatDate(contract.start_date)}</td>
        <td class="num">${formatDate(contract.maturity_date)}</td>
        <td>${badge(contract.status)}</td>
        <td>
          <div class="acct-cell">
            <span class="mono" title="Кредитный (основной) счёт 2400">${escapeHtml(contract.credit_account_number || '—')}</span>
            <span class="muted">основной (2400)</span>
          </div>
          <div class="acct-cell">
            <span class="mono" title="Процентный счёт 2470">${escapeHtml(contract.interest_account_number || '—')}</span>
            <span class="muted">процентный (2470)</span>
          </div>
        </td>
        <td class="col-actions">
          <button type="button" class="btn btn-small btn-edit" data-action="schedule" data-id="${contract.id}" title="График погашения кредита">График погашения</button>
        </td>
      `;
      elements.creditsTbody.appendChild(tr);
    });
  }

  // ---------------------------------------------------------------------------
  // Модальное окно выдачи кредита
  // ---------------------------------------------------------------------------
  async function openCreditModal() {
    clearErrors();
    elements.creditForm.reset();
    elements.creditRateDisplay.textContent = '—';
    elements.creditAnnualRate.value = '';
    elements.programHint.textContent = '';

    elements.creditClient.innerHTML = '<option value="">— Выберите клиента —</option>';
    state.clients
      .slice()
      .sort((a, b) => `${a.last_name} ${a.first_name}`.localeCompare(`${b.last_name} ${b.first_name}`))
      .forEach((client) => {
        const option = document.createElement('option');
        option.value = String(client.id);
        option.textContent = `${client.last_name} ${client.first_name} ${client.middle_name}`;
        elements.creditClient.appendChild(option);
      });

    elements.creditProgram.innerHTML = '<option value="">— Выберите программу —</option>';
    state.programs.forEach((program) => {
      const option = document.createElement('option');
      option.value = String(program.id);
      option.textContent = `${program.name} (${repaymentTypeLabel(program)})`;
      elements.creditProgram.appendChild(option);
    });

    elements.creditTerm.innerHTML = '<option value="">— Выберите срок —</option>';

    // Актуальная банковская дата с сервера: она могла измениться после
    // закрытия месяца или установки даты в модуле депозитов.
    try {
      await loadBankState();
    } catch (err) {
      /* сервер недоступен — оставляем последнюю известную дату */
    }
    elements.creditStartDate.value = state.bankDate || '';

    elements.creditModal.classList.remove('hidden');
    elements.creditClient.focus();
  }

  function selectProgramTerms() {
    const programId = Number(elements.creditProgram.value);
    const program = state.programs.find((p) => p.id === programId);

    elements.creditTerm.innerHTML = '<option value="">— Выберите срок —</option>';
    elements.creditRateDisplay.textContent = '—';
    elements.creditAnnualRate.value = '';
    elements.programHint.textContent = '';

    if (!program) return;

    elements.programHint.textContent = repaymentTypeLabel(program);

    (program.terms || []).slice().sort((a, b) => a.term_months - b.term_months)
      .forEach((term) => {
        const option = document.createElement('option');
        option.value = String(term.term_months);
        option.textContent = `${term.term_months} мес.`;
        elements.creditTerm.appendChild(option);
      });
  }

  function onTermChange() {
    const programId = Number(elements.creditProgram.value);
    const termMonths = Number(elements.creditTerm.value);
    const program = state.programs.find((p) => p.id === programId);
    if (!program || !termMonths) {
      elements.creditRateDisplay.textContent = '—';
      elements.creditAnnualRate.value = '';
      return;
    }
    const term = (program.terms || []).find((t) => Number(t.term_months) === termMonths);
    if (term) {
      elements.creditRateDisplay.textContent = `${term.annual_rate.toFixed(2)}% годовых`;
      elements.creditAnnualRate.value = String(term.annual_rate);
    }
  }

  async function submitCredit(event) {
    event.preventDefault();

    const data = {
      client_id: elements.creditClient.value,
      program_id: elements.creditProgram.value,
      term_months: elements.creditTerm.value,
      contract_number: elements.creditForm.elements.contract_number.value,
      start_date: elements.creditForm.elements.start_date.value,
      amount: elements.creditForm.elements.amount.value,
      currency: 'BYN',
      annual_rate: elements.creditAnnualRate.value,
    };

    const errors = Validators.validateCreditContract(data, { bankDate: state.bankDate, terms: state.flatTerms });
    if (Object.keys(errors).length > 0) {
      showErrors(errors);
      showToast('Исправьте ошибки в форме', 'error');
      return;
    }

    elements.btnSaveCredit.disabled = true;
    try {
      const result = await api.createCreditContract({
        client_id: Number(data.client_id),
        program_id: Number(data.program_id),
        term_months: Number(data.term_months),
        contract_number: data.contract_number,
        start_date: data.start_date,
        amount: Number(data.amount),
        currency: 'BYN',
      });

      elements.creditModal.classList.add('hidden');
      showToast(
        `Кредит ${result.contract.contract_number} выдан. Открыты счета: ${result.credit_account.account_number}, ${result.interest_account.account_number}`,
        'success'
      );

      await loadCreditContracts();

      renderLedgerOpening(result.log, result.contract);
      elements.ledgerModal.classList.remove('hidden');
    } catch (err) {
      handleRequestError(err);
    } finally {
      elements.btnSaveCredit.disabled = false;
    }
  }

  // ---------------------------------------------------------------------------
  // Журнал проводок выдачи кредита
  // ---------------------------------------------------------------------------
  function renderEntryLines(entry) {
    const rows = entry.lines.map((line) => {
      const side = line.side === 'D' ? 'Дт' : 'Кт';
      return `
        <tr>
          <td class="mono">${side}</td>
          <td class="mono">${escapeHtml(line.accountNumber || '—')}</td>
          <td>${escapeHtml(line.accountName || '—')}</td>
          <td class="num">${formatMoney(line.amount)}</td>
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
            <tr><th>Сторона</th><th>Счёт</th><th>Наименование</th><th>Сумма (BYN)</th></tr>
          </thead>
          <tbody>${rows}</tbody>
        </table>
      </div>
    `;
  }

  function renderLedgerOpening(entries, contract) {
    elements.ledgerModalTitle.textContent = 'Проводки выдачи кредита';
    const contractBlock = `
      <div class="log-contract-header">
        Договор <span class="mono">${escapeHtml(contract.contract_number)}</span> ·
        ${escapeHtml(contract.client_name)} · ${formatMoney(contract.amount)} BYN
      </div>
    `;
    elements.ledgerModalContent.innerHTML =
      contractBlock + entries.map(renderEntryLines).join('');
  }

  // ---------------------------------------------------------------------------
  // График погашения
  // ---------------------------------------------------------------------------
  function openScheduleModal(contract) {
    elements.scheduleModalTitle.textContent =
      `График погашения: договор ${contract.contract_number}`;

    const schedule = contract.schedule || [];
    const rows = schedule.map((row) => `
      <tr>
        <td class="num">${row.month}</td>
        <td class="num">${formatDate(row.date)}</td>
        <td class="num">${formatMoney(row.interest)}</td>
        <td class="num">${formatMoney(row.principal)}</td>
        <td class="num"><strong>${formatMoney(row.payment)}</strong></td>
        <td class="num">${formatMoney(row.remaining)}</td>
      </tr>
    `).join('');

    const totalInterest = schedule.reduce((sum, row) => sum + Number(row.interest), 0);
    const totalPrincipal = schedule.reduce((sum, row) => sum + Number(row.principal), 0);

    elements.scheduleModalContent.innerHTML = `
      <p class="field-hint">
        Программа: ${escapeHtml(contract.program_name)} ·
        ${escapeHtml(contract.annual_rate.toFixed(2))}% годовых · ${contract.term_months} мес. ·
        сумма ${formatMoney(contract.amount)} BYN · метод: ${escapeHtml(repaymentTypeLabel(contract))}
      </p>
      <div class="table-wrapper">
        <table class="clients-table">
          <thead>
            <tr>
              <th>№ месяца</th>
              <th>Дата платежа</th>
              <th>Начисленные проценты (BYN)</th>
              <th>Погашение основного долга (BYN)</th>
              <th>Ежемесячный платёж (BYN)</th>
              <th>Остаток долга (BYN)</th>
            </tr>
          </thead>
          <tbody>${rows}</tbody>
          <tfoot>
            <tr>
              <td colspan="2" class="num"><strong>Итого:</strong></td>
              <td class="num"><strong>${formatMoney(totalInterest)}</strong></td>
              <td class="num"><strong>${formatMoney(totalPrincipal)}</strong></td>
              <td class="num"><strong>${formatMoney(totalInterest + totalPrincipal)}</strong></td>
              <td></td>
            </tr>
          </tfoot>
        </table>
      </div>
    `;

    elements.scheduleModal.classList.remove('hidden');
  }

  // ---------------------------------------------------------------------------
  // События
  // ---------------------------------------------------------------------------
  function bindEvents() {
    elements.btnAddCredit.addEventListener('click', openCreditModal);
    elements.creditProgram.addEventListener('change', selectProgramTerms);
    elements.creditTerm.addEventListener('change', onTermChange);
    elements.creditForm.addEventListener('submit', submitCredit);

    elements.btnCloseCreditModal.addEventListener('click', () => {
      elements.creditModal.classList.add('hidden');
    });
    elements.btnCreditCancel.addEventListener('click', () => {
      elements.creditModal.classList.add('hidden');
    });

    elements.creditsTbody.addEventListener('click', (event) => {
      const btn = event.target.closest('button[data-action="schedule"]');
      if (!btn) return;
      const contract = state.contracts.find((c) => Number(c.id) === Number(btn.dataset.id));
      if (contract) openScheduleModal(contract);
    });

    elements.btnCloseScheduleModal.addEventListener('click', () => {
      elements.scheduleModal.classList.add('hidden');
    });
    elements.btnScheduleClose.addEventListener('click', () => {
      elements.scheduleModal.classList.add('hidden');
    });

    // После закрытия банковского месяца (из deposits.js) перезагружаем кредиты
    window.addEventListener('app:month-closed', () => {
      loadBankState().catch(handleRequestError);
      loadCreditContracts().catch(handleRequestError);
    });

    // Банковская дата изменена панелью установки даты (модуль депозитов)
    window.addEventListener('app:bank-date-changed', () => {
      loadBankState().catch(handleRequestError);
    });

    // Закрытие модалок по клику на подложку
    [elements.creditModal, elements.scheduleModal].forEach((overlay) => {
      overlay.addEventListener('click', (event) => {
        if (event.target === overlay) overlay.classList.add('hidden');
      });
    });

    // Escape закрывает модальные окна модуля кредитов
    document.addEventListener('keydown', (event) => {
      if (event.key === 'Escape') {
        elements.creditModal.classList.add('hidden');
        elements.scheduleModal.classList.add('hidden');
      }
    });
  }

  async function init() {
    bindEvents();
    try {
      await Promise.all([loadBankState(), loadCreditPrograms(), loadClients()]);
      await loadCreditContracts();
    } catch (err) {
      handleRequestError(err);
    }
  }

  document.addEventListener('DOMContentLoaded', init);
})();