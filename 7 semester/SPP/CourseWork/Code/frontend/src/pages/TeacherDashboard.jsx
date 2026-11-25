import { useState, useEffect, useCallback } from 'react';
import { useNavigate } from 'react-router-dom';
import useAuthStore from '../store/authStore';
import api from '../api/axios';
import toast from 'react-hot-toast';
import GuitarTuner from '../components/Tuner/GuitarTuner';

const NAV_ITEMS = [
  { id: 'students', label: 'Мои студенты', icon: '👥' },
  { id: 'courses',  label: 'Курсы',        icon: '📚' },
  { id: 'requests', label: 'Заявки',       icon: '📩' },
  { id: 'tuner',    label: 'Тюнер',        icon: '🎸' },
];

export default function TeacherDashboard() {
  const { user, logout } = useAuthStore();
  const navigate = useNavigate();

  const [activeTab, setActiveTab] = useState('students');
  const [students,  setStudents]  = useState([]);
  const [courses,   setCourses]   = useState([]);
  const [requests,  setRequests]  = useState([]);
  const [reviewingId, setReviewingId] = useState(null);
  const [isLoading, setIsLoading] = useState(false);
  const [publishingId, setPublishingId] = useState(null);

  const [showAddStudent, setShowAddStudent] = useState(false);
  const [showAddCourse,  setShowAddCourse]  = useState(false);
  const [studentEmail,   setStudentEmail]   = useState('');
  const [courseForm, setCourseForm] = useState({ title: '', description: '' });

  const loadStudents = useCallback(async () => {
    try {
      const { data } = await api.get('/users/students');
      setStudents(data.students || []);
    } catch {  }
  }, []);

  const loadCourses = useCallback(async () => {
    try {
      const { data } = await api.get('/courses');
      setCourses(data.courses || []);
    } catch {  }
  }, []);

  const loadRequests = useCallback(async () => {
    try {
      const { data } = await api.get('/courses/join-requests');
      setRequests(data.requests || []);
    } catch {  }
  }, []);

  useEffect(() => {
    loadStudents();
    loadCourses();
    loadRequests();
  }, [loadStudents, loadCourses, loadRequests]);

  const reviewRequest = async (request, decision) => {
    setReviewingId(request.id);
    try {
      await api.patch(`/courses/join-requests/${request.id}`, { decision });
      toast.success(decision === 'approve' ? 'Заявка одобрена' : 'Заявка отклонена');
      await Promise.all([loadRequests(), loadStudents(), loadCourses()]);
    } catch (err) {
      toast.error(err.response?.data?.error || 'Ошибка обработки заявки');
    } finally {
      setReviewingId(null);
    }
  };

  const handleAddStudent = async (e) => {
    e.preventDefault();
    setIsLoading(true);
    try {
      await api.post('/users/students', { email: studentEmail });
      toast.success('Студент добавлен!');
      setShowAddStudent(false);
      setStudentEmail('');
      loadStudents();
    } catch (err) {
      toast.error(err.response?.data?.error || 'Ошибка');
    } finally { setIsLoading(false); }
  };

  const handleCreateCourse = async (e) => {
    e.preventDefault();
    setIsLoading(true);
    try {
      const { data } = await api.post('/courses', courseForm);
      toast.success('Курс создан! Добавьте задания.');
      setShowAddCourse(false);
      setCourseForm({ title: '', description: '' });
      await loadCourses();
      if (data.course?.id) navigate(`/courses/${data.course.id}/edit`);
    } catch (err) {
      toast.error(err.response?.data?.error || 'Ошибка');
    } finally { setIsLoading(false); }
  };

  const togglePublish = async (course) => {
    const action = course.status === 'PUBLISHED' ? 'unpublish' : 'publish';
    setPublishingId(course.id);
    try {
      await api.patch(`/courses/${course.id}/${action}`);
      toast.success(
        action === 'publish' ? 'Курс опубликован 🎉' : 'Курс снят с публикации'
      );
      await loadCourses();
    } catch (err) {
      toast.error(err.response?.data?.error || 'Ошибка публикации');
    } finally {
      setPublishingId(null);
    }
  };

  const handleStartLive = (studentId) => {
    navigate(`/live?studentId=${studentId}`);
  };

  return (
    <div className="dashboard-layout">
      <aside className="sidebar">
        <div className="sidebar-logo">
          <span className="gradient-text">🎸 Guitar</span>
          <div style={{ fontSize: '0.7rem', color: 'var(--color-text-muted)', fontWeight: 400, marginTop: '4px' }}>
            {user?.firstName} {user?.lastName}
          </div>
          <div style={{
            display: 'inline-block',
            marginTop: '6px',
            padding: '2px 10px',
            background: 'var(--color-primary-soft)',
            borderRadius: 'var(--radius-full)',
            fontSize: '0.7rem',
            color: 'var(--color-primary)',
            fontWeight: 600,
          }}>
            Учитель
          </div>
        </div>

        {NAV_ITEMS.map(item => {
          const pendingCount = item.id === 'requests'
            ? requests.filter(r => r.status === 'PENDING').length
            : 0;

          return (
            <button
              key={item.id}
              className={`sidebar-item ${activeTab === item.id ? 'active' : ''}`}
              onClick={() => {
                setActiveTab(item.id);
                if (item.id === 'requests') loadRequests();
                if (item.id === 'courses') loadCourses();
              }}
              id={`nav-${item.id}`}
            >
              <span>{item.icon}</span>
              <span style={{ flex: 1, textAlign: 'left' }}>{item.label}</span>
              {pendingCount > 0 && (
                <span
                  style={{
                    background: 'var(--color-error)',
                    color: '#fff',
                    borderRadius: 'var(--radius-full)',
                    fontSize: '0.7rem',
                    fontWeight: 700,
                    padding: '1px 7px',
                  }}
                >
                  {pendingCount}
                </span>
              )}
            </button>
          );
        })}

        <div style={{ flex: 1 }} />

        <button
          className="sidebar-item"
          onClick={() => { logout(); navigate('/login'); }}
        >
          <span>🚪</span>
          <span>Выйти</span>
        </button>
      </aside>

      <main className="main-content">
        {activeTab === 'students' && (
          <div className="animate-fade-in">
            <div className="section-header">
              <div>
                <h2 className="page-title">Мои студенты</h2>
                <p className="page-subtitle">{students.length} студент(ов)</p>
              </div>
              <button className="btn btn-primary" id="add-student-btn" onClick={() => setShowAddStudent(true)}>
                + Добавить студента
              </button>
            </div>

            {students.length === 0 ? (
              <div className="empty-state">
                <div className="empty-state-icon">👥</div>
                <h3 style={{ marginBottom: '8px' }}>Нет студентов</h3>
                <p className="empty-state-text">Добавьте студентов по их email-адресу</p>
              </div>
            ) : (
              <div className="cards-grid">
                {students.map((s, i) => (
                  <div key={s.id} className={`glass animate-fade-in delay-${Math.min(i + 1, 4)}`}
                    style={{ padding: '20px' }}>
                    <div style={{ display: 'flex', alignItems: 'center', gap: '12px', marginBottom: '16px' }}>
                      <div className="avatar-circle">
                        {s.firstName?.[0]}{s.lastName?.[0]}
                      </div>
                      <div>
                        <div style={{ fontWeight: '700' }}>{s.firstName} {s.lastName}</div>
                        <div style={{ fontSize: '0.8rem', color: 'var(--color-text-muted)' }}>{s.email}</div>
                      </div>
                    </div>

                    {s.enrollments?.length > 0 && (
                      <div style={{ marginBottom: '16px' }}>
                        {s.enrollments.slice(0, 2).map(e => (
                          <div key={e.courseId} style={{ marginBottom: '8px' }}>
                            <div style={{ display: 'flex', justifyContent: 'space-between', fontSize: '0.8rem', marginBottom: '4px' }}>
                              <span style={{ color: 'var(--color-text-secondary)' }}>{e.course.title}</span>
                              <span style={{ color: 'var(--color-primary)', fontWeight: 600 }}>{e.progress}%</span>
                            </div>
                            <div className="progress-bar">
                              <div className="progress-bar-fill" style={{ width: `${e.progress}%` }} />
                            </div>
                          </div>
                        ))}
                      </div>
                    )}

                    <button
                      className="btn btn-accent btn-sm"
                      style={{ width: '100%' }}
                      onClick={() => handleStartLive(s.id)}
                      id={`live-session-${s.id}`}
                    >
                      ⚡ Начать Live-урок
                    </button>
                  </div>
                ))}
              </div>
            )}
          </div>
        )}

        {activeTab === 'courses' && (
          <div className="animate-fade-in">
            <div className="section-header">
              <div>
                <h2 className="page-title">Мои курсы</h2>
                <p className="page-subtitle">
                  {courses.length} курс(ов) · опубликовано{' '}
                  {courses.filter(c => c.status === 'PUBLISHED').length}
                </p>
              </div>
              <button className="btn btn-primary" id="add-course-btn" onClick={() => setShowAddCourse(true)}>
                + Создать курс
              </button>
            </div>

            {courses.length === 0 ? (
              <div className="empty-state">
                <div className="empty-state-icon">📚</div>
                <h3 style={{ marginBottom: '8px' }}>Нет курсов</h3>
                <p className="empty-state-text">Создайте свой первый курс</p>
              </div>
            ) : (
              <div className="cards-grid">
                {courses.map((c, i) => {
                  const isPublished = c.status === 'PUBLISHED';

                  return (
                    <div key={c.id} className={`glass animate-fade-in delay-${Math.min(i + 1, 4)}`}
                      style={{ padding: '24px', display: 'flex', flexDirection: 'column' }}>
                      <div style={{ marginBottom: '12px' }}>
                        <span className={`status-badge ${isPublished ? 'is-correct' : 'is-pending'}`}>
                          {isPublished ? '● Опубликован' : '○ Черновик'}
                        </span>
                      </div>

                      <h3 style={{ marginBottom: '8px' }}>{c.title}</h3>
                      <p style={{ fontSize: '0.85rem', color: 'var(--color-text-muted)', marginBottom: '16px' }}>
                        {c.description || 'Без описания'}
                      </p>

                      <div style={{ display: 'flex', gap: '12px', fontSize: '0.8rem', color: 'var(--color-text-muted)', marginBottom: '18px' }}>
                        <span>📝 {c._count?.tasks ?? c.tasks?.length ?? 0} заданий</span>
                        <span>👥 {c._count?.studentCourses || 0} студентов</span>
                      </div>

                      <div style={{ display: 'flex', gap: '8px', marginTop: 'auto' }}>
                        <button
                          className="btn btn-primary btn-sm"
                          style={{ flex: 1 }}
                          onClick={() => navigate(`/courses/${c.id}/edit`)}
                        >
                          Редактор
                        </button>
                        <button
                          className="btn btn-ghost btn-sm"
                          onClick={() => navigate(`/courses/${c.id}/edit`)}
                          title="Управление студентами курса"
                        >
                          👥 Студенты
                        </button>
                        <button
                          className={`btn btn-sm ${isPublished ? 'btn-ghost' : 'btn-accent'}`}
                          onClick={() => togglePublish(c)}
                          disabled={publishingId === c.id}
                          title={isPublished ? 'Снять с публикации' : 'Опубликовать курс'}
                        >
                          {publishingId === c.id
                            ? '…'
                            : isPublished ? 'Снять' : '🚀'}
                        </button>
                      </div>
                    </div>
                  );
                })}
              </div>
            )}
          </div>
        )}

        {activeTab === 'requests' && (
          <div className="animate-fade-in">
            <div className="section-header">
              <div>
                <h2 className="page-title">Заявки на курсы</h2>
                <p className="page-subtitle">
                  {requests.filter(r => r.status === 'PENDING').length} ожидают решения
                </p>
              </div>
              <button className="btn btn-ghost btn-sm" onClick={loadRequests}>
                ↻ Обновить
              </button>
            </div>

            {requests.length === 0 ? (
              <div className="empty-state">
                <div className="empty-state-icon">📩</div>
                <h3 style={{ marginBottom: '8px' }}>Заявок нет</h3>
                <p className="empty-state-text">
                  Ученики смогут запросить доступ к вашим опубликованным курсам
                </p>
              </div>
            ) : (
              <div className="cards-grid">
                {requests.map((request, i) => {
                  const isPending = request.status === 'PENDING';
                  const isApproved = request.status === 'APPROVED';

                  return (
                    <div
                      key={request.id}
                      className={`glass animate-fade-in delay-${Math.min(i + 1, 4)}`}
                      style={{ padding: '20px', display: 'flex', flexDirection: 'column' }}
                    >
                      <span
                        className={`status-badge ${isApproved ? 'is-correct' : isPending ? 'is-progress' : 'is-incorrect'}`}
                        style={{ alignSelf: 'flex-start', marginBottom: '12px' }}
                      >
                        {isApproved ? '✅ Одобрена' : isPending ? '⏳ Ожидает' : '❌ Отклонена'}
                      </span>

                      <div style={{ display: 'flex', alignItems: 'center', gap: '12px', marginBottom: '12px' }}>
                        <div className="avatar-circle">
                          {request.student?.firstName?.[0]}{request.student?.lastName?.[0]}
                        </div>
                        <div>
                          <div style={{ fontWeight: '700' }}>
                            {request.student?.firstName} {request.student?.lastName}
                          </div>
                          <div style={{ fontSize: '0.8rem', color: 'var(--color-text-muted)' }}>
                            {request.student?.email}
                          </div>
                        </div>
                      </div>

                      <div style={{ fontSize: '0.85rem', color: 'var(--color-text-secondary)', marginBottom: '8px' }}>
                        📚 {request.course?.title}
                      </div>

                      {request.message && (
                        <p style={{ fontSize: '0.82rem', color: 'var(--color-text-muted)', marginBottom: '12px' }}>
                          «{request.message}»
                        </p>
                      )}

                      {isPending && (
                        <div style={{ display: 'flex', gap: '8px', marginTop: 'auto' }}>
                          <button
                            className="btn btn-primary btn-sm"
                            style={{ flex: 1 }}
                            disabled={reviewingId === request.id}
                            onClick={() => reviewRequest(request, 'approve')}
                          >
                            Одобрить
                          </button>
                          <button
                            className="btn btn-ghost btn-sm"
                            style={{ flex: 1 }}
                            disabled={reviewingId === request.id}
                            onClick={() => reviewRequest(request, 'reject')}
                          >
                            Отклонить
                          </button>
                        </div>
                      )}
                    </div>
                  );
                })}
              </div>
            )}
          </div>
        )}

        {activeTab === 'tuner' && (
          <div className="animate-fade-in" style={{ maxWidth: '500px' }}>
            <h2 style={{ marginBottom: '24px' }}>Гитарный тюнер</h2>
            <GuitarTuner />
          </div>
        )}
      </main>

      {showAddStudent && (
        <div className="modal-overlay" onClick={() => setShowAddStudent(false)}>
          <div className="modal-content" onClick={e => e.stopPropagation()}>
            <h3 style={{ marginBottom: '20px' }}>Добавить студента</h3>
            <form onSubmit={handleAddStudent}>
              <div className="form-group" style={{ marginBottom: '20px' }}>
                <label className="form-label" htmlFor="student-email-input">Email студента</label>
                <input id="student-email-input" type="email" className="input"
                  placeholder="student@email.com"
                  value={studentEmail}
                  onChange={e => setStudentEmail(e.target.value)} required />
              </div>
              <div style={{ display: 'flex', gap: '12px' }}>
                <button type="button" className="btn btn-ghost" style={{ flex: 1 }}
                  onClick={() => setShowAddStudent(false)}>Отмена</button>
                <button type="submit" className="btn btn-primary" style={{ flex: 1 }} disabled={isLoading}>
                  {isLoading ? '...' : 'Добавить'}
                </button>
              </div>
            </form>
          </div>
        </div>
      )}

      {showAddCourse && (
        <div className="modal-overlay" onClick={() => setShowAddCourse(false)}>
          <div className="modal-content" onClick={e => e.stopPropagation()}>
            <h3 style={{ marginBottom: '20px' }}>Создать курс</h3>
            <form onSubmit={handleCreateCourse}>
              <div style={{ display: 'flex', flexDirection: 'column', gap: '16px', marginBottom: '20px' }}>
                <div className="form-group">
                  <label className="form-label" htmlFor="course-title">Название курса</label>
                  <input id="course-title" type="text" className="input"
                    placeholder="Основы гитары"
                    value={courseForm.title}
                    onChange={e => setCourseForm(f => ({ ...f, title: e.target.value }))} required />
                </div>
                <div className="form-group">
                  <label className="form-label" htmlFor="course-desc">Описание</label>
                  <textarea id="course-desc" className="input"
                    placeholder="О чём этот курс..." rows={3}
                    style={{ resize: 'vertical' }}
                    value={courseForm.description}
                    onChange={e => setCourseForm(f => ({ ...f, description: e.target.value }))} />
                </div>
              </div>
              <div style={{ display: 'flex', gap: '12px' }}>
                <button type="button" className="btn btn-ghost" style={{ flex: 1 }}
                  onClick={() => setShowAddCourse(false)}>Отмена</button>
                <button type="submit" className="btn btn-primary" style={{ flex: 1 }} disabled={isLoading}>
                  {isLoading ? '...' : 'Создать'}
                </button>
              </div>
            </form>
          </div>
        </div>
      )}
    </div>
  );
}
