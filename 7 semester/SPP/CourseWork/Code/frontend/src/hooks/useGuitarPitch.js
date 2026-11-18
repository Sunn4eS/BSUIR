/**
 * frontend/src/hooks/useGuitarPitch.js — Высокоточный DSP движок детекции одиночных нот гитары
 *
 * Архитектура и спецификация:
 * 1. Web Audio API аудио-граф:
 *    - getUserMedia({ audio: { echoCancellation: false, noiseSuppression: false, autoGainControl: false } })
 *    - BiquadFilterNode highpass (fc = 70 Hz, Q = 0.707) для подавления гула сети (50/60 Hz) и микрофонных шумов
 *    - BiquadFilterNode lowpass (fc = 1000 Hz, Q = 0.707) для отсечения шума ладов и гармоник выше первой струны
 *    - AnalyserNode (fftSize = 2048) для частотного разрешения низкого регистра (нота E2 = 82.41 Hz)
 *
 * 2. Алгоритм YIN (de Cheveigné & Kawahara):
 *    - Difference Function d_t(tau)
 *    - Cumulative Mean Normalized Difference Function d'_t(tau)
 *    - Поиск первого локального минимума ниже Harmonicity Threshold (~0.12)
 *    - Параболическая субдискретная интерполяция tau_refined
 *
 * 3. Энергетический гейт и стабилизация щипка (Pluck Onset & Hysteresis):
 *    - RMS порог тишины (RMS < 0.015)
 *    - Детекция резкой атаки струны (pluck onset)
 *    - Стабилизация/дебаунс: удержание ноты в пределах ±30 центов на протяжении >= 3-4 последовательных фреймов (~80-120 мс)
 *
 * 4. Таблица частот гитары (E2: 82.41 Hz … B4: 493.88 Hz):
 *    - n = 12 * log2(f / 440) + 69
 *    - cents = 1200 * log2(f / f_expected)
 */

import { useCallback, useEffect, useRef, useState } from 'react';

// Хроматическая шкала нот
const NOTE_NAMES = ['C', 'C#', 'D', 'D#', 'E', 'F', 'F#', 'G', 'G#', 'A', 'A#', 'B'];

// Диапазон гитары: E2 (MIDI 40, ~82.41 Hz) ... B4 (MIDI 71, ~493.88 Hz)
const GUITAR_MIN_MIDI = 39; // E2 (с запасом на пониженный строй)
const GUITAR_MAX_MIDI = 72; // B4 / C5
const GUITAR_MIN_FREQ = 75; // Hz
const GUITAR_MAX_FREQ = 530; // Hz

const FFT_SIZE = 2048;
const YIN_THRESHOLD = 0.14; // Harmonicity Threshold (0.10 - 0.15)
const SILENCE_RMS_THRESHOLD = 0.015; // Порог тишины
const TOLERANCE_CENTS = 30; // Допуск в центах
const REQUIRED_CONSECUTIVE_FRAMES = 3; // 3-4 кадра стабильности (~80-120 мс)

/**
 * Расчет среднеквадратичной амплитуды (RMS)
 */
function calculateRMS(buffer) {
  let sumSquares = 0;
  const len = buffer.length;
  for (let i = 0; i < len; i++) {
    const val = buffer[i];
    sumSquares += val * val;
  }
  return Math.sqrt(sumSquares / len);
}

/**
 * Преобразование частоты (Гц) в MIDI номер ноты
 * n = 12 * log2(f / 440) + 69
 */
function freqToMidi(f) {
  return 12 * Math.log2(f / 440) + 69;
}

/**
 * Преобразование MIDI номера в идеальную частоту (Гц)
 * f_expected = 440 * 2^((midi - 69) / 12)
 */
function midiToFreq(midi) {
  return 440 * Math.pow(2, (midi - 69) / 12);
}

/**
 * Расчет отклонения в центах от ближайшей эталонной ноты
 * cents = 1200 * log2(f / f_expected)
 */
function calculateCents(f, fExpected) {
  if (!f || !fExpected) return 0;
  return Math.round(1200 * Math.log2(f / fExpected));
}

/**
 * Полный алгоритм детекции высоты тона YIN
 * @param {Float32Array} buffer - буфер временной области
 * @param {number} sampleRate - частота дискретизации (44100 / 48000 Гц)
 * @returns {{ frequency: number|null, confidence: number }}
 */
function computeYIN(buffer, sampleRate) {
  const windowSize = Math.floor(buffer.length / 2); // 1024 сэмпла
  const minTau = Math.max(2, Math.floor(sampleRate / GUITAR_MAX_FREQ));
  const maxTau = Math.min(windowSize, Math.floor(sampleRate / GUITAR_MIN_FREQ));

  if (maxTau <= minTau) {
    return { frequency: null, confidence: 0 };
  }

  // 1. Difference Function d_t(tau)
  const d = new Float32Array(maxTau);
  for (let tau = 1; tau < maxTau; tau++) {
    let sum = 0;
    for (let j = 0; j < windowSize; j++) {
      const diff = buffer[j] - buffer[j + tau];
      sum += diff * diff;
    }
    d[tau] = sum;
  }

  // 2. Cumulative Mean Normalized Difference Function d'_t(tau)
  const dPrime = new Float32Array(maxTau);
  dPrime[0] = 1;
  let runningSum = 0;

  for (let tau = 1; tau < maxTau; tau++) {
    runningSum += d[tau];
    dPrime[tau] = runningSum === 0 ? 1 : (d[tau] * tau) / runningSum;
  }

  // 3. Absolute Threshold: поиск первого минимума ниже порога
  let tauFound = -1;
  for (let tau = minTau; tau < maxTau; tau++) {
    if (dPrime[tau] < YIN_THRESHOLD) {
      // Локальный минимум
      while (tau + 1 < maxTau && dPrime[tau + 1] < dPrime[tau]) {
        tau++;
      }
      tauFound = tau;
      break;
    }
  }

  // Если ниже порога ничего не найдено, ищем глобальный минимум с мягким порогом
  if (tauFound === -1) {
    let globalMinTau = minTau;
    let minVal = dPrime[minTau];
    for (let tau = minTau + 1; tau < maxTau; tau++) {
      if (dPrime[tau] < minVal) {
        minVal = dPrime[tau];
        globalMinTau = tau;
      }
    }
    // Принимаем только если гармоничность достаточно выражена
    if (minVal < 0.28) {
      tauFound = globalMinTau;
    } else {
      return { frequency: null, confidence: 0 };
    }
  }

  // 4. Параболическая интерполяция для точной дробной задержки tau
  let refinedTau = tauFound;
  if (tauFound > 0 && tauFound < maxTau - 1) {
    const s0 = dPrime[tauFound - 1];
    const s1 = dPrime[tauFound];
    const s2 = dPrime[tauFound + 1];
    const denom = 2 * (2 * s1 - s0 - s2);
    if (denom !== 0) {
      const delta = (s2 - s0) / denom;
      refinedTau = tauFound + delta;
    }
  }

  const frequency = sampleRate / refinedTau;
  const confidence = Math.max(0, Math.min(1, 1 - dPrime[tauFound]));

  return { frequency, confidence };
}

/**
 * Хук детекции нот гитары
 * @param {object} options
 * @param {function} [options.onNote] - коллбэк при распознавании стабильной ноты
 */
export function useGuitarPitch({ onNote = null } = {}) {
  const [isListening, setIsListening] = useState(false);
  const [detectedNote, setDetectedNote] = useState(null);
  const [stableNote, setStableNote] = useState(null);
  const [error, setError] = useState(null);
  const [currentRms, setCurrentRms] = useState(0);

  // Ссылки на Web Audio объекты
  const audioContextRef = useRef(null);
  const streamRef = useRef(null);
  const sourceNodeRef = useRef(null);
  const highpassNodeRef = useRef(null);
  const lowpassNodeRef = useRef(null);
  const analyserNodeRef = useRef(null);
  const timeBufferRef = useRef(null);
  const rafRef = useRef(null);

  // Ссылки для алгоритма гистерезиса и стабилизации
  const prevRmsRef = useRef(0);
  const candidateMidiRef = useRef(null);
  const candidateCountRef = useRef(0);
  const lastEmittedMidiRef = useRef(null);
  const lastEmittedTimeRef = useRef(0);
  const onNoteRef = useRef(onNote);

  useEffect(() => {
    onNoteRef.current = onNote;
  }, [onNote]);

  /**
   * Сброс сигналов и буферов
   */
  const clearSignal = useCallback(() => {
    candidateMidiRef.current = null;
    candidateCountRef.current = 0;
    setDetectedNote(null);
    setStableNote(null);
  }, []);

  /**
   * Остановка аудио-графа и отписка от микрофона
   */
  const stopListening = useCallback(() => {
    if (rafRef.current) {
      cancelAnimationFrame(rafRef.current);
      rafRef.current = null;
    }

    if (streamRef.current) {
      streamRef.current.getTracks().forEach((track) => track.stop());
      streamRef.current = null;
    }

    try {
      sourceNodeRef.current?.disconnect();
      highpassNodeRef.current?.disconnect();
      lowpassNodeRef.current?.disconnect();
      analyserNodeRef.current?.disconnect();
    } catch {
      // игнорируем ошибку при отключении
    }

    sourceNodeRef.current = null;
    highpassNodeRef.current = null;
    lowpassNodeRef.current = null;
    analyserNodeRef.current = null;
    timeBufferRef.current = null;

    if (audioContextRef.current && audioContextRef.current.state !== 'closed') {
      audioContextRef.current.close().catch(() => {});
      audioContextRef.current = null;
    }

    candidateMidiRef.current = null;
    candidateCountRef.current = 0;
    lastEmittedMidiRef.current = null;
    prevRmsRef.current = 0;

    setIsListening(false);
    setDetectedNote(null);
    setStableNote(null);
  }, []);

  /**
   * Цикл анализа кадров Web Audio API
   */
  const processFrame = useCallback(() => {
    const analyser = analyserNodeRef.current;
    const timeBuffer = timeBufferRef.current;
    const audioCtx = audioContextRef.current;

    if (!analyser || !timeBuffer || !audioCtx) {
      return;
    }

    analyser.getFloatTimeDomainData(timeBuffer);

    // 1. Расчет RMS
    const rms = calculateRMS(timeBuffer);
    setCurrentRms(rms);

    // Детекция атаки струны (pluck onset)
    const prevRms = prevRmsRef.current;
    prevRmsRef.current = rms;
    const isPluckOnset = rms > prevRms * 1.35 && rms >= SILENCE_RMS_THRESHOLD;

    // 2. Энергетический гейт: отсекаем тишину
    if (rms < SILENCE_RMS_THRESHOLD) {
      candidateCountRef.current = Math.max(0, candidateCountRef.current - 1);
      if (candidateCountRef.current === 0) {
        candidateMidiRef.current = null;
        setDetectedNote(null);
      }
      rafRef.current = requestAnimationFrame(processFrame);
      return;
    }

    // 3. Вычисление частоты через YIN
    const { frequency, confidence } = computeYIN(timeBuffer, audioCtx.sampleRate);

    if (frequency && confidence >= 0.6) {
      const midiExact = freqToMidi(frequency);
      const midiRounded = Math.round(midiExact);

      // Проверка диапазона гитары E2..B4
      if (midiRounded >= GUITAR_MIN_MIDI && midiRounded <= GUITAR_MAX_MIDI) {
        const expectedFreq = midiToFreq(midiRounded);
        const cents = calculateCents(frequency, expectedFreq);

        const noteIndex = ((midiRounded % 12) + 12) % 12;
        const noteName = NOTE_NAMES[noteIndex];
        const octave = Math.floor(midiRounded / 12) - 1;
        const noteLabel = `${noteName}${octave}`;

        const currentFrameNote = {
          name: noteName,
          octave,
          label: noteLabel,
          midi: midiRounded,
          frequency: Math.round(frequency * 10) / 10,
          expectedFreq: Math.round(expectedFreq * 10) / 10,
          cents,
          confidence: Math.round(confidence * 100),
          rms: Math.round(rms * 1000) / 1000,
          isOnset: isPluckOnset,
        };

        setDetectedNote(currentFrameNote);

        // 4. Стабилизация и дебаунс:
        // Нота считается распознанной, если алгоритм удерживает частоту
        // в пределах ±30 центов на протяжении >= 3-4 последовательных аудиофреймов
        if (Math.abs(cents) <= TOLERANCE_CENTS) {
          if (candidateMidiRef.current === midiRounded) {
            candidateCountRef.current += 1;
          } else {
            candidateMidiRef.current = midiRounded;
            candidateCountRef.current = 1;
          }

          const now = Date.now();
          const canEmitAgain =
            lastEmittedMidiRef.current !== midiRounded || now - lastEmittedTimeRef.current > 700;

          if (candidateCountRef.current >= REQUIRED_CONSECUTIVE_FRAMES && canEmitAgain) {
            lastEmittedMidiRef.current = midiRounded;
            lastEmittedTimeRef.current = now;

            const stablePayload = {
              ...currentFrameNote,
              atMs: now,
            };

            setStableNote(stablePayload);
            if (typeof onNoteRef.current === 'function') {
              onNoteRef.current(stablePayload);
            }
          }
        } else {
          // Выход за границы допуска по центам
          candidateCountRef.current = Math.max(0, candidateCountRef.current - 1);
        }
      }
    }

    rafRef.current = requestAnimationFrame(processFrame);
  }, []);

  /**
   * Запуск микрофона и инициализация Web Audio графа с фильтрацией
   */
  const startListening = useCallback(async () => {
    try {
      setError(null);

      // Запрашиваем микрофон без шумодавов ОС (RAW Audio)
      const stream = await navigator.mediaDevices.getUserMedia({
        audio: {
          echoCancellation: false,
          noiseSuppression: false,
          autoGainControl: false,
          channelCount: 1,
        },
      });

      streamRef.current = stream;

      const AudioCtxClass = window.AudioContext || window.webkitAudioContext;
      const audioCtx = new AudioCtxClass();
      if (audioCtx.state === 'suspended') {
        await audioCtx.resume();
      }
      audioContextRef.current = audioCtx;

      // Источник микрофона
      const source = audioCtx.createMediaStreamSource(stream);
      sourceNodeRef.current = source;

      // Каскад фильтров:
      // Highpass (fc = 70 Hz): отсекает 50/60 Hz сетевой гул и механику
      const highpass = audioCtx.createBiquadFilter();
      highpass.type = 'highpass';
      highpass.frequency.value = 70;
      highpass.Q.value = 0.707;
      highpassNodeRef.current = highpass;

      // Lowpass (fc = 1000 Hz): отсекает дребезг ладов и гармоники выше диапазона
      const lowpass = audioCtx.createBiquadFilter();
      lowpass.type = 'lowpass';
      lowpass.frequency.value = 1000;
      lowpass.Q.value = 0.707;
      lowpassNodeRef.current = lowpass;

      // Анализатор
      const analyser = audioCtx.createAnalyser();
      analyser.fftSize = FFT_SIZE; // 2048 сэмплов
      analyser.smoothingTimeConstant = 0; // Сырые сэмплы для YIN
      analyserNodeRef.current = analyser;

      // Сборка графа: source -> highpass -> lowpass -> analyser
      source.connect(highpass);
      highpass.connect(lowpass);
      lowpass.connect(analyser);

      timeBufferRef.current = new Float32Array(analyser.fftSize);

      candidateMidiRef.current = null;
      candidateCountRef.current = 0;
      lastEmittedMidiRef.current = null;
      prevRmsRef.current = 0;

      setIsListening(true);
      rafRef.current = requestAnimationFrame(processFrame);

      return true;
    } catch (err) {
      console.error('[useGuitarPitch] Microphone error:', err);
      const message =
        err.name === 'NotAllowedError'
          ? 'Доступ к микрофону заблокирован. Разрешите доступ в браузере.'
          : `Ошибка микрофона: ${err.message}`;
      setError(message);
      setIsListening(false);
      return false;
    }
  }, [processFrame]);

  // Очистка при размонтировании
  useEffect(() => {
    return () => {
      if (rafRef.current) {
        cancelAnimationFrame(rafRef.current);
      }
      if (streamRef.current) {
        streamRef.current.getTracks().forEach((track) => track.stop());
      }
      if (audioContextRef.current && audioContextRef.current.state !== 'closed') {
        audioContextRef.current.close().catch(() => {});
      }
    };
  }, []);

  return {
    isListening,
    detectedNote,
    stableNote,
    currentRms,
    error,
    startListening,
    stopListening,
    clearSignal,
  };
}

export default useGuitarPitch;
