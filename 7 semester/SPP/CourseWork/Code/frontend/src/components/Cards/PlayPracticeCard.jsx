import { useCallback, useEffect, useState } from 'react';
import { useAudioAnalyzer } from '../../hooks/useAudioAnalyzer';
import { useAudioSession } from '../../hooks/useAudioSession';
import MicCheckModal from '../Audio/MicCheckModal';

export default function PlayPracticeCard({ card, onAnswer, readOnly = false }) {
  const [phase, setPhase] = useState('idle');
  const [startTime] = useState(() => Date.now());
  const [showMicCheck, setShowMicCheck] = useState(false);

  const { micReady } = useAudioSession();

  const data = card.task || card.cardData || {};
  const expectedNote = data.expectedNote || 'E4';
  const toleranceCents = data.toleranceCents ?? 20;

  const handleSuccess = useCallback((payload) => {
    setPhase('success');
    stopListening();
    onAnswer?.({
      answer: 'correct',
      isCorrect: true,
      reactionMs: Date.now() - startTime,
      ...payload,
    });
  }, [startTime, onAnswer]);

  const {
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
  } = useAudioAnalyzer({
    expectedNote,
    toleranceCents,
    onSuccess: handleSuccess,
    holdMs: 700,
  });

  useEffect(() => () => stopListening(), [stopListening]);

  const beginListening = useCallback(() => {
    setPhase('listening');
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
    setPhase('idle');
    stopListening();
  }, [stopListening]);

  const ringColor =
    phase === 'success'
      ? 'var(--color-success)'
      : isCorrect === true
        ? 'var(--color-success)'
        : isCorrect === false
          ? 'var(--color-error)'
          : 'var(--color-primary)';

  const detectedLabel = detectedChord
    ? detectedChord
    : detectedNote
      ? `${detectedNote.name}${detectedNote.octave}`
      : '—';

  return (
    <div className="task-card play-practice animate-fade-in">
      <div className="task-card-badge badge-play">🎸 Практика игры</div>

      <h3 className="task-card-title">{data.title || 'Сыграй задание'}</h3>
      <p className="task-card-subtitle">
        {data.instruction || 'Сыграй и удержи ноту или аккорд'}
      </p>

      <div className="practice-target-wrap">
        <div
          className={`practice-target ${phase === 'success' ? 'is-success' : ''}`}
          style={{ borderColor: ringColor }}
        >
          <span className="practice-target-value">{expectedNote}</span>
        </div>

        <p className="task-card-hint">
          {expected?.kind === 'chord' ? 'Аккорд' : 'Нота'} · допуск ±{toleranceCents} центов
        </p>
      </div>

      {isListening && (
        <div className="detector-box" style={{ borderColor: ringColor }}>
          <div className="detector-value" style={{ color: ringColor }}>
            {detectedLabel}
          </div>
          <div className="detector-hint">
            {pitchHz > 0 ? `${pitchHz} Гц` : detectedChord ? 'Аккорд' : 'Играй…'}
          </div>

          <div className="detector-progress">
            <div className="detector-progress-labels">
              <span>Совпадение</span>
              <span>{confidence}%</span>
            </div>
            <div className="progress-bar">
              <div
                className="progress-bar-fill"
                style={{
                  width: `${confidence}%`,
                  background: isCorrect
                    ? 'var(--color-success)'
                    : 'linear-gradient(90deg, var(--color-primary), var(--color-accent))',
                }}
              />
            </div>
          </div>

          {progress > 0 && (
            <div className="detector-progress" style={{ marginTop: '10px' }}>
              <div className="detector-progress-labels">
                <span>Удержание</span>
                <span>{progress}%</span>
              </div>
              <div className="progress-bar">
                <div
                  className="progress-bar-fill is-success"
                  style={{ width: `${progress}%` }}
                />
              </div>
            </div>
          )}
        </div>
      )}

      {error && <div className="alert alert-error">⚠️ {error}</div>}

      {!readOnly && phase !== 'success' && (
        <div className="card-actions">
          {!isListening ? (
            <button className="btn btn-accent btn-lg btn-block" onClick={handleStart}>
              🎤 Начать играть
            </button>
          ) : (
            <button className="btn btn-ghost btn-lg btn-block" onClick={handleStop}>
              ⏹ Остановить
            </button>
          )}
        </div>
      )}

      {phase === 'success' && (
        <div className="answer-feedback is-correct">
          🎉 Отлично! Задание выполнено верно!
        </div>
      )}

      {isListening && (
        <div className="live-indicator is-centered">
          <div className="live-dot" style={{ background: 'var(--color-accent)' }} />
          <span>Анализирую звук…</span>
        </div>
      )}

      <MicCheckModal
        open={showMicCheck}
        onClose={() => setShowMicCheck(false)}
        onReady={handleMicReady}
        title="Проверка микрофона"
        description={`Сыграйте «${expectedNote}» — проверим, что микрофон слышит инструмент.`}
      />
    </div>
  );
}
