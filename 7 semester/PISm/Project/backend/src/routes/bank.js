'use strict';

const { Router } = require('express');
const bankController = require('../controllers/bankController');

const router = Router();

router.get('/', bankController.getBankState);
router.post('/set-date', bankController.setBankDate);
router.post('/close-month', bankController.closeMonth);

module.exports = router;