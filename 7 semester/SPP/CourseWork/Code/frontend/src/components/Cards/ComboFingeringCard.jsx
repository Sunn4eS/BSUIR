/**
 * components/Cards/ComboFingeringCard.jsx
 * Комбинированная карточка COMBO_FINGERING:
 *   фаза 1 — собери аппликатуру аккорда на грифе;
 *   фаза 2 — сыграй её (микрофон).
 *
 * Ответ отправляется после обеих фаз: собрать верно + сыграть верно.
 */

import { useCallback, useState } from 'react';
import Fretboard from './Fretboard';
import ChordPlayChallenge from './ChordPlayChallenge';
import {
  normalizeChordName,
  positionsFromShape,
  shapeFromPositions,
  shapesEqual,
  CHORD_SHAPES,
} from '../../audio/chordShapes';

export default function ComboFingeringCard({ card, onAnswer, readOnly = false }) {
  const data = card.task || card.cardData || {};
  const chord = normalizeChordName(data.expectedNote || data.correctAnswer || '');
  const shape = chord ? CHORD_SHAPES[chord] : null;
  const targetPositions = shape ? positionsFromShape(shape) : [];

  // build | play | done
  const [phase, setPhase] = useState('build');
  const [buildPositions, setBuildPositions] = useState([]);
  const [buildCorrect, setBuildCorrect] = useState(false);
  const [startTime] = useState(() => Date.now());

  const handleToggle = useCallback(({ string, fret, action }) => {
    setBuildPositions((prev) => {
      const without = prev.filter((pos) => Number(pos.string) !== Number(string));
      return action === 'set' ? [...without, { string, fret }] : without;
    });
  }, []);

  const builtCorrect = shapesEqual(shapeFromPositions(buildPositions), shape);

  const checkBuild = useCallback(() => {
    if (readOnly) return;
    const isCorrect = builtCorrect;
    setBuildCorrect(isCorrect);
    setPhase(isCorrect ? 'play' : 'play');
    // Неправильная сборка не блокирует вторую фазу — пусть попробует
    // сыграть так, как собрал, и узнает результат в конце.
  }, [builtCorrect, readOnly]);

  const handlePlayed = useCallback(
    (payload) => {
      const isCorrect = Boolean(payload?.correct) && buildCorrect;
      setPhase('done');
      onAnswer?.({
        answer: { chord, frets: shapeFromPositions(buildPositions), correct: isCorrect },
        isCorrect,
        reactionMs: Date.now() - startTime,
      });
    },
    [buildCorrect, buildPositions, chord, onAnswer, startTime]
  );

  if (!chord || !shape) {
    return (
      <div className="task-card combo-fingering animate-fade-in">
        <div className="task-card-badge badge-fingering">🖐 Аппликатура</div>
        <h3 className="task-card-title">{data.title || 'Собери и сыграй'}</h3>
        <div className="alert alert-error">
          Неизвестный аккорд: {data.expectedNote || '—'}
        </div>
      </div>
    );
  }

  return (
    <div className="task-card combo-fingering animate-fade-in">
      <div className="task-card-badge badge-fingering">🖐 Собери и сыграй</div>

      <h3 className="task-card-title">{data.title || `Аккорд ${chord}: собери и сыграй`}</h3>
      <p className="task-card-subtitle">
        {data.instruction ||
          'Сначала собери аппликатуру аккорда, затем сыграй её по струне за струной'}
      </p>

      {/* Степпер фаз */}
      <div className="combo-steps">
        <span className={`combo-step ${phase !== 'build' ? 'is-done' : 'is-active'}`}>
          1 · Собрать
        </span>
        <span className="combo-step-arrow">→</span>
        <span
          className={`combo-step ${
            phase === 'play' ? 'is-active' : phase === 'done' ? 'is-done' : ''
          }`}
        >
          2 · Сыграть
        </span>
      </div>

      {phase === 'build' && (
        <>
          <div className="practice-target-wrap">
            <div className="practice-target">
              <span className="practice-target-value">{chord}</span>
            </div>
          </div>

          <Fretboard
            positions={buildPositions}
            onToggle={handleToggle}
            status={buildPositions.length > 0 && builtCorrect ? 'correct' : 'default'}
          />

          <p className="task-card-hint">
            Клик по грифу ставит палец, повторный клик — убирает.
            Струна без точки считается приглушённой.
          </p>

          {!readOnly && (
            <div className="card-actions">
              <button
                className="btn btn-accent btn-lg btn-block"
                onClick={checkBuild}
                disabled={buildPositions.length === 0}
              >
                🎸 Собрал — играть!
              </button>
            </div>
          )}
        </>
      )}

      {phase === 'play' && (
        <>
          {!buildCorrect && (
            <div className="alert alert-warning">
              Аппликатура собрана неточно — зелёные кружки показывают верные лады.
              Всё равно попробуй сыграть!
            </div>
          )}
          {buildCorrect && (
            <div className="answer-feedback is-correct" style={{ marginBottom: '12px' }}>
              ✅ Аппликатура собрана верно! Теперь сыграй её.
            </div>
          )}

          <Fretboard
            positions={buildPositions}
            readOnly
            status={builtCorrect ? 'correct' : 'incorrect'}
            overlayPositions={builtCorrect ? null : targetPositions}
          />

          <ChordPlayChallenge chord={chord} onDone={handlePlayed} readOnly={readOnly} />
        </>
      )}

      {phase === 'done' && (
        <div className={`answer-feedback ${buildCorrect ? 'is-correct' : 'is-incorrect'}`}>
          {buildCorrect
            ? '🎉 Отлично! Аккорд собран и сыгран верно!'
            : '❌ Аппликатура была собрана неточно — зелёные кружки показывают верные лады.'}
        </div>
      )}

      {phase === 'done' && (
        <div style={{ marginTop: '12px' }}>
          <Fretboard
            positions={buildPositions}
            readOnly
            status={builtCorrect ? 'correct' : 'incorrect'}
            overlayPositions={builtCorrect ? null : targetPositions}
          />
        </div>
      )}
    </div>
  );
}
