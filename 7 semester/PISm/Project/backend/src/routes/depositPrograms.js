'use strict';

const { Router } = require('express');
const pool = require('../config/db');

const router = Router();

/** GET /api/deposit-programs — депозитные программы со сроками и ставками */
router.get('/', async (req, res, next) => {
  try {
    const { rows: programs } = await pool.query(
      'SELECT id, name, deposit_type, interest_payment, description FROM deposit_programs ORDER BY id'
    );
    const { rows: terms } = await pool.query(
      'SELECT program_id, term_months, annual_rate FROM deposit_program_terms ORDER BY program_id, term_months'
    );

    const programsWithTerms = programs.map((program) => ({
      id: program.id,
      name: program.name,
      deposit_type: program.deposit_type,
      interest_payment: program.interest_payment,
      description: program.description,
      terms: terms
        .filter((term) => term.program_id === program.id)
        .map((term) => ({
          term_months: term.term_months,
          annual_rate: Number(term.annual_rate),
        })),
    }));

    res.json(programsWithTerms);
  } catch (err) {
    next(err);
  }
});

module.exports = router;