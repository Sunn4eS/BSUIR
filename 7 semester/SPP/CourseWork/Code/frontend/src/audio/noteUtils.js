/**
 * audio/noteUtils.js — музыкальная теория и утилиты частот
 *
 * Всё, что связано с переводом частоты в ноту и обратно,
 * парсингом строк вида "E4", "A#2", "Am" и гитарным строем.
 */

export const NOTE_NAMES = ['C', 'C#', 'D', 'D#', 'E', 'F', 'F#', 'G', 'G#', 'A', 'A#', 'B'];

const FLAT_TO_SHARP = {
  Cb: 'B',
  Db: 'C#',
  Eb: 'D#',
  Fb: 'E',
  Gb: 'F#',
  Ab: 'G#',
  Bb: 'A#',
};

/** Стандартный строй гитары EADGBE (от 6-й струны к 1-й) */
export const GUITAR_STANDARD_TUNING = [
  { string: 6, name: 'E', octave: 2, midi: 40, frequency: 82.41, label: 'E2' },
  { string: 5, name: 'A', octave: 2, midi: 45, frequency: 110.0, label: 'A2' },
  { string: 4, name: 'D', octave: 3, midi: 50, frequency: 146.83, label: 'D3' },
  { string: 3, name: 'G', octave: 3, midi: 55, frequency: 196.0, label: 'G3' },
  { string: 2, name: 'B', octave: 3, midi: 59, frequency: 246.94, label: 'B3' },
  { string: 1, name: 'E', octave: 4, midi: 64, frequency: 329.63, label: 'E4' },
];

/** Частота (Гц) → MIDI-номер (A4 = 69 = 440 Гц) */
export function frequencyToMidi(frequency) {
  return 12 * Math.log2(frequency / 440) + 69;
}

/** MIDI-номер → частота (Гц) */
export function midiToFrequency(midi) {
  return 440 * Math.pow(2, (midi - 69) / 12);
}

/** MIDI-номер → информация о ноте */
export function midiToNote(midi) {
  const rounded = Math.round(midi);
  const name = NOTE_NAMES[((rounded % 12) + 12) % 12];
  const octave = Math.floor(rounded / 12) - 1;
  return {
    name,
    octave,
    midi: rounded,
    frequency: midiToFrequency(rounded),
  };
}

/** Приводит бемоль к диезу: Bb → A# */
export function normalizePitchClass(value) {
  if (!value) return null;
  const normalized = String(value).replace('♯', '#').replace('♭', 'b');
  if (FLAT_TO_SHARP[normalized]) return FLAT_TO_SHARP[normalized];
  return NOTE_NAMES.includes(normalized) ? normalized : null;
}

/**
 * Парсит одиночную ноту: "E4", "A#2", "Bb3", "E".
 * Если октава не указана — используется 4-я (E4).
 */
export function parseNote(value) {
  if (typeof value !== 'string') return null;

  const match = value.trim().match(/^([A-Ga-g])([#b]?)(-?\d+)?$/);
  if (!match) return null;

  const [, letter, accidental, octaveStr] = match;
  const name = normalizePitchClass(`${letter.toUpperCase()}${accidental}`);
  if (!name) return null;

  const octave = octaveStr !== undefined ? parseInt(octaveStr, 10) : 4;
  const midi = (octave + 1) * 12 + NOTE_NAMES.indexOf(name);

  return {
    name,
    octave,
    midi,
    frequency: midiToFrequency(midi),
    hasOctave: octaveStr !== undefined,
  };
}

/**
 * Парсит название аккорда: "Am", "C", "G", "F#m", "Cmaj7".
 * Возвращает root и суффикс.
 */
export function parseChordName(value) {
  if (typeof value !== 'string') return null;

  const match = value.trim().match(/^([A-Ga-g])([#b]?)(maj7|m7|sus4|sus2|dim|aug|m|7|5)?$/);
  if (!match) return null;

  const root = normalizePitchClass(`${match[1].toUpperCase()}${match[2]}`);
  if (!root) return null;

  const suffix = match[3] || '';
  return { root, suffix, name: `${root}${suffix}` };
}

/** Отклонение частоты от эталона в центах */
export function centsBetween(frequency, referenceFrequency) {
  if (!frequency || !referenceFrequency) return 0;
  return 1200 * Math.log2(frequency / referenceFrequency);
}

/** Ближайшая гитарная струна к частоте */
export function getClosestGuitarString(frequency) {
  if (!frequency) return null;

  let closest = null;
  let minDistance = Infinity;

  for (const string of GUITAR_STANDARD_TUNING) {
    const distance = Math.abs(centsBetween(frequency, string.frequency));
    if (distance < minDistance) {
      minDistance = distance;
      closest = string;
    }
  }

  return closest ? { ...closest, centsOff: centsBetween(frequency, closest.frequency) } : null;
}

/** Форматирует ноту: { name: 'E', octave: 2 } → "E2" */
export function formatNote(note) {
  if (!note) return '—';
  return `${note.name}${note.octave ?? ''}`;
}

// ─────────────────────────────────────────────────────────────
// Диапазон гитары для детекции: E2 (82.41 Гц) … B4 (493.88 Гц).
// MIDI 40–71: открытые струны + гриф до 12-го лада на низкой E
// и до 7-го лада на высокой e — рабочий диапазон заданий.
// ─────────────────────────────────────────────────────────────

/** Первая нота диапазона гитары (E2) */
export const GUITAR_MIN_MIDI = 40;
/** Последняя нота диапазона гитары (B4) */
export const GUITAR_MAX_MIDI = 71;

/** Все ноты диапазона гитары: [{ label, name, octave, midi, frequency }] */
export const GUITAR_NOTE_TABLE = Array.from(
  { length: GUITAR_MAX_MIDI - GUITAR_MIN_MIDI + 1 },
  (_, index) => {
    const midi = GUITAR_MIN_MIDI + index;
    const { name, octave, frequency } = midiToNote(midi);
    return { label: `${name}${octave}`, name, octave, midi, frequency };
  }
);

/**
 * Ищет ноту из гитарного диапазона по частоте.
 *
 * @param {number} frequency — измеренная частота, Гц
 * @param {number} toleranceCents — допуск в центах (по умолчанию 30)
 * @returns {object|null} — запись GUITAR_NOTE_TABLE или null, если
 *   частота вне диапазона/допуска
 */
export function findNoteByFrequency(frequency, toleranceCents = 30) {
  if (!frequency || frequency <= 0) return null;

  let best = null;
  let bestCents = Infinity;

  for (const note of GUITAR_NOTE_TABLE) {
    const cents = Math.abs(centsBetween(frequency, note.frequency));
    if (cents < bestCents) {
      bestCents = cents;
      best = note;
    }
  }

  return bestCents <= toleranceCents ? { ...best, centsOff: bestCents } : null;
}

/**
 * Проверяет, что частота соответствует ноте (например "E2")
 * с допуском в центах.
 */
export function isFrequencyInTolerance(frequency, noteLabel, toleranceCents = 30) {
  if (!frequency || !noteLabel) return false;

  const parsed = typeof noteLabel === 'string' ? parseNote(noteLabel) : null;
  if (!parsed) return false;

  return Math.abs(centsBetween(frequency, parsed.frequency)) <= toleranceCents;
}
