'use strict';

const { generateCardNumber } = require('../utils/cardGenerator');

/**
 * Эмиссия банковской карты к кредитному договору (Модуль 4).
 * Выполняется внутри переданной транзакции (db — клиент из pool.connect()).
 * Номер карты: префикс 4916 + 11 случайных цифр + контрольная цифра Луна.
 * ПИН по умолчанию: '1234'. При коллизии номера (UNIQUE) номер перегенерируется.
 *
 * @param {object} db — клиент транзакции PostgreSQL
 * @param {number} contractId — id кредитного договора (credit_contracts)
 * @param {number} accountId — id активного кредитного счёта 2400 (bank_accounts)
 * @param {string} [pinCode='1234'] — ПИН-код по умолчанию
 * @returns {Promise<{id:number, card_number:string, pin_code:string, is_blocked:boolean}>}
 */
async function issueCard(db, contractId, accountId, pinCode = '1234') {
  for (let attempt = 0; attempt < 100; attempt += 1) {
    const cardNumber = generateCardNumber('4916');
    try {
      const { rows } = await db.query(
        `INSERT INTO credit_cards (contract_id, account_id, card_number, pin_code)
         VALUES ($1, $2, $3, $4)
         RETURNING id, card_number, pin_code, is_blocked`,
        [contractId, accountId, cardNumber, pinCode]
      );
      return rows[0];
    } catch (err) {
      // 23505 — unique_violation: номер карты уже существует, пробуем другой
      if (err.code === '23505') continue;
      throw err;
    }
  }
  throw new Error('Не удалось сгенерировать уникальный номер банковской карты');
}

module.exports = { issueCard };