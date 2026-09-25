'use strict';

const { Router } = require('express');
const pool = require('../config/db');

const router = Router();

/** GET /api/dictionaries — все справочники одним запросом */
router.get('/', async (req, res, next) => {
  try {
    const [cities, maritalStatuses, citizenships, disabilityGroups] = await Promise.all([
      pool.query('SELECT id, name FROM cities ORDER BY id'),
      pool.query('SELECT id, name FROM marital_statuses ORDER BY id'),
      pool.query('SELECT id, name FROM citizenships ORDER BY id'),
      pool.query('SELECT id, name FROM disability_groups ORDER BY id'),
    ]);

    res.json({
      cities: cities.rows,
      marital_statuses: maritalStatuses.rows,
      citizenships: citizenships.rows,
      disability_groups: disabilityGroups.rows,
    });
  } catch (err) {
    next(err);
  }
});

module.exports = router;