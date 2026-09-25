'use strict';

const express = require('express');
const cors = require('cors');

const clientsRouter = require('./routes/clients');
const dictionariesRouter = require('./routes/dictionaries');
const contractsRouter = require('./routes/contracts');
const accountsRouter = require('./routes/accounts');
const bankRouter = require('./routes/bank');
const depositProgramsRouter = require('./routes/depositPrograms');
const creditProgramsRouter = require('./routes/creditPrograms');
const creditContractsRouter = require('./routes/creditContracts');
const atmRouter = require('./routes/atm');

const app = express();

app.use(cors());
app.use(express.json());

app.get('/api/health', (req, res) => {
  res.json({ status: 'ok' });
});

app.use('/api/clients', clientsRouter);
app.use('/api/dictionaries', dictionariesRouter);
app.use('/api/contracts', contractsRouter);
app.use('/api/accounts', accountsRouter);
app.use('/api/bank', bankRouter);
app.use('/api/deposit-programs', depositProgramsRouter);
app.use('/api/credit-programs', creditProgramsRouter);
app.use('/api/credit-contracts', creditContractsRouter);
app.use('/api/atm', atmRouter);

app.use((req, res) => {
  res.status(404).json({ message: 'Маршрут не найден' });
});

// Централизованный обработчик ошибок (уважает err.status для бизнес-ошибок)
app.use((err, req, res, next) => {
  const status = err.status && err.status >= 400 && err.status < 500 ? err.status : 500;
  if (status >= 500) console.error(err);
  res.status(status).json({ message: err.message || 'Внутренняя ошибка сервера' });
});

const PORT = Number(process.env.PORT || 3000);

app.listen(PORT, () => {
  console.log(`Банк «Дабрабыт»: backend запущен на порту ${PORT}`);
});