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
    /** Досрочное закрытие отзывного депозита: возвращает { contract, log } */
    closeDepositEarly(id) {
      return request('/contracts/' + id + '/close-early', { method: 'POST' });
    },
    /** Удаление депозитного договора вместе со счетами и проводками (Admin-режим) */
    deleteContract(id) {
      return request('/contracts/' + id, { method: 'DELETE' });
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
    /**
     * Полный сброс банковских данных (Admin-режим): удаляются договоры, кредиты,
     * карты, операции банкомата, проводки и клиентские счета; клиенты,
     * справочники и программы сохраняются.
     */
    resetBank() {
      return request('/bank/reset', { method: 'POST', body: JSON.stringify({}) });
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
    /**
     * Удаление кредитного договора вместе с картой, счетами, операциями
     * банкомата и проводками (Admin-режим).
     */
    deleteCreditContract(id) {
      return request('/credit-contracts/' + id, { method: 'DELETE' });
    },

    // --- Модуль 4 «Эмулятор банкомата (ATM)» ---
    getAtmCards() {
      return request('/atm/cards');
    },
    atmCardCheck(body) {
      return request('/atm/card-check', { method: 'POST', body: JSON.stringify(body) });
    },
    atmAuthorize(body) {
      return request('/atm/authorize', { method: 'POST', body: JSON.stringify(body) });
    },
    atmBalance(body) {
      return request('/atm/balance', { method: 'POST', body: JSON.stringify(body) });
    },
    atmWithdraw(body) {
      return request('/atm/withdraw', { method: 'POST', body: JSON.stringify(body) });
    },
    atmPayment(body) {
      return request('/atm/payment', { method: 'POST', body: JSON.stringify(body) });
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

  /**
   * Денежная сумма с указанием валюты: «1 500.00 USD», «4 800.00 BYN».
   * Используется в оборотной ведомости и журнале проводок, где у каждой
   * суммы своя валюта (клиентские счета — валюта договора, системные — BYN).
   */
  function formatMoneyWithCurrency(value, currency) {
    return `${formatMoney(value)} ${currency || 'BYN'}`;
  }

  // ==========================================================================
  // Роль администратора
  // ==========================================================================
  // В программе нет серверной авторизации, поэтому роль администратора
  // реализована скрытым переключателем: элементы с классом admin-only скрыты
  // и показываются, только когда на <body> выставлен класс admin-mode.
  // Включается двумя способами:
  //   * Ctrl+Shift+A — работает на всей странице;
  //   * тройной клик по заголовку любой таблицы, в которой есть admin-only.
  const ADMIN_CONFIRM_WORD = 'УДАЛИТЬ';

  /** Включён ли сейчас режим администратора. */
  function isAdminMode() {
    return document.body.classList.contains('admin-mode');
  }

  /** Включает/выключает режим администратора (показ кнопок удаления и сброса). */
  function toggleAdminMode() {
    const enabled = document.body.classList.toggle('admin-mode');
    showToast(
      enabled ? 'Режим администратора включён' : 'Режим администратора выключен',
      enabled ? 'success' : 'info'
    );
  }

  /** Быстрый тройной клик по элементу как альтернатива Ctrl+Shift+A. */
  function setupTripleClick(element) {
    if (!element) return;
    let clickCount = 0;
    let resetTimer = null;
    element.addEventListener('click', () => {
      clickCount += 1;
      clearTimeout(resetTimer);
      resetTimer = setTimeout(() => { clickCount = 0; }, 600);
      if (clickCount >= 3) {
        clickCount = 0;
        toggleAdminMode();
      }
    });
  }

  /**
   * Инициализация режима администратора: горячие клавиши + тройной клик по
   * заголовкам таблиц.
   *
   * Тройной клик вешаем на все заголовки таблиц без разбора: к моменту
   * запуска тело таблиц ещё пусто, поэтому искать там admin-only ячейки
   * бесполезно — они рендерятся позже.
   *
   * Горячих клавиш две, потому что Ctrl+Shift на Windows — системное
   * переключение раскладки клавиатуры, и сочетание Ctrl+Shift+A до страницы
   * часто не доходит. Ctrl+Alt+A от переключения раскладки не задет.
   */
  function initAdminMode() {
    document.addEventListener('keydown', (event) => {
      const isLetterA = event.key === 'a' || event.key === 'A'
        || event.key === 'а' || event.key === 'А';
      if (event.ctrlKey && isLetterA && (event.shiftKey || event.altKey)) {
        event.preventDefault();
        toggleAdminMode();
      }
    });

    document.querySelectorAll('table thead').forEach(setupTripleClick);
  }

  // ==========================================================================
  // Общие справочники предметной области
  // ==========================================================================
  // Курсы к банковской валюте BYN. Дублируются на сервере в
  // backend/src/config/currency.js — при изменении курса править оба места.
  const CURRENCY_RATES = {
    BYN: 1.0,
    USD: 3.2,
    EUR: 3.5,
    RUB: 0.035,
  };

  /**
   * Прибавляет к календарной дате N месяцев по правилам Postgres
   * (`date + interval 'N months'`): если в целевом месяце нет такого дня,
   * дата схлопывается на последний день месяца.
   * Здесь используется UTC, чтобы не зависеть от часового пояса браузера.
   */
  function addMonths(startIso, months) {
    const [year, month, day] = startIso.split('-').map(Number);
    // Последний день целевого месяца: месяц с индексом (month - 1 + months + 1) и днём 0
    const lastDay = new Date(Date.UTC(year, month - 1 + months + 1, 0)).getUTCDate();
    const target = new Date(Date.UTC(year, month - 1 + months, Math.min(day, lastDay)));
    const pad = (n) => String(n).padStart(2, '0');
    return `${target.getUTCFullYear()}-${pad(target.getUTCMonth() + 1)}-${pad(target.getUTCDate())}`;
  }

  // Включаем режим администратора сразу при загрузке страницы, а не из
  // bindEvents() конкретного модуля: bindEvents() не обёрнут в try/catch,
  // и любая ошибка в модуле молча отключала бы админ-функции целиком.
  document.addEventListener('DOMContentLoaded', initAdminMode);

  global.Common = {
    api, request, showToast, escapeHtml, formatDate, formatMoney, formatMoneyWithCurrency,
    initAdminMode, isAdminMode, toggleAdminMode, setupTripleClick, ADMIN_CONFIRM_WORD,
    CURRENCY_RATES, addMonths,
  };
})(window);