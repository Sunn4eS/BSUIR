'use strict';

const { Router } = require('express');
const contractController = require('../controllers/contractController');
const validateContract = require('../middlewares/validateContract');

const router = Router();

router.get('/', contractController.listContracts);
router.post('/', validateContract, contractController.createContract);

module.exports = router;