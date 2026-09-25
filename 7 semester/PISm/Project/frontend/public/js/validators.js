/**
 * Валидаторы фронтенда (дублируют серверную валидацию).
 * Global object: Validators.validateClient(data) -> { field: message, ... }
 */
(function (global) {
  'use strict';

  const NAME_REGEX = /^[A-Za-zА-Яа-яЁё]+(?:[\s-][A-Za-zА-Яа-яЁё]+)*$/;
  const PHONE_REGEX = /^\+375 \(\d{2}\) \d{3}-\d{2}-\d{2}$/;
  const IDENTIFICATION_REGEX = /^\d{7}[A-Z]\d{3}[A-Z]{2}\d$/;
  const PASSPORT_SERIES_REGEX = /^[A-Z]{2}$/;
  const PASSPORT_NUMBER_REGEX = /^\d{7}$/;
  const EMAIL_REGEX = /^[^\s@]+@[^\s@]+\.[^\s@]+$/;
  const DATE_REGEX = /^\d{4}-\d{2}-\d{2}$/;
  const INCOME_REGEX = /^\d+(\.\d{1,2})?$/;

  const FIELD_LABELS = {
    last_name: 'Фамилия',
    first_name: 'Имя',
    middle_name: 'Отчество',
    birth_date: 'Дата рождения',
    passport_series: 'Серия паспорта',
    passport_number: 'Номер паспорта',
    issued_by: 'Кем выдан',
    issue_date: 'Дата выдачи',
    identification_number: 'Идентификационный номер',
    birth_place: 'Место рождения',
    city_id: 'Город фактического проживания',
    actual_address: 'Адрес фактического проживания',
    marital_status_id: 'Семейное положение',
    citizenship_id: 'Гражданство',
    disability_group_id: 'Инвалидность',
    is_pensioner: 'Пенсионер',
    is_military_obligated: 'Военнообязанный',
  };

  function isEmpty(value) {
    return value === undefined || value === null || String(value).trim() === '';
  }

  /** Реальная календарная дата (31.02, 29.02 невисокосного года -> false) */
  function isRealCalendarDate(year, month, day) {
    if (month < 1 || month > 12 || day < 1 || day > 31) return false;
    const date = new Date(Date.UTC(year, month - 1, day));
    return (
      date.getUTCFullYear() === year &&
      date.getUTCMonth() === month - 1 &&
      date.getUTCDate() === day
    );
  }

  /**
   * Проверка даты YYYY-MM-DD: формат, реальность календаря, не из будущего.
   * Для банковских дат (заключение договора/кредита) будущее определяется
   * относительно банковской даты, а не реального календаря, поэтому вызывающий
   * код передаёт { noFutureCheck: true }.
   */
  function validateDate(value, label, opts) {
    if (isEmpty(value)) return `Поле «${label}» обязательно`;
    const str = String(value).trim();
    if (!DATE_REGEX.test(str)) return `Поле «${label}»: неверный формат даты`;
    const [year, month, day] = str.split('-').map(Number);
    if (!isRealCalendarDate(year, month, day)) return `Поле «${label}»: указанная дата не существует`;
    if (!opts || !opts.noFutureCheck) {
      if (Date.UTC(year, month - 1, day) > Date.now()) return `Поле «${label}» не может быть в будущем`;
    }
    return '';
  }

  /** ФИО: только буквы (латиница/кириллица), дефисы и пробелы */
  function validateName(value, label) {
    if (isEmpty(value)) return `Поле «${label}» обязательно`;
    if (!NAME_REGEX.test(String(value).trim())) {
      return `Поле «${label}»: допустимы только буквы, дефисы и пробелы (без цифр)`;
    }
    return '';
  }

  function validatePassportSeries(value) {
    if (isEmpty(value)) return 'Поле «Серия паспорта» обязательно';
    if (!PASSPORT_SERIES_REGEX.test(String(value).trim().toUpperCase())) {
      return 'Серия паспорта: две латинские буквы';
    }
    return '';
  }

  function validatePassportNumber(value) {
    if (isEmpty(value)) return 'Поле «Номер паспорта» обязательно';
    if (!PASSPORT_NUMBER_REGEX.test(String(value).trim())) {
      return 'Номер паспорта: ровно 7 цифр';
    }
    return '';
  }

  function validateIdentificationNumber(value) {
    if (isEmpty(value)) return 'Поле «Идентификационный номер» обязательно';
    if (!IDENTIFICATION_REGEX.test(String(value).trim().toUpperCase())) {
      return 'Идентификационный номер: формат 7 цифр + 1 буква + 3 цифры + 2 буквы + 1 цифра (например, 1234567A123PB1)';
    }
    return '';
  }

  function validatePhone(value, label) {
    if (isEmpty(value)) return '';
    if (!PHONE_REGEX.test(String(value).trim())) {
      return `Поле «${label}»: формат +375 (XX) XXX-XX-XX`;
    }
    return '';
  }

  function validateEmail(value) {
    if (isEmpty(value)) return '';
    if (!EMAIL_REGEX.test(String(value).trim())) return 'Некорректный адрес электронной почты';
    return '';
  }

  function validateIncome(value) {
    if (isEmpty(value)) return '';
    const str = String(value).trim();
    if (!INCOME_REGEX.test(str) || Number(str) > 999999999999.99) {
      return 'Ежемесячный доход: неотрицательное число с не более чем 2 знаками после запятой';
    }
    return '';
  }

  /** Полная валидация формы клиента */
  function validateClient(data) {
    const errors = {};

    // Обязательные текстовые поля
    ['last_name', 'first_name', 'middle_name'].forEach((field) => {
      const msg = validateName(data[field], FIELD_LABELS[field]);
      if (msg) errors[field] = msg;
    });

    ['issued_by', 'birth_place', 'actual_address'].forEach((field) => {
      const msg = isEmpty(data[field]) ? `Поле «${FIELD_LABELS[field]}» обязательно` : '';
      if (msg) errors[field] = msg;
    });

    // Обязательные поля с масками
    const seriesMsg = validatePassportSeries(data.passport_series);
    if (seriesMsg) errors.passport_series = seriesMsg;

    const numberMsg = validatePassportNumber(data.passport_number);
    if (numberMsg) errors.passport_number = numberMsg;

    const idMsg = validateIdentificationNumber(data.identification_number);
    if (idMsg) errors.identification_number = idMsg;

    // Обязательные даты
    const birthMsg = validateDate(data.birth_date, FIELD_LABELS.birth_date);
    if (birthMsg) errors.birth_date = birthMsg;

    const issueMsg = validateDate(data.issue_date, FIELD_LABELS.issue_date);
    if (issueMsg) errors.issue_date = issueMsg;

    // Обязательные поля-справочники
    ['city_id', 'marital_status_id', 'citizenship_id', 'disability_group_id'].forEach((field) => {
      const value = Number(data[field]);
      if (!Number.isInteger(value) || value <= 0) {
        errors[field] = `Выберите значение «${FIELD_LABELS[field]}»`;
      }
    });

    // Обязательные булевы поля
    if (typeof data.is_pensioner !== 'boolean') errors.is_pensioner = 'Укажите значение «Пенсионер»';
    if (typeof data.is_military_obligated !== 'boolean') {
      errors.is_military_obligated = 'Укажите значение «Военнообязанный»';
    }

    // Необязательные поля (проверяем только если заполнены)
    const homePhoneMsg = validatePhone(data.home_phone, 'Телефон домашний');
    if (homePhoneMsg) errors.home_phone = homePhoneMsg;

    const mobilePhoneMsg = validatePhone(data.mobile_phone, 'Телефон мобильный');
    if (mobilePhoneMsg) errors.mobile_phone = mobilePhoneMsg;

    const emailMsg = validateEmail(data.email);
    if (emailMsg) errors.email = emailMsg;

    const incomeMsg = validateIncome(data.monthly_income);
    if (incomeMsg) errors.monthly_income = incomeMsg;

    return errors;
  }

  /**
   * Полная валидация депозитного договора.
   * @param {object} data — поля формы {client_id, program_id, term_months,
   *   contract_number, start_date, amount, currency}
   * @param {object} context — { bankDate: 'YYYY-MM-DD', terms: [{...}] }
   * @returns {object} errors: { field: message, ... }
   */
  function validateContract(data, context) {
    const errors = {};
    const ctx = context || {};

    if (!Number.isInteger(Number(data.client_id)) || Number(data.client_id) <= 0) {
      errors.client_id = 'Выберите клиента';
    }

    if (!Number.isInteger(Number(data.program_id)) || Number(data.program_id) <= 0) {
      errors.program_id = 'Выберите депозитную программу';
    }

    if (!Number.isInteger(Number(data.term_months)) || Number(data.term_months) <= 0) {
      errors.term_months = 'Укажите срок вклада (в месяцах)';
    }

    if (isEmpty(data.contract_number)) {
      errors.contract_number = 'Поле «Номер договора» обязательно';
    } else if (String(data.contract_number).trim().length > 50) {
      errors.contract_number = 'Номер договора: не более 50 символов';
    }

    const amountStr = String(data.amount === undefined || data.amount === null ? '' : data.amount).trim();
    const amountValue = Number(amountStr);
    if (amountStr === '') {
      errors.amount = 'Поле «Сумма депозита» обязательно';
    } else if (!INCOME_REGEX.test(amountStr)) {
      errors.amount = 'Сумма депозита: число с не более чем 2 знаками после запятой';
    } else if (amountValue <= 0) {
      errors.amount = 'Сумма депозита должна быть больше нуля';
    } else if (amountValue > 999999999999.99) {
      errors.amount = 'Сумма депозита превышает допустимый лимит';
    }

    const dateMsg = validateDate(data.start_date, 'Дата заключения договора', { noFutureCheck: true });
    if (dateMsg) {
      errors.start_date = dateMsg;
    } else if (ctx.bankDate && String(data.start_date) > String(ctx.bankDate)) {
      errors.start_date = 'Дата заключения не может быть позже текущей банковской даты';
    }

    if (!isEmpty(data.currency) && String(data.currency).toUpperCase() !== 'BYN') {
      errors.currency = 'Валюта договора должна быть BYN';
    }

    // Проверка срока относительно выбранной программы
    const terms = (ctx.terms || []).filter((t) => Number(t.program_id) === Number(data.program_id));
    if (terms.length === 0 && !Number.isInteger(Number(data.program_id))) {
      // программа не выбрана — ошибка уже добавлена выше
    } else if (terms.length > 0 && !terms.some((t) => Number(t.term_months) === Number(data.term_months))) {
      errors.term_months = 'Для выбранной программы недоступен указанный срок';
    }

    return errors;
  }

  /**
   * Полная валидация кредитного договора (Модуль 3).
   * @param {object} data — поля формы {client_id, program_id, term_months,
   *   contract_number, start_date, amount, currency}
   * @param {object} context — { bankDate: 'YYYY-MM-DD', terms: [{program_id, term_months}] }
   * @returns {object} errors: { field: message, ... }
   */
  function validateCreditContract(data, context) {
    const errors = {};
    const ctx = context || {};

    if (!Number.isInteger(Number(data.client_id)) || Number(data.client_id) <= 0) {
      errors.client_id = 'Выберите клиента';
    }

    if (!Number.isInteger(Number(data.program_id)) || Number(data.program_id) <= 0) {
      errors.program_id = 'Выберите кредитную программу';
    }

    if (!Number.isInteger(Number(data.term_months)) || Number(data.term_months) <= 0) {
      errors.term_months = 'Укажите срок кредита (в месяцах)';
    }

    if (isEmpty(data.contract_number)) {
      errors.contract_number = 'Поле «Номер договора» обязательно';
    } else if (String(data.contract_number).trim().length > 50) {
      errors.contract_number = 'Номер договора: не более 50 символов';
    }

    const amountStr = String(data.amount === undefined || data.amount === null ? '' : data.amount).trim();
    const amountValue = Number(amountStr);
    if (amountStr === '') {
      errors.amount = 'Поле «Сумма кредита» обязательно';
    } else if (!INCOME_REGEX.test(amountStr)) {
      errors.amount = 'Сумма кредита: число с не более чем 2 знаками после запятой';
    } else if (amountValue <= 0) {
      errors.amount = 'Сумма кредита должна быть больше нуля';
    } else if (amountValue > 999999999999.99) {
      errors.amount = 'Сумма кредита превышает допустимый лимит';
    }

    const dateMsg = validateDate(data.start_date, 'Дата заключения договора', { noFutureCheck: true });
    if (dateMsg) {
      errors.start_date = dateMsg;
    } else if (ctx.bankDate && String(data.start_date) > String(ctx.bankDate)) {
      errors.start_date = 'Дата заключения не может быть позже текущей банковской даты';
    }

    if (!isEmpty(data.currency) && String(data.currency).toUpperCase() !== 'BYN') {
      errors.currency = 'Валюта договора должна быть BYN';
    }

    // Проверка срока относительно выбранной кредитной программы
    const terms = (ctx.terms || []).filter((t) => Number(t.program_id) === Number(data.program_id));
    if (terms.length > 0 && !terms.some((t) => Number(t.term_months) === Number(data.term_months))) {
      errors.term_months = 'Для выбранной программы недоступен указанный срок';
    }

    return errors;
  }

  global.Validators = {
    validateClient: validateClient,
    validateContract: validateContract,
    validateCreditContract: validateCreditContract,
    validateDate: validateDate,
    validateName: validateName,
    validatePhone: validatePhone,
    validateIdentificationNumber: validateIdentificationNumber,
    validateEmail: validateEmail,
  };
})(window);