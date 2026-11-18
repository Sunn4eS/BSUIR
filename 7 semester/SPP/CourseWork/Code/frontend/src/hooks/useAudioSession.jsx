/**
 * hooks/useAudioSession.jsx — общее состояние аудио/микрофона
 *
 * Провайдер монтируется один раз в main.jsx.
 * Благодаря ему Mic Check, тюнер и карточки используют один и тот же поток.
 */

import { createContext, useCallback, useContext, useEffect, useMemo, useState } from 'react';
import { ensureAudio, enableMic, isMicActive, releaseMic } from '../audio/audioEngine';

const AudioSessionContext = createContext(null);

function mapMicError(error) {
  switch (error?.name) {
    case 'NotAllowedError':
    case 'PermissionDeniedError':
      return 'Доступ к микрофону запрещён. Разрешите его в настройках браузера и попробуйте снова.';
    case 'NotFoundError':
    case 'DevicesNotFoundError':
      return 'Микрофон не найден. Подключите микрофон и обновите страницу.';
    case 'NotReadableError':
    case 'TrackStartError':
      return 'Микрофон занят другим приложением. Закройте его и попробуйте снова.';
    case 'SecurityError':
      return 'Доступ к микрофону возможен только по HTTPS или на localhost.';
    case 'MicTimeoutError':
      return 'Браузер не ответил на запрос доступа к микрофону. Проверьте разрешения в настройках сайта и попробуйте снова.';
    default:
      return `Не удалось получить доступ к микрофону: ${error?.message || 'неизвестная ошибка'}`;
  }
}

export function AudioSessionProvider({ children }) {
  const [micState, setMicState] = useState(() => (isMicActive() ? 'ready' : 'idle'));
  const [error, setError] = useState(null);

  const ensureAudioReady = useCallback(async () => {
    try {
      await ensureAudio();
      return true;
    } catch (err) {
      setError(`Не удалось запустить аудио: ${err.message}`);
      return false;
    }
  }, []);

  const startMic = useCallback(async () => {
    if (isMicActive()) {
      setMicState('ready');
      setError(null);
      return { ok: true };
    }

    setMicState('requesting');
    setError(null);

    try {
      await enableMic();
      setMicState('ready');
      return { ok: true };
    } catch (err) {
      const message = mapMicError(err);
      setError(message);
      setMicState(err?.name === 'NotAllowedError' || err?.name === 'PermissionDeniedError' ? 'denied' : 'error');
      return { ok: false, error: message };
    }
  }, []);

  const stopMic = useCallback(() => {
    releaseMic();
    setMicState('idle');
    setError(null);
  }, []);

  useEffect(() => {
    return () => {
      releaseMic();
    };
  }, []);

  const value = useMemo(
    () => ({
      micState,
      micReady: micState === 'ready',
      isRequesting: micState === 'requesting',
      error,
      startMic,
      stopMic,
      ensureAudioReady,
      clearError: () => setError(null),
    }),
    [micState, error, startMic, stopMic, ensureAudioReady]
  );

  return <AudioSessionContext.Provider value={value}>{children}</AudioSessionContext.Provider>;
}

export function useAudioSession() {
  const context = useContext(AudioSessionContext);

  if (!context) {
    throw new Error('useAudioSession must be used within AudioSessionProvider');
  }

  return context;
}
