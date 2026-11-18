/**
 * scripts/fingering-core-test.js — проверка аппликатур 24 аккордов
 * и гейта щипка на синтетических данных (без микрофона).
 * Бандлится esbuild'ом и запускается в Node.
 */

import {
  ALL_CHORD_NAMES,
  MAJOR_CHORD_NAMES,
  MINOR_CHORD_NAMES,
  CHORD_SHAPES,
  buildAnswerOptions,
  fretsToNotes,
  getChordShape,
  maxFretOfShape,
  normalizeChordName,
  positionsFromShape,
  shapeFromPositions,
  shapesEqual,
} from '../src/audio/chordShapes';
import { CHORD_NAMES, CHORD_VOICINGS, getChordVoicing } from '../src/audio/chords';
import { NOTE_NAMES, GUITAR_NOTE_TABLE, findNoteByFrequency, isFrequencyInTolerance, parseNote } from '../src/audio/noteUtils';
import { createPluckGate } from '../src/audio/pluckGate';

const results = [];
function check(name, ok, detail = '') {
  results.push({ name, ok });
  console.log(`${ok ? 'PASS' : 'FAIL'} — ${name}${detail ? ` (${detail})` : ''}`);
}

// ── Каталог аппликатур ─────────────────────────────────────────
check('24 аккорда в CHORD_SHAPES', Object.keys(CHORD_SHAPES).length === 24);
check('ALL_CHORD_NAMES = 12 мажорных + 12 минорных',
  ALL_CHORD_NAMES.length === 24
  && MINOR_CHORD_NAMES.every((n) => n.endsWith('m'))
  && MAJOR_CHORD_NAMES.length === 12
  && CHORD_NAMES === ALL_CHORD_NAMES);

// Каждая нота каждой аппликатуры принадлежит аккорду, корень — внизу
for (const chordName of ALL_CHORD_NAMES) {
  const shape = CHORD_SHAPES[chordName];
  const notes = fretsToNotes(shape);
  const isMinor = chordName.endsWith('m');
  const rootName = isMinor ? chordName.slice(0, -1) : chordName;
  const rootPc = NOTE_NAMES.indexOf(rootName);
  const intervals = isMinor ? [0, 3, 7] : [0, 4, 7];
  const chordPcs = new Set(intervals.map((i) => (rootPc + i) % 12));

  const allInChord = notes.length >= 4 && notes.every((label) => {
    const note = parseNote(label);
    return note && chordPcs.has(note.midi % 12);
  });
  const lowest = parseNote(notes[0]);
  const rootInBass = lowest && lowest.midi % 12 === rootPc;
  const maxFret = maxFretOfShape(shape);

  check(
    `fretsToNotes ${chordName}`,
    allInChord && rootInBass && maxFret <= 12,
    `notes=[${notes.join(' ')}] root=${rootName} maxFret=${maxFret}`
  );
}

// ── Позиции ↔ аппликатура (roundtrip) ─────────────────────────
for (const chordName of ALL_CHORD_NAMES) {
  const shape = CHORD_SHAPES[chordName];
  const positions = positionsFromShape(shape);
  const restored = shapeFromPositions(positions);
  const stringsValid = positions.every((p) => p.string >= 1 && p.string <= 6 && p.fret >= 0);
  check(`positions roundtrip ${chordName}`, shapesEqual(restored, shape) && stringsValid,
    `positions=${positions.length}`);
}

// Строки без позиций приглушены; мусор игнорируется
check('shapeFromPositions пустой -> все приглушены',
  shapeFromPositions([]).every((f) => f === -1));
check('shapeFromPositions фильтрует мусор',
  shapesEqual(shapeFromPositions([{ string: 6, fret: 3 }, { string: 0, fret: 1 }, { string: 'x', fret: 1 }, { string: 5, fret: 99 }]), [3, -1, -1, -1, -1, -1]));

// ── normalizeChordName ─────────────────────────────────────────
check('normalizeChordName Am', normalizeChordName('Am') === 'Am');
check('normalizeChordName am -> Am', normalizeChordName('am') === 'Am');
check('normalizeChordName Bb -> A#', normalizeChordName('Bb') === 'A#');
check('normalizeChordName Bbm -> A#m', normalizeChordName('Bbm') === 'A#m');
check('normalizeChordName " C# "', normalizeChordName(' C# ') === 'C#');
check('normalizeChordName Am7 -> null', normalizeChordName('Am7') === null);
check('normalizeChordName H -> null', normalizeChordName('H') === null);
check('normalizeChordName пусто -> null', normalizeChordName('') === null);
check('getChordShape Bbm', shapesEqual(getChordShape('Bbm'), CHORD_SHAPES['A#m']));

// ── Варианты ответа ────────────────────────────────────────────
for (const chordName of ['C', 'F#m', 'A#', 'D#m']) {
  const options = buildAnswerOptions(chordName);
  const valid = options.length === 4
    && new Set(options).size === 4
    && options.includes(chordName)
    && options.every((name) => ALL_CHORD_NAMES.includes(name));
  check(`buildAnswerOptions ${chordName}`, valid, `[${options.join(', ')}]`);
}

// ── Voicing'и (сэмплер) ────────────────────────────────────────
check('CHORD_VOICINGS покрывает 24 аккорда',
  Object.keys(CHORD_VOICINGS).length === 24
  && ALL_CHORD_NAMES.every((name) => CHORD_VOICINGS[name].length >= 4));
check('getChordVoicing Bbm = A#m',
  JSON.stringify(getChordVoicing('Bbm')) === JSON.stringify(CHORD_VOICINGS['A#m']));
check('getChordVoicing Am7 -> null', getChordVoicing('Am7') === null);

// ── Таблица нот гитары ─────────────────────────────────────────
check('GUITAR_NOTE_TABLE 32 ноты E2..B4',
  GUITAR_NOTE_TABLE.length === 32
  && GUITAR_NOTE_TABLE[0].label === 'E2'
  && Math.abs(GUITAR_NOTE_TABLE[0].frequency - 82.41) < 0.05
  && GUITAR_NOTE_TABLE[31].label === 'B4'
  && Math.abs(GUITAR_NOTE_TABLE[31].frequency - 493.88) < 0.05);

check('findNoteByFrequency 82.41 -> E2', findNoteByFrequency(82.41)?.label === 'E2');
check('findNoteByFrequency 110.5 -> A2', findNoteByFrequency(110.5)?.label === 'A2');
check('findNoteByFrequency 445 -> A4', findNoteByFrequency(445)?.label === 'A4');
check('findNoteByFrequency 84 (33 цента) -> null', findNoteByFrequency(84) === null);
check('findNoteByFrequency 452 (между A4 и A#4) -> null', findNoteByFrequency(452) === null);
check('isFrequencyInTolerance 110/A2', isFrequencyInTolerance(110, 'A2'));
check('isFrequencyInTolerance 111.5/A2 (23 цента)', isFrequencyInTolerance(111.5, 'A2'));
check('isFrequencyInTolerance 115/A2 -> false', !isFrequencyInTolerance(115, 'A2'));
check('isFrequencyInTolerance 329.63/E4', isFrequencyInTolerance(329.63, 'E4'));

// ─── Гейт щипка ─────────────────────────────────────────────────

const FRAME_MS = 20;

/** Прогоняет гейт через серию кадров; возвращает лог событий */
function simulate(gate, frames, rmsFn, startMs) {
  let now = startMs;
  let openFrames = 0;
  let closedFrames = 0;
  for (let i = 0; i < frames; i++) {
    const state = gate.push(rmsFn(i, now), now);
    if (state.isOpen) openFrames++;
    else closedFrames++;
    now += FRAME_MS;
  }
  return { now, openFrames, closedFrames, state: gate.getState() };
}

// 1. Тишина и тихий фон не открывают гейт
{
  const gate = createPluckGate();
  const { state } = simulate(gate, 100, () => 0.0005, 0);          // 2 с тишины
  const hum = simulate(gate, 200, () => 0.003, 2000);              // 4 с гула 0.003
  check('гейт закрыт на тишине и тихом гуле',
    !state.isOpen && state.onsetCount === 0 && !hum.state.isOpen && hum.state.onsetCount === 0);
}

// 2. Щипок: резкая атака -> ровно один onset, гейт открыт
{
  const gate = createPluckGate();
  const attack = simulate(gate, 3, () => 0.2, 0);                  // 60 мс громкого сигнала
  check('щипок открывает гейт ровно один раз',
    attack.state.onsetCount === 1 && attack.state.isOpen);
}

// 3. Затухающая струна: без повторных onset'ов, гейт держится открытым
{
  const gate = createPluckGate();
  let pluckAt = 0;
  const decayRms = (i, now) => 0.2 * Math.exp(-(now - pluckAt) / 400); // затухание 0.4 с
  const decay = simulate(gate, 150, decayRms, 0);                 // 3 с затухания
  const mid = 0.2 * Math.exp(-1500 / 400);                         // rms на 1.5 с ≈ 0.0047
  check('затухающая струна не даёт повторных onset',
    decay.state.onsetCount === 1,
    `midRms=${mid.toFixed(4)} onsets=${decay.state.onsetCount}`);
}

// 4. После полного затухания гейт закрывается (holdMs прошёл)
{
  const gate = createPluckGate();
  simulate(gate, 3, () => 0.2, 0);
  const after = simulate(gate, 100, (i, now) => 0.2 * Math.exp(-(now - 0) / 400), 60);
  // к концу 2 с rms ≈ 0.2*e^-5 ≈ 0.0013 < шума -> закрыт
  check('гейт закрывается после затухания струны', !after.state.isOpen);
}

// 5. Кратковременный провал (60 мс) не закрывает гейт
{
  const gate = createPluckGate();
  simulate(gate, 10, () => 0.15, 0);                              // 200 мс громко
  const dip = simulate(gate, 3, () => 0.001, 200);                 // 60 мс провал (< holdMs)
  const back = simulate(gate, 10, () => 0.15, 260);                // снова громко
  check('краткий провал не закрывает гейт (гистерезис)',
    dip.state.isOpen && back.state.isOpen && back.state.onsetCount === 1);
}

// 6. Долгая тишина закрывает; следующий щипок -> второй onset
{
  const gate = createPluckGate();
  simulate(gate, 3, () => 0.2, 0);
  const silence = simulate(gate, 30, () => 0.0005, 60);            // 600 мс тишины
  const second = simulate(gate, 3, () => 0.2, 660);
  check('повторный щипок после тишины -> второй onset',
    !silence.state.isOpen && second.state.onsetCount === 2);
}

// 7. reset() принудительно закрывает гейт
{
  const gate = createPluckGate();
  simulate(gate, 10, () => 0.15, 0);
  gate.reset();
  const state = gate.getState();
  check('reset закрывает гейт и обнуляет фон',
    !state.isOpen && state.fastRms === 0 && state.onsetCount === 0);
}

const failed = results.filter((r) => !r.ok);
console.log(`\n${results.length - failed.length}/${results.length} checks passed`);
if (failed.length) process.exit(1);
