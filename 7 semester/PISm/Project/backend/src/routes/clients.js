'use strict';

const { Router } = require('express');
const clientController = require('../controllers/clientController');
const validateClient = require('../middlewares/validateClient');

const router = Router();

router.get('/', clientController.listClients);
router.get('/:id', clientController.getClient);
router.post('/', validateClient, clientController.createClient);
router.put('/:id', validateClient, clientController.updateClient);
router.delete('/:id', clientController.deleteClient);

module.exports = router;