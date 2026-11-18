/**
 * App.jsx — корневой компонент с маршрутизацией
 */

import { useCallback, useEffect, useState } from 'react';
import { BrowserRouter, Routes, Route, Navigate, useNavigate, useLocation } from 'react-router-dom';
import { Toaster } from 'react-hot-toast';
import useAuthStore from './store/authStore';
import { useSocket } from './hooks/useSocket';
import { isDeclined, markDeclined } from './lib/declinedLiveSessions';

import LoginPage        from './pages/LoginPage';
import RegisterPage     from './pages/RegisterPage';
import TeacherDashboard from './pages/TeacherDashboard';
import StudentDashboard from './pages/StudentDashboard';
import LiveSessionPage  from './pages/LiveSessionPage';
import CourseEditorPage from './pages/CourseEditorPage';

function ProtectedRoute({ children }) {
  const { token, user, isCheckingAuth } = useAuthStore();

  // Пока идёт проверка токена на сервере — не редиректим вовсе,
  // показываем скелетон (раньше отсюда летели ложные /login)
  if (isCheckingAuth) return <AuthSkeleton />;
  if (!token || !user) return <Navigate to="/login" replace />;
  return children;
}

function DashboardRoute() {
  const { user, isCheckingAuth } = useAuthStore();
  if (isCheckingAuth) return <AuthSkeleton />;
  if (!user) return <Navigate to="/login" replace />;
  return user.role === 'TEACHER' ? <TeacherDashboard /> : <StudentDashboard />;
}

function PublicRoute({ children }) {
  const { token, user, isCheckingAuth } = useAuthStore();
  // Не отправляем на /dashboard, пока не убедились, что токен жив:
  // устаревший токен из persist раньше давал цикл Dashboard ↔ Login
  if (isCheckingAuth) return <AuthSkeleton />;
  if (token && user) return <Navigate to="/dashboard" replace />;
  return children;
}

/** Скелетон проверки авторизации — вместо «прыжка» между страницами */
function AuthSkeleton() {
  return (
    <div className="auth-check-skeleton">
      <div className="loader" />
      <span>Проверяем авторизацию…</span>
    </div>
  );
}

/**
 * Глобальный обработчик приглашений в Live-урок (Socket.io).
 *
 * Раньше ученика автоматически перебрасывало на /live при любом активном
 * уроке — экран «застревал». Теперь:
 *  - приглашение показывается модалкой, навигация только по кнопке;
 *  - «Отклонить» шлёт leave_room, сбрасывает стейт и ведёт на дашборд;
 *  - все слушатели снимаются в cleanup-функции useEffect (socket.off);
 *  - отклонённая сессия не предлагается повторно, пока учитель
 *    не создаст новую.
 */
function LiveInvitationWatcher() {
  const { user } = useAuthStore();
  const { on, off, emit, isConnected } = useSocket();
  const navigate = useNavigate();
  const location = useLocation();

  const [invite, setInvite] = useState(null);

  useEffect(() => {
    if (!isConnected || user?.role !== 'STUDENT') {
      setInvite(null);
      return undefined;
    }

    const isAlreadyInThisRoom = (roomCode) =>
      location.pathname === '/live' && location.search.includes(`room=${roomCode}`);

    const showInvite = (payload) => {
      if (!payload?.roomCode) return;
      if (isAlreadyInThisRoom(payload.roomCode)) return;
      if (payload.sessionId && isDeclined(payload.sessionId)) return;
      setInvite(payload);
    };

    const onInvited = (payload) => showInvite(payload);

    const onActiveSession = ({ session }) => {
      if (!session?.roomCode) return;
      showInvite({
        sessionId: session.id,
        roomCode: session.roomCode,
        teacher: session.teacher,
      });
    };

    on('session_invited', onInvited);
    on('active_session', onActiveSession);

    // На случай перезагрузки страницы — спрашиваем активный урок один раз
    emit('get_active_session');

    // Обязательная очистка слушателей при размонтировании/смене зависимостей
    return () => {
      off('session_invited', onInvited);
      off('active_session', onActiveSession);
    };
  }, [isConnected, user?.role, on, off, emit, location.pathname, location.search]);

  /** Принять приглашение: войти в комнату урока */
  const handleAccept = useCallback(() => {
    if (!invite?.roomCode) return;
    const { roomCode, sessionId } = invite;
    setInvite(null);
    if (sessionId) markDeclined(sessionId); // чтобы «Выйти» позже не зациклил приглашение
    navigate(`/live?room=${roomCode}`);
  }, [invite, navigate]);

  /**
   * Отклонить приглашение:
   *  а) покидаем комнату на сервере и закрываем модалку;
   *  б) сбрасываем стейт приглашения;
   *  в) уходим на главную страницу ученика через роутер.
   */
  const handleDecline = useCallback(() => {
    if (!invite) return;
    const { roomCode, sessionId } = invite;

    emit('leave_room', { roomCode });
    if (sessionId) markDeclined(sessionId);
    setInvite(null);
    navigate('/dashboard', { replace: true });
  }, [invite, emit, navigate]);

  if (!invite) return null;

  const teacherName = invite.teacher?.firstName
    ? `${invite.teacher.firstName} ${invite.teacher.lastName ?? ''}`.trim()
    : null;

  return (
    <div className="modal-overlay" role="dialog" aria-modal="true" aria-labelledby="live-invite-title">
      <div className="modal-content" onClick={(e) => e.stopPropagation()}>
        <div className="mic-check-icon" aria-hidden="true">🎧</div>

        <h2 id="live-invite-title" style={{ marginBottom: '10px' }}>
          {teacherName
            ? `${teacherName} приглашает вас на урок`
            : 'Приглашение на Live-урок'}
        </h2>

        <p className="mic-check-description">
          Присоединиться к онлайн-занятию прямо сейчас?
          Комната урока: <strong>#{invite.roomCode}</strong>
        </p>

        <div className="mic-check-actions" style={{ marginTop: '20px' }}>
          <button
            type="button"
            className="btn btn-ghost"
            onClick={handleDecline}
          >
            Отклонить
          </button>
          <button
            type="button"
            className="btn btn-primary"
            onClick={handleAccept}
          >
            Присоединиться →
          </button>
        </div>
      </div>
    </div>
  );
}

export default function App() {
  // Проверяем сохранённый токен один раз при старте приложения.
  // До ответа сервера маршруты стоят на скелетоне — без редиректов.
  const checkAuth = useAuthStore((state) => state.checkAuth);

  useEffect(() => {
    checkAuth();
  }, [checkAuth]);

  return (
    <BrowserRouter>
      <Toaster
        position="top-right"
        toastOptions={{
          style: {
            background: '#ffffff',
            color: '#0f172a',
            border: '1px solid #e2e8f0',
            borderRadius: '14px',
            boxShadow: '0 10px 30px rgba(15, 23, 42, 0.12)',
            fontFamily: 'Inter, sans-serif',
            fontSize: '0.9rem',
            padding: '12px 16px',
          },
          success: { iconTheme: { primary: '#059669', secondary: '#ffffff' } },
          error: { iconTheme: { primary: '#dc2626', secondary: '#ffffff' } },
        }}
      />

      <LiveInvitationWatcher />

      <Routes>
        <Route path="/login"    element={<PublicRoute><LoginPage /></PublicRoute>} />
        <Route path="/register" element={<PublicRoute><RegisterPage /></PublicRoute>} />

        <Route path="/dashboard" element={<ProtectedRoute><DashboardRoute /></ProtectedRoute>} />
        <Route path="/live"      element={<ProtectedRoute><LiveSessionPage /></ProtectedRoute>} />
        <Route path="/courses/:id/edit" element={<ProtectedRoute><CourseEditorPage /></ProtectedRoute>} />

        <Route path="/" element={<Navigate to="/dashboard" replace />} />
        <Route path="*" element={<Navigate to="/dashboard" replace />} />
      </Routes>
    </BrowserRouter>
  );
}
