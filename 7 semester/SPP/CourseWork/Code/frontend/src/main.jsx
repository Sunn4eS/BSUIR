import React from 'react';
import ReactDOM from 'react-dom/client';
import App from './App.jsx';
import { AudioSessionProvider } from './hooks/useAudioSession.jsx';
import './index.css';

ReactDOM.createRoot(document.getElementById('root')).render(
  <React.StrictMode>
    <AudioSessionProvider>
      <App />
    </AudioSessionProvider>
  </React.StrictMode>
);
