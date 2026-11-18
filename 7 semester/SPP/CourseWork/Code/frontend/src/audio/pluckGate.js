/**
 * audio/pluckGate.js — гейт атаки щипка струны
 *
 * Задача: отличить щипок струны от фонового шума и голоса.
 *
 * Алгоритм:
 *  1. Отслеживаем RMS двумя экспоненциальными скользящими средними (EMA):
 *     «быстрое» ловит атаку щипка, «медленное» запоминает уровень фона.
 *  2. Порог открытия = фон + gateDb (по умолчанию +6 дБ) — щипок резко
 *     громче окружения, речь и гул — нет.
 *  3. Гистерезис с hold: гейт закрывается, только если сигнал ниже
 *     шумового пола дольше holdMs (~150 мс). Кратковременные провалы
 *     амплитуды (биения гармоник) не закрывают гейт, и затухающая
 *     струна продолжает считаться валидным сигналом.
 *  4. Пока гейт закрыт, данные детектору высоты не нужны — это защита
 *     от ложных срабатываний на речь.
 */

/**
 * @param {object} options
 * @param {number} options.attackSeconds   — постоянная быстрого EMA (0.02 с)
 * @param {number} options.noiseSeconds    — постоянная шумового EMA (1.5 с)
 * @param {number} options.gateDb          — превышение над фоном для открытия (6 дБ)
 * @param {number} options.holdMs          — сколько сигнала ниже фона терпим (150 мс)
 * @param {number} options.minNoiseRms     — минимальный шумовой пол
 * @param {number} options.maxNoiseRms      — максимальный шумовой пол
 */
export function createPluckGate(options = {}) {
  const {
    attackSeconds = 0.02,
    noiseSeconds = 1.5,
    gateDb = 6,
    holdMs = 150,
    minNoiseRms = 0.002,
    maxNoiseRms = 0.1,
  } = options;

  // Коэффициенты EMA пересчитываются под реальный интервал кадров
  let attackAlpha = 0.3;
  let noiseAlpha = 0.02;

  let fastRms = 0;
  let noiseRms = minNoiseRms;
  let isOpen = false;
  let lastLoudAt = -Infinity;
  let lastOnsetAt = -Infinity;
  let lastFrameAt = -Infinity;
  let onsetCount = 0;

  /** Порог открытия: фон + gateDb */
  function openThreshold() {
    const boosted = noiseRms * Math.pow(10, gateDb / 20);
    return Math.min(Math.max(boosted, minNoiseRms * 4), maxNoiseRms);
  }

  /**
   * Пропускает очередной кадр через гейт.
   *
   * @param {number} rms      — RMS текущего кадра
   * @param {number} [nowMs]  — метка времени; по умолчанию Date.now()
   * @returns {{
   *   isOpen: boolean, isOnset: boolean, rms: number,
   *   fastRms: number, noiseRms: number,
   *   openThreshold: number, lastOnsetAt: number,
   * }}
   */
  function push(rms, nowMs = Date.now()) {
    const dt = lastFrameAt === -Infinity ? 0.05 : Math.max(0, (nowMs - lastFrameAt) / 1000);
    lastFrameAt = nowMs;

    if (dt > 0) {
      attackAlpha = 1 - Math.exp(-dt / attackSeconds);
      noiseAlpha = 1 - Math.exp(-dt / noiseSeconds);
    }

    fastRms = fastRms + attackAlpha * (rms - fastRms);

    // Шумовое EMA: растёт быстрее, чем падает — щипок не должен
    // мгновенно поднять «пол» и запереть гейт.
    if (rms > noiseRms) {
      noiseRms = Math.min(noiseRms + noiseAlpha * (rms - noiseRms), maxNoiseRms);
    } else {
      noiseRms = Math.max(noiseRms * 0.99, minNoiseRms);
    }

    const threshold = openThreshold();

    // Сигнал не тише фона — запоминаем момент «громкости»
    if (fastRms >= noiseRms) {
      lastLoudAt = nowMs;
    }

    const isOnset = !isOpen && fastRms >= threshold;
    if (isOnset) {
      isOpen = true;
      lastOnsetAt = nowMs;
      onsetCount += 1;
    } else if (isOpen && nowMs - lastLoudAt > holdMs) {
      // Сигнал ниже шумового пола дольше holdMs — закрываем
      isOpen = false;
    }

    return { isOpen, isOnset, rms, fastRms, noiseRms, openThreshold: threshold, lastOnsetAt };
  }

  /** Принудительно закрыть гейт и обнулить фон (при смене задания) */
  function reset() {
    fastRms = 0;
    noiseRms = minNoiseRms;
    isOpen = false;
    lastLoudAt = -Infinity;
    lastOnsetAt = -Infinity;
    lastFrameAt = -Infinity;
    onsetCount = 0;
  }

  function getState() {
    return {
      isOpen,
      fastRms,
      noiseRms,
      openThreshold: openThreshold(),
      lastOnsetAt,
      onsetCount,
    };
  }

  return { push, reset, getState };
}
