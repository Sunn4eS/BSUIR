/**
 * audio/audioEngine.js — единое аудио-ядро приложения
 *
 * Зачем это нужно:
 *  - браузеры разрешают AudioContext только после жеста пользователя;
 *  - нельзя создавать новый AudioContext на каждый клик/компонент;
 *  - микрофонный поток должен переиспользоваться между Mic Check, тюнером и карточками.
 *
 * Все функции, которые запускают звук, вызываются ТОЛЬКО из обработчиков кликов.
 */

import * as Tone from 'tone';

let micStream = null;
let sourceNode = null;
let filterNodes = [];
let analyserNode = null;
let timeDomainBuffer = null;
let frequencyBuffer = null;

const MIC_REQUEST_TIMEOUT_MS = 12000;

/**
 * Инициализирует/возобновляет общий AudioContext.
 * Обязательно вызывать внутри пользовательского жеста (click/tap).
 */
export async function ensureAudio() {
  await Tone.start();

  const ctx = Tone.getContext().rawContext;
  if (ctx.state !== 'running') {
    await ctx.resume();
  }

  return ctx;
}

/** Возвращает общий AudioContext (может быть suspended, если не было жеста) */
export function getAudioContext() {
  return Tone.getContext().rawContext;
}

/**
 * Запрашивает микрофон (один раз) и создаёт AnalyserNode.
 * Повторный вызов возвращает уже существующий анализатор.
 */
export async function enableMic() {
  const ctx = await ensureAudio();

  if (micStream?.active && analyserNode) {
    return analyserNode;
  }

  // Если поток «завис» или был остановлен — очищаем
  if (micStream) {
    releaseMic();
  }

  const constraints = {
    audio: {
      echoCancellation: false,
      noiseSuppression: false,
      autoGainControl: false,
      channelCount: 1,
    },
  };

  // Некоторые браузеры/Electron могут не завершить запрос доступа,
  // если разрешение заблокировано на уровне приложения.
  let timedOut = false;
  const request = navigator.mediaDevices.getUserMedia(constraints);
  const timeout = new Promise((_, reject) => {
    setTimeout(() => {
      timedOut = true;
      const error = new Error('Браузер не ответил на запрос доступа к микрофону');
      error.name = 'MicTimeoutError';
      reject(error);
    }, MIC_REQUEST_TIMEOUT_MS);
  });

  try {
    micStream = await Promise.race([request, timeout]);
  } finally {
    // Если пользователь ответил уже после таймаута — не оставляем поток висеть
    if (timedOut) {
      request
        .then((stream) => stream.getTracks().forEach((track) => track.stop()))
        .catch(() => {});
    }
  }

  sourceNode = ctx.createMediaStreamSource(micStream);

  // Гитарный тракт: highpass 70 Гц + lowpass 1800 Гц.
  // Раньше стоял bandpass 300 Гц Q=0.25 — он заметно давил низкие
  // струны (E2 = 82 Гц) и не давал детектору поймать бас.
  const highpass = ctx.createBiquadFilter();
  highpass.type = 'highpass';
  highpass.frequency.value = 70;
  highpass.Q.value = 0.707;

  const lowpass = ctx.createBiquadFilter();
  lowpass.type = 'lowpass';
  lowpass.frequency.value = 1800;
  lowpass.Q.value = 0.707;

  filterNodes = [highpass, lowpass];

  analyserNode = ctx.createAnalyser();
  // 8192 даёт разрешение ~5.9 Гц при 48 кГц — важно для низких струн,
  // иначе A2 (110 Гц) может округлиться до соседней ноты.
  analyserNode.fftSize = 8192;
  analyserNode.smoothingTimeConstant = 0;
  analyserNode.minDecibels = -100;
  analyserNode.maxDecibels = -10;

  sourceNode.connect(highpass);
  highpass.connect(lowpass);
  lowpass.connect(analyserNode);

  timeDomainBuffer = new Float32Array(analyserNode.fftSize);
  frequencyBuffer = new Float32Array(analyserNode.frequencyBinCount);

  return analyserNode;
}

export function getAnalyser() {
  return analyserNode;
}

export function getTimeDomainBuffer() {
  return timeDomainBuffer;
}

export function getFrequencyBuffer() {
  return frequencyBuffer;
}

export function getSampleRate() {
  return getAudioContext()?.sampleRate ?? 48000;
}

export function isMicActive() {
  return Boolean(micStream?.active && analyserNode);
}

/** Текущий уровень сигнала: RMS, dBFS и нормализованное значение 0..1 */
export function getLevel() {
  if (!analyserNode || !timeDomainBuffer) {
    return { rms: 0, db: -Infinity, normalized: 0 };
  }

  analyserNode.getFloatTimeDomainData(timeDomainBuffer);

  let sum = 0;
  for (let i = 0; i < timeDomainBuffer.length; i++) {
    sum += timeDomainBuffer[i] * timeDomainBuffer[i];
  }

  const rms = Math.sqrt(sum / timeDomainBuffer.length);
  const db = rms > 0 ? 20 * Math.log10(rms) : -Infinity;

  // -60 dBFS → 0, 0 dBFS → 1
  const normalized = Number.isFinite(db)
    ? Math.max(0, Math.min(1, (db + 60) / 60))
    : 0;

  return { rms, db, normalized };
}

/** Освобождает микрофон, но не закрывает общий AudioContext */
export function releaseMic() {
  if (filterNodes.length) {
    filterNodes.forEach((node) => {
      try {
        node.disconnect();
      } catch {
        // уже отключён
      }
    });
    filterNodes = [];
  }

  if (sourceNode) {
    try {
      sourceNode.disconnect();
    } catch {
      // уже отключён
    }
    sourceNode = null;
  }

  if (micStream) {
    micStream.getTracks().forEach((track) => track.stop());
    micStream = null;
  }

  analyserNode = null;
  timeDomainBuffer = null;
  frequencyBuffer = null;
}
