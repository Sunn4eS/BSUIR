'use strict';

const { Router } = require('express');
const creditController = require('../controllers/creditController');
const validateCreditContract = require('../middlewares/validateCreditContract');

const router = Router();

router.get('/', creditController.listCreditContracts);
router.post('/', validateCreditContract, creditController.createCreditContract);

module.exports = router;