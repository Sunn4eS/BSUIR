import {
  initGuitarSampler,
  isSamplerReady,
  getSamplerError,
  getGuitarSampler,
  strumSamplerNotes,
  stopAllSounds,
} from './guitarSampler';
import {
  CHORD_SHAPES,
  ALL_CHORD_NAMES,
  normalizeChordName,
  getChordShape,
  fretsToNotes,
} from './chordShapes';

export const CHORD_LIST = ALL_CHORD_NAMES;

export const MAJOR_CHORDS = ALL_CHORD_NAMES.filter((name) => !name.endsWith('m'));
export const MINOR_CHORDS = ALL_CHORD_NAMES.filter((name) => name.endsWith('m'));

export async function initChordSampler() {
  return initGuitarSampler();
}

export const isChordSamplerReady = isSamplerReady;
export const getChordSamplerError = getSamplerError;
export const getChordSampler = getGuitarSampler;
export const stopAllChords = stopAllSounds;

export function getChordNotes(chordName) {
  const shape = getChordShape(chordName);
  return shape ? fretsToNotes(shape) : null;
}

export async function playChordStrum(
  chordName,
  { strumMs = 26, duration = '2n', velocity = 0.8, direction = 'down' } = {}
) {
  const sampler = await initChordSampler();
  const normalized = normalizeChordName(chordName);
  const notes = getChordNotes(chordName);

  if (!normalized || !notes?.length) {
    throw new Error(`Неизвестный аккорд: ${chordName}`);
  }

  strumSamplerNotes(sampler, notes, { strumMs, duration, velocity, direction });
  return normalized;
}

export function playShape(shape, options = {}) {
  const sampler = getChordSampler();
  const notes = Array.isArray(shape) ? fretsToNotes(shape) : null;
  if (!sampler || !notes?.length) return false;
  strumSamplerNotes(sampler, notes, options);
  return true;
}

export { CHORD_SHAPES, normalizeChordName };
