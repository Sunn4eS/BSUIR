/**
 * Общие утилиты SPA: API-клиент, уведомления (тосты), форматирование.
 * Используется модулями «Клиенты» (app.js) и «Депозитные операции» (deposits.js).
 */
(function (global) {
  'use strict';

  const API_BASE = '/api';

  async function request(path, options) {
    let res;
    try {
      res = await fetch(API_BASE + path, Object.assign({}, options, {
        headers: { 'Content-Type': 'application/json' },
      }));
    } catch (networkError) {
      const err = new Error('Сервер недоступен. Проверьте соединение и повторите попытку.');
      err.cause = { status: 0, data: null };
      throw err;
    }

    let data = null;
    try {
      data = await res.json();
    } catch (parseError) {
      // Пустое тело ответа
    }

    if (!res.ok) {
      const err = new Error((data && data.message) || `Ошибка при выполнении запроса (${res.status})`);
      err.cause = { status: res.status, data: data };
      throw err;
    }
    return data;
  }

  const api = {
    // --- Модуль «Клиенты» (ЛР1) ---
    getClients() {
      return request('/clients');
    },
    createClient(body) {
      return request('/clients', { method: 'POST', body: JSON.stringify(body) });
    },
    updateClient(id, body) {
      return request('/clients/' + id, { method: 'PUT', body: JSON.stringify(body) });
    },
    deleteClient(id) {
      return request('/clients/' + id, { method: 'DELETE' });
    },
    getDictionaries() {
      return request('/dictionaries');
    },

    // --- Модуль «Депозитные операции» (ЛР1, Модуль 2) ---
    getDepositPrograms() {
      return request('/deposit-programs');
    },
    getContracts() {
      return request('/contracts');
    },
    createContract(body) {
      return request('/contracts', { method: 'POST', body: JSON.stringify(body) });
    },
    getAccounts() {
      return request('/accounts');
    },
    getBankState() {
      return request('/bank');
    },
    closeMonth() {
      return request('/bank/close-month', { method: 'POST', body: JSON.stringify({}) });
    },
    /** Установить банковскую дату: { year, month } — всегда первое число месяца */
    setBankDate(body) {
      return request('/bank/set-date', { method: 'POST', body: JSON.stringify(body) });
    },

    // --- Модуль 3 «Кредитные операции с физическими лицами» ---
    getCreditPrograms() {
      return request('/credit-programs');
    },
    getCreditContracts() {
      return request('/credit-contracts');
    },
    createCreditContract(body) {
      return request('/credit-contracts', { method: 'POST', body: JSON.stringify(body) });
    },
  };

  /** Уведомление-тост. Контейнер #toast-container создаётся при необходимости. */
  function showToast(message, type) {
    let container = document.getElementById('toast-container');
    if (!container) {
      container = document.createElement('div');
      container.id = 'toast-container';
      document.body.appendChild(container);
    }
    const toast = document.createElement('div');
    toast.className = 'toast ' + (type || 'info');
    toast.textContent = message;
    container.appendChild(toast);

    setTimeout(() => {
      toast.classList.add('fade-out');
      setTimeout(() => toast.remove(), 300);
    }, 4500);
  }

  function escapeHtml(value) {
    return String(value)
      .replace(/&/g, '&amp;')
      .replace(/</g, '&lt;')
      .replace(/>/g, '&gt;')
      .replace(/"/g, '&quot;')
      .replace(/'/g, '&#039;');
  }

  /** YYYY-MM-DD -> DD.MM.YYYY */
  function formatDate(isoDate) {
    if (!isoDate) return '—';
    const match = /^(\d{4})-(\d{2})-(\d{2})$/.exec(isoDate);
    if (!match) return isoDate;
    return `${match[3]}.${match[2]}.${match[1]}`;
  }

  /** Число -> «1 000.00» — 2 знака после запятой, пробел-разделитель тысяч (как в методичке) */
  function formatMoney(value) {
    const num = Number(value);
    if (Number.isNaN(num)) return '0.00';
    return num.toFixed(2).replace(/\B(?=(\d{3})+(?!\d))/g, ' ');
  }

  global.Common = { api, request, showToast, escapeHtml, formatDate, formatMoney };
})(window);