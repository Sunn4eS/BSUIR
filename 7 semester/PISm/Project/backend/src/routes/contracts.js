'use strict';

const { Router } = require('express');
const contractController = require('../controllers/contractController');
const validateContract = require('../middlewares/validateContract');

const router = Router();

router.get('/', contractController.listContracts);
router.post('/', validateContract, contractController.createContract);
router.post('/:id/close-early', contractController.closeContractEarly);
router.delete('/:id', contractController.deleteContract);

module.exports = router;