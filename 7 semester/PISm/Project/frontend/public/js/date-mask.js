/**
 * Маска ввода календарной даты ДД.ММ.ГГГГ.
 *
 * Зачем нужен этот модуль (а не нативный <input type="date">):
 * нативный виджет браузера проверяет дату на КАЖДОМ нажатии клавиши. При ручном
 * наборе 29.02 браузер доходит до года по одному символу, и как только значение
 * года перестаёт быть високосным (например, на первом символе «2» получается
 * год 0002, а 02.29.0002 не существует), дата отбрасывается — набрать 29.02
 * вручную невозможно, хотя через календарь такая дата выбирается без проблем.
 *
 * Маска принимает любые цифры и ничего не блокирует: пользователь свободно
 * набирает «29.02.2000». Проверку реальности календарной даты (в том числе
 * 29.02 — только в високосные годы) выполняют Validators на клиенте при отправке
 * формы и middlewares/validateClient.js на сервере: двойная проверка, как
 * требуется в лабораторной работе.
 *
 * API:
 *   DateMask.mount(input, { label, noFutureCheck }) — включить маску на поле;
 *   DateMask.get(input)  -> 'YYYY-MM-DD' | ''     — ISO-значение поля;
 *   DateMask.set(input, isoDate)                  — заполнить поле из ISO-даты.
 */
(function (global) {
  'use strict';

  /** '29022000' -> '29.02.2000'; точки проставляются по мере набора цифр */
  function withSeparators(digits) {
    let text = digits.slice(0, 2);
    if (digits.length > 2) text += '.' + digits.slice(2, 4);
    if (digits.length > 4) text += '.' + digits.slice(4, 8);
    return text;
  }

  /**
   * ISO-значение поля ('2000-02-29'). Незавершённый набор ('29.02.200')
   * возвращается как есть — его отсеет Validators.validateDate понятным
   * сообщением, а не «поле обязательно».
   */
  function get(input) {
    const text = String(input.value || '').trim();
    const match = /^(\d{2})\.(\d{2})\.(\d{4})$/.exec(text);
    return match ? `${match[3]}-${match[2]}-${match[1]}` : text;
  }

  /** Заполнить поле из ISO-даты ('2000-02-29' -> '29.02.2000') */
  function set(input, isoDate) {
    const match = /^(\d{4})-(\d{2})-(\d{2})$/.exec(String(isoDate || '').trim());
    input.value = match ? `${match[3]}.${match[2]}.${match[1]}` : '';
  }

  /** Показать/снять подсветку и текст ошибки поля (разметка #error-<id>) */
  function showState(input, message) {
    const error = document.getElementById('error-' + input.id);
    if (error) error.textContent = message;
    input.classList.toggle('invalid', Boolean(message));
  }

  /**
   * Включает маску на текстовом поле даты.
   * @param {HTMLInputElement} input — поле с id, для которого есть #error-<id>
   * @param {object} [options] — { label: 'Дата рождения', noFutureCheck: true }
   */
  function mount(input, options) {
    const opts = options || {};

    input.setAttribute('inputmode', 'numeric');
    input.setAttribute('autocomplete', 'off');
    input.setAttribute('placeholder', 'ДД.ММ.ГГГГ');
    input.setAttribute('maxlength', '10');

    // Первичная проверка маски: оставляем только цифры и расставляем точки.
    // Никакой проверки «существует ли дата» здесь нет — она в Validators,
    // иначе 29.02 снова нельзя было бы набрать.
    input.addEventListener('input', function () {
      input.value = withSeparators(input.value.replace(/\D/g, '').slice(0, 8));
    });

    // Подсказка при потере фокуса: 29.02.2003 отвергается сразу, не дожидаясь
    // отправки формы. Пустое поле не трогаем — его проверит форма.
    input.addEventListener('blur', function () {
      if (input.value.trim() === '') return;
      const message = global.Validators
        ? global.Validators.validateDate(get(input), opts.label || 'Дата', {
            noFutureCheck: Boolean(opts.noFutureCheck),
          })
        : '';
      showState(input, message);
    });
  }

  global.DateMask = { mount: mount, get: get, set: set };
})(window);
