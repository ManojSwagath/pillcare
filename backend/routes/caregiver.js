const express = require('express');
const router = express.Router();
const {
  linkPatient,
  getPatients,
  getPatientDetails,
  getAlerts,
  markAlertRead,
  unlinkPatient
} = require('../controllers/caregiverController');
const { protect, authorize } = require('../middleware/auth');

router.use(protect);
router.use(authorize('caregiver', 'admin'));

router.post('/link', linkPatient);
router.get('/patients', getPatients);
router.get('/patients/:patientId', getPatientDetails);
router.delete('/patients/:patientId', unlinkPatient);
router.get('/alerts', getAlerts);
router.put('/alerts/:id/read', markAlertRead);

module.exports = router;
