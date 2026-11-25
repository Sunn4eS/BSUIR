const jwt = require('jsonwebtoken');

const JWT_SECRET  = process.env.JWT_SECRET  || 'dev_secret_change_in_prod';
const JWT_EXPIRES = process.env.JWT_EXPIRES_IN || '7d';

function generateToken(payload) {
  const role = String(payload.role ?? '').trim().toUpperCase();

  if (!['TEACHER', 'STUDENT'].includes(role)) {
    throw new Error('JWT payload должен содержать корректную роль (TEACHER/STUDENT)');
  }

  return jwt.sign(
    { ...payload, role },
    JWT_SECRET,
    { expiresIn: JWT_EXPIRES }
  );
}

function verifyToken(token) {
  return jwt.verify(token, JWT_SECRET);
}

module.exports = { generateToken, verifyToken };
