/**
 * components/Live/TeacherLivePanel.jsx
 * Панель учителя: быстрый конструктор + библиотека курса.
 */

import { useState } from 'react';
import QuickTaskBuilder from './QuickTaskBuilder';
import CourseTaskLibrary from './CourseTaskLibrary';

const TABS = [
  { id: 'quick', label: '⚡ Быстрый конструктор' },
  { id: 'library', label: '📚 Библиотека курса' },
];

export default function TeacherLivePanel({ onSendQuick, onSendTask, studentOnline }) {
  const [activeTab, setActiveTab] = useState('quick');

  return (
    <div className="teacher-panel">
      <div className="teacher-panel-header">
        <div>
          <h3 className="section-title">Управление уроком</h3>
          <div className={`student-presence ${studentOnline ? 'is-online' : 'is-offline'}`}>
            <span className="presence-dot" />
            {studentOnline ? 'Ученик в комнате' : 'Ученик не подключён'}
          </div>
        </div>
      </div>

      <div className="tabs">
        {TABS.map((tab) => (
          <button
            key={tab.id}
            type="button"
            className={`tab ${activeTab === tab.id ? 'active' : ''}`}
            onClick={() => setActiveTab(tab.id)}
          >
            {tab.label}
          </button>
        ))}
      </div>

      <div className="teacher-panel-body">
        {activeTab === 'quick' ? (
          <QuickTaskBuilder onSend={onSendQuick} disabled={!studentOnline} />
        ) : (
          <CourseTaskLibrary onSendTask={onSendTask} disabled={!studentOnline} />
        )}
      </div>
    </div>
  );
}
