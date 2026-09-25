'use strict';

/**
 * Middleware валидации клиента (дублирует валидацию на фронтенде).
 * Нормализует тело запроса, проверяет обязательность, форматы масок,
 * корректность календарных дат. В случае ошибок отвечает 400 с объектом errors.
 */

const NAME_REGEX = /^[A-Za-zА-Яа-яЁё]+(?:[\s-][A-Za-zА-Яа-яЁё]+)*$/;
const PHONE_REGEX = /^\+375 \(\d{2}\) \d{3}-\d{2}-\d{2}$/;
const IDENTIFICATION_REGEX = /^\d{7}[A-Z]\d{3}[A-Z]{2}\d$/;
const PASSPORT_SERIES_REGEX = /^[A-Z]{2}$/;
const PASSPORT_NUMBER_REGEX = /^\d{7}$/;
const EMAIL_REGEX = /^[^\s@]+@[^\s@]+\.[^\s@]+$/;
const DATE_REGEX = /^\d{4}-\d{2}-\d{2}$/;
const INCOME_REGEX = /^\d+(\.\d{1,2})?$/;

const REQUIRED_TEXT_FIELDS = {
  last_name: 'Фамилия',
  first_name: 'Имя',
  middle_name: 'Отчество',
  issued_by: 'Кем выдан',
  birth_place: 'Место рождения',
  actual_address: 'Адрес фактического проживания',
};

const REQUIRED_SELECT_FIELDS = {
  city_id: 'Город фактического проживания',
  marital_status_id: 'Семейное положение',
  citizenship_id: 'Гражданство',
  disability_group_id: 'Инвалидность',
};

function isEmpty(value) {
  return value === undefined || value === null || String(value).trim() === '';
}

/** Проверка реальной календарной даты (блокирует 31.02, 29.02 в невисокосный год и т.п.) */
function isRealCalendarDate(year, month, day) {
  if (month < 1 || month > 12 || day < 1 || day > 31) return false;
  const date = new Date(Date.UTC(year, month - 1, day));
  return (
    date.getUTCFullYear() === year &&
    date.getUTCMonth() === month - 1 &&
    date.getUTCDate() === day
  );
}

/** Дата в формате YYYY-MM-DD, реальная и не из будущего */
function isValidIsoDateNotInFuture(value) {
  if (typeof value !== 'string' || !DATE_REGEX.test(value)) return false;
  const [year, month, day] = value.split('-').map(Number);
  if (!isRealCalendarDate(year, month, day)) return false;
  return Date.UTC(year, month - 1, day) <= Date.now();
}

/** Приведение входных данных к единому виду */
function normalize(body) {
  const out = {};

  const textFields = [
    'last_name', 'first_name', 'middle_name',
    'passport_series', 'passport_number', 'issued_by',
    'identification_number', 'birth_place', 'actual_address',
    'home_phone', 'mobile_phone', 'email', 'work_place', 'position',
  ];
  textFields.forEach((field) => {
    out[field] = isEmpty(body[field]) ? '' : String(body[field]).trim();
  });

  out.passport_series = out.passport_series.toUpperCase();
  out.identification_number = out.identification_number.toUpperCase();

  Object.keys(REQUIRED_SELECT_FIELDS).forEach((field) => {
    const raw = body[field];
    out[field] = (raw === undefined || raw === null || raw === '') ? null : Number(raw);
  });

  out.birth_date = isEmpty(body.birth_date) ? '' : String(body.birth_date).trim();
  out.issue_date = isEmpty(body.issue_date) ? '' : String(body.issue_date).trim();

  out.is_pensioner = body.is_pensioner;
  out.is_military_obligated = body.is_military_obligated;

  out.monthly_income = isEmpty(body.monthly_income) ? null : String(body.monthly_income).trim();

  return out;
}

function validateClient(req, res, next) {
  const data = normalize(req.body);
  const errors = {};

  // Обязательные текстовые поля
  Object.entries(REQUIRED_TEXT_FIELDS).forEach(([field, label]) => {
    if (isEmpty(data[field])) {
      errors[field] = `Поле «${label}» обязательно`;
    } else if (
      (field === 'last_name' || field === 'first_name' || field === 'middle_name') &&
      !NAME_REGEX.test(data[field])
    ) {
      errors[field] = `${label}: допустимы только буквы, дефисы и пробелы (без цифр)`;
    }
  });

  // Паспорт: серия и номер
  if (isEmpty(data.passport_series)) {
    errors.passport_series = 'Поле «Серия паспорта» обязательно';
  } else if (!PASSPORT_SERIES_REGEX.test(data.passport_series)) {
    errors.passport_series = 'Серия паспорта: две латинские буквы';
  }

  if (isEmpty(data.passport_number)) {
    errors.passport_number = 'Поле «Номер паспорта» обязательно';
  } else if (!PASSPORT_NUMBER_REGEX.test(data.passport_number)) {
    errors.passport_number = 'Номер паспорта: ровно 7 цифр';
  }

  // Идентификационный номер (маска: 7 цифр + 1 буква + 3 цифры + 2 буквы + 1 цифра)
  if (isEmpty(data.identification_number)) {
    errors.identification_number = 'Поле «Идентификационный номер» обязательно';
  } else if (!IDENTIFICATION_REGEX.test(data.identification_number)) {
    errors.identification_number = 'Идентификационный номер: формат 7 цифр + 1 буква + 3 цифры + 2 буквы + 1 цифра (например, 1234567A123PB1)';
  }

  // Календарные даты
  if (isEmpty(data.birth_date)) {
    errors.birth_date = 'Поле «Дата рождения» обязательно';
  } else if (!isValidIsoDateNotInFuture(data.birth_date)) {
    errors.birth_date = 'Дата рождения некорректна, не существует или относится к будущему';
  }

  if (isEmpty(data.issue_date)) {
    errors.issue_date = 'Поле «Дата выдачи» обязательно';
  } else if (!isValidIsoDateNotInFuture(data.issue_date)) {
    errors.issue_date = 'Дата выдачи некорректна, не существует или относится к будущему';
  }

  // Обязательные поля-справочники
  Object.entries(REQUIRED_SELECT_FIELDS).forEach(([field, label]) => {
    if (!Number.isInteger(data[field]) || data[field] <= 0) {
      errors[field] = `Выберите значение «${label}»`;
    }
  });

  // Обязательные булевы поля
  if (typeof data.is_pensioner !== 'boolean') {
    errors.is_pensioner = 'Укажите значение «Пенсионер»';
  }
  if (typeof data.is_military_obligated !== 'boolean') {
    errors.is_military_obligated = 'Укажите значение «Военнообязанный»';
  }

  // Необязательные поля (если заполнены — проверяем формат)
  if (!isEmpty(data.home_phone) && !PHONE_REGEX.test(data.home_phone)) {
    errors.home_phone = 'Телефон: формат +375 (XX) XXX-XX-XX';
  }
  if (!isEmpty(data.mobile_phone) && !PHONE_REGEX.test(data.mobile_phone)) {
    errors.mobile_phone = 'Телефон: формат +375 (XX) XXX-XX-XX';
  }
  if (!isEmpty(data.email) && !EMAIL_REGEX.test(data.email)) {
    errors.email = 'Некорректный адрес электронной почты';
  }
  if (data.monthly_income !== null) {
    if (!INCOME_REGEX.test(data.monthly_income) || Number(data.monthly_income) > 999999999999.99) {
      errors.monthly_income = 'Ежемесячный доход: неотрицательное число с не более чем 2 знаками после запятой';
    }
  }

  if (Object.keys(errors).length > 0) {
    return res.status(400).json({
      message: 'Ошибка валидации данных',
      errors,
    });
  }

  req.body = data;
  return next();
}

module.exports = validateClient;