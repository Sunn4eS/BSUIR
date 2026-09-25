'use strict';

const { Router } = require('express');
const atmController = require('../controllers/atmController');

const router = Router();

router.get('/cards', atmController.listCards);
router.post('/card-check', atmController.cardCheck);
router.post('/authorize', atmController.authorize);
router.post('/balance', atmController.balance);
router.post('/withdraw', atmController.withdraw);
router.post('/payment', atmController.payment);

module.exports = router;