import { useCallback, useEffect, useRef, useState } from 'react';

const NOTE_NAMES = ['C', 'C#', 'D', 'D#', 'E', 'F', 'F#', 'G', 'G#', 'A', 'A#', 'B'];

const GUITAR_MIN_MIDI = 39;
const GUITAR_MAX_MIDI = 72;
const GUITAR_MIN_FREQ = 75;
const GUITAR_MAX_FREQ = 530;

const FFT_SIZE = 2048;
const YIN_THRESHOLD = 0.14;
const SILENCE_RMS_THRESHOLD = 0.015;
const TOLERANCE_CENTS = 30;
const REQUIRED_CONSECUTIVE_FRAMES = 3;

function calculateRMS(buffer) {
  let sumSquares = 0;
  const len = buffer.length;
  for (let i = 0; i < len; i++) {
    const val = buffer[i];
    sumSquares += val * val;
  }
  return Math.sqrt(sumSquares / len);
}

function freqToMidi(f) {
  return 12 * Math.log2(f / 440) + 69;
}

function midiToFreq(midi) {
  return 440 * Math.pow(2, (midi - 69) / 12);
}

function calculateCents(f, fExpected) {
  if (!f || !fExpected) return 0;
  return Math.round(1200 * Math.log2(f / fExpected));
}

function computeYIN(buffer, sampleRate) {
  const windowSize = Math.floor(buffer.length / 2);
  const minTau = Math.max(2, Math.floor(sampleRate / GUITAR_MAX_FREQ));
  const maxTau = Math.min(windowSize, Math.floor(sampleRate / GUITAR_MIN_FREQ));

  if (maxTau <= minTau) {
    return { frequency: null, confidence: 0 };
  }

  const d = new Float32Array(maxTau);
  for (let tau = 1; tau < maxTau; tau++) {
    let sum = 0;
    for (let j = 0; j < windowSize; j++) {
      const diff = buffer[j] - buffer[j + tau];
      sum += diff * diff;
    }
    d[tau] = sum;
  }

  const dPrime = new Float32Array(maxTau);
  dPrime[0] = 1;
  let runningSum = 0;

  for (let tau = 1; tau < maxTau; tau++) {
    runningSum += d[tau];
    dPrime[tau] = runningSum === 0 ? 1 : (d[tau] * tau) / runningSum;
  }

  let tauFound = -1;
  for (let tau = minTau; tau < maxTau; tau++) {
    if (dPrime[tau] < YIN_THRESHOLD) {
      while (tau + 1 < maxTau && dPrime[tau + 1] < dPrime[tau]) {
        tau++;
      }
      tauFound = tau;
      break;
    }
  }

  if (tauFound === -1) {
    let globalMinTau = minTau;
    let minVal = dPrime[minTau];
    for (let tau = minTau + 1; tau < maxTau; tau++) {
      if (dPrime[tau] < minVal) {
        minVal = dPrime[tau];
        globalMinTau = tau;
      }
    }
    if (minVal < 0.28) {
      tauFound = globalMinTau;
    } else {
      return { frequency: null, confidence: 0 };
    }
  }

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

export function useGuitarPitch({ onNote = null } = {}) {
  const [isListening, setIsListening] = useState(false);
  const [detectedNote, setDetectedNote] = useState(null);
  const [stableNote, setStableNote] = useState(null);
  const [error, setError] = useState(null);
  const [currentRms, setCurrentRms] = useState(0);

  const audioContextRef = useRef(null);
  const streamRef = useRef(null);
  const sourceNodeRef = useRef(null);
  const highpassNodeRef = useRef(null);
  const lowpassNodeRef = useRef(null);
  const analyserNodeRef = useRef(null);
  const timeBufferRef = useRef(null);
  const rafRef = useRef(null);

  const prevRmsRef = useRef(0);
  const candidateMidiRef = useRef(null);
  const candidateCountRef = useRef(0);
  const lastEmittedMidiRef = useRef(null);
  const lastEmittedTimeRef = useRef(0);
  const onNoteRef = useRef(onNote);

  useEffect(() => {
    onNoteRef.current = onNote;
  }, [onNote]);

  const clearSignal = useCallback(() => {
    candidateMidiRef.current = null;
    candidateCountRef.current = 0;
    setDetectedNote(null);
    setStableNote(null);
  }, []);

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

  const processFrame = useCallback(() => {
    const analyser = analyserNodeRef.current;
    const timeBuffer = timeBufferRef.current;
    const audioCtx = audioContextRef.current;

    if (!analyser || !timeBuffer || !audioCtx) {
      return;
    }

    analyser.getFloatTimeDomainData(timeBuffer);

    const rms = calculateRMS(timeBuffer);
    setCurrentRms(rms);

    const prevRms = prevRmsRef.current;
    prevRmsRef.current = rms;
    const isPluckOnset = rms > prevRms * 1.35 && rms >= SILENCE_RMS_THRESHOLD;

    if (rms < SILENCE_RMS_THRESHOLD) {
      candidateCountRef.current = Math.max(0, candidateCountRef.current - 1);
      if (candidateCountRef.current === 0) {
        candidateMidiRef.current = null;
        setDetectedNote(null);
      }
      rafRef.current = requestAnimationFrame(processFrame);
      return;
    }

    const { frequency, confidence } = computeYIN(timeBuffer, audioCtx.sampleRate);

    if (frequency && confidence >= 0.6) {
      const midiExact = freqToMidi(frequency);
      const midiRounded = Math.round(midiExact);

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
          candidateCountRef.current = Math.max(0, candidateCountRef.current - 1);
        }
      }
    }

    rafRef.current = requestAnimationFrame(processFrame);
  }, []);

  const startListening = useCallback(async () => {
    try {
      setError(null);

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

      const source = audioCtx.createMediaStreamSource(stream);
      sourceNodeRef.current = source;

      const highpass = audioCtx.createBiquadFilter();
      highpass.type = 'highpass';
      highpass.frequency.value = 70;
      highpass.Q.value = 0.707;
      highpassNodeRef.current = highpass;

      const lowpass = audioCtx.createBiquadFilter();
      lowpass.type = 'lowpass';
      lowpass.frequency.value = 1000;
      lowpass.Q.value = 0.707;
      lowpassNodeRef.current = lowpass;

      const analyser = audioCtx.createAnalyser();
      analyser.fftSize = FFT_SIZE;
      analyser.smoothingTimeConstant = 0;
      analyserNodeRef.current = analyser;

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
