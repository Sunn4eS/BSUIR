import { useEffect, useRef, useState } from 'react';
import { getLevel } from '../../audio/audioEngine';

export default function VolumeMeter({ active = true, bars = 18 }) {
  const [level, setLevel] = useState({ normalized: 0, db: -Infinity });
  const rafRef = useRef(null);
  const lastUpdateRef = useRef(0);

  useEffect(() => {
    if (!active) {
      setLevel({ normalized: 0, db: -Infinity });
      return undefined;
    }

    const loop = (timestamp) => {
      if (timestamp - lastUpdateRef.current > 50) {
        setLevel(getLevel());
        lastUpdateRef.current = timestamp;
      }
      rafRef.current = requestAnimationFrame(loop);
    };

    rafRef.current = requestAnimationFrame(loop);

    return () => {
      if (rafRef.current) cancelAnimationFrame(rafRef.current);
    };
  }, [active]);

  const activeBars = Math.round(level.normalized * bars);
  const color =
    level.db > -12
      ? 'var(--color-error)'
      : level.db > -30
        ? 'var(--color-warning)'
        : 'var(--color-success)';

  const dbLabel = Number.isFinite(level.db) ? `${Math.round(level.db)} dBFS` : 'тишина';

  return (
    <div className="volume-meter-wrap">
      <div className="volume-meter" role="meter" aria-valuemin={0} aria-valuemax={100} aria-valuenow={Math.round(level.normalized * 100)}>
        {Array.from({ length: bars }).map((_, index) => (
          <span
            key={index}
            className={`volume-bar ${index < activeBars ? 'active' : ''}`}
            style={{
              background: index < activeBars ? color : 'var(--color-bg-muted)',
            }}
          />
        ))}
      </div>

      <div className="volume-meter-label">
        <span>Уровень сигнала</span>
        <span style={{ color: activeBars > 0 ? color : 'var(--color-text-muted)', fontWeight: 700 }}>
          {dbLabel}
        </span>
      </div>
    </div>
  );
}
