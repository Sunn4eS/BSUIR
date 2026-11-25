import { useState, useEffect, useCallback } from 'react';
import { useNavigate } from 'react-router-dom';
import useAuthStore from '../store/authStore';
import api from '../api/axios';
import TaskCard from '../components/Cards/TaskCard';
import GuitarTuner from '../components/Tuner/GuitarTuner';
import toast from 'react-hot-toast';

const NAV_ITEMS = [
  { id: 'learning', label: 'Мое обучение',   icon: '🎓' },
  { id: 'catalog',  label: 'Каталог курсов', icon: '📚' },
  { id: 'practice', label: 'Guitar Trainer', icon: '🎸' },
  { id: 'tuner',    label: 'Тюнер',          icon: '🎵' },
  { id: 'stats',    label: 'Статистика',     icon: '📊' },
];

export default function StudentDashboard() {
  const { user, logout } = useAuthStore();
  const navigate = useNavigate();

  const [activeTab, setActiveTab] = useState('learning');
  const [catalogCourses, setCatalogCourses] = useState([]);
  const [myCourses, setMyCourses] = useState([]);
  const [statsData, setStatsData] = useState(null);

  const [activeCourse, setActiveCourse] = useState(null);
  const [activeTaskIdx, setActiveTaskIdx] = useState(0);
  const [courseTasks, setCourseTasks] = useState([]);

  const [isLoading, setIsLoading] = useState(true);
  const [actionBusyId, setActionBusyId] = useState(null);

  const loadCatalog = useCallback(async () => {
    try {
      const { data } = await api.get('/courses/catalog');
      setCatalogCourses(data.courses || []);
    } catch {
      try {
        const { data } = await api.get('/courses/available');
        setCatalogCourses(
          (data.courses || []).map((c) => ({
            ...c,
            enrollmentStatus: c.isEnrolled ? 'APPROVED' : c.joinRequest?.status || 'NONE',
            taskCount: c._count?.tasks ?? 0,
          }))
        );
      } catch {  }
    }
  }, []);

  const loadMyCourses = useCallback(async () => {
    try {
      const { data } = await api.get('/courses/my-courses');
      setMyCourses(data.courses || []);
    } catch {
      try {
        const { data } = await api.get('/users/dashboard');
        setStatsData(data);
        const mapped = (data.enrollments || []).map((e) => ({
          ...e.course,
          progress: e.progress,
          enrollmentId: e.id,
          tasksCount: e.course?.tasks?.length || 0,
          tasks: e.course?.tasks || [],
        }));
        setMyCourses(mapped);
      } catch {  }
    }
  }, []);

  const loadStats = useCallback(async () => {
    try {
      const { data } = await api.get('/users/dashboard');
      setStatsData(data);
    } catch {  }
  }, []);

  useEffect(() => {
    setIsLoading(true);
    Promise.all([loadCatalog(), loadMyCourses(), loadStats()]).finally(() => {
      setIsLoading(false);
    });
  }, [loadCatalog, loadMyCourses, loadStats]);

  const handleEnroll = async (course) => {
    setActionBusyId(course.id);
    try {
      await api.post(`/courses/${course.id}/enroll`);
      toast.success('Заявка на курс успешно отправлена!');
      await loadCatalog();
    } catch (err) {
      toast.error(err.response?.data?.error || 'Не удалось отправить заявку');
    } finally {
      setActionBusyId(null);
    }
  };

  const handleStartCourse = async (course) => {
    setActiveCourse(course);
    setActiveTaskIdx(0);
    setActiveTab('practice');

    try {
      const { data } = await api.get(`/courses/${course.id}/tasks`);
      setCourseTasks(data.tasks || course.tasks || []);
    } catch {
      setCourseTasks(course.tasks || []);
    }
  };

  const handleTaskAnswer = async (task, { answer, isCorrect, reactionMs }) => {
    try {
      await api.post(`/tasks/${task.id}/submit`, {
        isCorrect: Boolean(isCorrect),
        answer: String(answer ?? ''),
        reactionMs,
      });
    } catch {
      try {
        await api.post(`/tasks/${task.id}/result`, {
          status: isCorrect ? 'CORRECT' : 'INCORRECT',
          answer: String(answer ?? ''),
          reactionMs,
        });
      } catch {  }
    }
    loadMyCourses();
    loadStats();
  };

  const stats = statsData?.taskResults || [];
  const totalCorrect = stats.find((s) => s.status === 'CORRECT')?._count || 0;
  const totalIncorrect = stats.find((s) => s.status === 'INCORRECT')?._count || 0;
  const totalPending = stats.find((s) => s.status === 'PENDING')?._count || 0;
  const total = totalCorrect + totalIncorrect + totalPending;

  return (
    <div className="dashboard-layout" style={{ minHeight: '100vh', backgroundColor: '#F8FAFC' }}>
      <aside className="sidebar">
        <div className="sidebar-logo">
          <span className="gradient-text">🎸 Guitar</span>
          <div style={{ fontSize: '0.75rem', color: '#64748B', fontWeight: 500, marginTop: '4px' }}>
            {user?.name || `${user?.firstName || ''} ${user?.lastName || ''}`.trim() || user?.email}
          </div>
          <div
            style={{
              display: 'inline-block',
              marginTop: '6px',
              padding: '2px 10px',
              backgroundColor: '#EEF2FF',
              borderRadius: '999px',
              fontSize: '0.7rem',
              color: '#4F46E5',
              fontWeight: 600,
            }}
          >
            Студент
          </div>
        </div>

        {NAV_ITEMS.map((item) => (
          <button
            key={item.id}
            className={`sidebar-item ${activeTab === item.id ? 'active' : ''}`}
            onClick={() => {
              setActiveTab(item.id);
              if (item.id === 'learning') loadMyCourses();
              if (item.id === 'catalog') loadCatalog();
            }}
            id={`nav-${item.id}`}
          >
            <span>{item.icon}</span>
            <span>{item.label}</span>
          </button>
        ))}

        <button className="sidebar-item" onClick={() => navigate('/live')}>
          <span>🎧</span>
          <span>Live-урок</span>
        </button>

        <div style={{ flex: 1 }} />
        <button
          className="sidebar-item"
          onClick={() => {
            logout();
            navigate('/login');
          }}
        >
          <span>🚪</span>
          <span>Выйти</span>
        </button>
      </aside>

      <main className="main-content" style={{ padding: '32px 40px' }}>
        {isLoading ? (
          <div style={{ display: 'flex', justifyContent: 'center', alignItems: 'center', height: '60vh' }}>
            <div className="loader" style={{ width: '40px', height: '40px' }} />
          </div>
        ) : (
          <>
            {activeTab === 'learning' && (
              <div className="animate-fade-in">
                <div style={{ marginBottom: '24px' }}>
                  <h2 style={{ fontSize: '1.5rem', fontWeight: 700, color: '#0F172A', marginBottom: '6px' }}>
                    🎓 Мое обучение
                  </h2>
                  <p style={{ color: '#64748B', fontSize: '0.9rem' }}>
                    Одобренные курсы для самостоятельного прохождения упражнений и закрепления материала
                  </p>
                </div>

                {myCourses.length === 0 ? (
                  <div className="empty-state" style={{ backgroundColor: '#FFFFFF', padding: '48px 24px', borderRadius: '16px' }}>
                    <div className="empty-state-icon">📚</div>
                    <h3 style={{ marginBottom: '8px', color: '#1E293B' }}>У вас пока нет активных курсов</h3>
                    <p className="empty-state-text" style={{ color: '#64748B' }}>
                      Перейдите во вкладку «Каталог курсов» и подайте заявку на вступление.
                    </p>
                    <button
                      className="btn btn-primary"
                      style={{ marginTop: '16px' }}
                      onClick={() => setActiveTab('catalog')}
                    >
                      Открыть каталог курсов →
                    </button>
                  </div>
                ) : (
                  <div className="cards-grid">
                    {myCourses.map((course, i) => {
                      const teacherName =
                        course.teacher?.displayName ||
                        course.teacher?.name ||
                        [course.teacher?.firstName, course.teacher?.lastName].filter(Boolean).join(' ') ||
                        'Преподаватель';
                      const progress = course.progress ?? 0;

                      return (
                        <div
                          key={course.id || i}
                          className="glass animate-fade-in"
                          style={{
                            backgroundColor: '#FFFFFF',
                            padding: '24px',
                            borderRadius: '16px',
                            border: '1px solid #E2E8F0',
                            boxShadow: '0 4px 20px rgba(15, 23, 42, 0.05)',
                            display: 'flex',
                            flexDirection: 'column',
                          }}
                        >
                          <div style={{ marginBottom: '16px' }}>
                            <span
                              style={{
                                display: 'inline-block',
                                backgroundColor: '#ECFDF5',
                                color: '#059669',
                                fontSize: '0.75rem',
                                fontWeight: 700,
                                padding: '2px 8px',
                                borderRadius: '999px',
                                marginBottom: '8px',
                              }}
                            >
                              ✓ Доступ открыт
                            </span>
                            <h3 style={{ fontSize: '1.2rem', fontWeight: 700, color: '#0F172A', marginBottom: '6px' }}>
                              {course.title}
                            </h3>
                            <p style={{ fontSize: '0.85rem', color: '#64748B', margin: 0 }}>
                              Преподаватель: <strong style={{ color: '#334155' }}>{teacherName}</strong>
                            </p>
                            {course.description && (
                              <p style={{ fontSize: '0.85rem', color: '#475569', marginTop: '8px' }}>
                                {course.description}
                              </p>
                            )}
                          </div>

                          <div style={{ marginTop: 'auto' }}>
                            <div style={{ marginBottom: '12px' }}>
                              <div
                                style={{
                                  display: 'flex',
                                  justifyContent: 'space-between',
                                  fontSize: '0.8rem',
                                  marginBottom: '6px',
                                }}
                              >
                                <span style={{ color: '#64748B' }}>Прогресс</span>
                                <span style={{ color: '#4F46E5', fontWeight: 600 }}>{progress}%</span>
                              </div>
                              <div className="progress-bar" style={{ height: '8px', borderRadius: '4px', backgroundColor: '#F1F5F9' }}>
                                <div
                                  className="progress-bar-fill"
                                  style={{
                                    width: `${progress}%`,
                                    backgroundColor: '#4F46E5',
                                    borderRadius: '4px',
                                  }}
                                />
                              </div>
                            </div>

                            <div style={{ fontSize: '0.8rem', color: '#64748B', marginBottom: '16px' }}>
                              📝 Заданий: {course.tasksCount || course.tasks?.length || 0}
                            </div>

                            <button
                              className="btn btn-primary"
                              style={{ width: '100%', borderRadius: '10px' }}
                              onClick={() => handleStartCourse(course)}
                            >
                              Перейти к обучению →
                            </button>
                          </div>
                        </div>
                      );
                    })}
                  </div>
                )}
              </div>
            )}

            {activeTab === 'catalog' && (
              <div className="animate-fade-in">
                <div style={{ marginBottom: '24px' }}>
                  <h2 style={{ fontSize: '1.5rem', fontWeight: 700, color: '#0F172A', marginBottom: '6px' }}>
                    📚 Каталог курсов
                  </h2>
                  <p style={{ color: '#64748B', fontSize: '0.9rem' }}>
                    Все опубликованные программы обучения. Подайте заявку, и преподаватель откроет вам доступ.
                  </p>
                </div>

                {catalogCourses.length === 0 ? (
                  <div className="empty-state" style={{ backgroundColor: '#FFFFFF', padding: '48px 24px', borderRadius: '16px' }}>
                    <div className="empty-state-icon">🎸</div>
                    <h3 style={{ marginBottom: '8px', color: '#1E293B' }}>Каталог пока пуст</h3>
                    <p className="empty-state-text" style={{ color: '#64748B' }}>
                      Преподаватели ещё не опубликовали курсы. Загляните позже!
                    </p>
                  </div>
                ) : (
                  <div className="cards-grid">
                    {catalogCourses.map((course) => {
                      const teacherName =
                        course.teacher?.displayName ||
                        course.teacher?.name ||
                        [course.teacher?.firstName, course.teacher?.lastName].filter(Boolean).join(' ') ||
                        'Преподаватель';
                      const status = course.enrollmentStatus || 'NONE';
                      const isPending = status === 'PENDING';
                      const isApproved = status === 'APPROVED';
                      const isNone = status === 'NONE' || status === 'REJECTED';
                      const isBusy = actionBusyId === course.id;

                      return (
                        <div
                          key={course.id}
                          className="glass animate-fade-in"
                          style={{
                            backgroundColor: '#FFFFFF',
                            padding: '24px',
                            borderRadius: '16px',
                            border: '1px solid #E2E8F0',
                            boxShadow: '0 4px 20px rgba(15, 23, 42, 0.05)',
                            display: 'flex',
                            flexDirection: 'column',
                          }}
                        >
                          <div style={{ marginBottom: '16px' }}>
                            <h3 style={{ fontSize: '1.2rem', fontWeight: 700, color: '#0F172A', marginBottom: '6px' }}>
                              {course.title}
                            </h3>
                            <p style={{ fontSize: '0.85rem', color: '#64748B', margin: 0 }}>
                              Преподаватель: <strong style={{ color: '#334155' }}>{teacherName}</strong>
                            </p>
                            {course.description && (
                              <p style={{ fontSize: '0.85rem', color: '#475569', marginTop: '10px' }}>
                                {course.description}
                              </p>
                            )}
                            <div style={{ fontSize: '0.8rem', color: '#94A3B8', marginTop: '10px' }}>
                              📝 Заданий: {course.taskCount ?? 0}
                            </div>
                          </div>

                          <div style={{ marginTop: 'auto', paddingTop: '16px' }}>
                            {isApproved && (
                              <button
                                className="btn btn-primary"
                                style={{ width: '100%', borderRadius: '10px', backgroundColor: '#059669', borderColor: '#059669' }}
                                onClick={() => handleStartCourse(course)}
                              >
                                ✓ Перейти к обучению
                              </button>
                            )}

                            {isPending && (
                              <div
                                style={{
                                  textAlign: 'center',
                                  padding: '10px',
                                  backgroundColor: '#FEF3C7',
                                  color: '#B45309',
                                  borderRadius: '10px',
                                  fontSize: '0.85rem',
                                  fontWeight: 600,
                                }}
                              >
                                ⏳ Заявка на рассмотрении
                              </div>
                            )}

                            {isNone && (
                              <button
                                className="btn btn-primary"
                                style={{ width: '100%', borderRadius: '10px' }}
                                disabled={isBusy}
                                onClick={() => handleEnroll(course)}
                              >
                                {isBusy ? 'Отправка...' : 'Подать заявку'}
                              </button>
                            )}
                          </div>
                        </div>
                      );
                    })}
                  </div>
                )}
              </div>
            )}

            {activeTab === 'practice' && (
              <div className="animate-fade-in">
                <div style={{ display: 'flex', alignItems: 'baseline', gap: '12px', marginBottom: '24px' }}>
                  <h2 style={{ fontSize: '1.5rem', fontWeight: 700, color: '#0F172A' }}>Guitar Trainer</h2>
                  <p style={{ fontSize: '0.9rem', color: '#64748B' }}>
                    тренировка слуха, детекция одиночных нот через микрофон и аппликатура на грифе
                  </p>
                </div>

                {!activeCourse ? (
                  <div className="empty-state" style={{ backgroundColor: '#FFFFFF', padding: '48px 24px', borderRadius: '16px' }}>
                    <div className="empty-state-icon">🎸</div>
                    <h3 style={{ marginBottom: '8px', color: '#1E293B' }}>Выберите курс для тренировки</h3>
                    <p className="empty-state-text" style={{ color: '#64748B' }}>
                      Перейдите во вкладку «Мое обучение» и выберите курс из списка зачисленных.
                    </p>
                    <button
                      className="btn btn-primary"
                      style={{ marginTop: '16px' }}
                      onClick={() => setActiveTab('learning')}
                    >
                      К моим курсам →
                    </button>
                  </div>
                ) : (
                  <>
                    <div
                      style={{
                        display: 'flex',
                        alignItems: 'center',
                        justifyContent: 'space-between',
                        backgroundColor: '#FFFFFF',
                        padding: '16px 20px',
                        borderRadius: '12px',
                        border: '1px solid #E2E8F0',
                        marginBottom: '24px',
                      }}
                    >
                      <button
                        className="btn btn-ghost btn-sm"
                        onClick={() => {
                          setActiveCourse(null);
                          setActiveTab('learning');
                        }}
                      >
                        ← Назад к списку курсов
                      </button>
                      <div style={{ textAlign: 'right' }}>
                        <h3 style={{ margin: 0, fontSize: '1.1rem', color: '#0F172A' }}>{activeCourse.title}</h3>
                        <p style={{ margin: 0, fontSize: '0.8rem', color: '#64748B' }}>
                          Задание {activeTaskIdx + 1} из {courseTasks.length}
                        </p>
                      </div>
                    </div>

                    {courseTasks[activeTaskIdx] ? (
                      <div style={{ maxWidth: '620px', margin: '0 auto' }}>
                        <TaskCard
                          card={{ task: courseTasks[activeTaskIdx] }}
                          onAnswer={(result) => {
                            handleTaskAnswer(courseTasks[activeTaskIdx], result);
                            if (result.isCorrect || result.correct) {
                              setTimeout(() => {
                                if (activeTaskIdx + 1 < courseTasks.length) {
                                  setActiveTaskIdx((i) => i + 1);
                                  toast.success('Следующее задание!');
                                } else {
                                  toast.success('🎉 Поздравляем! Вы прошли все задания курса!');
                                }
                              }, 1800);
                            }
                          }}
                        />

                        <div style={{ display: 'flex', justifyContent: 'space-between', marginTop: '20px' }}>
                          <button
                            className="btn btn-ghost btn-sm"
                            disabled={activeTaskIdx === 0}
                            onClick={() => setActiveTaskIdx((i) => i - 1)}
                          >
                            ◀ Предыдущее
                          </button>
                          <button
                            className="btn btn-ghost btn-sm"
                            disabled={activeTaskIdx >= courseTasks.length - 1}
                            onClick={() => setActiveTaskIdx((i) => i + 1)}
                          >
                            Следующее ▶
                          </button>
                        </div>
                      </div>
                    ) : (
                      <p style={{ color: '#64748B', textAlign: 'center' }}>В данном курсе пока нет заданий.</p>
                    )}
                  </>
                )}
              </div>
            )}

            {activeTab === 'tuner' && (
              <div className="animate-fade-in" style={{ maxWidth: '520px' }}>
                <h2 style={{ fontSize: '1.5rem', fontWeight: 700, color: '#0F172A', marginBottom: '24px' }}>
                  Гитарный тюнер
                </h2>
                <GuitarTuner />
              </div>
            )}

            {activeTab === 'stats' && (
              <div className="animate-fade-in">
                <h2 style={{ fontSize: '1.5rem', fontWeight: 700, color: '#0F172A', marginBottom: '24px' }}>
                  Моя статистика
                </h2>
                <div
                  style={{
                    display: 'grid',
                    gridTemplateColumns: 'repeat(auto-fit, minmax(200px, 1fr))',
                    gap: '16px',
                    marginBottom: '32px',
                  }}
                >
                  <div className="glass" style={{ backgroundColor: '#FFFFFF', padding: '20px', borderRadius: '14px' }}>
                    <div style={{ fontSize: '0.85rem', color: '#64748B' }}>Всего попыток</div>
                    <div style={{ fontSize: '2rem', fontWeight: 700, color: '#0F172A' }}>{total}</div>
                  </div>
                  <div className="glass" style={{ backgroundColor: '#FFFFFF', padding: '20px', borderRadius: '14px' }}>
                    <div style={{ fontSize: '0.85rem', color: '#059669' }}>Верных ответов</div>
                    <div style={{ fontSize: '2rem', fontWeight: 700, color: '#059669' }}>{totalCorrect}</div>
                  </div>
                  <div className="glass" style={{ backgroundColor: '#FFFFFF', padding: '20px', borderRadius: '14px' }}>
                    <div style={{ fontSize: '0.85rem', color: '#DC2626' }}>Неверных ответов</div>
                    <div style={{ fontSize: '2rem', fontWeight: 700, color: '#DC2626' }}>{totalIncorrect}</div>
                  </div>
                </div>
              </div>
            )}
          </>
        )}
      </main>
    </div>
  );
}
