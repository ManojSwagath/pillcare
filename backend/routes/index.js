const authRoutes = require('./auth');
const medicineRoutes = require('./medicine');
const scheduleRoutes = require('./schedule');
const doseRoutes = require('./dose');
const caregiverRoutes = require('./caregiver');
const patientRoutes = require('./patient');

module.exports = {
  authRoutes,
  medicineRoutes,
  scheduleRoutes,
  doseRoutes,
  caregiverRoutes,
  patientRoutes
};
