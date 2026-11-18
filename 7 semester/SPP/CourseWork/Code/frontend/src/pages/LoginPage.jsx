/**
 * pages/LoginPage.jsx
 */

import { useState } from 'react';
import { Link, useNavigate } from 'react-router-dom';
import useAuthStore from '../store/authStore';
import toast from 'react-hot-toast';

export default function LoginPage() {
  const [form, setForm] = useState({ email: '', password: '' });
  const { login, isLoading } = useAuthStore();
  const navigate = useNavigate();

  const handleSubmit = async (e) => {
    e.preventDefault();
    const result = await login(form.email, form.password);
    if (result.success) {
      toast.success('Добро пожаловать!');
      navigate('/dashboard');
    } else {
      toast.error(result.error);
    }
  };

  return (
    <div className="auth-page">
      {/* Фоновые декоративные элементы */}
      <div style={{
        position: 'fixed', inset: 0, pointerEvents: 'none', overflow: 'hidden', zIndex: 0,
      }}>
        {[...Array(3)].map((_, i) => (
          <div key={i} style={{
            position: 'absolute',
            width: '400px', height: '400px',
            borderRadius: '50%',
            background: i % 2 === 0
              ? 'radial-gradient(circle, rgba(99,102,241,0.10), transparent)'
              : 'radial-gradient(circle, rgba(20,184,166,0.08), transparent)',
            top: `${[10, 60, 30][i]}%`,
            left: `${[5, 70, 40][i]}%`,
            transform: 'translate(-50%, -50%)',
          }} />
        ))}
      </div>

      <div className="auth-card" style={{ position: 'relative', zIndex: 1 }}>
        {/* Логотип */}
        <div className="auth-logo">
          <span className="gradient-text">🎸 Guitar</span>
          <span style={{ color: 'var(--color-text-primary)' }}> Trainer</span>
        </div>
        <p className="auth-subtitle">Войдите в свой аккаунт</p>

        <form className="auth-form" onSubmit={handleSubmit}>
          <div className="form-group">
            <label className="form-label" htmlFor="login-email">Email</label>
            <input
              id="login-email"
              type="email"
              className="input"
              placeholder="your@email.com"
              value={form.email}
              onChange={e => setForm(f => ({ ...f, email: e.target.value }))}
              required
            />
          </div>

          <div className="form-group">
            <label className="form-label" htmlFor="login-password">Пароль</label>
            <input
              id="login-password"
              type="password"
              className="input"
              placeholder="••••••••"
              value={form.password}
              onChange={e => setForm(f => ({ ...f, password: e.target.value }))}
              required
            />
          </div>

          <button
            id="login-submit"
            type="submit"
            className="btn btn-primary btn-lg"
            disabled={isLoading}
            style={{ width: '100%', marginTop: '8px' }}
          >
            {isLoading ? (
              <><div className="loader" style={{ width: '18px', height: '18px', borderWidth: '2px' }} /> Вход...</>
            ) : 'Войти →'}
          </button>
        </form>

        <div className="auth-footer">
          Нет аккаунта?{' '}
          <Link to="/register" style={{ color: 'var(--color-primary)', fontWeight: '600' }}>
            Зарегистрироваться
          </Link>
        </div>

        {/* Демо-данные */}
        <div style={{
          marginTop: '24px',
          padding: '14px',
          background: 'var(--color-primary-soft)',
          border: '1px solid #c7d2fe',
          borderRadius: 'var(--radius-md)',
          fontSize: '0.8rem',
          color: 'var(--color-text-muted)',
        }}>
          <p style={{ fontWeight: '600', color: 'var(--color-primary)', marginBottom: '8px' }}>
            🧪 Тестовые аккаунты
          </p>
          <p>Учитель: <code>teacher@guitar.app</code> / <code>password123</code></p>
          <p>Студент: <code>student1@guitar.app</code> / <code>password123</code></p>
        </div>
      </div>
    </div>
  );
}
