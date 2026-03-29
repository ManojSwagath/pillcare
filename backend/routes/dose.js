const express = require('express');
const router = express.Router();
const {
  respondToDose,
  getDoseHistory,
  getTodayDoses,
  getAdherenceStats
} = require('../controllers/doseController');
const { protect } = require('../middleware/auth');

router.use(protect);

router.post('/respond', respondToDose);
router.get('/history', getDoseHistory);
router.get('/today', getTodayDoses);
router.get('/stats', getAdherenceStats);

module.exports = router;
