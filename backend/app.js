const express = require('express');
const cors = require('cors');
const {
  authRoutes,
  medicineRoutes,
  scheduleRoutes,
  doseRoutes,
  caregiverRoutes,
  patientRoutes
} = require('./routes');
const errorHandler = require('./middleware/errorHandler');

const app = express();

// CORS - allow all origins for development
app.use(cors({
  origin: '*',
  methods: ['GET', 'POST', 'PUT', 'DELETE', 'OPTIONS'],
  allowedHeaders: ['Content-Type', 'Authorization']
}));

// Handle preflight requests
app.options('*', cors());

app.use(express.json());
app.use(express.urlencoded({ extended: true }));

app.get('/api/health', (req, res) => {
  res.json({ status: 'ok', timestamp: new Date().toISOString() });
});

app.use('/api/auth', authRoutes);
app.use('/api/medicine', medicineRoutes);
app.use('/api/schedule', scheduleRoutes);
app.use('/api/dose', doseRoutes);
app.use('/api/caregiver', caregiverRoutes);
app.use('/api/patient', patientRoutes);

app.use((req, res) => {
  res.status(404).json({ success: false, message: 'Route not found' });
});

app.use(errorHandler);

module.exports = app;
