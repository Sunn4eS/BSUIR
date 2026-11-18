/**
 * components/Cards/Fretboard.jsx — интерактивный гитарный гриф (SVG)
 *
 * Ориентация: струны горизонтально, низкая E внизу, высокая e наверху
 * (как будто гитара лежит на коленях ученика). Лады — вертикальные
 * линии, «порожек» (nut) — утолщённая линия слева.
 *
 * Режимы:
 *  - интерактивный: onToggle({string, fret}) — клик по ячейке ставит/
 *    снимает палец (одна позиция на струну; струна без точки = приглушена);
 *  - readOnly: просто показывает позиции (например, заданную аппликатуру).
 *
 * Гриф авто-расширяется под баррэ на 8-м ладу (D#m/A#m: x68876).
 */

import { useCallback, useMemo } from 'react';
import { GUITAR_STANDARD_TUNING } from '../../audio/noteUtils';
import { maxFretOfShape, shapeFromPositions } from '../../audio/chordShapes';

const STRING_GAP = 26;   // расстояние между струнами
const FRET_GAP = 44;     // ширина одного лада
const OPEN_ZONE = 26;    // зона открытой струны (слева от порожка)
const PAD_LEFT = 26;     // подписи струн
const PAD_TOP = 18;
const PAD_BOTTOM = 22;   // номера ладов

/** Подпись струны: низкая E заглавной, высокая e строчной */
function stringLabel(stringNumber) {
  if (stringNumber === 1) return 'e';
  const entry = GUITAR_STANDARD_TUNING.find((item) => item.string === stringNumber);
  return entry ? entry.name : '';
}

export default function Fretboard({
  positions = [],
  onToggle = null,
  readOnly = false,
  minFret = 12,
  overlayPositions = null, // «эталонная» аппликатура — полые зелёные точки
  status = 'default',     // default | correct | incorrect
}) {
  const interactive = !readOnly && typeof onToggle === 'function';

  // Сколько ладов рисуем: минимум minFret, но хватает баррэ-формам
  const fretCount = useMemo(() => {
    const needed = maxFretOfShape(shapeFromPositions(positions));
    const overlayNeeded = maxFretOfShape(shapeFromPositions(overlayPositions || []));
    return Math.max(minFret, needed, overlayNeeded);
  }, [positions, overlayPositions, minFret]);

  // Геометрия
  const geometry = useMemo(() => {
    const stringsTop = PAD_TOP;
    const stringsBottom = PAD_TOP + STRING_GAP * 5;
    const nutX = PAD_LEFT + OPEN_ZONE;
    const width = nutX + FRET_GAP * fretCount + 16;
    const height = stringsBottom + PAD_BOTTOM;

    const stringY = (stringNumber) => PAD_TOP + (stringNumber - 1) * STRING_GAP;
    const cellCenterX = (fret) =>
      fret === 0 ? nutX - OPEN_ZONE / 2 : nutX + (fret - 0.5) * FRET_GAP;
    const fretLineX = (fret) => nutX + fret * FRET_GAP;

    return { stringsTop, stringsBottom, nutX, width, height, stringY, cellCenterX, fretLineX };
  }, [fretCount]);

  const { width, height, nutX, stringY, cellCenterX, fretLineX, stringsTop, stringsBottom } = geometry;

  // Позиция на струне (или null)
  const positionOnString = useCallback(
    (stringNumber) => positions.find((pos) => Number(pos.string) === stringNumber) || null,
    [positions]
  );

  const handleClick = useCallback(
    (stringNumber, fret) => {
      if (!interactive) return;
      const existing = positionOnString(stringNumber);
      if (existing && Number(existing.fret) === fret) {
        onToggle({ string: stringNumber, fret, action: 'remove' });
      } else {
        onToggle({ string: stringNumber, fret, action: 'set' });
      }
    },
    [interactive, onToggle, positionOnString]
  );

  const dotColor =
    status === 'correct'
      ? 'var(--color-success, #22c55e)'
      : status === 'incorrect'
        ? 'var(--color-error, #ef4444)'
        : 'var(--color-primary, #7c3aed)';

  const stringNumbers = [1, 2, 3, 4, 5, 6];

  return (
    <div className={`fretboard-wrap ${interactive ? 'is-interactive' : ''}`}>
      <svg
        className="fretboard-svg"
        viewBox={`0 0 ${width} ${height}`}
        role="img"
        aria-label="Гитарный гриф"
      >
        {/* Зона открытых струн + порожек */}
        <line
          x1={nutX} y1={stringsTop - 4} x2={nutX} y2={stringsBottom + 4}
          stroke="var(--color-text-primary, #1f2937)"
          strokeWidth="4"
          strokeLinecap="round"
        />

        {/* Лады */}
        {Array.from({ length: fretCount }, (_, i) => i + 1).map((fret) => (
          <line
            key={`fret-${fret}`}
            x1={fretLineX(fret)} y1={stringsTop}
            x2={fretLineX(fret)} y2={stringsBottom}
            stroke="var(--color-border, #d1d5db)"
            strokeWidth="2"
            strokeLinecap="round"
          />
        ))}

        {/* Маркеры ладов (3, 5, 7, 9 — одинарная точка, 12 — двойная точка) */}
        {[3, 5, 7, 9].filter((fret) => fret <= fretCount).map((fret) => (
          <circle
            key={`marker-${fret}`}
            cx={cellCenterX(fret)}
            cy={(stringY(3) + stringY(4)) / 2}
            r="4.5"
            fill="var(--color-border, #cbd5e1)"
            opacity="0.8"
          />
        ))}
        {[12].filter((fret) => fret <= fretCount).map((fret) => (
          <g key={`marker-double-${fret}`}>
            <circle
              cx={cellCenterX(fret)}
              cy={(stringY(2) + stringY(3)) / 2}
              r="4"
              fill="var(--color-border, #cbd5e1)"
              opacity="0.8"
            />
            <circle
              cx={cellCenterX(fret)}
              cy={(stringY(4) + stringY(5)) / 2}
              r="4"
              fill="var(--color-border, #cbd5e1)"
              opacity="0.8"
            />
          </g>
        ))}

        {/* Струны: от высокой e (1) сверху к низкой E (6) внизу */}
        {stringNumbers.map((stringNumber) => {
          const thickness = 1 + (6 - stringNumber) * 0.45;
          return (
            <line
              key={`string-${stringNumber}`}
              x1={PAD_LEFT} y1={stringY(stringNumber)}
              x2={nutX + FRET_GAP * fretCount + 8} y2={stringY(stringNumber)}
              stroke="var(--color-text-muted, #9ca3af)"
              strokeWidth={thickness}
              strokeLinecap="round"
            />
          );
        })}

        {/* Подписи струн слева */}
        {stringNumbers.map((stringNumber) => (
          <text
            key={`label-${stringNumber}`}
            x={PAD_LEFT - 8}
            y={stringY(stringNumber) + 4}
            textAnchor="end"
            className="fretboard-string-label"
          >
            {stringLabel(stringNumber)}
          </text>
        ))}

        {/* Номера ладов */}
        {Array.from({ length: fretCount }, (_, i) => i + 1).map((fret) => (
          <text
            key={`fretnum-${fret}`}
            x={cellCenterX(fret)}
            y={height - 6}
            textAnchor="middle"
            className="fretboard-fret-num"
          >
            {fret}
          </text>
        ))}

        {/* Приглушённые струны (без позиции) — крестик у порожка */}
        {stringNumbers
          .filter((stringNumber) => !positionOnString(stringNumber))
          .map((stringNumber) => (
            <text
              key={`mute-${stringNumber}`}
              x={cellCenterX(0)}
              y={stringY(stringNumber) + 5}
              textAnchor="middle"
              className="fretboard-mute"
            >
              ×
            </text>
          ))}

        {/* Эталонная аппликатура — полые зелёные точки (пояснение) */}
        {(overlayPositions || []).map((pos, index) => (
          <circle
            key={`overlay-${index}`}
            cx={cellCenterX(Number(pos.fret))}
            cy={stringY(Number(pos.string))}
            r="8"
            fill="none"
            stroke="var(--color-success, #22c55e)"
            strokeWidth="2"
          />
        ))}

        {/* Текущие позиции — точки */}
        {positions.map((pos, index) => (
          <circle
            key={`pos-${index}`}
            cx={cellCenterX(Number(pos.fret))}
            cy={stringY(Number(pos.string))}
            r="9"
            fill={dotColor}
            stroke="white"
            strokeWidth="1.5"
          />
        ))}

        {/* Кликабельные зоны (по струне × лад) */}
        {interactive &&
          stringNumbers.map((stringNumber) => (
            <g key={`hit-${stringNumber}`}>
              {/* Зона открытой струны */}
              <rect
                x={nutX - OPEN_ZONE}
                y={stringY(stringNumber) - STRING_GAP / 2}
                width={OPEN_ZONE}
                height={STRING_GAP}
                fill="transparent"
                className="fretboard-hit"
                onClick={() => handleClick(stringNumber, 0)}
              />
              {/* Лады 1..fretCount */}
              {Array.from({ length: fretCount }, (_, i) => i + 1).map((fret) => (
                <rect
                  key={`hit-${stringNumber}-${fret}`}
                  x={fretLineX(fret - 1)}
                  y={stringY(stringNumber) - STRING_GAP / 2}
                  width={FRET_GAP}
                  height={STRING_GAP}
                  fill="transparent"
                  className="fretboard-hit"
                  onClick={() => handleClick(stringNumber, fret)}
                />
              ))}
            </g>
          ))}
      </svg>
    </div>
  );
}
