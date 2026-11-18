/**
 * components/Live/QuickTaskBuilder.jsx
 * Быстрый конструктор карточки для Live-урока (2–3 клика).
 *
 * Три сегмента: 🎸 Сыграть, 🎵 На слух, 🖐 Аппликатура.
 * В сегменте «Аппликатура» — 4 подтипа (угадать / собрать / сыграть /
 * собрать и сыграть), выбор из всех 24 аккордов и превью на грифе
 * с прослушиванием «чёса».
 */

import { useMemo, useState } from 'react';
import { CHORD_NAMES } from '../../audio/chords';
import {
  MAJOR_CHORD_NAMES,
  MINOR_CHORD_NAMES,
  buildAnswerOptions,
  getChordShape,
  positionsFromShape,
  normalizeChordName,
} from '../../audio/chordShapes';
import { playChordStrum, stopAllChords } from '../../audio/chordSampler';
import { useAudioSession } from '../../hooks/useAudioSession';
import Fretboard from '../Cards/Fretboard';

const NOTE_TARGETS = ['E2', 'A2', 'D3', 'G3', 'B3', 'E4', 'A4', 'C4', 'D4', 'G4'];
const EAR_TARGETS = ['A', 'B', 'C', 'D', 'E', 'F', 'G', 'Am', 'C', 'G', 'Em', 'D', 'E'];

// Подтипы сегмента «Аппликатура»
const FINGERING_KINDS = [
  { id: 'TEST_GUESS', label: '🧩 Угадать', type: 'FINGERING_TEST', mode: 'GUESS' },
  { id: 'TEST_BUILD', label: '🛠 Собрать', type: 'FINGERING_TEST', mode: 'BUILD' },
  { id: 'PLAY',       label: '🎸 Сыграть', type: 'PLAY_FINGERING', mode: null },
  { id: 'COMBO',      label: '🎯 Собрать и сыграть', type: 'COMBO_FINGERING', mode: null },
];

function uniqueOptions(correct, pool) {
  const options = [correct];
  for (const value of pool) {
    if (options.length >= 4) break;
    if (!options.includes(value)) options.push(value);
  }
  return options;
}

export default function QuickTaskBuilder({ onSend, disabled = false }) {
  const [type, setType] = useState('PLAY_PRACTICE');
  const [playTarget, setPlayTarget] = useState('E4');
  const [earTarget, setEarTarget] = useState('Am');
  const [tolerance, setTolerance] = useState(20);

  // Сегмент «Аппликатура»
  const [fingeringKindId, setFingeringKindId] = useState('TEST_GUESS');
  const [fingeringTarget, setFingeringTarget] = useState('Am');
  const [isPreviewPlaying, setIsPreviewPlaying] = useState(false);

  const [instruction, setInstruction] = useState('');

  const { ensureAudioReady } = useAudioSession();

  const fingeringKind = FINGERING_KINDS.find((item) => item.id === fingeringKindId) || FINGERING_KINDS[0];

  const earOptions = useMemo(
    () => uniqueOptions(earTarget, EAR_TARGETS.filter((item) => item !== earTarget)),
    [earTarget]
  );

  const fingeringOptions = useMemo(
    () => buildAnswerOptions(fingeringTarget, 4),
    [fingeringTarget]
  );

  const previewPositions = useMemo(() => {
    const shape = getChordShape(fingeringTarget);
    return shape ? positionsFromShape(shape) : [];
  }, [fingeringTarget]);

  const handlePreviewPlay = async () => {
    if (isPreviewPlaying) return;
    setIsPreviewPlaying(true);
    try {
      const audioOk = await ensureAudioReady();
      if (!audioOk) throw new Error('Аудио недоступно');
      stopAllChords();
      await playChordStrum(fingeringTarget, { strumMs: 28, velocity: 0.85 });
    } catch {
      // Превью не критично — тихо игнорируем
    } finally {
      setTimeout(() => setIsPreviewPlaying(false), 900);
    }
  };

  const handleSend = () => {
    if (type === 'EAR_TRAINING') {
      onSend({
        type: 'EAR_TRAINING',
        title: `Угадай: ${earTarget}`,
        instruction: instruction || 'Прослушай звук и выбери правильный ответ',
        correctAnswer: earTarget,
        answerOptions: earOptions,
      });
      return;
    }

    if (type === 'FINGERING') {
      const chord = normalizeChordName(fingeringTarget) || fingeringTarget;

      if (fingeringKind.type === 'FINGERING_TEST') {
        onSend({
          type: 'FINGERING_TEST',
          title: `Аппликатура: ${chord}`,
          instruction:
            instruction ||
            (fingeringKind.mode === 'BUILD'
              ? `Собери на грифе аппликатуру аккорда ${chord}`
              : 'Посмотри на аппликатуру и выбери аккорд'),
          correctAnswer: chord,
          expectedNote: chord,
          answerOptions: fingeringOptions,
          fingeringMode: fingeringKind.mode,
        });
        return;
      }

      onSend({
        type: fingeringKind.type,
        title:
          fingeringKind.type === 'PLAY_FINGERING'
            ? `Сыграй: ${chord}`
            : `Собери и сыграй: ${chord}`,
        instruction: instruction || 'Возьми аккорд по аппликатуре и щипни все струны',
        expectedNote: chord,
        toleranceCents: Number(tolerance) || 30,
      });
      return;
    }

    onSend({
      type: 'PLAY_PRACTICE',
      title: `Сыграй: ${playTarget}`,
      instruction: instruction || 'Сыграй и удержи задание',
      expectedNote: playTarget,
      toleranceCents: Number(tolerance) || 20,
    });
  };

  const isFingeringPlayKind =
    type === 'FINGERING' &&
    (fingeringKind.type === 'PLAY_FINGERING' || fingeringKind.type === 'COMBO_FINGERING');

  return (
    <div className="quick-builder">
      <div className="form-group">
        <span className="form-label">Тип задания</span>
        <div className="segmented">
          <button
            type="button"
            className={`segmented-item ${type === 'PLAY_PRACTICE' ? 'active' : ''}`}
            onClick={() => setType('PLAY_PRACTICE')}
          >
            🎸 Сыграть
          </button>
          <button
            type="button"
            className={`segmented-item ${type === 'EAR_TRAINING' ? 'active' : ''}`}
            onClick={() => setType('EAR_TRAINING')}
          >
            🎵 На слух
          </button>
          <button
            type="button"
            className={`segmented-item ${type === 'FINGERING' ? 'active' : ''}`}
            onClick={() => setType('FINGERING')}
          >
            🖐 Аппликатура
          </button>
        </div>
      </div>

      {type === 'PLAY_PRACTICE' && (
        <>
          <div className="form-group">
            <label className="form-label" htmlFor="quick-play-target">
              Нота или аккорд
            </label>
            <select
              id="quick-play-target"
              className="input"
              value={playTarget}
              onChange={(event) => setPlayTarget(event.target.value)}
            >
              <optgroup label="Ноты">
                {NOTE_TARGETS.map((note) => (
                  <option key={note} value={note}>{note}</option>
                ))}
              </optgroup>
              <optgroup label="Аккорды">
                {CHORD_NAMES.map((chord) => (
                  <option key={chord} value={chord}>{chord}</option>
                ))}
              </optgroup>
            </select>
          </div>

          <div className="form-group">
            <label className="form-label" htmlFor="quick-tolerance">
              Допуск: ±{tolerance} центов
            </label>
            <input
              id="quick-tolerance"
              type="range"
              min="5"
              max="50"
              step="5"
              value={tolerance}
              onChange={(event) => setTolerance(event.target.value)}
            />
          </div>
        </>
      )}

      {type === 'EAR_TRAINING' && (
        <>
          <div className="form-group">
            <label className="form-label" htmlFor="quick-ear-target">
              Правильный ответ
            </label>
            <select
              id="quick-ear-target"
              className="input"
              value={earTarget}
              onChange={(event) => setEarTarget(event.target.value)}
            >
              <optgroup label="Ноты">
                {['A', 'B', 'C', 'D', 'E', 'F', 'G'].map((note) => (
                  <option key={note} value={note}>{note}</option>
                ))}
              </optgroup>
              <optgroup label="Аккорды">
                {['Am', 'C', 'G', 'Em', 'D', 'E'].map((chord) => (
                  <option key={chord} value={chord}>{chord}</option>
                ))}
              </optgroup>
            </select>
          </div>

          <div className="form-group">
            <span className="form-label">Варианты ответа</span>
            <div className="chip-list">
              {earOptions.map((option) => (
                <span key={option} className="chip chip-primary">{option}</span>
              ))}
            </div>
          </div>
        </>
      )}

      {type === 'FINGERING' && (
        <>
          <div className="form-group">
            <span className="form-label">Подтип карточки</span>
            <div className="segmented segmented-wrap">
              {FINGERING_KINDS.map((kind) => (
                <button
                  key={kind.id}
                  type="button"
                  className={`segmented-item ${fingeringKindId === kind.id ? 'active' : ''}`}
                  onClick={() => setFingeringKindId(kind.id)}
                >
                  {kind.label}
                </button>
              ))}
            </div>
          </div>

          <div className="form-group">
            <label className="form-label" htmlFor="quick-fingering-target">
              Аккорд (все 24)
            </label>
            <select
              id="quick-fingering-target"
              className="input"
              value={fingeringTarget}
              onChange={(event) => setFingeringTarget(event.target.value)}
            >
              <optgroup label="Мажорные">
                {MAJOR_CHORD_NAMES.map((chord) => (
                  <option key={chord} value={chord}>{chord}</option>
                ))}
              </optgroup>
              <optgroup label="Минорные">
                {MINOR_CHORD_NAMES.map((chord) => (
                  <option key={chord} value={chord}>{chord}</option>
                ))}
              </optgroup>
            </select>
          </div>

          {/* Превью аппликатуры — учитель видит, что отправляет */}
          <div className="form-group">
            <span className="form-label">Превью аппликатуры</span>
            <div className="fretboard-preview">
              <Fretboard positions={previewPositions} readOnly />
              <button
                type="button"
                className="btn btn-ghost btn-sm"
                onClick={handlePreviewPlay}
                disabled={isPreviewPlaying}
              >
                {isPreviewPlaying ? '🔊 Звучит…' : '▶ Прослушать'}
              </button>
            </div>
          </div>

          {fingeringKind.type === 'FINGERING_TEST' && (
            <div className="form-group">
              <span className="form-label">Варианты ответа</span>
              <div className="chip-list">
                {fingeringOptions.map((option) => (
                  <span
                    key={option}
                    className={`chip ${option === fingeringTarget ? 'chip-success' : 'chip-primary'}`}
                  >
                    {option}
                  </span>
                ))}
              </div>
            </div>
          )}

          {isFingeringPlayKind && (
            <div className="form-group">
              <label className="form-label" htmlFor="quick-fingering-tolerance">
                Допуск: ±{tolerance} центов
              </label>
              <input
                id="quick-fingering-tolerance"
                type="range"
                min="10"
                max="50"
                step="5"
                value={tolerance}
                onChange={(event) => setTolerance(event.target.value)}
              />
            </div>
          )}
        </>
      )}

      <div className="form-group">
        <label className="form-label" htmlFor="quick-instruction">
          Инструкция (необязательно)
        </label>
        <input
          id="quick-instruction"
          className="input"
          placeholder="Например: возьми аккорд одним боем"
          value={instruction}
          onChange={(event) => setInstruction(event.target.value)}
        />
      </div>

      <button
        type="button"
        className="btn btn-primary btn-lg btn-block"
        onClick={handleSend}
        disabled={disabled}
      >
        📤 Отправить ученику
      </button>
    </div>
  );
}
