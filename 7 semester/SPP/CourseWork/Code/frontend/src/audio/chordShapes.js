/**
 * audio/chordShapes.js — аппликатуры всех 24 базовых аккордов
 *
 * Формат: массив ладов ОТ НИЗКОЙ E К ВЫСОКОЙ e (6-я → 1-я струна).
 *   -1  — струна приглушена (не звучит)
 *    0  — открытая струна
 *    N  — лад (1..12)
 *
 * Аппликатуры — стандартные «открытые» и баррэ-формы (E-shape / A-shape),
 * как их играют на реальной гитаре. Низкий голос всегда корень аккорда,
 * что важно и для звучания «чёсом», и для распознавания по хромаграмме.
 */

import { GUITAR_STANDARD_TUNING, midiToNote } from './noteUtils';

/** MIDI открытых струн: [E2, A2, D3, G3, B3, E4] = [40, 45, 50, 55, 59, 64] */
const OPEN_STRING_MIDI = GUITAR_STANDARD_TUNING.map((string) => string.midi ?? null);

export const CHORD_SHAPES = {
  // ── Мажорные (12) ─────────────────────────────────────────
  C:    [-1, 3, 2, 0, 1, 0],
  'C#': [-1, 4, 3, 1, 2, 1],
  D:    [-1, -1, 0, 2, 3, 2],
  'D#': [-1, 6, 8, 8, 8, 6],
  E:    [0, 2, 2, 1, 0, 0],
  F:    [1, 3, 3, 2, 1, 1],
  'F#': [2, 4, 4, 3, 2, 2],
  G:    [3, 2, 0, 0, 0, 3],
  'G#': [4, 6, 6, 5, 4, 4],
  A:    [-1, 0, 2, 2, 2, 0],
  'A#': [-1, 1, 3, 3, 3, 1],
  B:    [-1, 2, 4, 4, 4, 2],

  // ── Минорные (12) ─────────────────────────────────────────
  Cm:    [-1, 3, 5, 5, 4, 3],
  'C#m': [-1, 4, 6, 6, 5, 4],
  Dm:    [-1, -1, 0, 2, 3, 1],
  'D#m': [-1, 6, 8, 8, 7, 6],
  Em:    [0, 2, 2, 0, 0, 0],
  Fm:    [1, 3, 3, 1, 1, 1],
  'F#m': [2, 4, 4, 2, 2, 2],
  Gm:    [3, 5, 5, 3, 3, 3],
  'G#m': [4, 6, 6, 4, 4, 4],
  Am:    [-1, 0, 2, 2, 1, 0],
  'A#m': [-1, 1, 3, 3, 2, 1],
  Bm:    [-1, 2, 4, 4, 3, 2],
};

/** Порядок для UI: мажоры C..B, затем миноры Cm..Bm */
export const MAJOR_CHORD_NAMES = ['C', 'C#', 'D', 'D#', 'E', 'F', 'F#', 'G', 'G#', 'A', 'A#', 'B'];
export const MINOR_CHORD_NAMES = MAJOR_CHORD_NAMES.map((name) => `${name}m`);
export const ALL_CHORD_NAMES = [...MAJOR_CHORD_NAMES, ...MINOR_CHORD_NAMES];

const FLAT_ROOT_TO_SHARP = {
  Db: 'C#',
  Eb: 'D#',
  Gb: 'F#',
  Ab: 'G#',
  Bb: 'A#',
};

/**
 * Нормализует название аккорда к ключу CHORD_SHAPES.
 * "Am", "am", "A-minor" не поддерживаются — только стандартная запись
 * "C", "C#", "Db", "Cm", "C#m", "Bbm".
 *
 * @returns {string|null} ключ CHORD_SHAPES или null
 */
export function normalizeChordName(value) {
  if (typeof value !== 'string') return null;

  const match = value.trim().match(/^([A-Ga-g])([#b]?)(m?)$/);
  if (!match) return null;

  let root = `${match[1].toUpperCase()}${match[2]}`;
  if (FLAT_ROOT_TO_SHARP[root]) root = FLAT_ROOT_TO_SHARP[root];

  const name = `${root}${match[3] ? 'm' : ''}`;
  return name in CHORD_SHAPES ? name : null;
}

/** Аппликатура аккорда по названию (с нормализацией бемолей) */
export function getChordShape(chordName) {
  const normalized = normalizeChordName(chordName);
  return normalized ? CHORD_SHAPES[normalized] : null;
}

/**
 * Звучащие ноты аппликатуры — от низкой струны к высокой.
 * Используется семплером: каждая струна = реальный сэмпл.
 *
 * @param {number[]} shape — массив ладов (6 → 1)
 * @returns {string[]} — например ['A2', 'E3', 'A3', 'C4', 'E4']
 */
export function fretsToNotes(shape) {
  if (!Array.isArray(shape) || shape.length !== 6) return [];

  const notes = [];
  for (let i = 0; i < 6; i++) {
    const fret = shape[i];
    if (fret === -1 || fret === undefined || fret === null) continue;

    const openMidi = OPEN_STRING_MIDI[i];
    if (openMidi == null) continue;

    const note = midiToNote(openMidi + Number(fret));
    notes.push(`${note.name}${note.octave}`);
  }
  return notes;
}

/**
 * Позиции аппликатуры в виде {string, fret}.
 * string: 6 (низкая E) .. 1 (высокая e), fret >= 0.
 */
export function positionsFromShape(shape) {
  if (!Array.isArray(shape) || shape.length !== 6) return [];

  const positions = [];
  for (let i = 0; i < 6; i++) {
    const fret = shape[i];
    if (fret === -1 || fret === undefined || fret === null) continue;
    positions.push({ string: 6 - i, fret: Number(fret) });
  }
  return positions;
}

/**
 * Обратное преобразование: набор позиций → массив ладов длиной 6.
 * Струны без позиций считаются приглушёнными (-1).
 */
export function shapeFromPositions(positions) {
  const shape = new Array(6).fill(-1);
  for (const position of positions || []) {
    const stringNumber = Number(position?.string);
    const fret = Number(position?.fret);
    if (!Number.isInteger(stringNumber) || stringNumber < 1 || stringNumber > 6) continue;
    if (!Number.isInteger(fret) || fret < 0 || fret > 15) continue;
    shape[6 - stringNumber] = fret;
  }
  return shape;
}

/** Сравнение двух аппликатур */
export function shapesEqual(a, b) {
  return Array.isArray(a) && Array.isArray(b) && a.length === b.length && a.every((fret, i) => fret === b[i]);
}

/** Максимальный лад в аппликатуре (для авто-ширины грифа) */
export function maxFretOfShape(shape) {
  return (Array.isArray(shape) ? shape : []).reduce((max, fret) => Math.max(max, Number(fret) || -1), 0);
}

/** Случайные варианты ответа: правильный + 3 других аккорда */
export function buildAnswerOptions(correctChord, count = 4) {
  const correct = normalizeChordName(correctChord);
  if (!correct) return [];

  const pool = ALL_CHORD_NAMES.filter((name) => name !== correct);
  // Детерминированный «шаффл» без Math.random — стабильно в тестах
  const startIndex = ALL_CHORD_NAMES.indexOf(correct);
  const options = [correct];
  for (let i = 0; i < pool.length && options.length < count; i++) {
    const candidate = pool[(startIndex + i * 3 + 1) % pool.length];
    if (!options.includes(candidate)) options.push(candidate);
  }
  return options.slice(0, count);
}
