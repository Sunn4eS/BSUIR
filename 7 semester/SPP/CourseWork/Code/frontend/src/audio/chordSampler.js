/**
 * audio/chordSampler.js — семплер всех 24 базовых аккордов
 *
 * Построен поверх гитарного Tone.Sampler (initGuitarSampler):
 * каждая струна аккорда — отдельный реальный сэмпл.
 *
 * Основная операция — «чёс» (strum): струны щиплются по очереди
 * со смещением strumMs (20–40 мс), как при ударе по открытым
 * струнам настоящей гитары. Направление: down — от низкой E к
 * высокой e, up — наоборот.
 */

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

/** Список всех 24 аккордов для UI: ['C', 'C#', … 'B', 'Cm', … 'Bm'] */
export const CHORD_LIST = ALL_CHORD_NAMES;

/** Мажорные (12) и минорные (12) отдельно — для группировки в UI */
export const MAJOR_CHORDS = ALL_CHORD_NAMES.filter((name) => !name.endsWith('m'));
export const MINOR_CHORDS = ALL_CHORD_NAMES.filter((name) => name.endsWith('m'));

/** Инициализация (ленивая, после пользовательского жеста) */
export async function initChordSampler() {
  return initGuitarSampler();
}

export const isChordSamplerReady = isSamplerReady;
export const getChordSamplerError = getSamplerError;
export const getChordSampler = getGuitarSampler;
export const stopAllChords = stopAllSounds;

/**
 * Ноты аккорда от низкой струны к высокой (по реальной аппликатуре).
 *
 * @param {string} chordName — 'Am', 'C', 'F#m', 'Bb'…
 * @returns {string[]|null}
 */
export function getChordNotes(chordName) {
  const shape = getChordShape(chordName);
  return shape ? fretsToNotes(shape) : null;
}

/**
 * Проиграть аккорд «чёсом».
 *
 * @param {string} chordName
 * @param {object} options
 * @param {number} options.strumMs    — смещение между струнами, мс (по умолчанию 26)
 * @param {string} options.duration   — длительность ноты Tone.js ('2n')
 * @param {number} options.velocity   — громкость 0..1
 * @param {'down'|'up'} options.direction
 * @returns {Promise<string|null>} — нормализованное имя аккорда (или null)
 */
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

/** Удобная обёртка: сыграть аккорд по ключу CHORD_SHAPES без нормализации */
export function playShape(shape, options = {}) {
  const sampler = getChordSampler();
  const notes = Array.isArray(shape) ? fretsToNotes(shape) : null;
  if (!sampler || !notes?.length) return false;
  strumSamplerNotes(sampler, notes, options);
  return true;
}

export { CHORD_SHAPES, normalizeChordName };
