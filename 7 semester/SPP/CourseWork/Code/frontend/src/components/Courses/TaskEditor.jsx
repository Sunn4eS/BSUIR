/**
 * components/Courses/TaskEditor.jsx
 * Модальное окно создания/редактирования задания.
 * Поддерживает все 5 типов карточек, включая аппликатуру.
 */

import { useEffect, useMemo, useState } from 'react';
import {
  MAJOR_CHORD_NAMES,
  MINOR_CHORD_NAMES,
  buildAnswerOptions,
  normalizeChordName,
} from '../../audio/chordShapes';

const TASK_TYPES = [
  { value: 'PLAY_PRACTICE', label: '🎸 Практика игры' },
  { value: 'EAR_TRAINING', label: '🎵 Тренировка слуха' },
  { value: 'FINGERING_TEST', label: '🧩 Аппликатура: угадать/собрать' },
  { value: 'PLAY_FINGERING', label: '🖐 Аппликатура: сыграть' },
  { value: 'COMBO_FINGERING', label: '🎯 Аппликатура: собрать и сыграть' },
];

const EMPTY_FORM = {
  type: 'PLAY_PRACTICE',
  title: '',
  instruction: '',
  audioContent: '',
  answerOptions: 'A, B, C, D',
  correctAnswer: '',
  expectedNote: '',
  toleranceCents: 20,
  fingeringMode: 'GUESS',
  isTemplate: true,
};

function toForm(task) {
  if (!task) return { ...EMPTY_FORM };

  return {
    type: task.type || 'PLAY_PRACTICE',
    title: task.title || '',
    instruction: task.instruction || '',
    audioContent: task.audioContent || '',
    answerOptions: Array.isArray(task.answerOptions)
      ? task.answerOptions.join(', ')
      : (task.answerOptions || ''),
    correctAnswer: task.correctAnswer || '',
    expectedNote: task.expectedNote || '',
    toleranceCents: task.toleranceCents ?? 20,
    fingeringMode: task.fingeringMode || 'GUESS',
    isTemplate: task.isTemplate ?? true,
  };
}

export default function TaskEditor({ open, task, onClose, onSave, isSaving }) {
  const [form, setForm] = useState(EMPTY_FORM);
  const [error, setError] = useState(null);

  useEffect(() => {
    if (open) {
      setForm(toForm(task));
      setError(null);
    }
  }, [open, task]);

  const set = (field) => (event) => {
    const value = event.target.type === 'checkbox' ? event.target.checked : event.target.value;
    setForm((prev) => ({ ...prev, [field]: value }));
  };

  const isFingeringType =
    form.type === 'FINGERING_TEST' ||
    form.type === 'PLAY_FINGERING' ||
    form.type === 'COMBO_FINGERING';

  const fingeringChord = normalizeChordName(form.expectedNote) || '';

  // Варианты для FINGERING_TEST генерируются автоматически: 4 аккорда
  const fingeringOptions = useMemo(
    () => (fingeringChord ? buildAnswerOptions(fingeringChord, 4) : []),
    [fingeringChord]
  );

  const handleSubmit = (event) => {
    event.preventDefault();
    setError(null);

    if (!form.title.trim()) {
      setError('Введите название задания');
      return;
    }

    if (form.type === 'EAR_TRAINING') {
      const options = form.answerOptions
        .split(',')
        .map((item) => item.trim())
        .filter(Boolean);

      if (options.length < 2) {
        setError('Нужно минимум 2 варианта ответа');
        return;
      }
      if (!form.correctAnswer.trim()) {
        setError('Укажите правильный ответ');
        return;
      }
      if (!options.includes(form.correctAnswer.trim())) {
        setError('Правильный ответ должен быть одним из вариантов');
        return;
      }
    }

    if (form.type === 'PLAY_PRACTICE' && !form.expectedNote.trim()) {
      setError('Укажите ноту или аккорд');
      return;
    }

    if (isFingeringType && !fingeringChord) {
      setError('Выберите аккорд из списка (24 базовых аккорда)');
      return;
    }

    const base = {
      type: form.type,
      title: form.title.trim(),
      instruction: form.instruction.trim() || null,
      isTemplate: form.isTemplate,
    };

    if (form.type === 'EAR_TRAINING') {
      onSave({
        ...base,
        audioContent: form.audioContent.trim() || null,
        answerOptions: form.answerOptions.split(',').map((item) => item.trim()).filter(Boolean),
        correctAnswer: form.correctAnswer.trim(),
        expectedNote: null,
        toleranceCents: 20,
      });
      return;
    }

    if (form.type === 'PLAY_PRACTICE') {
      onSave({
        ...base,
        audioContent: null,
        answerOptions: [],
        correctAnswer: null,
        expectedNote: form.expectedNote.trim(),
        toleranceCents: Number(form.toleranceCents) || 20,
      });
      return;
    }

    if (form.type === 'FINGERING_TEST') {
      onSave({
        ...base,
        audioContent: null,
        answerOptions: fingeringOptions,
        correctAnswer: fingeringChord,
        expectedNote: fingeringChord,
        toleranceCents: Number(form.toleranceCents) || 30,
        fingeringMode: form.fingeringMode === 'BUILD' ? 'BUILD' : 'GUESS',
      });
      return;
    }

    // PLAY_FINGERING / COMBO_FINGERING
    onSave({
      ...base,
      audioContent: null,
      answerOptions: [],
      correctAnswer: null,
      expectedNote: fingeringChord,
      toleranceCents: Number(form.toleranceCents) || 30,
      fingeringMode: null,
    });
  };

  if (!open) return null;

  return (
    <div className="modal-overlay" onClick={onClose}>
      <div className="modal-content modal-lg" onClick={(event) => event.stopPropagation()}>
        <div className="modal-header">
          <h3>{task ? 'Редактировать задание' : 'Новое задание'}</h3>
          <button type="button" className="icon-btn" onClick={onClose} aria-label="Закрыть">
            ✕
          </button>
        </div>

        <form className="modal-form" onSubmit={handleSubmit}>
          <div className="form-group">
            <label className="form-label" htmlFor="task-type">Тип задания</label>
            <select id="task-type" className="input" value={form.type} onChange={set('type')}>
              {TASK_TYPES.map((item) => (
                <option key={item.value} value={item.value}>{item.label}</option>
              ))}
            </select>
          </div>

          <div className="form-group">
            <label className="form-label" htmlFor="task-title">Название</label>
            <input
              id="task-title"
              className="input"
              placeholder="Например: Сыграй аккорд Am"
              value={form.title}
              onChange={set('title')}
              required
            />
          </div>

          <div className="form-group">
            <label className="form-label" htmlFor="task-instruction">Инструкция</label>
            <textarea
              id="task-instruction"
              className="input"
              rows={3}
              placeholder="Что должен сделать ученик"
              value={form.instruction}
              onChange={set('instruction')}
            />
          </div>

          {form.type === 'PLAY_PRACTICE' && (
            <div className="form-row">
              <div className="form-group">
                <label className="form-label" htmlFor="task-expected">Нота или аккорд</label>
                <input
                  id="task-expected"
                  className="input"
                  placeholder="E4, A2, Am, C…"
                  value={form.expectedNote}
                  onChange={set('expectedNote')}
                  required
                />
              </div>

              <div className="form-group">
                <label className="form-label" htmlFor="task-tolerance">Допуск, центов</label>
                <input
                  id="task-tolerance"
                  type="number"
                  min="5"
                  max="100"
                  className="input"
                  value={form.toleranceCents}
                  onChange={set('toleranceCents')}
                />
              </div>
            </div>
          )}

          {form.type === 'EAR_TRAINING' && (
            <>
              <div className="form-group">
                <label className="form-label" htmlFor="task-audio">Аудио (URL или ключ)</label>
                <input
                  id="task-audio"
                  className="input"
                  placeholder="samples/guitar/E4.mp3 или A4"
                  value={form.audioContent}
                  onChange={set('audioContent')}
                />
                <span className="form-hint">
                  Если поле пустое, звук берётся из гитарного семплера.
                </span>
              </div>

              <div className="form-row">
                <div className="form-group">
                  <label className="form-label" htmlFor="task-options">Варианты ответа</label>
                  <input
                    id="task-options"
                    className="input"
                    placeholder="Am, C, G, Em"
                    value={form.answerOptions}
                    onChange={set('answerOptions')}
                    required
                  />
                </div>

                <div className="form-group">
                  <label className="form-label" htmlFor="task-correct">Правильный ответ</label>
                  <input
                    id="task-correct"
                    className="input"
                    placeholder="Am"
                    value={form.correctAnswer}
                    onChange={set('correctAnswer')}
                    required
                  />
                </div>
              </div>
            </>
          )}

          {isFingeringType && (
            <>
              <div className="form-row">
                <div className="form-group">
                  <label className="form-label" htmlFor="task-fingering-chord">Аккорд</label>
                  <select
                    id="task-fingering-chord"
                    className="input"
                    value={fingeringChord}
                    onChange={set('expectedNote')}
                    required
                  >
                    <option value="" disabled>Выберите аккорд…</option>
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

                {form.type !== 'FINGERING_TEST' && (
                  <div className="form-group">
                    <label className="form-label" htmlFor="task-fingering-tolerance">
                      Допуск, центов
                    </label>
                    <input
                      id="task-fingering-tolerance"
                      type="number"
                      min="10"
                      max="100"
                      className="input"
                      value={form.toleranceCents}
                      onChange={set('toleranceCents')}
                    />
                  </div>
                )}
              </div>

              {form.type === 'FINGERING_TEST' && (
                <>
                  <div className="form-group">
                    <span className="form-label">Режим карточки</span>
                    <div className="segmented">
                      <button
                        type="button"
                        className={`segmented-item ${form.fingeringMode === 'GUESS' ? 'active' : ''}`}
                        onClick={() => setForm((prev) => ({ ...prev, fingeringMode: 'GUESS' }))}
                      >
                        🧩 Угадать (выбор из вариантов)
                      </button>
                      <button
                        type="button"
                        className={`segmented-item ${form.fingeringMode === 'BUILD' ? 'active' : ''}`}
                        onClick={() => setForm((prev) => ({ ...prev, fingeringMode: 'BUILD' }))}
                      >
                        🛠 Собрать (на грифе)
                      </button>
                    </div>
                    <span className="form-hint">
                      Угадать: ученик видит аппликатуру и выбирает аккорд.
                      Собрать: ученик собирает аппликатуру по названию.
                    </span>
                  </div>

                  {fingeringChord && (
                    <div className="form-group">
                      <span className="form-label">Варианты ответа (авто)</span>
                      <div className="chip-list">
                        {fingeringOptions.map((option) => (
                          <span
                            key={option}
                            className={`chip ${option === fingeringChord ? 'chip-success' : 'chip-primary'}`}
                          >
                            {option}
                          </span>
                        ))}
                      </div>
                    </div>
                  )}
                </>
              )}
            </>
          )}

          <label className="checkbox-row">
            <input type="checkbox" checked={form.isTemplate} onChange={set('isTemplate')} />
            <span>Использовать как шаблон в Live-уроках</span>
          </label>

          {error && <div className="alert alert-error">{error}</div>}

          <div className="modal-actions">
            <button type="button" className="btn btn-ghost" onClick={onClose}>
              Отмена
            </button>
            <button type="submit" className="btn btn-primary" disabled={isSaving}>
              {isSaving ? 'Сохраняем…' : 'Сохранить задание'}
            </button>
          </div>
        </form>
      </div>
    </div>
  );
}
