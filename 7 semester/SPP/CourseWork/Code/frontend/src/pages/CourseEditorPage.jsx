import { useCallback, useEffect, useState } from 'react';
import { useNavigate, useParams } from 'react-router-dom';
import api from '../api/axios';
import TaskEditor from '../components/Courses/TaskEditor';
import toast from 'react-hot-toast';

const TASK_TYPE_BADGES = {
  EAR_TRAINING: '🎵 Тренировка слуха',
  PLAY_PRACTICE: '🎸 Практика',
  FINGERING_TEST: '🧩 Аппликатура',
  PLAY_FINGERING: '🖐 Аппликатура · сыграть',
  COMBO_FINGERING: '🎯 Аппликатура · комбо',
};

export default function CourseEditorPage() {
  const { id } = useParams();
  const navigate = useNavigate();

  const [course, setCourse] = useState(null);
  const [form, setForm] = useState({ title: '', description: '' });
  const [isLoading, setIsLoading] = useState(true);
  const [isSaving, setIsSaving] = useState(false);
  const [isPublishing, setIsPublishing] = useState(false);

  const [editorOpen, setEditorOpen] = useState(false);
  const [editingTask, setEditingTask] = useState(null);

  const [courseStudents, setCourseStudents] = useState([]);
  const [availableStudents, setAvailableStudents] = useState([]);
  const [selectedStudentId, setSelectedStudentId] = useState('');
  const [studentEmail, setStudentEmail] = useState('');
  const [isStudentBusy, setIsStudentBusy] = useState(false);

  const loadCourse = useCallback(async () => {
    setIsLoading(true);
    try {
      const { data } = await api.get(`/courses/${id}`);
      setCourse(data.course);
      setForm({
        title: data.course.title || '',
        description: data.course.description || '',
      });
    } catch (err) {
      toast.error(err.response?.data?.error || 'Не удалось загрузить курс');
      navigate('/dashboard');
    } finally {
      setIsLoading(false);
    }
  }, [id, navigate]);

  const loadCourseStudents = useCallback(async () => {
    try {
      const { data } = await api.get(`/courses/${id}/students`);
      setCourseStudents(data.students || []);
      setAvailableStudents(data.availableStudents || []);
    } catch {  }
  }, [id]);

  useEffect(() => {
    loadCourse();
    loadCourseStudents();
  }, [loadCourse, loadCourseStudents]);

  const addStudentToCourse = async (event) => {
    event.preventDefault();
    if (!selectedStudentId && !studentEmail.trim()) {
      toast.error('Выберите студента или укажите email');
      return;
    }

    setIsStudentBusy(true);
    try {
      await api.post(`/courses/${id}/students`, {
        studentId: selectedStudentId || undefined,
        email: selectedStudentId ? undefined : studentEmail.trim(),
      });
      toast.success('Студент добавлен в курс');
      setSelectedStudentId('');
      setStudentEmail('');
      await loadCourseStudents();
    } catch (err) {
      toast.error(err.response?.data?.error || 'Не удалось добавить студента');
    } finally {
      setIsStudentBusy(false);
    }
  };

  const removeStudentFromCourse = async (student) => {
    if (!window.confirm(`Убрать ${student.firstName} ${student.lastName} из курса?`)) return;

    setIsStudentBusy(true);
    try {
      await api.delete(`/courses/${id}/students/${student.id}`);
      toast.success('Студент убран из курса');
      await loadCourseStudents();
    } catch (err) {
      toast.error(err.response?.data?.error || 'Не удалось убрать студента');
    } finally {
      setIsStudentBusy(false);
    }
  };

  const saveCourse = async (event) => {
    event.preventDefault();
    if (!form.title.trim()) {
      toast.error('Название курса обязательно');
      return;
    }

    setIsSaving(true);
    try {
      const { data } = await api.put(`/courses/${id}`, form);
      setCourse((prev) => ({ ...prev, ...data.course }));
      toast.success('Курс сохранён');
    } catch (err) {
      toast.error(err.response?.data?.error || 'Ошибка сохранения');
    } finally {
      setIsSaving(false);
    }
  };

  const saveTask = async (payload) => {
    setIsSaving(true);
    try {
      if (editingTask) {
        await api.put(`/tasks/${editingTask.id}`, payload);
        toast.success('Задание обновлено');
      } else {
        await api.post(`/tasks/course/${id}`, payload);
        toast.success('Задание добавлено');
      }
      setEditorOpen(false);
      setEditingTask(null);
      await loadCourse();
    } catch (err) {
      toast.error(err.response?.data?.error || 'Ошибка сохранения задания');
    } finally {
      setIsSaving(false);
    }
  };

  const deleteTask = async (task) => {
    if (!window.confirm(`Удалить задание «${task.title}»?`)) return;

    try {
      await api.delete(`/tasks/${task.id}`);
      toast.success('Задание удалено');
      await loadCourse();
    } catch (err) {
      toast.error(err.response?.data?.error || 'Ошибка удаления');
    }
  };

  const togglePublish = async () => {
    setIsPublishing(true);
    try {
      const action = course.status === 'PUBLISHED' ? 'unpublish' : 'publish';
      const { data } = await api.patch(`/courses/${id}/${action}`);
      setCourse((prev) => ({ ...prev, ...data.course }));
      toast.success(
        action === 'publish' ? 'Курс опубликован 🎉' : 'Курс снят с публикации'
      );
    } catch (err) {
      toast.error(err.response?.data?.error || 'Ошибка публикации');
    } finally {
      setIsPublishing(false);
    }
  };

  if (isLoading) {
    return (
      <div className="editor-loading">
        <div className="loader" />
        <span>Загружаем курс…</span>
      </div>
    );
  }

  if (!course) return null;

  const isPublished = course.status === 'PUBLISHED';
  const tasks = course.tasks || [];

  return (
    <div className="editor-page">
      <header className="editor-header">
        <div className="editor-header-left">
          <button className="btn btn-ghost btn-sm" onClick={() => navigate('/dashboard')}>
            ← К курсам
          </button>
          <span className={`status-badge ${isPublished ? 'is-correct' : 'is-pending'}`}>
            {isPublished ? '● Опубликован' : '○ Черновик'}
          </span>
        </div>

        <div className="editor-header-actions">
          <button
            className={`btn ${isPublished ? 'btn-ghost' : 'btn-primary'}`}
            onClick={togglePublish}
            disabled={isPublishing}
          >
            {isPublishing
              ? 'Сохраняем…'
              : isPublished
                ? 'Снять с публикации'
                : '🚀 Опубликовать курс'}
          </button>
        </div>
      </header>

      <main className="editor-body">
        <section className="editor-card">
          <h2 className="section-title">Информация о курсе</h2>

          <form className="editor-form" onSubmit={saveCourse}>
            <div className="form-group">
              <label className="form-label" htmlFor="course-title">Название</label>
              <input
                id="course-title"
                className="input"
                value={form.title}
                onChange={(event) => setForm((prev) => ({ ...prev, title: event.target.value }))}
                required
              />
            </div>

            <div className="form-group">
              <label className="form-label" htmlFor="course-description">Описание</label>
              <textarea
                id="course-description"
                className="input"
                rows={3}
                value={form.description}
                onChange={(event) => setForm((prev) => ({ ...prev, description: event.target.value }))}
              />
            </div>

            <div className="editor-form-footer">
              <span className="form-hint">
                {isPublished
                  ? 'Изменения в опубликованном курсе сразу видны ученикам.'
                  : 'Чтобы назначить курс ученикам, опубликуйте его.'}
              </span>
              <button type="submit" className="btn btn-primary" disabled={isSaving}>
                {isSaving ? 'Сохраняем…' : 'Сохранить'}
              </button>
            </div>
          </form>
        </section>

        <section className="editor-card">
          <div className="section-header">
            <div>
              <h2 className="section-title">Задания курса</h2>
              <p className="section-subtitle">
                {tasks.length} заданий · порядок прохождения сверху вниз
              </p>
            </div>

            <button
              className="btn btn-accent"
              onClick={() => {
                setEditingTask(null);
                setEditorOpen(true);
              }}
            >
              + Добавить задание
            </button>
          </div>

          {tasks.length === 0 ? (
            <div className="empty-state compact">
              <div className="empty-state-icon">📝</div>
              <h3>В курсе пока нет заданий</h3>
              <p className="empty-state-text">
                Добавьте первое задание, чтобы затем опубликовать курс.
              </p>
            </div>
          ) : (
            <div className="task-list">
              {tasks.map((task, index) => (
                <div key={task.id} className="task-list-item">
                  <div className="task-list-index">{index + 1}</div>

                  <div className="task-list-main">
                    <div className="task-list-title">{task.title}</div>
                    <div className="task-list-meta">
                      <span className={`task-type-pill ${task.type === 'EAR_TRAINING' ? 'is-ear' : 'is-play'}`}>
                        {TASK_TYPE_BADGES[task.type] || '🎼 Задание'}
                      </span>
                      {task.type === 'EAR_TRAINING'
                        ? <span>Ответ: {task.correctAnswer || '—'}</span>
                        : task.type === 'FINGERING_TEST'
                          ? <span>Аккорд: {task.expectedNote || '—'} ({task.fingeringMode === 'BUILD' ? 'сборка' : 'угадать'})</span>
                          : task.type === 'PLAY_FINGERING' || task.type === 'COMBO_FINGERING'
                            ? <span>Аккорд: {task.expectedNote || '—'} (±{task.toleranceCents}¢)</span>
                            : <span>Сыграть: {task.expectedNote || '—'} (±{task.toleranceCents}¢)</span>}
                    </div>
                  </div>

                  <div className="task-list-actions">
                    <button
                      className="btn btn-ghost btn-sm"
                      onClick={() => {
                        setEditingTask(task);
                        setEditorOpen(true);
                      }}
                    >
                      Изменить
                    </button>
                    <button
                      className="btn btn-danger btn-sm"
                      onClick={() => deleteTask(task)}
                    >
                      Удалить
                    </button>
                  </div>
                </div>
              ))}
            </div>
          )}
        </section>

        <section className="editor-card">
          <div className="section-header">
            <div>
              <h2 className="section-title">Студенты курса</h2>
              <p className="section-subtitle">
                {courseStudents.length} записан(о) · добавьте ученика по списку или email
              </p>
            </div>
          </div>

          {courseStudents.length === 0 ? (
            <div className="empty-state compact">
              <div className="empty-state-icon">👥</div>
              <h3>На курс ещё никто не записан</h3>
              <p className="empty-state-text">
                Добавьте ученика ниже — он сразу получит доступ к заданиям курса.
              </p>
            </div>
          ) : (
            <div className="task-list">
              {courseStudents.map((student) => (
                <div key={student.id} className="task-list-item">
                  <div className="avatar-circle" style={{ flexShrink: 0 }}>
                    {student.firstName?.[0]}{student.lastName?.[0]}
                  </div>

                  <div className="task-list-main">
                    <div className="task-list-title">
                      {[student.firstName, student.lastName].filter(Boolean).join(' ') || student.email}
                    </div>
                    <div className="task-list-meta">
                      <span>{student.email}</span>
                      <span style={{ color: 'var(--color-primary)', fontWeight: 600 }}>
                        {student.progress}%
                      </span>
                    </div>
                    <div className="progress-bar" style={{ marginTop: '8px' }}>
                      <div className="progress-bar-fill" style={{ width: `${student.progress}%` }} />
                    </div>
                  </div>

                  <div className="task-list-actions">
                    <button
                      className="btn btn-danger btn-sm"
                      onClick={() => removeStudentFromCourse(student)}
                      disabled={isStudentBusy}
                    >
                      Убрать
                    </button>
                  </div>
                </div>
              ))}
            </div>
          )}

          <form
            onSubmit={addStudentToCourse}
            style={{
              display: 'flex',
              flexWrap: 'wrap',
              gap: '10px',
              alignItems: 'center',
              marginTop: '20px',
              paddingTop: '20px',
              borderTop: '1px solid var(--color-border)',
            }}
          >
            <select
              className="input"
              value={selectedStudentId}
              onChange={(event) => {
                setSelectedStudentId(event.target.value);
                if (event.target.value) setStudentEmail('');
              }}
              disabled={isStudentBusy}
              style={{ flex: '1 1 220px', minWidth: '180px' }}
            >
              <option value="">Выберите студента…</option>
              {availableStudents.map((student) => (
                <option key={student.id} value={student.id}>
                  {[student.firstName, student.lastName].filter(Boolean).join(' ') || student.email}
                  {' · '}
                  {student.email}
                </option>
              ))}
            </select>

            <input
              className="input"
              type="email"
              placeholder="или email студента"
              value={studentEmail}
              onChange={(event) => {
                setStudentEmail(event.target.value);
                if (event.target.value) setSelectedStudentId('');
              }}
              disabled={isStudentBusy || Boolean(selectedStudentId)}
              style={{ flex: '1 1 220px', minWidth: '180px' }}
            />

            <button className="btn btn-primary" type="submit" disabled={isStudentBusy}>
              {isStudentBusy ? 'Добавляем…' : '+ Добавить в курс'}
            </button>
          </form>
        </section>
      </main>

      <TaskEditor
        open={editorOpen}
        task={editingTask}
        onClose={() => {
          setEditorOpen(false);
          setEditingTask(null);
        }}
        onSave={saveTask}
        isSaving={isSaving}
      />
    </div>
  );
}
