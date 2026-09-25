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

app.use((req, res) => {
  res.status(404).json({ message: 'Маршрут не найден' });
});

// Централизованный обработчик ошибок
app.use((err, req, res, next) => {
  console.error(err);
  res.status(500).json({ message: 'Внутренняя ошибка сервера' });
});

const PORT = Number(process.env.PORT || 3000);

app.listen(PORT, () => {
  console.log(`Банк «Дабрабыт»: backend запущен на порту ${PORT}`);
});