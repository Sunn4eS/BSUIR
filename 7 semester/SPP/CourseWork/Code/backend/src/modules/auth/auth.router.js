const { Router } = require('express');
const authController = require('./auth.controller');
const { authenticate } = require('../../middleware/authenticate');

const router = Router();

router.post('/register', authController.register.bind(authController));
router.post('/login',    authController.login.bind(authController));
router.get('/me',        authenticate, authController.getMe.bind(authController));

module.exports = router;
