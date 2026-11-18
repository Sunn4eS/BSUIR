/**
 * audio/guitarSampler.js — воспроизведение реальных гитарных семплов
 *
 * Используется Tone.Sampler с сэмплами акустической гитары.
 * Сэмплы лежат в public/samples/guitar (E2, A2, D3, G3, B3, E4),
 * остальные ноты Sampler получает питч-шифтом от ближайшего сэмпла.
 *
 * Аккорды играются «чёсом»: струны щиплются одна за другой
 * со смещением 25 мс — как на настоящей гитаре.
 */

import * as Tone from 'tone';
import { ensureAudio } from './audioEngine';
import { CHORD_VOICINGS } from './chords';
import { getChordShape, fretsToNotes } from './chordShapes';
import { parseChordName, NOTE_NAMES } from './noteUtils';

const SAMPLE_NOTES = ['E2', 'A2', 'D3', 'G3', 'B3', 'E4'];
const SAMPLE_BASE_URL = `${import.meta.env.BASE_URL || '/'}samples/guitar/`;

let sampler = null;
let loadPromise = null;
let loadError = null;

/**
 * Ленивая загрузка сэмплера.
 * Вызывать после ensureAudio() внутри пользовательского жеста.
 */
export async function initGuitarSampler() {
  await ensureAudio();

  if (sampler) return sampler;
  if (loadPromise) return loadPromise;

  loadError = null;

  loadPromise = new Promise((resolve, reject) => {
    const urls = Object.fromEntries(
      SAMPLE_NOTES.map((note) => [note, `${note}.mp3`])
    );

    sampler = new Tone.Sampler({
      urls,
      baseUrl: SAMPLE_BASE_URL,
      attack: 0.005,
      release: 1.2,
      curve: 'exponential',
      volume: -4,
      onload: () => resolve(sampler),
      onerror: (error) => {
        loadError = error;
        sampler = null;
        loadPromise = null;
        reject(error);
      },
    }).toDestination();
  });

  return loadPromise;
}

/** Синхронный доступ к загруженному сэмплеру (или null) */
export function getGuitarSampler() {
  return sampler;
}

export function isSamplerReady() {
  return Boolean(sampler);
}

export function getSamplerError() {
  return loadError;
}

function getVoicing(chordName) {
  if (CHORD_VOICINGS[chordName]) return CHORD_VOICINGS[chordName];

  // Фолбэк: строим трезвучие от корня в 3-й октаве
  const parsed = parseChordName(chordName);
  if (!parsed) return null;

  const rootPc = NOTE_NAMES.indexOf(parsed.root);
  const intervals = {
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
  }[parsed.suffix] || [0, 4, 7];

  return intervals.map((interval) => {
    const midi = 48 + ((rootPc + interval) % 12);
    const name = NOTE_NAMES[midi % 12];
    const octave = Math.floor(midi / 12) - 1;
    return `${name}${octave}`;
  });
}

/**
 * «Чёс»: щипки струн одна за другой со смещением strumMs.
 * Ноты передаются от низкой струны к высокой.
 */
export function strumSamplerNotes(
  samplerInstance,
  notes,
  { strumMs = 25, duration = '2n', velocity = 0.8, direction = 'down' } = {}
) {
  if (!samplerInstance || !notes?.length) return;

  const ordered = direction === 'up' ? [...notes].reverse() : notes;
  const startTime = Tone.now();

  ordered.forEach((note, index) => {
    samplerInstance.triggerAttackRelease(
      note,
      duration,
      startTime + (index * strumMs) / 1000,
      velocity
    );
  });
}

/** Проиграть одну ноту: "E4", "A2" */
export async function playNote(note, duration = '2n', velocity = 0.8) {
  const s = await initGuitarSampler();
  s.triggerAttackRelease(note, duration, Tone.now(), velocity);
}

/** Проиграть аккорд «чёсом»: "Am", "C", "G", "F#m" */
export async function playChord(chordName, duration = '2n', velocity = 0.8) {
  const s = await initGuitarSampler();

  const shape = getChordShape(chordName);
  const notes = shape ? fretsToNotes(shape) : getVoicing(chordName);

  if (!notes?.length) {
    throw new Error(`Неизвестный аккорд: ${chordName}`);
  }

  strumSamplerNotes(s, notes, { strumMs: 25, duration, velocity, direction: 'down' });
}

/** Проиграть ноту или аккорд по строке */
export async function playExpected(value, duration = '2n', velocity = 0.8) {
  if (!value) return;

  if (CHORD_VOICINGS[value] || parseChordName(value)) {
    return playChord(value, duration, velocity);
  }

  return playNote(value, duration, velocity);
}

/** Остановить все звучащие ноты */
export function stopAllSounds() {
  sampler?.releaseAll();
}
