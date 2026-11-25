import { CHORD_INTERVALS } from './chords';
import { NOTE_NAMES, parseChordName } from './noteUtils';

const MIN_FREQ = 70;
const MAX_FREQ = 1000;

export function computeChromagram(frequencyData, sampleRate, fftSize) {
  const chroma = new Array(12).fill(0);
  const binWidth = sampleRate / fftSize;

  for (let i = 2; i < frequencyData.length - 1; i++) {
    const frequency = i * binWidth;
    if (frequency < MIN_FREQ || frequency > MAX_FREQ) continue;

    const db = frequencyData[i];
    if (!Number.isFinite(db) || db < -85) continue;
    if (db < frequencyData[i - 1] || db < frequencyData[i + 1]) continue;

    const left = frequencyData[i - 1];
    const right = frequencyData[i + 1];
    const denominator = left - 2 * db + right;
    const delta = denominator !== 0 ? (0.5 * (left - right)) / denominator : 0;
    const refinedBin = i + Math.max(-0.5, Math.min(0.5, delta));
    const refinedFrequency = refinedBin * binWidth;

    const magnitude = Math.pow(10, db / 20) / Math.sqrt(refinedFrequency);
    const midi = 69 + 12 * Math.log2(refinedFrequency / 440);
    const pitchClass = ((Math.round(midi) % 12) + 12) % 12;

    chroma[pitchClass] += magnitude;
  }

  const max = Math.max(...chroma);
  return max > 0 ? chroma.map((value) => value / max) : chroma;
}

export function chromaPitchClasses(chroma, threshold = 0.3) {
  if (!chroma?.length) return [];

  const result = [];
  for (let pc = 0; pc < 12; pc++) {
    if (chroma[pc] >= threshold) {
      result.push({ name: NOTE_NAMES[pc], strength: chroma[pc] });
    }
  }
  return result;
}

function buildTemplate(chordName) {  const parsed = parseChordName(chordName);
  if (!parsed) return null;

  const rootPitchClass = NOTE_NAMES.indexOf(parsed.root);
  const intervals = CHORD_INTERVALS[parsed.suffix] || CHORD_INTERVALS[''];
  const template = new Array(12).fill(0);

  for (const interval of intervals) {
    template[(rootPitchClass + interval) % 12] = 1;
  }

  return { template, rootPitchClass };
}

function cosineSimilarity(a, b) {
  let dot = 0;
  let normA = 0;
  let normB = 0;

  for (let i = 0; i < 12; i++) {
    dot += a[i] * b[i];
    normA += a[i] * a[i];
    normB += b[i] * b[i];
  }

  if (normA === 0 || normB === 0) return 0;
  return dot / (Math.sqrt(normA) * Math.sqrt(normB));
}

export function detectChord(chroma, allowedChords) {
  if (!chroma?.length) return null;

  let best = null;

  for (const chordName of allowedChords) {
    const built = buildTemplate(chordName);
    if (!built) continue;

    const score = cosineSimilarity(chroma, built.template);
    const rootScore = chroma[built.rootPitchClass];

    if (!best || score > best.score) {
      best = { chord: chordName, score, rootScore };
    }
  }

  return best;
}

export function matchChord(chroma, expectedChord, threshold = 0.72) {
  const built = buildTemplate(expectedChord);
  if (!built || !chroma?.length) {
    return { isMatch: false, score: 0, detectedChord: null };
  }

  const score = cosineSimilarity(chroma, built.template);
  const rootScore = chroma[built.rootPitchClass];

  const isMatch = score >= threshold && rootScore >= 0.2;

  return {
    isMatch,
    score,
    rootScore,
    detectedChord: isMatch ? expectedChord : null,
  };
}
