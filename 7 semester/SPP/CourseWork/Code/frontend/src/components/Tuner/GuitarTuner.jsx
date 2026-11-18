/**
 * components/Tuner/GuitarTuner.jsx — гитарный тюнер
 *
 * Использует общий AudioContext и микрофонный поток (useAudioSession).
 * Перед первым запуском обязательно показывает Mic Check.
 */

import { useCallback, useState } from 'react';
import { useGuitarTuner } from '../../hooks/useGuitarTuner';
import { useAudioSession } from '../../hooks/useAudioSession';
import MicCheckModal from '../Audio/MicCheckModal';

const STATUS_CONFIG = {
  'in-tune': { color: 'var(--color-success)', label: 'В строю ✓', emoji: '✅' },
  'too-low': { color: 'var(--color-warning)', label: '↑ Натяни', emoji: '⬆️' },
  'too-high': { color: 'var(--color-error)', label: '↓ Ослабь', emoji: '⬇️' },
  'no-signal': { color: 'var(--color-text-muted)', label: 'Играй...', emoji: '🎸' },
};

const STRING_LABELS = [
  { label: '6E', freq: 82.41, note: 'E2' },
  { label: '5A', freq: 110.0, note: 'A2' },
  { label: '4D', freq: 146.83, note: 'D3' },
  { label: '3G', freq: 196.0, note: 'G3' },
  { label: '2B', freq: 246.94, note: 'B3' },
  { label: '1E', freq: 329.63, note: 'E4' },
];

export default function GuitarTuner() {
  const { isActive, note, string: currentString, centsOff, status, confidence, error, start, stop } =
    useGuitarTuner();
  const { micReady } = useAudioSession();

  const [showMicCheck, setShowMicCheck] = useState(false);

  const statusCfg = STATUS_CONFIG[status] || STATUS_CONFIG['no-signal'];
  const indicatorPos = Math.max(5, Math.min(95, 50 + centsOff));

  const handleStart = useCallback(() => {
    if (!micReady) {
      setShowMicCheck(true);
      return;
    }
    start();
  }, [micReady, start]);

  const handleMicReady = useCallback(() => {
    setShowMicCheck(false);
    start();
  }, [start]);

  const isCurrent = (targetNote) =>
    note && `${note.name}${note.octave}` === targetNote;

  return (
    <div className="tuner-display animate-fade-in">
      <div className="section-header">
        <div>
          <h3 className="section-title">🎸 Гитарный тюнер</h3>
          <p className="section-subtitle">Стандартный строй (EADGBE)</p>
        </div>

        <button
          className={isActive ? 'btn btn-danger btn-sm' : 'btn btn-primary btn-sm'}
          onClick={isActive ? stop : handleStart}
        >
          {isActive ? '⏹ Стоп' : '🎤 Старт'}
        </button>
      </div>

      {error && <div className="alert alert-error">⚠️ {error}</div>}

      <div className="tuner-main">
        <div className="tuner-note" style={{ color: statusCfg.color }} key={note?.name}>
          {isActive ? (note ? `${note.name}${note.octave}` : '—') : '—'}
        </div>

        <div className="tuner-cents">
          {isActive && note
            ? `${centsOff > 0 ? '+' : ''}${centsOff} центов`
            : 'Нажми «Старт»'}
        </div>

        <div
          className="tuner-status-pill"
          style={{
            background: `${statusCfg.color}18`,
            borderColor: `${statusCfg.color}44`,
            color: statusCfg.color,
          }}
        >
          {statusCfg.label}
        </div>

        {isActive && note && (
          <div className="tuner-confidence">
            Точность распознавания: {confidence}%
            {currentString ? ` · ближайшая струна ${currentString.string}` : ''}
          </div>
        )}
      </div>

      <div className="tuner-scale">
        <div className="tuner-scale-labels">
          <span>-50¢</span>
          <span>-25¢</span>
          <span className="is-zero">0</span>
          <span>+25¢</span>
          <span>+50¢</span>
        </div>

        <div className="tuner-bar-container">
          <div className="tuner-bar-center" />
          {isActive && note && (
            <div
              className="tuner-bar-indicator"
              style={{ left: `${indicatorPos}%`, background: statusCfg.color }}
            />
          )}
        </div>
      </div>

      <div className="tuner-strings">
        {STRING_LABELS.map((s) => {
          const active = isCurrent(s.note);
          return (
            <div
              key={s.label}
              className={`tuner-string ${active ? 'is-active' : ''}`}
              style={
                active
                  ? { borderColor: statusCfg.color, background: `${statusCfg.color}14` }
                  : undefined
              }
            >
              <div className="tuner-string-label" style={active ? { color: statusCfg.color } : undefined}>
                {s.label}
              </div>
              <div className="tuner-string-freq">{s.freq}Hz</div>
            </div>
          );
        })}
      </div>

      {isActive && (
        <div className="live-indicator is-centered">
          <div className="live-dot" style={{ background: 'var(--color-success)' }} />
          <span>Слушаю микрофон…</span>
        </div>
      )}

      <MicCheckModal
        open={showMicCheck}
        onClose={() => setShowMicCheck(false)}
        onReady={handleMicReady}
        title="Проверка микрофона для тюнера"
        description="Сыграйте любую струну — мы проверим, что микрофон слышит гитару."
      />
    </div>
  );
}
