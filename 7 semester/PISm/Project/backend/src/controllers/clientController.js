'use strict';

const pool = require('../config/db');

const SELECT_WITH_JOINS = `
  SELECT
    c.id,
    c.last_name,
    c.first_name,
    c.middle_name,
    c.birth_date::text AS birth_date,
    c.passport_series,
    c.passport_number,
    c.issued_by,
    c.issue_date::text AS issue_date,
    c.identification_number,
    c.birth_place,
    c.city_id,
    ci.name AS city_name,
    c.actual_address,
    c.home_phone,
    c.mobile_phone,
    c.email,
    c.marital_status_id,
    ms.name AS marital_status_name,
    c.citizenship_id,
    ct.name AS citizenship_name,
    c.disability_group_id,
    dg.name AS disability_group_name,
    c.is_pensioner,
    c.monthly_income,
    c.work_place,
    c.position,
    c.is_military_obligated
  FROM clients c
  JOIN cities ci            ON ci.id = c.city_id
  JOIN marital_statuses ms  ON ms.id = c.marital_status_id
  JOIN citizenships ct      ON ct.id = c.citizenship_id
  JOIN disability_groups dg ON dg.id = c.disability_group_id
`;

const INSERT_SQL = `
  INSERT INTO clients (
    last_name, first_name, middle_name, birth_date,
    passport_series, passport_number, issued_by, issue_date,
    identification_number, birth_place, city_id, actual_address,
    home_phone, mobile_phone, email,
    marital_status_id, citizenship_id, disability_group_id,
    is_pensioner, monthly_income, work_place, position, is_military_obligated
  ) VALUES ($1, $2, $3, $4, $5, $6, $7, $8, $9, $10, $11, $12, $13, $14, $15, $16, $17, $18, $19, $20, $21, $22, $23)
  RETURNING id
`;

const UPDATE_SQL = `
  UPDATE clients SET
    last_name = $1,
    first_name = $2,
    middle_name = $3,
    birth_date = $4,
    passport_series = $5,
    passport_number = $6,
    issued_by = $7,
    issue_date = $8,
    identification_number = $9,
    birth_place = $10,
    city_id = $11,
    actual_address = $12,
    home_phone = $13,
    mobile_phone = $14,
    email = $15,
    marital_status_id = $16,
    citizenship_id = $17,
    disability_group_id = $18,
    is_pensioner = $19,
    monthly_income = $20,
    work_place = $21,
    position = $22,
    is_military_obligated = $23,
    updated_at = NOW()
  WHERE id = $24
`;

function nullIfEmpty(value) {
  return value === undefined || value === null || String(value).trim() === ''
    ? null
    : String(value).trim();
}

function mapClient(row) {
  return {
    id: row.id,
    last_name: row.last_name,
    first_name: row.first_name,
    middle_name: row.middle_name,
    birth_date: row.birth_date,
    passport_series: row.passport_series,
    passport_number: row.passport_number,
    issued_by: row.issued_by,
    issue_date: row.issue_date,
    identification_number: row.identification_number,
    birth_place: row.birth_place,
    city_id: row.city_id,
    city_name: row.city_name,
    actual_address: row.actual_address,
    home_phone: row.home_phone,
    mobile_phone: row.mobile_phone,
    email: row.email,
    marital_status_id: row.marital_status_id,
    marital_status_name: row.marital_status_name,
    citizenship_id: row.citizenship_id,
    citizenship_name: row.citizenship_name,
    disability_group_id: row.disability_group_id,
    disability_group_name: row.disability_group_name,
    is_pensioner: row.is_pensioner,
    monthly_income: row.monthly_income === null ? null : Number(row.monthly_income),
    work_place: row.work_place,
    position: row.position,
    is_military_obligated: row.is_military_obligated,
  };
}

async function findById(id) {
  const { rows } = await pool.query(`${SELECT_WITH_JOINS} WHERE c.id = $1`, [id]);
  return rows.length > 0 ? mapClient(rows[0]) : null;
}

function buildInsertValues(b) {
  return [
    b.last_name, b.first_name, b.middle_name, b.birth_date,
    b.passport_series, b.passport_number, b.issued_by, b.issue_date,
    b.identification_number, b.birth_place, b.city_id, b.actual_address,
    nullIfEmpty(b.home_phone), nullIfEmpty(b.mobile_phone), nullIfEmpty(b.email),
    b.marital_status_id, b.citizenship_id, b.disability_group_id,
    b.is_pensioner, b.monthly_income === null ? null : Number(b.monthly_income),
    nullIfEmpty(b.work_place), nullIfEmpty(b.position),
    b.is_military_obligated,
  ];
}

function handleDbError(err, res, next) {
  if (err.code === '23505') {
    const messages = {
      clients_identification_number_key: 'Клиент с таким идентификационным номером уже существует',
      clients_passport_series_passport_number_key: 'Клиент с таким паспортом (серия и номер) уже существует',
      clients_full_name_birth_date_key: 'Клиент с такими ФИО и датой рождения уже существует',
    };
    return res.status(409).json({
      message: messages[err.constraint] || 'Нарушение уникальности данных',
    });
  }
  if (err.code === '23503') {
    return res.status(400).json({ message: 'Некорректное значение справочника (город, семейное положение, гражданство или инвалидность)' });
  }
  if (err.code === '22P02') {
    return res.status(400).json({ message: 'Некорректный формат переданных данных' });
  }
  return next(err);
}

/** GET /api/clients — список клиентов, сортировка по фамилии (А-Я) */
async function listClients(req, res, next) {
  try {
    const { rows } = await pool.query(
      `${SELECT_WITH_JOINS} ORDER BY c.last_name ASC, c.first_name ASC, c.middle_name ASC, c.birth_date ASC`
    );
    res.json(rows.map(mapClient));
  } catch (err) {
    next(err);
  }
}

/** GET /api/clients/:id — один клиент */
async function getClient(req, res, next) {
  try {
    const id = Number(req.params.id);
    if (!Number.isInteger(id) || id <= 0) {
      return res.status(400).json({ message: 'Некорректный идентификатор клиента' });
    }
    const client = await findById(id);
    if (!client) {
      return res.status(404).json({ message: 'Клиент не найден' });
    }
    res.json(client);
  } catch (err) {
    next(err);
  }
}

/** POST /api/clients — создание клиента */
async function createClient(req, res, next) {
  try {
    const { rows } = await pool.query(INSERT_SQL, buildInsertValues(req.body));
    const client = await findById(rows[0].id);
    res.status(201).json(client);
  } catch (err) {
    handleDbError(err, res, next);
  }
}

/** PUT /api/clients/:id — обновление клиента */
async function updateClient(req, res, next) {
  try {
    const id = Number(req.params.id);
    if (!Number.isInteger(id) || id <= 0) {
      return res.status(400).json({ message: 'Некорректный идентификатор клиента' });
    }
    const values = [...buildInsertValues(req.body), id];
    const result = await pool.query(UPDATE_SQL, values);
    if (result.rowCount === 0) {
      return res.status(404).json({ message: 'Клиент не найден' });
    }
    const client = await findById(id);
    res.json(client);
  } catch (err) {
    handleDbError(err, res, next);
  }
}

/** DELETE /api/clients/:id — удаление клиента */
async function deleteClient(req, res, next) {
  try {
    const id = Number(req.params.id);
    if (!Number.isInteger(id) || id <= 0) {
      return res.status(400).json({ message: 'Некорректный идентификатор клиента' });
    }

    // Защита: нельзя удалить клиента с открытыми (ACTIVE) депозитными
    // или кредитными договорами (Модули 2 и 3).
    const openRes = await pool.query(
      `SELECT 1 FROM clients c
        WHERE c.id = $1
          AND (
            EXISTS (SELECT 1 FROM deposit_contracts dc
                     WHERE dc.client_id = c.id AND dc.status = 'ACTIVE')
            OR EXISTS (SELECT 1 FROM credit_contracts cc
                        WHERE cc.client_id = c.id AND cc.status = 'ACTIVE')
          )
        LIMIT 1`,
      [id]
    );
    if (openRes.rows.length > 0) {
      return res.status(400).json({
        message: 'Нельзя удалить клиента с открытыми кредитными/депозитными обязательствами',
      });
    }

    const result = await pool.query('DELETE FROM clients WHERE id = $1', [id]);
    if (result.rowCount === 0) {
      return res.status(404).json({ message: 'Клиент не найден' });
    }
    res.json({ message: 'Клиент успешно удалён' });
  } catch (err) {
    next(err);
  }
}

module.exports = {
  listClients,
  getClient,
  createClient,
  updateClient,
  deleteClient,
};