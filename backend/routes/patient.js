const express = require('express');
const router = express.Router();
const { getProfile, updateProfile } = require('../controllers/patientController');
const { protect, authorize } = require('../middleware/auth');

router.use(protect);
router.use(authorize('patient', 'admin'));

router.route('/profile')
  .get(getProfile)
  .put(updateProfile);

module.exports = router;
