/**
 * components/Cards/PlayFingeringCard.jsx
 * Карточка PLAY_FINGERING: сыграй аккорд по заданной аппликатуре.
 *
 * Ученик видит название аккорда, его аппликатуру на грифе и может
 * прослушать эталон («чёс» реальными сэмплами). Затем поочерёдно
 * щипывает струны — ChordPlayChallenge слушает микрофон.
 */

import { useCallback, useEffect, useState } from 'react';
import Fretboard from './Fretboard';
import ChordPlayChallenge from './ChordPlayChallenge';
import { useAudioSession } from '../../hooks/useAudioSession';
import {
  normalizeChordName,
  positionsFromShape,
  CHORD_SHAPES,
} from '../../audio/chordShapes';
import { playChordStrum, stopAllChords } from '../../audio/chordSampler';

export default function PlayFingeringCard({ card, onAnswer, readOnly = false }) {
  const data = card.task || card.cardData || {};
  const chord = normalizeChordName(data.expectedNote || '');
  const shape = chord ? CHORD_SHAPES[chord] : null;
  const positions = shape ? positionsFromShape(shape) : [];

  const [startTime] = useState(() => Date.now());
  const [isPlaying, setIsPlaying] = useState(false);
  const [playError, setPlayError] = useState(null);
  const { ensureAudioReady } = useAudioSession();

  useEffect(() => () => {
    stopAllChords();
  }, []);

  const handlePlay = useCallback(async () => {
    if (isPlaying || !chord) return;
    setPlayError(null);
    setIsPlaying(true);
    try {
      const audioOk = await ensureAudioReady();
      if (!audioOk) throw new Error('Аудио недоступно');
      stopAllChords();
      await playChordStrum(chord, { strumMs: 28, velocity: 0.85 });
    } catch (err) {
      setPlayError(`Не удалось воспроизвести: ${err.message}`);
    } finally {
      setTimeout(() => setIsPlaying(false), 900);
    }
  }, [isPlaying, chord, ensureAudioReady]);

  const handleDone = useCallback(
    (payload) => {
      onAnswer?.({
        answer: true,
        isCorrect: payload?.correct === true,
        reactionMs: Date.now() - startTime,
        ...payload,
      });
    },
    [onAnswer, startTime]
  );

  if (!chord || !shape) {
    return (
      <div className="task-card play-fingering animate-fade-in">
        <div className="task-card-badge badge-fingering">🖐 Аппликатура</div>
        <h3 className="task-card-title">{data.title || 'Сыграй аппликатуру'}</h3>
        <div className="alert alert-error">
          Неизвестный аккорд: {data.expectedNote || '—'}
        </div>
      </div>
    );
  }

  return (
    <div className="task-card play-fingering animate-fade-in">
      <div className="task-card-badge badge-fingering">🖐 Сыграй аппликатуру</div>

      <h3 className="task-card-title">{data.title || `Сыграй аккорд ${chord}`}</h3>
      <p className="task-card-subtitle">
        {data.instruction ||
          'Возьми аккорд по этой аппликатуре и поочерёдно щипни все струны'}
      </p>

      <div className="practice-target-wrap">
        <div className="practice-target">
          <span className="practice-target-value">{chord}</span>
        </div>
      </div>

      <Fretboard positions={positions} readOnly />

      <button
        className="btn btn-primary btn-block"
        onClick={handlePlay}
        disabled={isPlaying}
      >
        {isPlaying ? '🔊 Звучит…' : '▶ Прослушать эталон'}
      </button>

      {playError && <div className="alert alert-error">{playError}</div>}

      <ChordPlayChallenge chord={chord} onDone={handleDone} readOnly={readOnly} />
    </div>
  );
}
