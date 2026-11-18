/**
 * components/Cards/EarTrainingCard.jsx
 * Карточка EAR_TRAINING: играем реальный гитарный семпл, ученик выбирает ответ.
 */

import { useCallback, useEffect, useRef, useState } from 'react';
import { playNote, playExpected, stopAllSounds } from '../../audio/guitarSampler';
import { useAudioSession } from '../../hooks/useAudioSession';

export default function EarTrainingCard({ card, onAnswer, readOnly = false }) {
  const { ensureAudioReady } = useAudioSession();

  const [selected, setSelected] = useState(null);
  const [isRevealed, setIsRevealed] = useState(false);
  const [startTime] = useState(() => Date.now());
  const [isPlaying, setIsPlaying] = useState(false);
  const [playError, setPlayError] = useState(null);

  const playTimerRef = useRef(null);

  const data = card.task || card.cardData || {};

  const options = Array.isArray(data.answerOptions)
    ? data.answerOptions
    : (typeof data.answerOptions === 'string'
        ? JSON.parse(data.answerOptions)
        : ['A', 'B', 'C', 'D']);

  const target = data.correctAnswer || data.expectedNote || 'A';

  // Если все варианты — одиночные ноты (A, B, C…), играем ноту,
  // а не аккорд с таким же названием.
  const isNoteMode = options.length > 0
    && options.every((option) => /^[A-G][#b]?$/.test(String(option).trim()));

  useEffect(() => () => {
    if (playTimerRef.current) clearTimeout(playTimerRef.current);
    stopAllSounds();
  }, []);

  const playSound = useCallback(async () => {
    if (isPlaying) return;

    setPlayError(null);
    setIsPlaying(true);

    try {
      // AudioContext возобновляется строго внутри клика
      const audioOk = await ensureAudioReady();
      if (!audioOk) throw new Error('Аудио недоступно');

      stopAllSounds();

      if (isNoteMode) {
        const noteToPlay = /\d$/.test(target) ? target : `${target}4`;
        await playNote(noteToPlay, '2n', 0.85);
      } else {
        await playExpected(target, '2n', 0.85);
      }
    } catch (err) {
      setPlayError(`Не удалось воспроизвести звук: ${err.message}`);
    } finally {
      // Даём семплу отзвучать, но не блокируем кнопку навсегда
      if (playTimerRef.current) clearTimeout(playTimerRef.current);
      playTimerRef.current = setTimeout(() => setIsPlaying(false), 900);
    }
  }, [isPlaying, ensureAudioReady, isNoteMode, target]);

  const handleSelect = useCallback((option) => {
    if (selected || readOnly) return;

    setSelected(option);
    setIsRevealed(true);

    onAnswer?.({
      answer: option,
      isCorrect: option === data.correctAnswer,
      reactionMs: Date.now() - startTime,
    });
  }, [selected, readOnly, data.correctAnswer, startTime, onAnswer]);

  const getOptionClass = (option) => {
    if (!isRevealed) return 'answer-option';
    if (option === data.correctAnswer) return 'answer-option correct';
    if (option === selected) return 'answer-option incorrect';
    return 'answer-option';
  };

  const isCorrect = selected === data.correctAnswer;

  return (
    <div className="task-card ear-training animate-fade-in">
      <div className="task-card-badge badge-ear">🎵 Тренировка слуха</div>

      <h3 className="task-card-title">{data.title || card.title || 'Угадай ноту'}</h3>
      <p className="task-card-subtitle">
        {data.instruction || 'Прослушай звук и выбери правильный ответ'}
      </p>

      <button
        className="btn btn-primary btn-lg btn-block"
        onClick={playSound}
        disabled={isPlaying}
      >
        {isPlaying ? '🔊 Звучит…' : '▶ Воспроизвести звук'}
      </button>

      <p className="task-card-hint">Можно прослушать несколько раз</p>

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
        <div className={`answer-feedback ${isCorrect ? 'is-correct' : 'is-incorrect'}`}>
          {isCorrect
            ? '✅ Верно! Отличный слух!'
            : `❌ Неверно. Правильный ответ: ${data.correctAnswer}`}
        </div>
      )}
    </div>
  );
}
