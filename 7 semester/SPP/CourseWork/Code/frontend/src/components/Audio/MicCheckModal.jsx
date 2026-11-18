/**
 * components/Audio/MicCheckModal.jsx — обязательная проверка микрофона
 *
 * Показывает уровень сигнала и не даёт продолжить, пока пользователь
 * реально не сыграет ноту/не скажет что-то в микрофон.
 */

import { useCallback, useEffect, useState } from 'react';
import { getLevel } from '../../audio/audioEngine';
import { useAudioSession } from '../../hooks/useAudioSession';
import VolumeMeter from './VolumeMeter';

export default function MicCheckModal({
  open,
  onClose,
  onReady,
  title = 'Проверка микрофона',
  description = 'Чтобы тюнер и задания на игру работали, приложению нужен доступ к микрофону.',
  required = true,
}) {
  const { micReady, isRequesting, error, startMic, clearError } = useAudioSession();
  const [hasSignal, setHasSignal] = useState(false);
  const [isStarting, setIsStarting] = useState(false);

  // Сбрасываем индикатор при каждом открытии
  useEffect(() => {
    if (open) setHasSignal(false);
  }, [open]);

  // Слушаем уровень, пока микрофон готов
  useEffect(() => {
    if (!open || !micReady) return undefined;

    let rafId;
    let lastUpdate = 0;

    const loop = (timestamp) => {
      if (timestamp - lastUpdate > 80) {
        const { db } = getLevel();
        if (db > -45) setHasSignal(true);
        lastUpdate = timestamp;
      }
      rafId = requestAnimationFrame(loop);
    };

    rafId = requestAnimationFrame(loop);

    return () => {
      if (rafId) cancelAnimationFrame(rafId);
    };
  }, [open, micReady]);

  const handleEnable = useCallback(async () => {
    clearError();
    setIsStarting(true);
    await startMic();
    setIsStarting(false);
  }, [clearError, startMic]);

  const handleContinue = useCallback(() => {
    onReady?.();
    onClose?.();
  }, [onReady, onClose]);

  if (!open) return null;

  return (
    <div className="modal-overlay" role="dialog" aria-modal="true" aria-labelledby="mic-check-title">
      <div className="modal-content mic-check-modal">
        <div className="mic-check-icon" aria-hidden="true">🎤</div>

        <h2 id="mic-check-title" style={{ marginBottom: '10px' }}>
          {title}
        </h2>
        <p className="mic-check-description">{description}</p>

        {!micReady ? (
          <>
            <button
              type="button"
              className="btn btn-primary btn-lg"
              onClick={handleEnable}
              disabled={isRequesting || isStarting}
              style={{ width: '100%', marginBottom: '16px' }}
            >
              {isRequesting || isStarting ? 'Запрашиваем доступ…' : 'Разрешить микрофон'}
            </button>

            {error && (
              <div className="alert alert-error" role="alert">
                ⚠️ {error}
              </div>
            )}

            <p className="mic-check-hint">
              Браузер покажет запрос разрешения. Нажмите «Разрешить». Доступ нужен только
              для анализа звука — запись никуда не отправляется.
            </p>

            <button type="button" className="btn btn-ghost" onClick={onClose} style={{ width: '100%' }}>
              Отмена
            </button>
          </>
        ) : (
          <>
            <VolumeMeter active={micReady} />

            <div className={`mic-check-status ${hasSignal ? 'is-ok' : ''}`}>
              {hasSignal ? '✅ Микрофон работает — сигнал есть' : '🎸 Сыграйте любую ноту или скажите что-нибудь'}
            </div>

            <div className="mic-check-actions">
              <button type="button" className="btn btn-ghost" onClick={onClose}>
                Отмена
              </button>
              <button
                type="button"
                className="btn btn-primary"
                onClick={handleContinue}
                disabled={required && !hasSignal}
              >
                Продолжить →
              </button>
            </div>

            {required && !hasSignal && (
              <p className="mic-check-hint" style={{ marginTop: '14px', marginBottom: 0 }}>
                Проверьте, что микрофон не выключен и уровень сигнала двигается.
              </p>
            )}
          </>
        )}
      </div>
    </div>
  );
}
