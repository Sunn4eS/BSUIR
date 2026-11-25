const express = require('express');
const cors = require('cors');

const { errorHandler } = require('./middleware/errorHandler');
const authRouter    = require('./modules/auth/auth.router');
const usersRouter   = require('./modules/users/users.router');
const coursesRouter = require('./modules/courses/courses.router');
const tasksRouter   = require('./modules/tasks/tasks.router');

const app = express();

app.use(cors({
  origin: process.env.FRONTEND_URL || 'http://localhost:5173',
  credentials: true,
  methods: ['GET', 'POST', 'PUT', 'PATCH', 'DELETE', 'OPTIONS'],
  allowedHeaders: ['Content-Type', 'Authorization'],
}));

app.use(express.json({ limit: '10mb' }));
app.use(express.urlencoded({ extended: true }));

if (process.env.NODE_ENV === 'development') {
  app.use((req, _res, next) => {
    console.log(`[${new Date().toISOString()}] ${req.method} ${req.path}`);
    next();
  });
}

app.get('/api/health', (_req, res) => {
  res.json({
    status: 'ok',
    service: 'guitar-trainer-backend',
    timestamp: new Date().toISOString(),
  });
});

app.use('/api/auth',    authRouter);
app.use('/api/users',   usersRouter);
app.use('/api/courses', coursesRouter);
app.use('/api/tasks',   tasksRouter);

app.use((_req, res) => {
  res.status(404).json({ error: 'Маршрут не найден' });
});

app.use(errorHandler);

module.exports = app;
