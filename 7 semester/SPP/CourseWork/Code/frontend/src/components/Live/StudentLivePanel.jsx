import TaskCard from '../Cards/TaskCard';
import LessonTaskList from './LessonTaskList';

const STATUS_BANNERS = {
  CORRECT: { className: 'is-correct', text: '✅ Это задание уже выполнено' },
  INCORRECT: { className: 'is-incorrect', text: '❌ Ответ был неверным — можно попробовать снова' },
  SKIPPED: { className: 'is-skipped', text: '⏭ Это задание пропущено' },
};

export default function StudentLivePanel({
  currentCard,
  currentCardId = null,
  onSelectCard,
  isReadOnly = false,
  onAnswer,
  teacherName,
  isConnected,
  micReady,
  lessonTasks = [],
}) {
  const currentIndex = lessonTasks.findIndex((task) => task.cardId === currentCardId);
  const prevTask = currentIndex > 0 ? lessonTasks[currentIndex - 1] : null;
  const nextTask =
    currentIndex >= 0 && currentIndex < lessonTasks.length - 1
      ? lessonTasks[currentIndex + 1]
      : null;

  const currentStatus = currentIndex >= 0 ? lessonTasks[currentIndex]?.status : null;
  const banner = currentStatus ? STATUS_BANNERS[currentStatus] : null;

  const allDone =
    lessonTasks.length > 0 &&
    lessonTasks.every((task) => task.status === 'CORRECT' || task.status === 'SKIPPED');

  return (
    <div className="student-live">
      <div className="student-live-header">
        <div>
          <h2 className="page-title">Live-урок</h2>
          <p className="page-subtitle">
            {teacherName ? `Учитель: ${teacherName}` : 'Онлайн-занятие с преподавателем'}
          </p>
        </div>

        <div className={`connection-pill ${isConnected ? 'is-online' : 'is-offline'}`}>
          <span className="presence-dot" />
          {isConnected ? 'На связи' : 'Нет соединения'}
        </div>
      </div>

      <LessonTaskList
        tasks={lessonTasks}
        currentCardId={currentCardId}
        onSelectTask={onSelectCard}
      />

      {!currentCard ? (
        <div className="waiting-card">
          <div className="waiting-animation" aria-hidden="true">
            <span className="waiting-ring" />
            <span className="waiting-ring delay" />
            <span className="waiting-emoji">🎸</span>
          </div>

          <h3 className="waiting-title">
            {allDone ? 'Все задания выполнены! 🎉' : 'Ожидание задания от учителя…'}
          </h3>
          <p className="waiting-text">
            {lessonTasks.length > 0
              ? 'Выберите задание в списке выше или дождитесь новой карточки.'
              : 'Как только учитель отправит карточку, она появится здесь автоматически.'}
          </p>

          {!micReady && (
            <p className="waiting-hint">
              💡 Совет: разрешите микрофон заранее — это понадобится для заданий на игру.
            </p>
          )}

          <div className="waiting-dots">
            <span />
            <span />
            <span />
          </div>
        </div>
      ) : (
        <div key={currentCard.id} className="student-card-wrap animate-fade-in">
          <div className="incoming-card-label">
            <span
              className="live-dot"
              style={{ background: isReadOnly ? 'var(--color-text-muted)' : 'var(--color-success)' }}
            />
            {isReadOnly ? 'Выполненное задание · просмотр' : 'Текущее задание'}
          </div>

          {banner && (
            <div className={`live-task-banner ${banner.className}`}>
              {banner.text}
            </div>
          )}

          <TaskCard card={currentCard} onAnswer={onAnswer} readOnly={isReadOnly} />

          {(prevTask || nextTask) && (
            <div className="live-task-nav">
              <button
                type="button"
                className="btn btn-ghost btn-sm"
                disabled={!prevTask}
                onClick={() => prevTask && onSelectCard?.(prevTask.cardId)}
              >
                ← Предыдущее
              </button>
              <button
                type="button"
                className="btn btn-ghost btn-sm"
                disabled={!nextTask}
                onClick={() => nextTask && onSelectCard?.(nextTask.cardId)}
              >
                Следующее →
              </button>
            </div>
          )}
        </div>
      )}
    </div>
  );
}
