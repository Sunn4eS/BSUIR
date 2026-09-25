/**
 * Модуль «Клиенты» — клиентская логика SPA.
 * Список клиентов, форма добавления/редактирования, удаление с подтверждением,
 * валидация, отображение серверных ошибок.
 */
(function () {
  'use strict';

  // Общие утилиты и API-клиент вынесены в common.js
  const { api: API, showToast, escapeHtml, formatDate } = Common;

  // ---------------------------------------------------------------------------
  // Состояние приложения
  // ---------------------------------------------------------------------------
  const state = {
    editingId: null,
    clients: [],
    dictionaries: {
      cities: [],
      marital_statuses: [],
      citizenships: [],
      disability_groups: [],
    },
    pendingDeleteId: null,
  };

  // ---------------------------------------------------------------------------
  // Элементы DOM
  // ---------------------------------------------------------------------------
  const elements = {
    clientsTbody: document.getElementById('clients-tbody'),
    clientsEmpty: document.getElementById('clients-empty'),
    btnAddClient: document.getElementById('btn-add-client'),
    clientModal: document.getElementById('client-modal'),
    deleteModal: document.getElementById('delete-modal'),
    modalTitle: document.getElementById('modal-title'),
    clientForm: document.getElementById('client-form'),
    btnCloseModal: document.getElementById('btn-close-modal'),
    btnFormCancel: document.getElementById('btn-form-cancel'),
    btnSaveClient: document.getElementById('btn-save-client'),
    deleteMessage: document.getElementById('delete-message'),
    btnDeleteCancel: document.getElementById('btn-delete-cancel'),
    btnDeleteConfirm: document.getElementById('btn-delete-confirm'),
    toastContainer: document.getElementById('toast-container'),
  };

  const SELECT_FIELDS = ['city_id', 'marital_status_id', 'citizenship_id', 'disability_group_id'];
  const CHECKBOX_FIELDS = ['is_pensioner', 'is_military_obligated'];

  function fieldEl(field) {
    return document.getElementById(field);
  }

  function errorEl(field) {
    return document.getElementById('error-' + field);
  }

  // ---------------------------------------------------------------------------
  // Утилиты (escapeHtml, formatDate, showToast — общие, см. common.js)
  // ---------------------------------------------------------------------------
  /** Кириллические буквы -> латинские (для идентификационного номера и серии паспорта) */
  function toLatin(value) {
    const map = {
      'А': 'A', 'В': 'B', 'Е': 'E', 'К': 'K', 'М': 'M', 'Н': 'H',
      'О': 'O', 'Р': 'P', 'С': 'C', 'Т': 'T', 'У': 'Y', 'Х': 'X',
    };
    return value.toUpperCase().split('').map((ch) => (map[ch] || ch)).join('');
  }

  // ---------------------------------------------------------------------------
  // Отображение ошибок валидации
  // ---------------------------------------------------------------------------
  function clearErrors() {
    document.querySelectorAll('.field-error').forEach((el) => (el.textContent = ''));
    document.querySelectorAll('.form-group input.invalid, .form-group select.invalid')
      .forEach((el) => el.classList.remove('invalid'));
  }

  function clearFieldError(field) {
    const el = errorEl(field);
    if (el) el.textContent = '';
    const input = fieldEl(field);
    if (input) input.classList.remove('invalid');
  }

  function showErrors(errors) {
    clearErrors();
    const keys = Object.keys(errors);
    keys.forEach((field) => {
      const el = errorEl(field);
      if (el) el.textContent = errors[field];
      const input = fieldEl(field);
      if (input) input.classList.add('invalid');
    });
    // Фокус на первом невалидном поле
    const first = document.querySelector('.form-group input.invalid, .form-group select.invalid');
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
  // Маски ввода
  // ---------------------------------------------------------------------------
  function initPhoneMask(input) {
    input.addEventListener('input', () => {
      let digits = input.value.replace(/\D/g, '');
      if (digits.length > 12) digits = digits.slice(0, 12);
      if (digits.startsWith('375')) digits = digits.slice(3);

      if (digits.length === 0) {
        input.value = '';
        return;
      }

      let formatted = '+375 (' + digits.slice(0, 2);
      const rest = digits.slice(2);

      if (rest.length > 0) {
        formatted += ') ';
        formatted += rest.slice(0, 3);
      }
      if (rest.length > 3) {
        formatted += '-' + rest.slice(3, 5);
      }
      if (rest.length > 5) {
        formatted += '-' + rest.slice(5, 7);
      }
      input.value = formatted;
    });
  }

  function initIdentificationMask(input) {
    input.addEventListener('input', () => {
      // Латинские буквы + цифры, не более 14 символов, кириллица -> латиница
      input.value = toLatin(input.value).toUpperCase().replace(/[^A-Z0-9]/g, '').slice(0, 14);
    });
  }

  function initPassportSeriesMask(input) {
    input.addEventListener('input', () => {
      input.value = toLatin(input.value).toUpperCase().replace(/[^A-Z]/g, '').slice(0, 2);
    });
  }

  function initPassportNumberMask(input) {
    input.addEventListener('input', () => {
      input.value = input.value.replace(/\D/g, '').slice(0, 7);
    });
  }

  function setupMasks() {
    [fieldEl('home_phone'), fieldEl('mobile_phone')].forEach(initPhoneMask);
    initIdentificationMask(fieldEl('identification_number'));
    initPassportSeriesMask(fieldEl('passport_series'));
    initPassportNumberMask(fieldEl('passport_number'));
  }

  // ---------------------------------------------------------------------------
  // Загрузка данных
  // ---------------------------------------------------------------------------
  function fillSelect(selectEl, items, selectedValue) {
    const current = selectEl.value;
    selectEl.innerHTML = '<option value="">— Выберите —</option>';
    items.forEach((item) => {
      const option = document.createElement('option');
      option.value = String(item.id);
      option.textContent = item.name;
      selectEl.appendChild(option);
    });
    if (selectedValue !== undefined && selectedValue !== null) {
      selectEl.value = String(selectedValue);
    } else {
      selectEl.value = current;
    }
  }

  async function loadDictionaries() {
    const data = await API.getDictionaries();
    state.dictionaries = data;

    fillSelect(fieldEl('city_id'), data.cities);
    fillSelect(fieldEl('marital_status_id'), data.marital_statuses);
    fillSelect(fieldEl('citizenship_id'), data.citizenships);
    fillSelect(fieldEl('disability_group_id'), data.disability_groups);
  }

  async function loadClients() {
    state.clients = await API.getClients();
    renderClients(state.clients);
  }

  // ---------------------------------------------------------------------------
  // Таблица клиентов
  // ---------------------------------------------------------------------------
  function renderClients(clients) {
    elements.clientsEmpty.classList.toggle('hidden', clients.length > 0);

    elements.clientsTbody.innerHTML = clients.map((client) => {
      const fullName = [client.last_name, client.first_name, client.middle_name].join(' ');
      const passport = `${client.passport_series} ${client.passport_number}`;

      return `
        <tr>
          <td>${escapeHtml(fullName)}</td>
          <td>${escapeHtml(formatDate(client.birth_date))}</td>
          <td>${escapeHtml(passport)}</td>
          <td>${escapeHtml(client.identification_number)}</td>
          <td>${escapeHtml(client.city_name)}</td>
          <td>${client.mobile_phone ? escapeHtml(client.mobile_phone) : '—'}</td>
          <td>${client.is_pensioner
            ? '<span class="badge badge-yes">Да</span>'
            : '<span class="badge badge-no">Нет</span>'}</td>
          <td class="col-actions">
            <button type="button" class="btn btn-small btn-edit" data-action="edit" data-id="${client.id}">Редактировать</button>
            <button type="button" class="btn btn-small btn-danger" data-action="delete" data-id="${client.id}">Удалить</button>
          </td>
        </tr>
      `;
    }).join('');
  }

  // ---------------------------------------------------------------------------
  // Модальное окно формы
  // ---------------------------------------------------------------------------
  function openClientModal(mode, client) {
    clearErrors();
    elements.clientForm.reset();

    if (mode === 'edit' && client) {
      state.editingId = client.id;
      elements.modalTitle.textContent = 'Редактирование клиента';
      populateForm(client);
    } else {
      state.editingId = null;
      elements.modalTitle.textContent = 'Добавление клиента';
      // Чекбоксы сброшены в false через reset()
    }

    elements.clientModal.classList.remove('hidden');
    fieldEl('last_name').focus();
  }

  function closeClientModal() {
    elements.clientModal.classList.add('hidden');
    state.editingId = null;
    elements.clientForm.reset();
    clearErrors();
  }

  function populateForm(client) {
    fieldEl('last_name').value = client.last_name;
    fieldEl('first_name').value = client.first_name;
    fieldEl('middle_name').value = client.middle_name;
    fieldEl('birth_date').value = client.birth_date;
    fieldEl('passport_series').value = client.passport_series;
    fieldEl('passport_number').value = client.passport_number;
    fieldEl('issued_by').value = client.issued_by;
    fieldEl('issue_date').value = client.issue_date;
    fieldEl('identification_number').value = client.identification_number;
    fieldEl('birth_place').value = client.birth_place;
    fieldEl('city_id').value = String(client.city_id);
    fieldEl('actual_address').value = client.actual_address;
    fieldEl('home_phone').value = client.home_phone || '';
    fieldEl('mobile_phone').value = client.mobile_phone || '';
    fieldEl('email').value = client.email || '';
    fieldEl('marital_status_id').value = String(client.marital_status_id);
    fieldEl('citizenship_id').value = String(client.citizenship_id);
    fieldEl('disability_group_id').value = String(client.disability_group_id);
    fieldEl('is_pensioner').checked = client.is_pensioner;
    fieldEl('is_military_obligated').checked = client.is_military_obligated;
    fieldEl('work_place').value = client.work_place || '';
    fieldEl('position').value = client.position || '';
    fieldEl('monthly_income').value = client.monthly_income === null ? '' : String(client.monthly_income);
  }

  function collectFormData() {
    const data = {};

    [
      'last_name', 'first_name', 'middle_name',
      'passport_series', 'passport_number', 'issued_by',
      'identification_number', 'birth_place', 'actual_address',
      'home_phone', 'mobile_phone', 'email', 'work_place', 'position',
    ].forEach((field) => {
      data[field] = fieldEl(field).value.trim();
    });

    SELECT_FIELDS.forEach((field) => {
      data[field] = fieldEl(field).value;
    });

    data.birth_date = fieldEl('birth_date').value;
    data.issue_date = fieldEl('issue_date').value;

    CHECKBOX_FIELDS.forEach((field) => {
      data[field] = fieldEl(field).checked;
    });

    data.monthly_income = fieldEl('monthly_income').value.trim();

    return data;
  }

  async function handleFormSubmit(event) {
    event.preventDefault();

    const data = collectFormData();

    // 1. Клиентская валидация
    const errors = Validators.validateClient(data);
    if (Object.keys(errors).length > 0) {
      showErrors(errors);
      return;
    }

    clearErrors();
    elements.btnSaveClient.disabled = true;

    try {
      if (state.editingId === null) {
        await API.createClient(data);
        showToast('Клиент успешно добавлен', 'success');
      } else {
        await API.updateClient(state.editingId, data);
        showToast('Данные клиента успешно обновлены', 'success');
      }
      closeClientModal();
      await loadClients();
    } catch (err) {
      handleRequestError(err);
    } finally {
      elements.btnSaveClient.disabled = false;
    }
  }

  // ---------------------------------------------------------------------------
  // Удаление с подтверждением
  // ---------------------------------------------------------------------------
  function openDeleteConfirm(id) {
    const client = state.clients.find((item) => item.id === id);
    if (!client) return;

    state.pendingDeleteId = id;
    const fullName = [client.last_name, client.first_name, client.middle_name].join(' ');
    elements.deleteMessage.textContent =
      `Вы уверены, что хотите удалить клиента «${fullName}»? Это действие нельзя отменить.`;
    elements.deleteModal.classList.remove('hidden');
  }

  function closeDeleteConfirm() {
    elements.deleteModal.classList.add('hidden');
    state.pendingDeleteId = null;
  }

  async function confirmDelete() {
    if (state.pendingDeleteId === null) return;
    const id = state.pendingDeleteId;

    elements.btnDeleteConfirm.disabled = true;
    try {
      await API.deleteClient(id);
      closeDeleteConfirm();
      await loadClients();
      showToast('Клиент удалён', 'success');
    } catch (err) {
      closeDeleteConfirm();
      handleRequestError(err);
    } finally {
      elements.btnDeleteConfirm.disabled = false;
    }
  }

  // ---------------------------------------------------------------------------
  // Обработчики событий
  // ---------------------------------------------------------------------------
  function bindEvents() {
    elements.btnAddClient.addEventListener('click', () => openClientModal('create'));

    elements.btnCloseModal.addEventListener('click', closeClientModal);
    elements.btnFormCancel.addEventListener('click', closeClientModal);

    elements.clientForm.addEventListener('submit', handleFormSubmit);

    // Действия в таблице
    elements.clientsTbody.addEventListener('click', (event) => {
      const btn = event.target.closest('button[data-action]');
      if (!btn) return;
      const id = Number(btn.dataset.id);
      if (btn.dataset.action === 'edit') {
        const client = state.clients.find((item) => item.id === id);
        if (client) openClientModal('edit', client);
      } else if (btn.dataset.action === 'delete') {
        openDeleteConfirm(id);
      }
    });

    // Подтверждение удаления
    elements.btnDeleteCancel.addEventListener('click', closeDeleteConfirm);
    elements.btnDeleteConfirm.addEventListener('click', confirmDelete);

    // Закрытие модальных окон по Escape
    document.addEventListener('keydown', (event) => {
      if (event.key === 'Escape') {
        if (!elements.clientModal.classList.contains('hidden')) closeClientModal();
        if (!elements.deleteModal.classList.contains('hidden')) closeDeleteConfirm();
      }
    });

    // Клик по подложке закрывает модальное окно
    [elements.clientModal, elements.deleteModal].forEach((overlay) => {
      overlay.addEventListener('click', (event) => {
        if (event.target === overlay) {
          if (overlay === elements.clientModal) closeClientModal();
          else closeDeleteConfirm();
        }
      });
    });

    // Сброс ошибки поля при вводе
    document.addEventListener('input', (event) => {
      if (event.target.id && errorEl(event.target.id)) clearFieldError(event.target.id);
    });
    document.addEventListener('change', (event) => {
      if (event.target.id && errorEl(event.target.id)) clearFieldError(event.target.id);
    });
  }

  // ---------------------------------------------------------------------------
  // Инициализация
  // ---------------------------------------------------------------------------
  async function init() {
    bindEvents();
    setupMasks();

    try {
      await Promise.all([loadDictionaries(), loadClients()]);
    } catch (err) {
      handleRequestError(err);
    }
  }

  document.addEventListener('DOMContentLoaded', init);
})();