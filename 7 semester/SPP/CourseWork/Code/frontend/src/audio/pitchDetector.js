const DEFAULT_OPTIONS = {
  minFrequency: 70,
  maxFrequency: 1200,
  threshold: 0.12,
  silenceRms: 0.008,
};

export function getRms(buffer) {
  let sum = 0;
  for (let i = 0; i < buffer.length; i++) {
    sum += buffer[i] * buffer[i];
  }
  return Math.sqrt(sum / buffer.length);
}

export function rmsToDb(rms) {
  return rms > 0 ? 20 * Math.log10(rms) : -Infinity;
}

function parabolicInterpolation(buffer, tau) {
  const x0 = tau > 0 ? buffer[tau - 1] : buffer[tau];
  const x1 = buffer[tau];
  const x2 = tau + 1 < buffer.length ? buffer[tau + 1] : buffer[tau];

  const a = (x0 + x2 - 2 * x1) / 2;
  const b = (x2 - x0) / 2;

  if (a === 0) return tau;
  return tau - b / (2 * a);
}

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

  yinBuffer[0] = 1;
  let runningSum = 0;
  for (let tau = 1; tau < maxTau; tau++) {
    runningSum += yinBuffer[tau];
    yinBuffer[tau] = runningSum === 0 ? 1 : (yinBuffer[tau] * tau) / runningSum;
  }

  let tauEstimate = -1;
  for (let tau = minTau; tau < maxTau; tau++) {
    if (yinBuffer[tau] < threshold) {
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

  const confidence = Math.max(0, Math.min(1, 1 - yinBuffer[tauEstimate]));

  return { frequency, confidence, rms };
}
