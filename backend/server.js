require('dotenv').config();
const http = require('http');
const { Server } = require('socket.io');
const app = require('./app');
const connectDB = require('./config/db');
const ReminderService = require('./services/reminderService');

const PORT = process.env.PORT || 5000;

const server = http.createServer(app);

const io = new Server(server, {
  cors: {
    origin: process.env.FRONTEND_URL || '*',
    methods: ['GET', 'POST']
  }
});

app.set('io', io);

io.on('connection', (socket) => {
  console.log('Client connected:', socket.id);

  socket.on('join_patient', (patientId) => {
    socket.join(`patient_${patientId}`);
    console.log(`Socket ${socket.id} joined patient_${patientId}`);
  });

  socket.on('join_caregiver', (caregiverId) => {
    socket.join(`caregiver_${caregiverId}`);
    console.log(`Socket ${socket.id} joined caregiver_${caregiverId}`);
  });

  socket.on('disconnect', () => {
    console.log('Client disconnected:', socket.id);
  });
});

const startServer = async () => {
  try {
    await connectDB();

    const reminderService = new ReminderService(io);
    reminderService.start();

    server.listen(PORT, () => {
      console.log(`Server running on port ${PORT}`);
      console.log(`Environment: ${process.env.NODE_ENV}`);
    });
  } catch (error) {
    console.error('Failed to start server:', error);
    process.exit(1);
  }
};

startServer();
