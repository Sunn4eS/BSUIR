/**
 * scripts/audio-core-test.js — проверка YIN и распознавания аккордов
 * на синтетических сигналах (без микрофона).
 * Бандлится esbuild'ом и запускается в Node.
 */

import { detectPitch, getRms } from '../src/audio/pitchDetector';
import { computeChromagram, detectChord, matchChord, chromaPitchClasses } from '../src/audio/chordDetector';
import {
  centsBetween,
  frequencyToMidi,
  getClosestGuitarString,
  midiToNote,
  parseChordName,
  parseNote,
} from '../src/audio/noteUtils';

const SAMPLE_RATE = 48000;
const FFT_SIZE = 8192;

function sine(frequency, seconds = 0.2, amplitude = 0.4) {
  const length = Math.round(SAMPLE_RATE * seconds);
  const buffer = new Float32Array(length);
  for (let i = 0; i < length; i++) {
    buffer[i] = amplitude * Math.sin((2 * Math.PI * frequency * i) / SAMPLE_RATE);
  }
  return buffer;
}

const results = [];
function check(name, ok, detail = '') {
  results.push({ name, ok });
  console.log(`${ok ? 'PASS' : 'FAIL'} — ${name}${detail ? ` (${detail})` : ''}`);
}

// ── YIN ──────────────────────────────────────────────────────
for (const [note, frequency] of [['E2', 82.41], ['A2', 110.0], ['D3', 146.83], ['G3', 196.0], ['B3', 246.94], ['E4', 329.63]]) {
  const pitch = detectPitch(sine(frequency), SAMPLE_RATE);
  const error = pitch.frequency ? Math.abs(pitch.frequency - frequency) : Infinity;
  check(`detectPitch ${note}`, error < 2 && pitch.confidence > 0.6, `f=${pitch.frequency?.toFixed(2)} conf=${pitch.confidence.toFixed(2)}`);
}

const silence = detectPitch(new Float32Array(FFT_SIZE), SAMPLE_RATE);
check('detectPitch silence -> null', silence.frequency === null && getRms(new Float32Array(FFT_SIZE)) === 0);

const a4 = detectPitch(sine(440), SAMPLE_RATE);
check('detectPitch A4', a4.frequency && Math.abs(a4.frequency - 440) < 2, `f=${a4.frequency?.toFixed(2)}`);

// ── Теория ───────────────────────────────────────────────────
const e2 = parseNote('E2');
check('parseNote E2', e2?.midi === 40 && Math.abs(e2.frequency - 82.41) < 0.1);
check('parseNote Bb3 -> A#3', parseNote('Bb3')?.name === 'A#');
check('midiToNote 40 -> E2', (() => { const n = midiToNote(40); return n.name === 'E' && n.octave === 2; })());
check('frequencyToMidi 440 -> 69', Math.abs(frequencyToMidi(440) - 69) < 0.001);
check('centsBetween 442/440 > 0', centsBetween(442, 440) > 7 && centsBetween(442, 440) < 9);
check('parseChordName Am', parseChordName('Am')?.root === 'A' && parseChordName('Am')?.suffix === 'm');
check('parseChordName C', parseChordName('C')?.root === 'C' && parseChordName('C')?.suffix === '');

const closest = getClosestGuitarString(84);
check('closest string to 84Hz is E2', closest?.label === 'E2', `cents=${closest?.centsOff.toFixed(1)}`);

// ── Хромаграмма / аккорды ────────────────────────────────────
function spectrumFor(frequencies, db = -25) {
  const data = new Float32Array(FFT_SIZE / 2);
  data.fill(-120);
  const binWidth = SAMPLE_RATE / FFT_SIZE;
  for (const frequency of frequencies) {
    const index = Math.round(frequency / binWidth);
    data[index] = db;
    data[index - 1] = Math.max(data[index - 1], db - 6);
    data[index + 1] = Math.max(data[index + 1], db - 6);
  }
  return data;
}

const amSpectrum = spectrumFor([110, 130.81, 164.81, 220, 261.63, 329.63]);
const amChroma = computeChromagram(amSpectrum, SAMPLE_RATE, FFT_SIZE);
const amMatch = matchChord(amChroma, 'Am', 0.72);
check('matchChord Am', amMatch.isMatch && amMatch.score > 0.9, `score=${amMatch.score.toFixed(3)}`);

const detected = detectChord(amChroma, ['Am', 'C', 'G', 'Em', 'D', 'E']);
check('detectChord picks Am', detected?.chord === 'Am', `chord=${detected?.chord} score=${detected?.score.toFixed(3)}`);

const cSpectrum = spectrumFor([130.81, 164.81, 196.0, 261.63, 329.63]);
const cChroma = computeChromagram(cSpectrum, SAMPLE_RATE, FFT_SIZE);
const cMatch = matchChord(cChroma, 'C', 0.72);
check('matchChord C', cMatch.isMatch && cMatch.score > 0.9, `score=${cMatch.score.toFixed(3)}`);

const wrong = matchChord(amChroma, 'G', 0.72);
check('matchChord rejects G for Am', !wrong.isMatch, `score=${wrong.score.toFixed(3)}`);

// ── Полифоническая детекция: аккорд одним боем ───────────────
const cTones = chromaPitchClasses(cChroma, 0.3).map((tone) => tone.name).sort();
check(
  'chromaPitchClasses C -> C,E,G',
  ['C', 'E', 'G'].every((pc) => cTones.includes(pc)),
  `heard=${cTones.join(',')}`
);

const singleNoteChroma = computeChromagram(spectrumFor([329.63]), SAMPLE_RATE, FFT_SIZE);
const singleTones = chromaPitchClasses(singleNoteChroma, 0.3).map((tone) => tone.name);
check('chromaPitchClasses E4 -> E', singleTones.includes('E'), `heard=${singleTones.join(',')}`);

const failed = results.filter((r) => !r.ok);
console.log(`\n${results.length - failed.length}/${results.length} checks passed`);
if (failed.length) process.exit(1);
