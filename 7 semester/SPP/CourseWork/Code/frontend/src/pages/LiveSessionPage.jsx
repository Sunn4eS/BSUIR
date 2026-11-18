/**
 * pages/LiveSessionPage.jsx — Live-урок учитель ↔ ученик
 *
 * Учитель:
 *   - создаёт сессию для выбранного ученика;
 *   - отправляет карточки из быстрого конструктора или библиотеки;
 *   - видит статусы выполнения в реальном времени.
 *
 * Ученик:
 *   - автоматически попадает в комнату по приглашению;
 *   - видит «Ожидание задания от учителя…»;
 *   - получает карточку и отвечает на неё.
 */

import { useCallback, useEffect, useMemo, useRef, useState } from 'react';
import { useNavigate, useSearchParams } from 'react-router-dom';
import useAuthStore from '../store/authStore';
import { useSocket } from '../hooks/useSocket';
import { useAudioSession } from '../hooks/useAudioSession';
import LiveLessonStudent from '../components/LiveLesson/LiveLessonStudent';
import TeacherLivePanel from '../components/Live/TeacherLivePanel';
import api from '../api/axios';
import toast from 'react-hot-toast';
import { markDeclined, unmarkDeclined } from '../lib/declinedLiveSessions';

const STATUS_LABELS = {
  PENDING: 'Ожидает',
  IN_PROGRESS: 'Выполняет',
  CORRECT: 'Верно',
  INCORRECT: 'Неверно',
  SKIPPED: 'Пропущено',
};

const STATUS_CLASSES = {
  PENDING: 'is-pending',
  IN_PROGRESS: 'is-progress',
  CORRECT: 'is-correct',
  INCORRECT: 'is-incorrect',
  SKIPPED: 'is-skipped',
};

const CARD_TYPE_ICONS = {
  EAR_TRAINING: '🎵',
  PLAY_PRACTICE: '🎸',
  FINGERING_TEST: '🧩',
  PLAY_FINGERING: '🖐',
  COMBO_FINGERING: '🎯',
};

const CARD_TYPE_LABELS = {
  EAR_TRAINING: 'Тренировка слуха',
  PLAY_PRACTICE: 'Практика',
  FINGERING_TEST: 'Аппликатура',
  PLAY_FINGERING: 'Аппликатура · сыграть',
  COMBO_FINGERING: 'Аппликатура · собрать и сыграть',
};

export default function LiveSessionPage() {
  const { user } = useAuthStore();
  const { micReady } = useAudioSession();
  const [searchParams] = useSearchParams();
  const navigate = useNavigate();

  const studentIdParam = searchParams.get('studentId');
  const roomCodeParam = searchParams.get('room');

  const { on, off, emit, isConnected } = useSocket();
  const role = user?.role;

  const [session, setSession] = useState(null);
  const [roomCode, setRoomCode] = useState(roomCodeParam || null);
  const [isInRoom, setIsInRoom] = useState(false);
  const [students, setStudents] = useState([]);
  const [studentOnline, setStudentOnline] = useState(false);

  // Ученик
  const [currentCard, setCurrentCard] = useState(null);
  const [selectedCardId, setSelectedCardId] = useState(null);
  const [myResults, setMyResults] = useState({});
  const [studentCards, setStudentCards] = useState([]);

  // Учитель
  const [sentCards, setSentCards] = useState([]);
  const [cardStatuses, setCardStatuses] = useState({});

  const createdSessionRef = useRef(false);
  const joinedRoomRef = useRef(null);

  // ── Вспомогательные действия ──────────────────────────────
  const joinRoom = useCallback((code) => {
    if (!code || joinedRoomRef.current === code) return;
    // Перед входом в новую комнату выходим из предыдущей,
    // чтобы сокет не оставался в двух session-комнатах сразу
    if (joinedRoomRef.current) {
      emit('leave_room', { roomCode: joinedRoomRef.current });
    }
    joinedRoomRef.current = code;
    emit('join_room', { roomCode: code });
  }, [emit]);

  const createSession = useCallback(() => {
    if (createdSessionRef.current) return;
    createdSessionRef.current = true;
    emit('create_session', { studentId: studentIdParam });
  }, [emit, studentIdParam]);

  const sendQuickCard = useCallback((cardData) => {
    emit('send_task', { cardData });
  }, [emit]);

  const sendLibraryTask = useCallback((taskId) => {
    emit('send_task', { taskId });
  }, [emit]);

  const handleStudentAnswer = useCallback((card, result) => {
    emit('task_answer', {
      cardId: card.id,
      answer: result.answer,
      reactionMs: result.reactionMs,
    });
  }, [emit]);

  // ── Загрузка списка учеников (если учитель открыл /live без studentId) ──
  useEffect(() => {
    if (role !== 'TEACHER' || studentIdParam) return;

    api.get('/users/students')
      .then(({ data }) => setStudents(data.students || []))
      .catch(() => {});
  }, [role, studentIdParam]);

  // ── Socket listeners ──────────────────────────────────────
  useEffect(() => {
    if (!isConnected) return undefined;

    const onSessionCreated = ({ roomCode: code }) => {
      setRoomCode(code);
      toast.success(`Урок создан. Код комнаты: ${code}`, { duration: 6000 });
      joinRoom(code);
    };

    const onRoomJoined = ({ session: joinedSession, participants = [] }) => {
      setSession(joinedSession);
      setIsInRoom(true);

      const hasStudent = participants.some((participant) => participant.role === 'STUDENT');
      setStudentOnline(hasStudent);

      if (role === 'TEACHER') {
        toast.success('Вы в Live-комнате');
      }
    };

    const onNewCard = ({ card }) => {
      if (role !== 'STUDENT') return;
      setCurrentCard(card);
      setSelectedCardId(card.id);
      setStudentCards((prev) =>
        prev.some((item) => item.id === card.id) ? prev : [...prev, card]
      );
      toast('📋 Новое задание от учителя!', { icon: '🎸' });
      emit('task_status', { cardId: card.id, status: 'IN_PROGRESS' });
    };

    const onTaskSent = ({ card }) => {
      if (role !== 'TEACHER') return;
      setSentCards((prev) => [card, ...prev]);
      setCardStatuses((prev) => ({ ...prev, [card.id]: 'PENDING' }));
      toast.success('Задание отправлено ученику');
    };

    // История карточек приходит при входе в комнату (join_room):
    // учитель восстанавливает список отправленных заданий,
    // ученик — прогресс урока после перезагрузки страницы
    const onTaskHistory = ({ cards = [] }) => {
      if (role === 'TEACHER') {
        setSentCards([...cards].reverse());
        setCardStatuses(
          Object.fromEntries(cards.map((card) => [card.id, card.status || 'PENDING']))
        );
      } else {
        setStudentCards(cards);
        const unfinished = cards.filter(
          (card) => card.status === 'PENDING' || card.status === 'IN_PROGRESS'
        );
        const latest = unfinished[unfinished.length - 1] || null;
        setCurrentCard(latest);
        setSelectedCardId(latest ? latest.id : null);
      }
    };

    const onCardStatus = ({ cardId, status }) => {
      setCardStatuses((prev) => ({ ...prev, [cardId]: status }));
    };

    const onTaskResult = ({ cardId, isCorrect }) => {
      // Этот тост предназначен учителю; ученик получает обратную связь
      // в самой карточке через my_task_result.
      if (role !== 'TEACHER') return;

      setCardStatuses((prev) => ({ ...prev, [cardId]: isCorrect ? 'CORRECT' : 'INCORRECT' }));
      toast(isCorrect ? '✅ Ученик ответил верно' : '❌ Ученик ответил неверно', {
        icon: isCorrect ? '✅' : '❌',
      });
    };

    const onMyResult = ({ cardId, isCorrect }) => {
      setMyResults((prev) => ({ ...prev, [cardId]: isCorrect }));
    };

    const onUserJoined = ({ user: joinedUser }) => {
      if (joinedUser?.role === 'STUDENT') setStudentOnline(true);
      toast(`${joinedUser?.firstName || 'Участник'} подключился к уроку`);
    };

    const onUserLeft = () => {
      if (role === 'TEACHER') setStudentOnline(false);
    };

    const onSessionEnded = ({ sessionId }) => {
      toast('Урок завершён', { icon: '🏁' });
      unmarkDeclined(sessionId);
      setIsInRoom(false);
      setSession(null);
      setCurrentCard(null);
      setSelectedCardId(null);
      setStudentCards([]);
      joinedRoomRef.current = null;
      setRoomCode(null);
    };

    const onRoomError = ({ message }) => toast.error(message);
    const onTaskError = ({ message }) => toast.error(message);

    on('session_created', onSessionCreated);
    on('room_joined', onRoomJoined);
    on('new_task_card', onNewCard);
    on('task_sent', onTaskSent);
    on('task_history', onTaskHistory);
    on('card_status_updated', onCardStatus);
    on('task_result', onTaskResult);
    on('my_task_result', onMyResult);
    on('user_joined', onUserJoined);
    on('user_left', onUserLeft);
    on('session_ended', onSessionEnded);
    on('room_error', onRoomError);
    on('task_error', onTaskError);

    return () => {
      off('session_created', onSessionCreated);
      off('room_joined', onRoomJoined);
      off('new_task_card', onNewCard);
      off('task_sent', onTaskSent);
      off('task_history', onTaskHistory);
      off('card_status_updated', onCardStatus);
      off('task_result', onTaskResult);
      off('my_task_result', onMyResult);
      off('user_joined', onUserJoined);
      off('user_left', onUserLeft);
      off('session_ended', onSessionEnded);
      off('room_error', onRoomError);
      off('task_error', onTaskError);
    };
  }, [isConnected, role, on, off, emit, joinRoom]);

  // ── Авто-вход в комнату ───────────────────────────────────
  useEffect(() => {
    if (!isConnected) return;

    if (roomCodeParam) joinRoom(roomCodeParam);

    if (role === 'TEACHER' && studentIdParam) createSession();
    // Приглашения и активные сессии обрабатывает LiveInvitationWatcher
    // в App.jsx — он показывает модалку, а не тянет ученика на страницу.
  }, [isConnected, roomCodeParam, studentIdParam, role, joinRoom, createSession]);

  // ── Завершение урока (учитель) ────────────────────────────
  const handleEndSession = () => {
    emit('end_session');
  };

  // ── Список заданий урока для ученика (п.4) ────────────────
  // Источник: task_history + новые карточки; статусы обновляются
  // через card_status_updated и my_task_result
  const lessonTasks = useMemo(
    () =>
      studentCards.map((card) => {
        const data = card.task || card.cardData || {};
        let status = card.status || 'PENDING';
        if (cardStatuses[card.id]) status = cardStatuses[card.id];
        if (myResults[card.id] !== undefined) {
          status = myResults[card.id] ? 'CORRECT' : 'INCORRECT';
        }
        return {
          cardId: card.id,
          title: data.title || 'Задание',
          type: data.type,
          status,
        };
      }),
    [studentCards, cardStatuses, myResults]
  );

  // ── Выбор задания: ученик может вернуться к предыдущим карточкам ──
  const selectedCard = useMemo(
    () => studentCards.find((card) => card.id === selectedCardId) || null,
    [studentCards, selectedCardId]
  );

  const selectedTaskStatus = useMemo(() => {
    if (!selectedCard) return null;
    const task = lessonTasks.find((item) => item.cardId === selectedCard.id);
    return task?.status || null;
  }, [selectedCard, lessonTasks]);

  // Завершённые задания открываются только для просмотра
  const isSelectedReadOnly =
    selectedTaskStatus === 'CORRECT' || selectedTaskStatus === 'SKIPPED';

  const handleSelectCard = useCallback((cardId) => {
    if (!cardId) return;
    setSelectedCardId(cardId);
  }, []);

  // ── Выход из урока (ученик/учитель) ───────────────────────
  // Покидает комнату на сервере и возвращает на дашборд.
  const handleExit = useCallback(() => {
    if (joinedRoomRef.current) {
      emit('leave_room', { roomCode: joinedRoomRef.current });
      joinedRoomRef.current = null;
    }

    // Ученик, ушедший с урока, не должен быть тут же приглашён обратно
    if (role === 'STUDENT' && session?.id) {
      markDeclined(session.id);
    }

    navigate('/dashboard', { replace: true });
  }, [emit, role, session, navigate]);

  // ── Выбор ученика (учитель без studentId) ─────────────────
  if (role === 'TEACHER' && !studentIdParam && !roomCodeParam) {
    return (
      <div className="live-page">
        <LiveHeader
          isConnected={isConnected}
          onExit={() => navigate('/dashboard')}
        />

        <div className="live-page-body">
          <div className="select-student-card">
            <h2 className="page-title">Начать Live-урок</h2>
            <p className="page-subtitle">Выберите ученика, чтобы открыть комнату.</p>

            {students.length ? (
              <div className="student-picker">
                {students.map((student) => (
                  <button
                    key={student.id}
                    type="button"
                    className="student-picker-item"
                    onClick={() => navigate(`/live?studentId=${student.id}`)}
                  >
                    <span className="avatar-circle">
                      {student.firstName?.[0]}{student.lastName?.[0]}
                    </span>
                    <span>
                      <strong>{student.firstName} {student.lastName}</strong>
                      <small>{student.email}</small>
                    </span>
                    <span className="student-picker-arrow">→</span>
                  </button>
                ))}
              </div>
            ) : (
              <div className="empty-state compact">
                <div className="empty-state-icon">👥</div>
                <p className="empty-state-text">Сначала добавьте учеников на дашборде</p>
              </div>
            )}
          </div>
        </div>
      </div>
    );
  }

  return (
    <div className="live-page">
      <LiveHeader
        isConnected={isConnected}
        roomCode={roomCode}
        role={role}
        isInRoom={isInRoom}
        onExit={handleExit}
        onEnd={handleEndSession}
      />

      <div className="live-page-body">
        {!isInRoom ? (
          <div className="waiting-card">
            <div className="waiting-animation" aria-hidden="true">
              <span className="waiting-ring" />
              <span className="waiting-ring delay" />
              <span className="waiting-emoji">🎧</span>
            </div>

            <h3 className="waiting-title">
              {!isConnected
                ? 'Нет соединения с сервером'
                : role === 'STUDENT'
                  ? 'Ожидание приглашения от учителя…'
                  : 'Подключаемся к уроку…'}
            </h3>
            <p className="waiting-text">
              {!isConnected
                ? 'Проверьте интернет и обновите страницу'
                : role === 'TEACHER'
                  ? 'Создаём комнату для ученика…'
                  : 'Учитель создаст комнату — вы попадёте в неё автоматически. Или введите код вручную.'}
            </p>

            {!isConnected && (
              <button
                type="button"
                className="btn btn-ghost"
                onClick={() => window.location.reload()}
              >
                Обновить страницу
              </button>
            )}

            {isConnected && role === 'STUDENT' && !roomCode && (
              <JoinRoomForm onJoin={joinRoom} />
            )}
          </div>
        ) : role === 'STUDENT' ? (
          <LiveLessonStudent
            roomCode={roomCode}
            teacherName={
              session?.teacher
                ? `${session.teacher.firstName || ''} ${session.teacher.lastName || ''}`.trim() || 'Преподаватель'
                : 'Преподаватель'
            }
            initialTasks={studentCards}
            onLeave={handleExit}
          />
        ) : (
          <div className="teacher-live-layout">
            <section className="teacher-main">
              <div className="section-header">
                <div>
                  <h2 className="page-title">Отправленные задания</h2>
                  <p className="page-subtitle">
                    {sentCards.length
                      ? `Всего отправлено: ${sentCards.length}`
                      : 'Отправьте первое задание из панели справа'}
                  </p>
                </div>
              </div>

              {sentCards.length === 0 ? (
                <div className="empty-state">
                  <div className="empty-state-icon">📋</div>
                  <p className="empty-state-text">
                    Здесь появятся отправленные карточки и их статусы
                  </p>
                </div>
              ) : (
                <div className="sent-cards">
                  {sentCards.map((card) => {
                    const data = card.task || card.cardData || {};
                    const status = cardStatuses[card.id] || card.status || 'PENDING';
                    const typeIcon = CARD_TYPE_ICONS[data.type] || '🎼';
                    const typeLabel = CARD_TYPE_LABELS[data.type] || data.type || 'Задание';

                    return (
                      <div key={card.id} className="sent-card">
                        <div className="sent-card-main">
                          <div className={`task-type-icon ${data.type === 'EAR_TRAINING' ? 'is-ear' : 'is-play'}`}>
                            {typeIcon}
                          </div>
                          <div>
                            <div className="sent-card-title">{data.title || 'Задание'}</div>
                            <div className="sent-card-meta">
                              {typeLabel}
                              {data.expectedNote ? ` · ${data.expectedNote}` : ''}
                              {data.fingeringMode ? ` (${data.fingeringMode === 'BUILD' ? 'сборка' : 'угадать'})` : ''}
                            </div>
                          </div>
                        </div>

                        <span className={`status-badge ${STATUS_CLASSES[status] || 'is-pending'}`}>
                          {STATUS_LABELS[status] || status}
                        </span>
                      </div>
                    );
                  })}
                </div>
              )}
            </section>

            <aside className="teacher-side">
              <TeacherLivePanel
                onSendQuick={sendQuickCard}
                onSendTask={sendLibraryTask}
                studentOnline={studentOnline}
              />
            </aside>
          </div>
        )}
      </div>
    </div>
  );
}

/** Верхняя панель Live-страницы */
function LiveHeader({ isConnected, roomCode, role, isInRoom, onExit, onEnd }) {
  const studentInRoom = role === 'STUDENT' && isInRoom;

  return (
    <header className="live-header">
      <div className="live-header-left">
        <button
          type="button"
          className={`btn btn-sm ${studentInRoom ? 'btn-danger' : 'btn-ghost'}`}
          onClick={onExit}
        >
          {studentInRoom ? 'Выйти из урока' : '← Выйти'}
        </button>

        <div className="live-header-title">
          <span>Live-урок</span>
          {roomCode && <span className="room-code">#{roomCode}</span>}
        </div>
      </div>

      <div className="live-header-right">
        <span className={`connection-pill ${isConnected ? 'is-online' : 'is-offline'}`}>
          <span className="presence-dot" />
          {isConnected ? 'Подключён' : 'Нет соединения'}
        </span>

        {role === 'TEACHER' && isInRoom && (
          <button type="button" className="btn btn-danger btn-sm" onClick={onEnd}>
            Завершить урок
          </button>
        )}
      </div>
    </header>
  );
}

/** Ручной ввод кода комнаты */
function JoinRoomForm({ onJoin }) {
  const [code, setCode] = useState('');

  return (
    <form
      className="join-room-form"
      onSubmit={(event) => {
        event.preventDefault();
        if (code.trim()) onJoin(code.trim().toUpperCase());
      }}
    >
      <div className="form-group">
        <label className="form-label" htmlFor="room-code-input">Код комнаты</label>
        <input
          id="room-code-input"
          className="input room-code-input"
          placeholder="XXXXXXXX"
          value={code}
          onChange={(event) => setCode(event.target.value.toUpperCase())}
          maxLength={8}
          required
        />
      </div>
      <button type="submit" className="btn btn-primary btn-block">
        Войти в урок →
      </button>
    </form>
  );
}
