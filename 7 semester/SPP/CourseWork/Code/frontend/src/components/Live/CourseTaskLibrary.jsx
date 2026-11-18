/**
 * components/Live/CourseTaskLibrary.jsx
 * Библиотека опубликованных курсов и заданий для Live-урока.
 */

import { useCallback, useEffect, useState } from 'react';
import api from '../../api/axios';
import toast from 'react-hot-toast';

export default function CourseTaskLibrary({ onSendTask, disabled = false }) {
  const [courses, setCourses] = useState([]);
  const [isLoading, setIsLoading] = useState(true);
  const [expanded, setExpanded] = useState(null);

  const loadLibrary = useCallback(async () => {
    setIsLoading(true);
    try {
      const { data } = await api.get('/courses/library');
      setCourses(data.courses || []);
      if (data.courses?.length) setExpanded(data.courses[0].id);
    } catch (err) {
      toast.error(err.response?.data?.error || 'Не удалось загрузить библиотеку');
    } finally {
      setIsLoading(false);
    }
  }, []);

  useEffect(() => {
    loadLibrary();
  }, [loadLibrary]);

  if (isLoading) {
    return (
      <div className="panel-loader">
        <div className="loader" />
        <span>Загружаем библиотеку…</span>
      </div>
    );
  }

  if (!courses.length) {
    return (
      <div className="empty-state compact">
        <div className="empty-state-icon">📚</div>
        <p className="empty-state-text">
          Нет опубликованных курсов. Создайте курс и нажмите «Опубликовать».
        </p>
      </div>
    );
  }

  return (
    <div className="library">
      {courses.map((course) => {
        const isOpen = expanded === course.id;

        return (
          <div key={course.id} className="library-course">
            <button
              type="button"
              className="library-course-header"
              onClick={() => setExpanded(isOpen ? null : course.id)}
            >
              <div>
                <div className="library-course-title">{course.title}</div>
                <div className="library-course-meta">
                  {course.tasks?.length || 0} заданий
                </div>
              </div>
              <span className="library-chevron">{isOpen ? '−' : '+'}</span>
            </button>

            {isOpen && (
              <div className="library-tasks">
                {course.tasks?.length ? (
                  course.tasks.map((task) => (
                    <div key={task.id} className="library-task">
                      <div className="library-task-info">
                        <span className={`task-type-dot ${task.type === 'EAR_TRAINING' ? 'is-ear' : 'is-play'}`} />
                        <div>
                          <div className="library-task-title">{task.title}</div>
                          <div className="library-task-meta">
                            {task.type === 'EAR_TRAINING'
                              ? `Ответ: ${task.correctAnswer || '—'}`
                              : task.type === 'FINGERING_TEST'
                                ? `Аккорд: ${task.expectedNote || '—'} (${task.fingeringMode === 'BUILD' ? 'сборка' : 'угадать'})`
                                : task.type === 'PLAY_FINGERING' || task.type === 'COMBO_FINGERING'
                                  ? `Аккорд: ${task.expectedNote || '—'}`
                                  : `Сыграть: ${task.expectedNote || '—'}`}
                          </div>
                        </div>
                      </div>

                      <button
                        type="button"
                        className="btn btn-accent btn-sm"
                        disabled={disabled}
                        onClick={() => onSendTask(task.id)}
                      >
                        Отправить
                      </button>
                    </div>
                  ))
                ) : (
                  <p className="library-empty">В курсе пока нет заданий</p>
                )}
              </div>
            )}
          </div>
        );
      })}
    </div>
  );
}
