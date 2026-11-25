import { useCallback, useEffect, useMemo, useRef, useState } from 'react';
import {
  getAnalyser,
  getFrequencyBuffer,
  getSampleRate,
  getTimeDomainBuffer,
} from '../audio/audioEngine';
import { detectPitch, getRms } from '../audio/pitchDetector';
import { computeChromagram, detectChord, matchChord } from '../audio/chordDetector';
import { createPluckGate } from '../audio/pluckGate';
import {
  centsBetween,
  frequencyToMidi,
  midiToNote,
  parseChordName,
  parseNote,
} from '../audio/noteUtils';
import { CHORD_NAMES, CHORD_VOICINGS } from '../audio/chords';
import { useAudioSession } from './useAudioSession';

const ANALYSIS_INTERVAL_MS = 33;
const MIN_PITCH_CONFIDENCE = 0.45;
const CHORD_MATCH_THRESHOLD = 0.72;

const GUITAR_MIN_FREQUENCY = 75;
const GUITAR_MAX_FREQUENCY = 520;

const CHORD_RING_WINDOW_MS = 1500;

const MISS_FRAMES_TO_RESET = 3;

export function parseExpectedTarget(expectedNote) {
  if (!expectedNote || typeof expectedNote !== 'string') return null;

  const parsedNote = parseNote(expectedNote);
  if (parsedNote?.hasOctave) {
    return { kind: 'note', ...parsedNote };
  }

  if (CHORD_VOICINGS[expectedNote] || parseChordName(expectedNote)) {
    return { kind: 'chord', chord: expectedNote };
  }

  if (parsedNote) {
    return { kind: 'note', ...parsedNote };
  }

  return null;
}

export function useAudioAnalyzer({
  expectedNote = null,
  toleranceCents = 20,
  onSuccess = null,
  holdMs = 800,
} = {}) {
  const { startMic, stopMic } = useAudioSession();

  const [isListening, setIsListening] = useState(false);
  const [detectedNote, setDetectedNote] = useState(null);
  const [detectedChord, setDetectedChord] = useState(null);
  const [pitchHz, setPitchHz] = useState(0);
  const [isCorrect, setIsCorrect] = useState(null);
  const [confidence, setConfidence] = useState(0);
  const [progress, setProgress] = useState(0);
  const [error, setError] = useState(null);

  const rafRef = useRef(null);
  const lastAnalysisRef = useRef(0);
  const holdStartRef = useRef(null);
  const hasSucceededRef = useRef(false);
  const startingRef = useRef(false);
  const onSuccessRef = useRef(onSuccess);
  const detectedChordRef = useRef(null);
  const pitchHzRef = useRef(0);
  const gateRef = useRef(null);
  const missFramesRef = useRef(0);

  const expected = useMemo(() => parseExpectedTarget(expectedNote), [expectedNote]);

  useEffect(() => {
    onSuccessRef.current = onSuccess;
  }, [onSuccess]);

  const analyzeLoop = useCallback(() => {
    const analyser = getAnalyser();
    const timeBuffer = getTimeDomainBuffer();

    if (!analyser || !timeBuffer || !expected) {
      rafRef.current = requestAnimationFrame(analyzeLoop);
      return;
    }

    const now = performance.now();
    if (now - lastAnalysisRef.current < ANALYSIS_INTERVAL_MS) {
      rafRef.current = requestAnimationFrame(analyzeLoop);
      return;
    }
    lastAnalysisRef.current = now;

    analyser.getFloatTimeDomainData(timeBuffer);
    if (!gateRef.current) gateRef.current = createPluckGate();
    const gate = gateRef.current.push(getRms(timeBuffer));
    const gateActive =
      gate.isOpen || now - gate.lastOnsetAt < CHORD_RING_WINDOW_MS;

    let matched = false;
    let matchConfidence = 0;
    let heardSignal = gateActive;

    if (expected.kind === 'note') {
      const pitch = detectPitch(timeBuffer, getSampleRate(), {
        minFrequency: GUITAR_MIN_FREQUENCY,
        maxFrequency: GUITAR_MAX_FREQUENCY,
        silenceRms: gate.isOpen ? gate.noiseRms : gate.openThreshold,
      });

      if (gate.isOpen && pitch.frequency && pitch.confidence >= MIN_PITCH_CONFIDENCE) {
        const detected = midiToNote(frequencyToMidi(pitch.frequency));
        const cents = centsBetween(pitch.frequency, expected.frequency);

        setDetectedNote(detected);
        pitchHzRef.current = Math.round(pitch.frequency);
        setPitchHz(pitchHzRef.current);
        detectedChordRef.current = null;
        setDetectedChord(null);

        matched = Math.abs(cents) <= toleranceCents;
        matchConfidence = Math.max(
          0,
          Math.min(100, Math.round(100 - Math.abs(cents) * 2))
        );
      } else {
        heardSignal = false;
      }
    } else {
      const frequencyBuffer = getFrequencyBuffer();
      if (!gateActive || !frequencyBuffer) {
        heardSignal = false;
      } else {
        analyser.getFloatFrequencyData(frequencyBuffer);
        const chroma = computeChromagram(
          frequencyBuffer,
          getSampleRate(),
          analyser.fftSize
        );

        const match = matchChord(chroma, expected.chord, CHORD_MATCH_THRESHOLD);
        const best = detectChord(chroma, CHORD_NAMES);

        setDetectedNote(null);
        pitchHzRef.current = 0;
        setPitchHz(0);
        detectedChordRef.current = best?.score >= 0.6 ? best.chord : null;
        setDetectedChord(detectedChordRef.current);

        matched = match.isMatch;
        matchConfidence = Math.round(match.score * 100);
      }
    }

    if (!heardSignal) {
      setDetectedNote(null);
      pitchHzRef.current = 0;
      setPitchHz(0);
      detectedChordRef.current = null;
      setDetectedChord(null);
    }

    setConfidence(heardSignal ? matchConfidence : 0);
    setIsCorrect(heardSignal ? matched : null);

    if (matched) {
      missFramesRef.current = 0;

      if (!holdStartRef.current) {
        holdStartRef.current = now;
      }

      const heldMs = now - holdStartRef.current;
      const nextProgress = Math.min(100, Math.round((heldMs / holdMs) * 100));
      setProgress(nextProgress);

      if (nextProgress >= 100 && !hasSucceededRef.current) {
        hasSucceededRef.current = true;
        onSuccessRef.current?.({
          note: expected.kind === 'note' ? expected : null,
          chord: expected.kind === 'chord' ? expected.chord : null,
          detectedChord: detectedChordRef.current,
          pitchHz: pitchHzRef.current,
        });
      }
    } else {
      missFramesRef.current += 1;
      if (missFramesRef.current >= MISS_FRAMES_TO_RESET) {
        holdStartRef.current = null;
        setProgress(0);
      }
    }

    rafRef.current = requestAnimationFrame(analyzeLoop);
  }, [
    expected,
    toleranceCents,
    holdMs,
  ]);

  const startListening = useCallback(async () => {
    if (startingRef.current) return false;

    if (!expected) {
      setError(`Некорректное задание: не удалось распознать «${expectedNote}»`);
      return false;
    }

    startingRef.current = true;

    try {
      setError(null);
      const result = await startMic();

      if (!result.ok) {
        setError(result.error || 'Не удалось получить доступ к микрофону');
        return false;
      }

      hasSucceededRef.current = false;
      holdStartRef.current = null;
      lastAnalysisRef.current = 0;
      missFramesRef.current = 0;
      gateRef.current?.reset();

      setIsListening(true);
      setIsCorrect(null);
      setProgress(0);
      setConfidence(0);
      setDetectedNote(null);
      detectedChordRef.current = null;
      setDetectedChord(null);
      pitchHzRef.current = 0;

      rafRef.current = requestAnimationFrame(analyzeLoop);
      return true;
    } catch (err) {
      setError(`Ошибка запуска анализа: ${err.message}`);
      return false;
    } finally {
      startingRef.current = false;
    }
  }, [expected, expectedNote, startMic, analyzeLoop]);

  const stopListening = useCallback(() => {
    if (rafRef.current) {
      cancelAnimationFrame(rafRef.current);
      rafRef.current = null;
    }

    stopMic();
    holdStartRef.current = null;
    hasSucceededRef.current = false;
    lastAnalysisRef.current = 0;
    missFramesRef.current = 0;
    gateRef.current?.reset();

    setIsListening(false);
    setDetectedNote(null);
    detectedChordRef.current = null;
    setDetectedChord(null);
    pitchHzRef.current = 0;
    setPitchHz(0);
    setIsCorrect(null);
    setConfidence(0);
    setProgress(0);
  }, [stopMic]);

  useEffect(() => {
    return () => {
      if (rafRef.current) cancelAnimationFrame(rafRef.current);
    };
  }, []);

  return {
    isListening,
    detectedNote,
    detectedChord,
    pitchHz,
    isCorrect,
    confidence,
    progress,
    error,
    expected,
    startListening,
    stopListening,
  };
}
