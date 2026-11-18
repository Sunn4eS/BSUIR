/**
 * components/Cards/FingeringTestCard.jsx
 * Карточка FINGERING_TEST — аппликатура аккорда.
 *
 * Режим GUESS: на грифе показана аппликатура — выбери название аккорда
 * из 4 вариантов (аппликатуру можно прослушать).
 *
 * Режим BUILD: показано название аккорда — собери аппликатуру на грифе.
 * Ответ: { chord, frets, correct } — сервер доверяет локальной проверке.
 */

import { useCallback, useEffect, useRef, useState } from 'react';
import Fretboard from './Fretboard';
import { useAudioSession } from '../../hooks/useAudioSession';
import {
  getChordShape,
  normalizeChordName,
  positionsFromShape,
  shapeFromPositions,
  shapesEqual,
  CHORD_SHAPES,
} from '../../audio/chordShapes';
import { playChordStrum, stopAllChords } from '../../audio/chordSampler';

export default function FingeringTestCard({ card, onAnswer, readOnly = false }) {
  const data = card.task || card.cardData || {};
  const mode = data.fingeringMode || 'GUESS';
  const { ensureAudioReady } = useAudioSession();

  const options = Array.isArray(data.answerOptions)
    ? data.answerOptions
    : typeof data.answerOptions === 'string'
      ? String(data.answerOptions).split(',').map((item) => item.trim()).filter(Boolean)
      : [];

  const targetChord = normalizeChordName(
    data.correctAnswer || data.expectedNote || ''
  );

  const [selected, setSelected] = useState(null);
  const [isRevealed, setIsRevealed] = useState(false);
  const [buildPositions, setBuildPositions] = useState([]);
  const [buildChecked, setBuildChecked] = useState(false);
  const [isPlaying, setIsPlaying] = useState(false);
  const [playError, setPlayError] = useState(null);
  const [startTime] = useState(() => Date.now());
  const playTimerRef = useRef(null);

  const targetShape = targetChord ? CHORD_SHAPES[targetChord] : null;
  const targetPositions = targetShape ? positionsFromShape(targetShape) : [];

  useEffect(() => () => {
    if (playTimerRef.current) clearTimeout(playTimerRef.current);
    stopAllChords();
  }, []);

  // ── Прослушать показанную аппликатуру ──────────────────────
  const playShape = useCallback(async () => {
    if (isPlaying || !targetChord) return;
    setPlayError(null);
    setIsPlaying(true);
    try {
      const audioOk = await ensureAudioReady();
      if (!audioOk) throw new Error('Аудио недоступно');
      stopAllChords();
      await playChordStrum(targetChord, { strumMs: 28, velocity: 0.85 });
    } catch (err) {
      setPlayError(`Не удалось воспроизвести: ${err.message}`);
    } finally {
      if (playTimerRef.current) clearTimeout(playTimerRef.current);
      playTimerRef.current = setTimeout(() => setIsPlaying(false), 900);
    }
  }, [isPlaying, targetChord]);

  // ── GUESS: выбор варианта ──────────────────────────────────
  const handleSelect = useCallback((option) => {
    if (selected || readOnly) return;

    const normalized = normalizeChordName(option) || option;
    const correctNormalized = targetChord || data.correctAnswer;
    const isCorrect = normalized === correctNormalized;

    setSelected(option);
    setIsRevealed(true);
    onAnswer?.({ answer: option, isCorrect, reactionMs: Date.now() - startTime });
  }, [selected, readOnly, targetChord, data.correctAnswer, startTime, onAnswer]);

  const getOptionClass = (option) => {
    if (!isRevealed) return 'answer-option';
    const normalized = normalizeChordName(option) || option;
    if (normalized === (targetChord || data.correctAnswer)) return 'answer-option correct';
    if (option === selected) return 'answer-option incorrect';
    return 'answer-option';
  };

  // ── BUILD: сборка на грифе ─────────────────────────────────
  const handleToggle = useCallback(({ string, fret, action }) => {
    setBuildPositions((prev) => {
      const without = prev.filter((pos) => Number(pos.string) !== Number(string));
      return action === 'set' ? [...without, { string, fret }] : without;
    });
    setBuildChecked(false);
  }, []);

  const checkBuild = useCallback(() => {
    if (!targetShape || readOnly) return;

    const built = shapeFromPositions(buildPositions);
    const isCorrect = shapesEqual(built, targetShape);

    setBuildChecked(true);
    onAnswer?.({
      answer: { chord: targetChord, frets: built, correct: isCorrect },
      isCorrect,
      reactionMs: Date.now() - startTime,
    });
  }, [targetShape, readOnly, buildPositions, targetChord, startTime, onAnswer]);

  // ── Рендер ────────────────────────────────────────────────
  if (!targetChord || !targetShape) {
    return (
      <div className="task-card fingering-test animate-fade-in">
        <div className="task-card-badge badge-fingering">🖐 Аппликатура</div>
        <h3 className="task-card-title">{data.title || 'Аппликатура аккорда'}</h3>
        <div className="alert alert-error">
          Неизвестный аккорд: {data.correctAnswer || data.expectedNote || '—'}
        </div>
      </div>
    );
  }

  return (
    <div className="task-card fingering-test animate-fade-in">
      <div className="task-card-badge badge-fingering">🖐 Аппликатура</div>

      <h3 className="task-card-title">{data.title || 'Аппликатура аккорда'}</h3>
      <p className="task-card-subtitle">
        {data.instruction ||
          (mode === 'BUILD'
            ? `Собери на грифе аппликатуру аккорда ${targetChord}`
            : 'Посмотри на аппликатуру и выбери аккорд')}
      </p>

      {mode === 'GUESS' ? (
        <>
          <Fretboard positions={targetPositions} readOnly />

          <button
            className="btn btn-primary btn-block"
            onClick={playShape}
            disabled={isPlaying}
          >
            {isPlaying ? '🔊 Звучит…' : '▶ Прослушать этот аккорд'}
          </button>

          {playError && <div className="alert alert-error">{playError}</div>}

          <div className="answer-options">
            {options.map((option) => (
              <button
                key={option}
                className={getOptionClass(option)}
                onClick={() => handleSelect(option)}
                disabled={isRevealed || readOnly}
              >
                {option}
              </button>
            ))}
          </div>

          {isRevealed && (
            <div
              className={`answer-feedback ${
                normalizeChordName(selected) === targetChord ? 'is-correct' : 'is-incorrect'
              }`}
            >
              {normalizeChordName(selected) === targetChord
                ? '✅ Верно! Аппликатура узнана!'
                : `❌ Неверно. Это аккорд ${targetChord}`}
            </div>
          )}
        </>
      ) : (
        <>
          <div className="practice-target-wrap">
            <div className="practice-target">
              <span className="practice-target-value">{targetChord}</span>
            </div>
          </div>

          <Fretboard
            positions={buildPositions}
            onToggle={handleToggle}
            status={buildChecked ? (shapesEqual(shapeFromPositions(buildPositions), targetShape) ? 'correct' : 'incorrect') : 'default'}
            overlayPositions={buildChecked && !shapesEqual(shapeFromPositions(buildPositions), targetShape) ? targetPositions : null}
          />

          <p className="task-card-hint">
            Клик по грифу ставит палец, повторный клик — убирает.
            Струна без точки считается приглушённой.
          </p>

          {!readOnly && !buildChecked && (
            <div className="card-actions">
              <button
                className="btn btn-accent btn-lg btn-block"
                onClick={checkBuild}
                disabled={buildPositions.length === 0}
              >
                ✅ Проверить аппликатуру
              </button>
            </div>
          )}

          {buildChecked && (
            <div
              className={`answer-feedback ${
                shapesEqual(shapeFromPositions(buildPositions), targetShape)
                  ? 'is-correct'
                  : 'is-incorrect'
              }`}
            >
              {shapesEqual(shapeFromPositions(buildPositions), targetShape)
                ? '✅ Верно! Аппликатура собрана правильно!'
                : '❌ Не совсем так. Зелёные кружки — верные лады.'}
            </div>
          )}
        </>
      )}
    </div>
  );
}
