/**
 * audio/chords.js — интервалы аккордов и voicing'и из аппликатур
 *
 * CHORD_INTERVALS — для распознавания аккордов по хромаграмме.
 * CHORD_VOICINGS/CHORD_NAMES — выводятся из CHORD_SHAPES (24 аккорда:
 * 12 мажорных + 12 минорных), каждая нота = реальная струна сэмплера.
 */

import { CHORD_SHAPES, ALL_CHORD_NAMES, normalizeChordName, fretsToNotes } from './chordShapes';

export const CHORD_INTERVALS = {
  '': [0, 4, 7],          // мажор
  m: [0, 3, 7],           // минор
  '7': [0, 4, 7, 10],     // доминантсептаккорд
  maj7: [0, 4, 7, 11],    // большой мажорный септаккорд
  m7: [0, 3, 7, 10],      // малый минорный септаккорд
  sus2: [0, 2, 7],
  sus4: [0, 5, 7],
  dim: [0, 3, 6],
  aug: [0, 4, 8],
  '5': [0, 7],
};

/** Voicing'и всех 24 аккордов — из реальных аппликатур (струны сэмпла) */
export const CHORD_VOICINGS = Object.fromEntries(
  ALL_CHORD_NAMES.map((name) => [name, fretsToNotes(CHORD_SHAPES[name])])
);

export const CHORD_NAMES = ALL_CHORD_NAMES;

/** Обёртка для совместимости: voicing по названию аккорда */
export function getChordVoicing(chordName) {
  const normalized = normalizeChordName(chordName);
  return normalized ? CHORD_VOICINGS[normalized] : null;
}
