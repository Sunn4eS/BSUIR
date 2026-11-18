/**
 * frontend/src/components/Courses/CourseManagement.jsx
 *
 * Панель управления студентами курса для преподавателя:
 * - Вкладка «Заявки на вступление» (PENDING) с кнопками «Принять» (APPROVED) / «Отклонить» (REJECTED)
 * - Вкладка «Зачисленные студенты» (APPROVED) со списком и кнопкой «Исключить из курса»
 * - Форма «Добавить ученика по Email» (прямой ввод и зачисление)
 *
 * Дизайн: строго Light Theme (фон #F8FAFC / #FFFFFF, текст #334155, мягкие тени, просторные отступы)
 */

import { useCallback, useEffect, useState } from 'react';
import api from '../../api/axios';
import toast from 'react-hot-toast';

export default function CourseManagement({ courseId, courseTitle = '', onUpdate = null }) {
  const [activeTab, setActiveTab] = useState('requests'); // 'requests' | 'enrolled' | 'add'
  const [enrollments, setEnrollments] = useState([]);
  const [isLoading, setIsLoading] = useState(true);
  const [actionLoadingId, setActionLoadingId] = useState(null);

  // Форма добавления по Email
  const [emailInput, setEmailInput] = useState('');
  const [isAdding, setIsAdding] = useState(false);

  // Загрузка заявок курса
  const loadEnrollments = useCallback(async () => {
    if (!courseId) return;
    setIsLoading(true);
    try {
      const { data } = await api.get(`/courses/${courseId}/enrollments`);
      setEnrollments(data.enrollments || []);
    } catch (err) {
      toast.error(err.response?.data?.error || 'Не удалось загрузить список заявок');
    } finally {
      setIsLoading(false);
    }
  }, [courseId]);

  useEffect(() => {
    loadEnrollments();
  }, [loadEnrollments]);

  // Фильтрация заявок и зачисленных студентов
  const pendingRequests = enrollments.filter((e) => e.status === 'PENDING');
  const enrolledStudents = enrollments.filter((e) => e.status === 'APPROVED');
  const rejectedRequests = enrollments.filter((e) => e.status === 'REJECTED');

  // Одобрение или отклонение заявки
  const handleReview = async (enrollmentId, status) => {
    setActionLoadingId(enrollmentId);
    try {
      await api.patch(`/courses/${courseId}/enrollments/${enrollmentId}`, { status });
      toast.success(status === 'APPROVED' ? 'Заявка одобрена! Ученик зачислен.' : 'Заявка отклонена');
      await loadEnrollments();
      onUpdate?.();
    } catch (err) {
      toast.error(err.response?.data?.error || 'Ошибка при обработке заявки');
    } finally {
      setActionLoadingId(null);
    }
  };

  // Исключение студента из курса
  const handleRemove = async (studentId, studentName) => {
    if (!window.confirm(`Вы уверены, что хотите исключить студента ${studentName || ''} из курса?`)) {
      return;
    }

    setActionLoadingId(studentId);
    try {
      await api.delete(`/courses/${courseId}/students/${studentId}`);
      toast.success('Студент исключен из курса');
      await loadEnrollments();
      onUpdate?.();
    } catch (err) {
      toast.error(err.response?.data?.error || 'Не удалось исключить студента');
    } finally {
      setActionLoadingId(null);
    }
  };

  // Добавление студента по Email
  const handleAddByEmail = async (e) => {
    e.preventDefault();
    if (!emailInput.trim()) {
      toast.error('Введите email ученика');
      return;
    }

    setIsAdding(true);
    try {
      await api.post(`/courses/${courseId}/students`, {
        email: emailInput.trim(),
      });
      toast.success('Ученик успешно зачислен на курс!');
      setEmailInput('');
      await loadEnrollments();
      setActiveTab('enrolled');
      onUpdate?.();
    } catch (err) {
      toast.error(err.response?.data?.error || 'Пользователь не найден или уже зачислен');
    } finally {
      setIsAdding(false);
    }
  };

  return (
    <div
      className="course-management-card"
      style={{
        backgroundColor: '#FFFFFF',
        borderRadius: '16px',
        border: '1px solid #E2E8F0',
        boxShadow: '0 8px 30px rgba(15, 23, 42, 0.05)',
        padding: '24px',
        marginTop: '24px',
      }}
    >
      {/* Заголовок секции */}
      <div style={{ marginBottom: '20px' }}>
        <div style={{ display: 'flex', alignItems: 'center', justifyContent: 'space-between' }}>
          <div>
            <h3 style={{ fontSize: '1.2rem', fontWeight: 700, color: '#0F172A', margin: 0 }}>
              👥 Управление студентами {courseTitle ? `· «${courseTitle}»` : ''}
            </h3>
            <p style={{ margin: '4px 0 0', fontSize: '0.85rem', color: '#64748B' }}>
              Рассмотрение заявок, список зачисленных и добавление новых учеников
            </p>
          </div>

          <button
            onClick={loadEnrollments}
            disabled={isLoading}
            className="btn btn-ghost btn-sm"
            style={{ fontSize: '0.8rem', color: '#64748B' }}
            title="Обновить список"
          >
            🔄 Обновить
          </button>
        </div>

        {/* Навигационные вкладки блока */}
        <div
          style={{
            display: 'flex',
            gap: '8px',
            borderBottom: '1px solid #E2E8F0',
            marginTop: '16px',
            paddingBottom: '2px',
          }}
        >
          <button
            onClick={() => setActiveTab('requests')}
            style={{
              padding: '8px 16px',
              border: 'none',
              borderBottom: activeTab === 'requests' ? '2px solid #4F46E5' : '2px solid transparent',
              backgroundColor: 'transparent',
              color: activeTab === 'requests' ? '#4F46E5' : '#64748B',
              fontWeight: activeTab === 'requests' ? 700 : 500,
              fontSize: '0.9rem',
              cursor: 'pointer',
              display: 'flex',
              alignItems: 'center',
              gap: '6px',
            }}
          >
            <span>Заявки на вступление</span>
            {pendingRequests.length > 0 && (
              <span
                style={{
                  backgroundColor: '#EF4444',
                  color: '#FFFFFF',
                  borderRadius: '999px',
                  padding: '2px 7px',
                  fontSize: '0.75rem',
                  fontWeight: 700,
                }}
              >
                {pendingRequests.length}
              </span>
            )}
          </button>

          <button
            onClick={() => setActiveTab('enrolled')}
            style={{
              padding: '8px 16px',
              border: 'none',
              borderBottom: activeTab === 'enrolled' ? '2px solid #4F46E5' : '2px solid transparent',
              backgroundColor: 'transparent',
              color: activeTab === 'enrolled' ? '#4F46E5' : '#64748B',
              fontWeight: activeTab === 'enrolled' ? 700 : 500,
              fontSize: '0.9rem',
              cursor: 'pointer',
              display: 'flex',
              alignItems: 'center',
              gap: '6px',
            }}
          >
            <span>Зачисленные студенты</span>
            <span
              style={{
                backgroundColor: '#F1F5F9',
                color: '#475569',
                borderRadius: '999px',
                padding: '2px 7px',
                fontSize: '0.75rem',
                fontWeight: 600,
              }}
            >
              {enrolledStudents.length}
            </span>
          </button>

          <button
            onClick={() => setActiveTab('add')}
            style={{
              padding: '8px 16px',
              border: 'none',
              borderBottom: activeTab === 'add' ? '2px solid #4F46E5' : '2px solid transparent',
              backgroundColor: 'transparent',
              color: activeTab === 'add' ? '#4F46E5' : '#64748B',
              fontWeight: activeTab === 'add' ? 700 : 500,
              fontSize: '0.9rem',
              cursor: 'pointer',
            }}
          >
            ➕ Добавить по Email
          </button>
        </div>
      </div>

      {/* ── Содержимое вкладок ── */}
      {isLoading ? (
        <div style={{ padding: '40px', textAlign: 'center', color: '#64748B' }}>
          <div className="loader" style={{ margin: '0 auto 12px' }} />
          <span>Загрузка списка студентов...</span>
        </div>
      ) : (
        <div>
          {/* ВКЛАДКА 1: Заявки на вступление */}
          {activeTab === 'requests' && (
            <div>
              {pendingRequests.length === 0 ? (
                <div style={{ textAlign: 'center', padding: '36px 16px', color: '#64748B' }}>
                  <div style={{ fontSize: '2rem', marginBottom: '8px' }}>📬</div>
                  <p style={{ margin: 0, fontWeight: 500 }}>Новых заявок пока нет</p>
                  <p style={{ margin: '4px 0 0', fontSize: '0.85rem' }}>
                    Когда ученики отправят заявку из Каталога курсов, она отобразится здесь.
                  </p>
                </div>
              ) : (
                <div style={{ display: 'flex', flexDirection: 'column', gap: '12px' }}>
                  {pendingRequests.map((reqItem) => {
                    const student = reqItem.student;
                    const studentName =
                      student?.displayName ||
                      student?.name ||
                      [student?.firstName, student?.lastName].filter(Boolean).join(' ') ||
                      student?.email;
                    const isBusy = actionLoadingId === reqItem.id;

                    return (
                      <div
                        key={reqItem.id}
                        style={{
                          display: 'flex',
                          alignItems: 'center',
                          justifyContent: 'space-between',
                          padding: '16px 20px',
                          backgroundColor: '#F8FAFC',
                          borderRadius: '12px',
                          border: '1px solid #E2E8F0',
                        }}
                      >
                        <div>
                          <div style={{ fontWeight: 600, color: '#1E293B', fontSize: '0.95rem' }}>
                            {studentName}
                          </div>
                          <div style={{ fontSize: '0.85rem', color: '#64748B', marginTop: '2px' }}>
                            {student?.email} · Дата заявки:{' '}
                            {new Date(reqItem.enrolledAt).toLocaleDateString('ru-RU')}
                          </div>
                        </div>

                        <div style={{ display: 'flex', gap: '8px' }}>
                          <button
                            onClick={() => handleReview(reqItem.id, 'APPROVED')}
                            disabled={isBusy}
                            style={{
                              backgroundColor: '#059669',
                              color: '#FFFFFF',
                              padding: '8px 16px',
                              borderRadius: '8px',
                              fontSize: '0.85rem',
                              fontWeight: 600,
                              border: 'none',
                              cursor: isBusy ? 'not-allowed' : 'pointer',
                              opacity: isBusy ? 0.6 : 1,
                            }}
                          >
                            ✓ Принять
                          </button>
                          <button
                            onClick={() => handleReview(reqItem.id, 'REJECTED')}
                            disabled={isBusy}
                            style={{
                              backgroundColor: '#FFFFFF',
                              color: '#DC2626',
                              border: '1px solid #FCA5A5',
                              padding: '8px 16px',
                              borderRadius: '8px',
                              fontSize: '0.85rem',
                              fontWeight: 600,
                              cursor: isBusy ? 'not-allowed' : 'pointer',
                              opacity: isBusy ? 0.6 : 1,
                            }}
                          >
                            ✕ Отклонить
                          </button>
                        </div>
                      </div>
                    );
                  })}
                </div>
              )}
            </div>
          )}

          {/* ВКЛАДКА 2: Зачисленные студенты */}
          {activeTab === 'enrolled' && (
            <div>
              {enrolledStudents.length === 0 ? (
                <div style={{ textAlign: 'center', padding: '36px 16px', color: '#64748B' }}>
                  <div style={{ fontSize: '2rem', marginBottom: '8px' }}>🎓</div>
                  <p style={{ margin: 0, fontWeight: 500 }}>На этот курс еще никто не зачислен</p>
                  <p style={{ margin: '4px 0 0', fontSize: '0.85rem' }}>
                    Вы можете принять поступившую заявку или добавить ученика по email.
                  </p>
                </div>
              ) : (
                <div style={{ display: 'flex', flexDirection: 'column', gap: '12px' }}>
                  {enrolledStudents.map((enroll) => {
                    const student = enroll.student;
                    const studentName =
                      student?.displayName ||
                      student?.name ||
                      [student?.firstName, student?.lastName].filter(Boolean).join(' ') ||
                      student?.email;
                    const isBusy = actionLoadingId === enroll.studentId;

                    return (
                      <div
                        key={enroll.id}
                        style={{
                          display: 'flex',
                          alignItems: 'center',
                          justifyContent: 'space-between',
                          padding: '16px 20px',
                          backgroundColor: '#F8FAFC',
                          borderRadius: '12px',
                          border: '1px solid #E2E8F0',
                        }}
                      >
                        <div>
                          <div style={{ display: 'flex', alignItems: 'center', gap: '8px' }}>
                            <span style={{ fontWeight: 600, color: '#1E293B', fontSize: '0.95rem' }}>
                              {studentName}
                            </span>
                            <span
                              style={{
                                backgroundColor: '#ECFDF5',
                                color: '#059669',
                                fontSize: '0.75rem',
                                padding: '2px 8px',
                                borderRadius: '999px',
                                fontWeight: 600,
                              }}
                            >
                              Зачислен
                            </span>
                          </div>
                          <div style={{ fontSize: '0.85rem', color: '#64748B', marginTop: '4px' }}>
                            {student?.email} · В курсе с{' '}
                            {new Date(enroll.enrolledAt).toLocaleDateString('ru-RU')}
                          </div>
                        </div>

                        <button
                          onClick={() => handleRemove(enroll.studentId, studentName)}
                          disabled={isBusy}
                          style={{
                            backgroundColor: '#FFFFFF',
                            color: '#DC2626',
                            border: '1px solid #FECACA',
                            padding: '6px 14px',
                            borderRadius: '8px',
                            fontSize: '0.8rem',
                            fontWeight: 600,
                            cursor: isBusy ? 'not-allowed' : 'pointer',
                            opacity: isBusy ? 0.6 : 1,
                          }}
                        >
                          Исключить из курса
                        </button>
                      </div>
                    );
                  })}
                </div>
              )}
            </div>
          )}

          {/* ВКЛАДКА 3: Добавить ученика по Email */}
          {activeTab === 'add' && (
            <form onSubmit={handleAddByEmail} style={{ maxWidth: '480px', marginTop: '8px' }}>
              <div style={{ marginBottom: '16px' }}>
                <label
                  htmlFor="student-email-input"
                  style={{ display: 'block', fontWeight: 600, fontSize: '0.875rem', color: '#334155', marginBottom: '6px' }}
                >
                  Email зарегистрированного студента:
                </label>
                <input
                  id="student-email-input"
                  type="email"
                  value={emailInput}
                  onChange={(e) => setEmailInput(e.target.value)}
                  placeholder="student@example.com"
                  required
                  style={{
                    width: '100%',
                    padding: '10px 14px',
                    borderRadius: '10px',
                    border: '1px solid #CBD5E1',
                    fontSize: '0.95rem',
                    color: '#0F172A',
                    outline: 'none',
                    backgroundColor: '#FFFFFF',
                  }}
                />
                <p style={{ margin: '6px 0 0', fontSize: '0.8rem', color: '#64748B' }}>
                  Студент получит мгновенный доступ со статусом «Одобрено» (APPROVED) и сможет проходить задания курса.
                </p>
              </div>

              <button
                type="submit"
                disabled={isAdding}
                style={{
                  backgroundColor: '#4F46E5',
                  color: '#FFFFFF',
                  padding: '10px 20px',
                  borderRadius: '10px',
                  fontSize: '0.9rem',
                  fontWeight: 600,
                  border: 'none',
                  cursor: isAdding ? 'not-allowed' : 'pointer',
                  opacity: isAdding ? 0.7 : 1,
                  display: 'flex',
                  alignItems: 'center',
                  gap: '8px',
                }}
              >
                {isAdding ? 'Зачисление...' : 'Зачислить студента на курс'}
              </button>
            </form>
          )}
        </div>
      )}
    </div>
  );
}
