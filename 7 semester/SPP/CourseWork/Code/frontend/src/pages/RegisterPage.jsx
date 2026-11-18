/**
 * pages/RegisterPage.jsx
 */

import { useState } from 'react';
import { Link, useNavigate } from 'react-router-dom';
import useAuthStore from '../store/authStore';
import toast from 'react-hot-toast';

export default function RegisterPage() {
  const [form, setForm] = useState({
    email: '', password: '', firstName: '', lastName: '', role: 'STUDENT',
  });
  const { register, isLoading } = useAuthStore();
  const navigate = useNavigate();

  const handleSubmit = async (e) => {
    e.preventDefault();
    if (form.password.length < 6) {
      toast.error('Пароль минимум 6 символов');
      return;
    }
    const result = await register(form);
    if (result.success) {
      toast.success('Аккаунт создан! Добро пожаловать!');
      navigate('/dashboard');
    } else {
      toast.error(result.error);
    }
  };

  const set = (field) => (e) => setForm(f => ({ ...f, [field]: e.target.value }));

  return (
    <div className="auth-page">
      <div className="auth-card">
        <div className="auth-logo">
          <span className="gradient-text">🎸 Guitar</span>
          <span style={{ color: 'var(--color-text-primary)' }}> Trainer</span>
        </div>
        <p className="auth-subtitle">Создайте аккаунт</p>

        <form className="auth-form" onSubmit={handleSubmit}>
          {/* Имя и фамилия в ряд */}
          <div style={{ display: 'grid', gridTemplateColumns: '1fr 1fr', gap: '12px' }}>
            <div className="form-group">
              <label className="form-label" htmlFor="reg-firstname">Имя</label>
              <input id="reg-firstname" type="text" className="input"
                placeholder="Иван" value={form.firstName} onChange={set('firstName')} required />
            </div>
            <div className="form-group">
              <label className="form-label" htmlFor="reg-lastname">Фамилия</label>
              <input id="reg-lastname" type="text" className="input"
                placeholder="Иванов" value={form.lastName} onChange={set('lastName')} required />
            </div>
          </div>

          <div className="form-group">
            <label className="form-label" htmlFor="reg-email">Email</label>
            <input id="reg-email" type="email" className="input"
              placeholder="your@email.com" value={form.email} onChange={set('email')} required />
          </div>

          <div className="form-group">
            <label className="form-label" htmlFor="reg-password">Пароль</label>
            <input id="reg-password" type="password" className="input"
              placeholder="Минимум 6 символов" value={form.password} onChange={set('password')} required />
          </div>

          {/* Выбор роли */}
          <div className="form-group">
            <label className="form-label">Я являюсь</label>
            <div style={{ display: 'grid', gridTemplateColumns: '1fr 1fr', gap: '12px' }}>
              {[
                { value: 'STUDENT', label: '🎓 Студент', desc: 'Учусь играть' },
                { value: 'TEACHER', label: '👨‍🏫 Учитель', desc: 'Обучаю других' },
              ].map(role => (
                <button
                  key={role.value}
                  type="button"
                  onClick={() => setForm(f => ({ ...f, role: role.value }))}
                  style={{
                    padding: '14px',
                    background: form.role === role.value
                      ? 'var(--color-primary-soft)'
                      : '#fff',
                    border: `2px solid ${form.role === role.value ? 'var(--color-primary)' : 'var(--color-border)'}`,
                    borderRadius: 'var(--radius-md)',
                    cursor: 'pointer',
                    textAlign: 'center',
                    transition: 'all 0.2s ease',
                  }}
                >
                  <div style={{ fontSize: '1.2rem', marginBottom: '4px' }}>{role.label}</div>
                  <div style={{ fontSize: '0.75rem', color: 'var(--color-text-muted)' }}>{role.desc}</div>
                </button>
              ))}
            </div>
          </div>

          <button
            id="register-submit"
            type="submit"
            className="btn btn-primary btn-lg"
            disabled={isLoading}
            style={{ width: '100%', marginTop: '8px' }}
          >
            {isLoading
              ? <><div className="loader" style={{ width: '18px', height: '18px', borderWidth: '2px' }} /> Создаём...</>
              : 'Создать аккаунт →'
            }
          </button>
        </form>

        <div className="auth-footer">
          Уже есть аккаунт?{' '}
          <Link to="/login" style={{ color: 'var(--color-primary)', fontWeight: '600' }}>
            Войти
          </Link>
        </div>
      </div>
    </div>
  );
}
