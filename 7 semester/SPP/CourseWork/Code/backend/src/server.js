require('dotenv').config();
const http = require('http');
const app = require('./app');
const { initSocketServer } = require('./sockets/socket.server');
const { prisma } = require('./config/database');

const PORT = process.env.PORT || 4000;

const server = http.createServer(app);

initSocketServer(server);

async function bootstrap() {
  try {
    await prisma.$connect();
    console.log('✅ Подключение к PostgreSQL установлено');

    server.listen(PORT, () => {
      console.log(`🎸 Guitar Trainer Backend запущен на порту ${PORT}`);
      console.log(`   ENV: ${process.env.NODE_ENV || 'development'}`);
      console.log(`   API: http://localhost:${PORT}/api`);
    });
  } catch (error) {
    console.error('❌ Ошибка при запуске сервера:', error);
    process.exit(1);
  }
}

process.on('SIGTERM', async () => {
  console.log('🛑 SIGTERM получен, завершаем работу...');
  await prisma.$disconnect();
  server.close(() => process.exit(0));
});

bootstrap();
