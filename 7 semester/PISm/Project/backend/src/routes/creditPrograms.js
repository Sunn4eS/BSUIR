'use strict';

const { Router } = require('express');
const pool = require('../config/db');

const router = Router();

/** GET /api/credit-programs — кредитные программы со сроками и ставками */
router.get('/', async (req, res, next) => {
  try {
    const { rows: programs } = await pool.query(
      'SELECT id, name, repayment_type, description FROM credit_programs ORDER BY id'
    );
    const { rows: terms } = await pool.query(
      'SELECT program_id, term_months, annual_rate FROM credit_program_terms ORDER BY program_id, term_months'
    );

    const programsWithTerms = programs.map((program) => ({
      id: program.id,
      name: program.name,
      repayment_type: program.repayment_type,
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