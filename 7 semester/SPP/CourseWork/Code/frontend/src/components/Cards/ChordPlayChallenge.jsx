/**
 * components/Cards/ChordPlayChallenge.jsx
 * Фаза «сыграй аппликатуру»: слушаем микрофон и собираем ноты аккорда.
 *
 * Ученик может играть аккорд двумя способами:
 *  - поочерёдно щипать струны (монофонический YIN, useGuitarPitch);
 *  - взять аккорд одним боем (полифоническая проверка по хромаграмме).
 *
 * Задание выполнено, когда прозвучали все ступени аккорда.
 *
 * Используется в PLAY_FINGERING и во второй фазе COMBO_FINGERING.
 */

import { useCallback, useEffect, useMemo, useRef, useState } from 'react';
import { useGuitarPitch } from '../../hooks/useGuitarPitch';
import { useAudioSession } from '../../hooks/useAudioSession';
import MicCheckModal from '../Audio/MicCheckModal';
import { getChordShape, fretsToNotes, normalizeChordName } from '../../audio/chordShapes';
import { parseNote } from '../../audio/noteUtils';
import { getAnalyser, getFrequencyBuffer, getSampleRate } from '../../audio/audioEngine';
import { computeChromagram, chromaPitchClasses } from '../../audio/chordDetector';

export default function ChordPlayChallenge({ chord, onDone, readOnly = false }) {
  const [playedPcs, setPlayedPcs] = useState(() => new Set());
  const [lastNote, setLastNote] = useState(null);
  const [polyTones, setPolyTones] = useState([]);
  const [showMicCheck, setShowMicCheck] = useState(false);
  const [isComplete, setIsComplete] = useState(false);
  const doneRef = useRef(false);

  const { micReady } = useAudioSession();

  const expectedPcs = useMemo(() => {
    const normalized = normalizeChordName(chord);
    const shape = getChordShape(normalized || chord);
    const notes = shape ? fretsToNotes(shape) : [];
    const pcs = [];
    for (const label of notes) {
      const parsed = parseNote(label);
      if (parsed && !pcs.includes(parsed.name)) pcs.push(parsed.name);
    }
    return pcs;
  }, [chord]);

  const handleNote = useCallback(
    (note) => {
      setLastNote(note);
      setPlayedPcs((prev) => {
        const next = new Set(prev);
        next.add(note.name);
        return next;
      });
    },
    []
  );

  const {
    isListening,
    detectedNote,
    error,
    startListening,
    stopListening,
  } = useGuitarPitch({ onNote: handleNote });

  // Полифоническая проверка: один бой по всем струнам.
  // Каждые 150 мс строим хромаграмму и добавляем услышанные ступени.
  useEffect(() => {
    if (!isListening || isComplete || readOnly) return undefined;

    const timer = setInterval(() => {
      const analyser = getAnalyser();
      const buffer = getFrequencyBuffer();
      if (!analyser || !buffer) return;

      analyser.getFloatFrequencyData(buffer);
      const chroma = computeChromagram(buffer, getSampleRate(), analyser.fftSize);
      const tones = chromaPitchClasses(chroma, 0.32);
      if (!tones.length) return;

      const expected = new Set(expectedPcs);
      const heard = tones.map((tone) => tone.name).filter((name) => expected.has(name));
      if (!heard.length) return;

      setPolyTones(heard);
      setPlayedPcs((prev) => {
        const next = new Set(prev);
        let changed = false;
        for (const name of heard) {
          if (!next.has(name)) {
            next.add(name);
            changed = true;
          }
        }
        return changed ? next : prev;
      });
    }, 150);

    return () => clearInterval(timer);
  }, [isListening, isComplete, readOnly, expectedPcs]);

  // Успех: все ступени аккорда прозвучали
  useEffect(() => {
    if (isComplete || readOnly || expectedPcs.length === 0) return;
    const allPlayed = expectedPcs.every((pc) => playedPcs.has(pc));
    if (allPlayed && isListening && !doneRef.current) {
      doneRef.current = true;
      setIsComplete(true);
      stopListening();
      onDone?.({ correct: true });
    }
  }, [playedPcs, expectedPcs, isListening, isComplete, readOnly, onDone, stopListening]);

  useEffect(() => () => stopListening(), [stopListening]);

  const beginListening = useCallback(() => {
    doneRef.current = false;
    startListening();
  }, [startListening]);

  const handleStart = useCallback(() => {
    if (!micReady) {
      setShowMicCheck(true);
      return;
    }
    beginListening();
  }, [micReady, beginListening]);

  const handleMicReady = useCallback(() => {
    setShowMicCheck(false);
    beginListening();
  }, [beginListening]);

  const handleStop = useCallback(() => {
    stopListening();
  }, [stopListening]);

  const progressPercent =
    expectedPcs.length > 0
      ? Math.round(
          (expectedPcs.filter((pc) => playedPcs.has(pc)).length / expectedPcs.length) * 100
        )
      : 0;

  return (
    <div className="chord-play-challenge">
      {isListening && (
        <div className="detector-box">
          <div className="detector-value">
            {detectedNote ? `${detectedNote.name}${detectedNote.octave}` : lastNote?.label || '—'}
          </div>
          <div className="detector-hint">
            {detectedNote
              ? 'Нота услышана — щипай следующую струну'
              : polyTones.length
                ? `Слышу: ${polyTones.join(' · ')}`
                : 'Щипай струны по одной или ударь по всем струнам…'}
          </div>

          <div className="chord-notes-progress">
            {expectedPcs.map((pc) => (
              <span
                key={pc}
                className={`chord-note-chip ${playedPcs.has(pc) ? 'is-played' : ''}`}
              >
                {playedPcs.has(pc) ? '✓' : '•'} {pc}
              </span>
            ))}
          </div>

          <div className="detector-progress">
            <div className="detector-progress-labels">
              <span>Ступени аккорда</span>
              <span>{progressPercent}%</span>
            </div>
            <div className="progress-bar">
              <div
                className="progress-bar-fill is-success"
                style={{ width: `${progressPercent}%` }}
              />
            </div>
          </div>
        </div>
      )}

      {error && <div className="alert alert-error">⚠️ {error}</div>}

      {!readOnly && !isComplete && (
        <div className="card-actions">
          {!isListening ? (
            <button className="btn btn-accent btn-lg btn-block" onClick={handleStart}>
              🎤 Играть аккорд
            </button>
          ) : (
            <button className="btn btn-ghost btn-lg btn-block" onClick={handleStop}>
              ⏹ Остановить
            </button>
          )}
        </div>
      )}

      {isComplete && (
        <div className="answer-feedback is-correct">
          🎉 Отлично! Аккорд прозвучал верно!
        </div>
      )}

      {isListening && (
        <div className="live-indicator is-centered">
          <div className="live-dot" style={{ background: 'var(--color-accent)' }} />
          <span>Слушаю гитару…</span>
        </div>
      )}

      <MicCheckModal
        open={showMicCheck}
        onClose={() => setShowMicCheck(false)}
        onReady={handleMicReady}
        title="Проверка микрофона"
        description={`Поочерёдно щипните струны аккорда «${chord}» — проверим, что микрофон слышит инструмент.`}
      />
    </div>
  );
}
