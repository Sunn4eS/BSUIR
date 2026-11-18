/**
 * audio/pitchDetector.js — определение основной частоты (YIN)
 *
 * Реализация упрощённого YIN:
 *  1. difference function
 *  2. cumulative mean normalized difference
 *  3. absolute threshold + parabolic interpolation
 *
 * Возвращает частоту и confidence (0..1), а не просто число.
 */

const DEFAULT_OPTIONS = {
  minFrequency: 70,
  maxFrequency: 1200,
  threshold: 0.12,
  silenceRms: 0.008,
};

/** RMS сигнала — используется как gate тишины */
export function getRms(buffer) {
  let sum = 0;
  for (let i = 0; i < buffer.length; i++) {
    sum += buffer[i] * buffer[i];
  }
  return Math.sqrt(sum / buffer.length);
}

/** RMS → dBFS (отрицательное число, -Infinity для тишины) */
export function rmsToDb(rms) {
  return rms > 0 ? 20 * Math.log10(rms) : -Infinity;
}

/** Параболическая интерполяция минимума YIN */
function parabolicInterpolation(buffer, tau) {
  const x0 = tau > 0 ? buffer[tau - 1] : buffer[tau];
  const x1 = buffer[tau];
  const x2 = tau + 1 < buffer.length ? buffer[tau + 1] : buffer[tau];

  const a = (x0 + x2 - 2 * x1) / 2;
  const b = (x2 - x0) / 2;

  if (a === 0) return tau;
  return tau - b / (2 * a);
}

/**
 * Основная функция pitch detection.
 *
 * @param {Float32Array} buffer — временной буфер с AnalyserNode
 * @param {number} sampleRate
 * @param {object} options
 * @returns {{ frequency: number|null, confidence: number, rms: number }}
 */
export function detectPitch(buffer, sampleRate, options = {}) {
  const { minFrequency, maxFrequency, threshold, silenceRms } = {
    ...DEFAULT_OPTIONS,
    ...options,
  };

  const size = buffer.length;
  const rms = getRms(buffer);

  if (rms < silenceRms) {
    return { frequency: null, confidence: 0, rms };
  }

  const minTau = Math.max(2, Math.floor(sampleRate / maxFrequency));
  const maxTau = Math.min(Math.floor(sampleRate / minFrequency), Math.floor(size / 2));

  if (maxTau <= minTau) {
    return { frequency: null, confidence: 0, rms };
  }

  // 1. Difference function
  // Окно интегрирования одинаковое для всех tau: size - maxTau.
  // Раньше здесь стоял maxTau — для низких струн (tau ~ 580 при E2)
  // окно получалось короче одного периода, и YIN не находил ноту.
  const windowSize = size - maxTau;
  if (windowSize <= 0) {
    return { frequency: null, confidence: 0, rms };
  }

  const yinBuffer = new Float32Array(maxTau);
  for (let tau = 1; tau < maxTau; tau++) {
    let sum = 0;
    for (let i = 0; i < windowSize; i++) {
      const delta = buffer[i] - buffer[i + tau];
      sum += delta * delta;
    }
    yinBuffer[tau] = sum;
  }

  // 2. Cumulative mean normalized difference
  yinBuffer[0] = 1;
  let runningSum = 0;
  for (let tau = 1; tau < maxTau; tau++) {
    runningSum += yinBuffer[tau];
    yinBuffer[tau] = runningSum === 0 ? 1 : (yinBuffer[tau] * tau) / runningSum;
  }

  // 3. Absolute threshold
  let tauEstimate = -1;
  for (let tau = minTau; tau < maxTau; tau++) {
    if (yinBuffer[tau] < threshold) {
      // Ищем локальный минимум, чтобы не зацепиться за соседний период
      while (tau + 1 < maxTau && yinBuffer[tau + 1] < yinBuffer[tau]) {
        tau++;
      }
      tauEstimate = tau;
      break;
    }
  }

  if (tauEstimate === -1) {
    return { frequency: null, confidence: 0, rms };
  }

  const betterTau = parabolicInterpolation(yinBuffer, tauEstimate);
  if (!betterTau || betterTau <= 0) {
    return { frequency: null, confidence: 0, rms };
  }

  const frequency = sampleRate / betterTau;
  if (frequency < minFrequency || frequency > maxFrequency) {
    return { frequency: null, confidence: 0, rms };
  }

  // Чем меньше значение YIN, тем выше уверенность
  const confidence = Math.max(0, Math.min(1, 1 - yinBuffer[tauEstimate]));

  return { frequency, confidence, rms };
}
