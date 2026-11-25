import { useCallback, useEffect, useRef, useState } from 'react';
import {
  getAnalyser,
  getSampleRate,
  getTimeDomainBuffer,
} from '../audio/audioEngine';
import { detectPitch } from '../audio/pitchDetector';
import {
  centsBetween,
  frequencyToMidi,
  getClosestGuitarString,
  GUITAR_STANDARD_TUNING,
  midiToNote,
} from '../audio/noteUtils';
import { useAudioSession } from './useAudioSession';

const ANALYSIS_INTERVAL_MS = 33;
const MIN_CONFIDENCE = 0.5;
const IN_TUNE_CENTS = 5;

export function useGuitarTuner() {
  const { startMic, stopMic, micReady } = useAudioSession();

  const [isActive, setIsActive] = useState(false);
  const [note, setNote] = useState(null);
  const [centsOff, setCentsOff] = useState(0);
  const [status, setStatus] = useState('no-signal');
  const [string, setString] = useState(null);
  const [confidence, setConfidence] = useState(0);
  const [error, setError] = useState(null);

  const rafRef = useRef(null);
  const lastAnalysisRef = useRef(0);
  const smoothedFrequenciesRef = useRef([]);
  const startingRef = useRef(false);

  const analyzeLoop = useCallback(() => {
    const analyser = getAnalyser();
    const buffer = getTimeDomainBuffer();

    if (!analyser || !buffer) {
      rafRef.current = requestAnimationFrame(analyzeLoop);
      return;
    }

    const now = performance.now();
    if (now - lastAnalysisRef.current < ANALYSIS_INTERVAL_MS) {
      rafRef.current = requestAnimationFrame(analyzeLoop);
      return;
    }
    lastAnalysisRef.current = now;

    analyser.getFloatTimeDomainData(buffer);
    const result = detectPitch(buffer, getSampleRate());

    if (!result.frequency || result.confidence < MIN_CONFIDENCE) {
      smoothedFrequenciesRef.current = [];
      setStatus('no-signal');
      setNote(null);
      setCentsOff(0);
      setString(null);
      setConfidence(0);
      rafRef.current = requestAnimationFrame(analyzeLoop);
      return;
    }

    const history = smoothedFrequenciesRef.current;
    history.push(result.frequency);
    if (history.length > 5) history.shift();

    const sorted = [...history].sort((a, b) => a - b);
    const median = sorted[Math.floor(sorted.length / 2)];

    if (Math.abs(result.frequency - median) / median > 0.08) {
      smoothedFrequenciesRef.current = [result.frequency];
    }

    const frequency = smoothedFrequenciesRef.current[0];
    const detectedNote = midiToNote(frequencyToMidi(frequency));
    const cents = centsBetween(frequency, detectedNote.frequency);
    const closestString = getClosestGuitarString(frequency);

    setNote(detectedNote);
    setCentsOff(Math.round(cents));
    setString(closestString);
    setConfidence(Math.round(result.confidence * 100));

    if (Math.abs(cents) <= IN_TUNE_CENTS) {
      setStatus('in-tune');
    } else if (cents < 0) {
      setStatus('too-low');
    } else {
      setStatus('too-high');
    }

    rafRef.current = requestAnimationFrame(analyzeLoop);
  }, []);

  const start = useCallback(async () => {
    if (startingRef.current) return false;
    startingRef.current = true;

    try {
      setError(null);
      const result = await startMic();

      if (!result.ok) {
        setError(result.error || 'Не удалось запустить микрофон');
        return false;
      }

      setIsActive(true);
      lastAnalysisRef.current = 0;
      smoothedFrequenciesRef.current = [];
      rafRef.current = requestAnimationFrame(analyzeLoop);
      return true;
    } catch (err) {
      setError(`Ошибка при запуске тюнера: ${err.message}`);
      return false;
    } finally {
      startingRef.current = false;
    }
  }, [startMic, analyzeLoop]);

  const stop = useCallback(() => {
    if (rafRef.current) {
      cancelAnimationFrame(rafRef.current);
      rafRef.current = null;
    }

    stopMic();
    smoothedFrequenciesRef.current = [];
    lastAnalysisRef.current = 0;

    setIsActive(false);
    setNote(null);
    setCentsOff(0);
    setStatus('no-signal');
    setString(null);
    setConfidence(0);
  }, [stopMic]);

  useEffect(() => {
    return () => {
      if (rafRef.current) cancelAnimationFrame(rafRef.current);
    };
  }, []);

  return {
    isActive,
    micReady,
    note,
    string,
    centsOff,
    status,
    confidence,
    error,
    start,
    stop,
    GUITAR_STANDARD_TUNING,
  };
}
