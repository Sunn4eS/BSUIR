/**
 * components/Live/LessonTaskList.jsx
 * Список заданий Live-урока для ученика: степпер «Задание N из M»,
 * статусы («Ожидание» / «В процессе» / «Выполнено») и прогресс.
 *
 * Любое задание можно выбрать кликом — так ученик возвращается
 * к предыдущим карточкам, не дожидаясь новой от учителя.
 *
 * Данные приходят из task_history (join_room) и обновляются вживую
 * через Socket.io (new_task_card / card_status_updated / my_task_result).
 */

const STATUS_LABELS = {
  PENDING: 'Ожидание',
  IN_PROGRESS: 'В процессе',
  CORRECT: 'Выполнено',
  INCORRECT: 'Неверно',
  SKIPPED: 'Пропущено',
};

const STATUS_ICONS = {
  PENDING: '⏳',
  IN_PROGRESS: '🔄',
  CORRECT: '✅',
  INCORRECT: '❌',
  SKIPPED: '⏭',
};

const TYPE_ICONS = {
  EAR_TRAINING: '🎵',
  PLAY_PRACTICE: '🎸',
  FINGERING_TEST: '🧩',
  PLAY_FINGERING: '🖐',
  COMBO_FINGERING: '🎯',
};

export default function LessonTaskList({
  tasks = [],
  currentCardId = null,
  onSelectTask,
}) {
  const total = tasks.length;
  if (total === 0) return null;

  const completed = tasks.filter(
    (task) => task.status === 'CORRECT' || task.status === 'SKIPPED'
  ).length;

  const currentIdx = tasks.findIndex((task) => task.cardId === currentCardId);
  const firstUnfinishedIdx = tasks.findIndex(
    (task) => task.status === 'PENDING' || task.status === 'IN_PROGRESS'
  );

  // «Задание N из M»: активная карточка, иначе первая незавершённая,
  // иначе (всё сделано) — последняя
  const displayIndex =
    currentIdx >= 0
      ? currentIdx + 1
      : firstUnfinishedIdx >= 0
        ? firstUnfinishedIdx + 1
        : total;

  const progressPercent = Math.round((completed / total) * 100);
  const isInteractive = typeof onSelectTask === 'function';

  return (
    <div className="lesson-tasks">
      <div className="lesson-tasks-header">
        <h3 className="lesson-tasks-title">📋 Задания урока</h3>
        <span className="lesson-tasks-counter">
          Задание {displayIndex} из {total}
        </span>
      </div>

      <div className="progress-bar lesson-tasks-progress">
        <div
          className={`progress-bar-fill ${completed === total ? 'is-success' : ''}`}
          style={{ width: `${progressPercent}%` }}
        />
      </div>

      <ol className="lesson-tasks-list">
        {tasks.map((task, index) => {
          const isActive = task.cardId === currentCardId;
          const status = task.status || 'PENDING';
          const isDone = status === 'CORRECT' || status === 'SKIPPED';

          return (
            <li
              key={task.cardId}
              className={[
                'lesson-task',
                `status-${status.toLowerCase()}`,
                isActive ? 'is-active' : '',
                isInteractive ? 'is-clickable' : '',
              ].filter(Boolean).join(' ')}
              role={isInteractive ? 'button' : undefined}
              tabIndex={isInteractive ? 0 : undefined}
              aria-current={isActive ? 'true' : undefined}
              title={isInteractive ? (isDone ? 'Открыть выполненное задание' : 'Перейти к заданию') : undefined}
              onClick={isInteractive ? () => onSelectTask(task.cardId) : undefined}
              onKeyDown={isInteractive
                ? (event) => {
                    if (event.key === 'Enter' || event.key === ' ') {
                      event.preventDefault();
                      onSelectTask(task.cardId);
                    }
                  }
                : undefined}
            >
              <span className="lesson-task-icon">
                {TYPE_ICONS[task.type] || '🎼'}
              </span>
              <span className="lesson-task-title">
                {index + 1}. {task.title}
              </span>
              <span className="lesson-task-status">
                {STATUS_ICONS[status]} {STATUS_LABELS[status] || status}
              </span>
            </li>
          );
        })}
      </ol>
    </div>
  );
}
