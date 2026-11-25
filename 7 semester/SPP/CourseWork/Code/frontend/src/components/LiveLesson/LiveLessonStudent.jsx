import { useCallback, useEffect, useMemo, useRef, useState } from 'react';
import TaskCard from '../Cards/TaskCard';
import { useSocket } from '../../hooks/useSocket';
import toast from 'react-hot-toast';

const STATUS_ICONS = {
  CORRECT: '✅',
  INCORRECT: '❌',
  IN_PROGRESS: '⏳',
  PENDING: '⚪',
  SKIPPED: '⏭',
};

const STATUS_LABELS = {
  CORRECT: 'Выполнено',
  INCORRECT: 'Неверно',
  IN_PROGRESS: 'В процессе',
  PENDING: 'Ожидает решения',
  SKIPPED: 'Пропущено',
};

export default function LiveLessonStudent({
  roomCode,
  teacherName = 'Преподаватель',
  initialTasks = [],
  onLeave = null,
}) {
  const { on, off, emit, isConnected } = useSocket();

  const [tasks, setTasks] = useState(initialTasks);

  const [teacherTaskIndex, setTeacherTaskIndex] = useState(
    initialTasks.length > 0 ? initialTasks.length - 1 : 0
  );

  const [studentTaskIndex, setStudentTaskIndex] = useState(
    initialTasks.length > 0 ? initialTasks.length - 1 : 0
  );

  const [maxOpenedIndex, setMaxOpenedIndex] = useState(
    initialTasks.length > 0 ? initialTasks.length - 1 : 0
  );

  const [taskStatuses, setTaskStatuses] = useState({});

  const currentTask = tasks[studentTaskIndex] || null;
  const isViewingTeacherTask = studentTaskIndex === teacherTaskIndex;

  useEffect(() => {
    if (!isConnected) return;

    const handleInitState = (payload) => {
      if (!payload) return;
      const loadedTasks = payload.tasks || [];
      setTasks(loadedTasks);

      const targetIdx =
        payload.currentTaskIndex !== undefined
          ? payload.currentTaskIndex
          : Math.max(0, loadedTasks.length - 1);

      setTeacherTaskIndex(targetIdx);
      setStudentTaskIndex(targetIdx);
      setMaxOpenedIndex(Math.max(0, loadedTasks.length - 1));

      if (payload.statuses) {
        setTaskStatuses(payload.statuses);
      } else {
        const statuses = {};
        loadedTasks.forEach((t) => {
          if (t.id && t.status) statuses[t.id] = t.status;
        });
        setTaskStatuses(statuses);
      }
    };

    const handleSetTask = (payload) => {
      if (!payload) return;

      if (payload.card) {
        setTasks((prev) => {
          const exists = prev.some((item) => item.id === payload.card.id);
          if (exists) return prev;
          const next = [...prev, payload.card];
          const newIdx = next.length - 1;
          setTeacherTaskIndex(newIdx);
          setMaxOpenedIndex((m) => Math.max(m, newIdx));
          setStudentTaskIndex((currentIdx) =>
            currentIdx >= prev.length - 1 ? newIdx : currentIdx
          );
          return next;
        });
        toast('🔔 Новое задание от учителя!', { icon: '🎸' });
      } else if (payload.currentTaskIndex !== undefined) {
        const idx = Number(payload.currentTaskIndex);
        setTeacherTaskIndex(idx);
        setMaxOpenedIndex((m) => Math.max(m, idx));
        setStudentTaskIndex((cur) => (cur === teacherTaskIndex ? idx : cur));
      }
    };

    const handleNewTaskCard = ({ card }) => {
      if (!card) return;
      setTasks((prev) => {
        const exists = prev.some((item) => item.id === card.id);
        if (exists) return prev;
        const next = [...prev, card];
        const newIdx = next.length - 1;
        setTeacherTaskIndex(newIdx);
        setMaxOpenedIndex((m) => Math.max(m, newIdx));
        setStudentTaskIndex(newIdx);
        return next;
      });
      toast.success('Учитель отправил новое задание!');
    };

    const handleTaskCompleted = (result) => {
      if (!result?.cardId) return;
      setTaskStatuses((prev) => ({
        ...prev,
        [result.cardId]: result.status || (result.isCorrect ? 'CORRECT' : 'INCORRECT'),
      }));
    };

    const handleTaskResult = ({ cardId, isCorrect }) => {
      if (!cardId) return;
      const status = isCorrect ? 'CORRECT' : 'INCORRECT';
      setTaskStatuses((prev) => ({
        ...prev,
        [cardId]: status,
      }));
    };

    on('lesson:init_state', handleInitState);
    on('lesson:set_task', handleSetTask);
    on('lesson:task_completed', handleTaskCompleted);
    on('new_task_card', handleNewTaskCard);
    on('task_result', handleTaskResult);
    on('my_task_result', handleTaskResult);

    return () => {
      off('lesson:init_state', handleInitState);
      off('lesson:set_task', handleSetTask);
      off('lesson:task_completed', handleTaskCompleted);
      off('new_task_card', handleNewTaskCard);
      off('task_result', handleTaskResult);
      off('my_task_result', handleTaskResult);
    };
  }, [isConnected, on, off, teacherTaskIndex]);

  useEffect(() => {
    if (!initialTasks?.length) return;

    setTasks((prev) => {
      if (prev.length === 0) return initialTasks;

      const byId = new Map(prev.map((task) => [task.id, task]));
      let changed = false;
      for (const task of initialTasks) {
        if (!byId.has(task.id)) {
          byId.set(task.id, task);
          changed = true;
        }
      }
      return changed ? [...byId.values()] : prev;
    });

    setTaskStatuses((prev) => {
      const next = { ...prev };
      let changed = false;
      for (const task of initialTasks) {
        const status = task.status || 'PENDING';
        if (task.id && next[task.id] === undefined) {
          next[task.id] = status;
          changed = true;
        }
      }
      return changed ? next : prev;
    });

    setMaxOpenedIndex((m) => Math.max(m, initialTasks.length - 1));

    setStudentTaskIndex((idx) => {
      if (idx > 0) return idx;
      const firstUnfinished = initialTasks.findIndex(
        (task) => !task.status || task.status === 'PENDING' || task.status === 'IN_PROGRESS'
      );
      return firstUnfinished >= 0 ? firstUnfinished : initialTasks.length - 1;
    });
  }, [initialTasks]);

  const canGoBack = studentTaskIndex > 0;
  const canGoForward = studentTaskIndex < Math.min(tasks.length - 1, maxOpenedIndex);

  const handlePrevTask = useCallback(() => {
    if (!canGoBack) return;
    const targetIdx = studentTaskIndex - 1;
    setStudentTaskIndex(targetIdx);
    emit('lesson:student_navigate', { targetIndex: targetIdx });
  }, [canGoBack, studentTaskIndex, emit]);

  const handleNextTask = useCallback(() => {
    if (!canGoForward) return;
    const targetIdx = studentTaskIndex + 1;
    setStudentTaskIndex(targetIdx);
    emit('lesson:student_navigate', { targetIndex: targetIdx });
  }, [canGoForward, studentTaskIndex, emit]);

  const handleJumpToTeacher = useCallback(() => {
    if (teacherTaskIndex >= 0 && teacherTaskIndex < tasks.length) {
      setStudentTaskIndex(teacherTaskIndex);
      emit('lesson:student_navigate', { targetIndex: teacherTaskIndex });
    }
  }, [teacherTaskIndex, tasks.length, emit]);

  const handleSelectTaskByIndex = useCallback(
    (index) => {
      if (index >= 0 && index <= maxOpenedIndex && index < tasks.length) {
        setStudentTaskIndex(index);
        emit('lesson:student_navigate', { targetIndex: index });
      }
    },
    [maxOpenedIndex, tasks.length, emit]
  );

  const handleAnswerSubmit = useCallback(
    (result) => {
      if (!currentTask) return;
      const isCorrect = Boolean(result?.isCorrect || result?.correct);
      const cardId = currentTask.id;

      const newStatus = isCorrect ? 'CORRECT' : 'INCORRECT';
      setTaskStatuses((prev) => ({
        ...prev,
        [cardId]: newStatus,
      }));

      emit('lesson:task_completed', {
        cardId,
        taskId: currentTask.taskId || currentTask.task?.id,
        isCorrect,
        answer: result?.answer,
        reactionMs: result?.reactionMs,
      });

      emit('task_answer', {
        cardId,
        answer: result?.answer ?? (isCorrect ? 'correct' : 'incorrect'),
        reactionMs: result?.reactionMs,
      });

      if (isCorrect) {
        toast.success('🎯 Отлично! Задание выполнено верно.');
      } else {
        toast.error('Пока не совсем то. Попробуйте еще раз!');
      }
    },
    [currentTask, emit]
  );

  const currentCardStatus = currentTask
    ? taskStatuses[currentTask.id] || currentTask.status || 'PENDING'
    : 'PENDING';

  return (
    <div className="live-lesson-student" style={{ maxWidth: '860px', margin: '0 auto', padding: '16px' }}>
      <header
        style={{
          display: 'flex',
          justifyContent: 'space-between',
          alignItems: 'center',
          backgroundColor: '#FFFFFF',
          padding: '16px 24px',
          borderRadius: '16px',
          boxShadow: '0 4px 20px rgba(15, 23, 42, 0.05)',
          border: '1px solid #E2E8F0',
          marginBottom: '20px',
        }}
      >
        <div>
          <div style={{ display: 'flex', alignItems: 'center', gap: '8px' }}>
            <span style={{ fontSize: '1.25rem' }}>🎸</span>
            <h1 style={{ fontSize: '1.2rem', fontWeight: 700, color: '#0F172A', margin: 0 }}>
              Guitar Trainer · Live-урок
            </h1>
          </div>
          <p style={{ margin: '4px 0 0', fontSize: '0.85rem', color: '#64748B' }}>
            Преподаватель: <strong style={{ color: '#334155' }}>{teacherName}</strong>
          </p>
        </div>

        <div style={{ display: 'flex', alignItems: 'center', gap: '12px' }}>
          <div
            style={{
              display: 'inline-flex',
              alignItems: 'center',
              gap: '6px',
              padding: '6px 12px',
              backgroundColor: isConnected ? '#ECFDF5' : '#FEF2F2',
              color: isConnected ? '#059669' : '#DC2626',
              borderRadius: '999px',
              fontSize: '0.8rem',
              fontWeight: 600,
            }}
          >
            <span
              style={{
                width: '8px',
                height: '8px',
                borderRadius: '50%',
                backgroundColor: isConnected ? '#10B981' : '#EF4444',
              }}
            />
            {isConnected ? 'На связи' : 'Подключение...'}
          </div>

          {onLeave && (
            <button
              onClick={onLeave}
              className="btn btn-ghost btn-sm"
              style={{ color: '#64748B', borderColor: '#E2E8F0' }}
            >
              Выйти
            </button>
          )}
        </div>
      </header>

      <section
        style={{
          backgroundColor: '#FFFFFF',
          borderRadius: '16px',
          padding: '20px 24px',
          boxShadow: '0 4px 20px rgba(15, 23, 42, 0.05)',
          border: '1px solid #E2E8F0',
          marginBottom: '24px',
        }}
      >
        <div
          style={{
            display: 'flex',
            alignItems: 'center',
            justifyContent: 'space-between',
            flexWrap: 'wrap',
            gap: '12px',
            marginBottom: '16px',
          }}
        >
          <div>
            <div style={{ display: 'flex', alignItems: 'center', gap: '8px' }}>
              <span style={{ fontSize: '0.9rem', fontWeight: 700, color: '#334155' }}>
                {tasks.length > 0
                  ? `Задание ${studentTaskIndex + 1} из ${tasks.length}`
                  : 'Ожидание заданий'}
              </span>

              {isViewingTeacherTask ? (
                <span
                  style={{
                    backgroundColor: '#EEF2FF',
                    color: '#4F46E5',
                    fontSize: '0.75rem',
                    padding: '2px 8px',
                    borderRadius: '999px',
                    fontWeight: 600,
                  }}
                >
                  📡 В эфире с учителем
                </span>
              ) : (
                <span
                  style={{
                    backgroundColor: '#F1F5F9',
                    color: '#64748B',
                    fontSize: '0.75rem',
                    padding: '2px 8px',
                    borderRadius: '999px',
                    fontWeight: 500,
                  }}
                >
                  📖 Просмотр истории
                </span>
              )}
            </div>

            {currentTask && (
              <p style={{ margin: '4px 0 0', fontSize: '0.8rem', color: '#64748B' }}>
                Статус:{' '}
                <strong>
                  {STATUS_ICONS[currentCardStatus] || '⚪'} {STATUS_LABELS[currentCardStatus] || 'В процессе'}
                </strong>
              </p>
            )}
          </div>

          <div style={{ display: 'flex', alignItems: 'center', gap: '8px' }}>
            <button
              onClick={handlePrevTask}
              disabled={!canGoBack}
              className="btn btn-outline btn-sm"
              style={{
                borderRadius: '8px',
                padding: '6px 14px',
                cursor: canGoBack ? 'pointer' : 'not-allowed',
                opacity: canGoBack ? 1 : 0.45,
                borderColor: '#CBD5E1',
                color: '#334155',
              }}
              title="Вернуться к предыдущему заданию"
            >
              ◀ Назад
            </button>

            <button
              onClick={handleNextTask}
              disabled={!canGoForward}
              className="btn btn-outline btn-sm"
              style={{
                borderRadius: '8px',
                padding: '6px 14px',
                cursor: canGoForward ? 'pointer' : 'not-allowed',
                opacity: canGoForward ? 1 : 0.45,
                borderColor: '#CBD5E1',
                color: '#334155',
              }}
              title="Перейти к следующему открытому заданию"
            >
              Вперед ▶
            </button>

            {!isViewingTeacherTask && (
              <button
                onClick={handleJumpToTeacher}
                className="btn btn-primary btn-sm"
                style={{
                  backgroundColor: '#4F46E5',
                  color: '#FFFFFF',
                  borderRadius: '8px',
                  padding: '6px 14px',
                  fontWeight: 600,
                  border: 'none',
                  cursor: 'pointer',
                  marginLeft: '4px',
                }}
              >
                🎯 К заданию учителя
              </button>
            )}
          </div>
        </div>

        {tasks.length > 0 && (
          <div
            style={{
              display: 'flex',
              alignItems: 'center',
              gap: '8px',
              overflowX: 'auto',
              paddingBottom: '6px',
            }}
          >
            {tasks.map((task, idx) => {
              const status = taskStatuses[task.id] || task.status || 'PENDING';
              const isCurrent = idx === studentTaskIndex;
              const isTeacher = idx === teacherTaskIndex;
              const isAvailable = idx <= maxOpenedIndex;

              return (
                <button
                  key={task.id || idx}
                  onClick={() => handleSelectTaskByIndex(idx)}
                  disabled={!isAvailable}
                  style={{
                    display: 'flex',
                    alignItems: 'center',
                    gap: '6px',
                    padding: '8px 12px',
                    borderRadius: '10px',
                    border: isCurrent
                      ? '2px solid #4F46E5'
                      : isTeacher
                      ? '2px dashed #818CF8'
                      : '1px solid #E2E8F0',
                    backgroundColor: isCurrent ? '#EEF2FF' : '#F8FAFC',
                    color: isCurrent ? '#4338CA' : '#334155',
                    cursor: isAvailable ? 'pointer' : 'not-allowed',
                    opacity: isAvailable ? 1 : 0.4,
                    fontSize: '0.8rem',
                    fontWeight: isCurrent ? 700 : 500,
                    whiteSpace: 'nowrap',
                    transition: 'all 0.15s ease',
                  }}
                  title={`Задание ${idx + 1}: ${STATUS_LABELS[status] || status}`}
                >
                  <span>{STATUS_ICONS[status] || '⚪'}</span>
                  <span>№ {idx + 1}</span>
                  {isTeacher && <span style={{ fontSize: '0.7rem' }}>📡</span>}
                </button>
              );
            })}
          </div>
        )}
      </section>

      <main
        style={{
          backgroundColor: '#FFFFFF',
          borderRadius: '16px',
          padding: '32px 24px',
          boxShadow: '0 8px 30px rgba(15, 23, 42, 0.06)',
          border: '1px solid #E2E8F0',
          minHeight: '420px',
        }}
      >
        {!currentTask ? (
          <div style={{ textAlign: 'center', padding: '60px 20px' }}>
            <div style={{ fontSize: '3rem', marginBottom: '16px' }}>🎸</div>
            <h2 style={{ fontSize: '1.25rem', fontWeight: 700, color: '#1E293B', marginBottom: '8px' }}>
              Ожидание задания от учителя…
            </h2>
            <p style={{ color: '#64748B', maxWidth: '440px', margin: '0 auto', fontSize: '0.9rem' }}>
              Преподаватель скоро запустит карточку упражнения. Настройте гитару и подготовьте микрофон!
            </p>
          </div>
        ) : (
          <div>
            {!isViewingTeacherTask && (
              <div
                style={{
                  display: 'flex',
                  alignItems: 'center',
                  justifyContent: 'space-between',
                  backgroundColor: '#FFFBEB',
                  border: '1px solid #FDE68A',
                  color: '#92400E',
                  padding: '10px 16px',
                  borderRadius: '10px',
                  marginBottom: '20px',
                  fontSize: '0.85rem',
                }}
              >
                <span>
                  💡 Вы просматриваете ранее открытую карточку № {studentTaskIndex + 1}. Учитель сейчас на карточке № {teacherTaskIndex + 1}.
                </span>
                <button
                  onClick={handleJumpToTeacher}
                  style={{
                    background: 'none',
                    border: 'none',
                    color: '#B45309',
                    fontWeight: 700,
                    textDecoration: 'underline',
                    cursor: 'pointer',
                    fontSize: '0.85rem',
                  }}
                >
                  Вернуться в эфир →
                </button>
              </div>
            )}

            <TaskCard
              card={currentTask}
              onAnswer={handleAnswerSubmit}
              readOnly={!isViewingTeacherTask && currentCardStatus === 'CORRECT'}
            />
          </div>
        )}
      </main>
    </div>
  );
}
