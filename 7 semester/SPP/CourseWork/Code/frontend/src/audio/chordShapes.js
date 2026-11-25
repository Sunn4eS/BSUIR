import { GUITAR_STANDARD_TUNING, midiToNote } from './noteUtils';

const OPEN_STRING_MIDI = GUITAR_STANDARD_TUNING.map((string) => string.midi ?? null);

export const CHORD_SHAPES = {
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

export function normalizeChordName(value) {
  if (typeof value !== 'string') return null;

  const match = value.trim().match(/^([A-Ga-g])([#b]?)(m?)$/);
  if (!match) return null;

  let root = `${match[1].toUpperCase()}${match[2]}`;
  if (FLAT_ROOT_TO_SHARP[root]) root = FLAT_ROOT_TO_SHARP[root];

  const name = `${root}${match[3] ? 'm' : ''}`;
  return name in CHORD_SHAPES ? name : null;
}

export function getChordShape(chordName) {
  const normalized = normalizeChordName(chordName);
  return normalized ? CHORD_SHAPES[normalized] : null;
}

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

export function shapesEqual(a, b) {
  return Array.isArray(a) && Array.isArray(b) && a.length === b.length && a.every((fret, i) => fret === b[i]);
}

export function maxFretOfShape(shape) {
  return (Array.isArray(shape) ? shape : []).reduce((max, fret) => Math.max(max, Number(fret) || -1), 0);
}

export function buildAnswerOptions(correctChord, count = 4) {
  const correct = normalizeChordName(correctChord);
  if (!correct) return [];

  const pool = ALL_CHORD_NAMES.filter((name) => name !== correct);
  const startIndex = ALL_CHORD_NAMES.indexOf(correct);
  const options = [correct];
  for (let i = 0; i < pool.length && options.length < count; i++) {
    const candidate = pool[(startIndex + i * 3 + 1) % pool.length];
    if (!options.includes(candidate)) options.push(candidate);
  }
  return options.slice(0, count);
}
