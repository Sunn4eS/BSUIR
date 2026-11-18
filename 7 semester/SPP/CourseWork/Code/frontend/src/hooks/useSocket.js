/**
 * hooks/useSocket.js — общее Socket.io подключение на всё приложение
 *
 * Сокет создаётся один раз (singleton) и переиспользуется всеми компонентами,
 * чтобы не открывать по соединению на каждую страницу.
 */

import { useCallback, useEffect, useRef, useState } from 'react';
import { io } from 'socket.io-client';
import useAuthStore from '../store/authStore';

const WS_URL = import.meta.env.VITE_WS_URL || 'http://localhost:4000';

let sharedSocket = null;
let sharedToken = null;

function getSharedSocket(token) {
  if (!token) {
    if (sharedSocket) {
      sharedSocket.disconnect();
      sharedSocket = null;
      sharedToken = null;
    }
    return null;
  }

  if (sharedSocket && sharedToken === token) return sharedSocket;

  if (sharedSocket) sharedSocket.disconnect();

  sharedToken = token;
  sharedSocket = io(WS_URL, {
    auth: { token: `Bearer ${token}` },
    transports: ['websocket'],
    reconnectionAttempts: 10,
    reconnectionDelay: 1000,
  });

  return sharedSocket;
}

/** Принудительно закрыть соединение (например, при logout) */
export function disconnectSocket() {
  if (sharedSocket) sharedSocket.disconnect();
  sharedSocket = null;
  sharedToken = null;
}

export function useSocket() {
  const token = useAuthStore((state) => state.token);
  const socketRef = useRef(null);

  const [isConnected, setIsConnected] = useState(false);
  const [connectionError, setConnectionError] = useState(null);

  useEffect(() => {
    const socket = getSharedSocket(token);
    socketRef.current = socket;

    if (!socket) {
      setIsConnected(false);
      return undefined;
    }

    setIsConnected(socket.connected);

    const handleConnect = () => {
      setIsConnected(true);
      setConnectionError(null);
    };

    const handleDisconnect = () => setIsConnected(false);

    const handleConnectError = (err) => {
      setConnectionError(err.message);
      setIsConnected(false);
    };

    socket.on('connect', handleConnect);
    socket.on('disconnect', handleDisconnect);
    socket.on('connect_error', handleConnectError);

    return () => {
      socket.off('connect', handleConnect);
      socket.off('disconnect', handleDisconnect);
      socket.off('connect_error', handleConnectError);
    };
  }, [token]);

  const on = useCallback((event, handler) => {
    socketRef.current?.on(event, handler);
  }, []);

  const off = useCallback((event, handler) => {
    socketRef.current?.off(event, handler);
  }, []);

  const emit = useCallback((event, data) => {
    socketRef.current?.emit(event, data);
  }, []);

  return {
    socket: socketRef.current,
    isConnected,
    connectionError,
    on,
    off,
    emit,
  };
}
