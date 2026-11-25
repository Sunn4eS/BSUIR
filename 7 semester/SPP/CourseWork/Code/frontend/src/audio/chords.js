import { CHORD_SHAPES, ALL_CHORD_NAMES, normalizeChordName, fretsToNotes } from './chordShapes';

export const CHORD_INTERVALS = {
  '': [0, 4, 7],
  m: [0, 3, 7],
  '7': [0, 4, 7, 10],
  maj7: [0, 4, 7, 11],
  m7: [0, 3, 7, 10],
  sus2: [0, 2, 7],
  sus4: [0, 5, 7],
  dim: [0, 3, 6],
  aug: [0, 4, 8],
  '5': [0, 7],
};

export const CHORD_VOICINGS = Object.fromEntries(
  ALL_CHORD_NAMES.map((name) => [name, fretsToNotes(CHORD_SHAPES[name])])
);

export const CHORD_NAMES = ALL_CHORD_NAMES;

export function getChordVoicing(chordName) {
  const normalized = normalizeChordName(chordName);
  return normalized ? CHORD_VOICINGS[normalized] : null;
}
