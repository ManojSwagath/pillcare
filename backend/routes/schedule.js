const express = require('express');
const router = express.Router();
const {
  createSchedule,
  getSchedules,
  getTodaySchedules,
  updateSchedule,
  deleteSchedule
} = require('../controllers/scheduleController');
const { protect } = require('../middleware/auth');

router.use(protect);

router.route('/')
  .get(getSchedules)
  .post(createSchedule);

router.get('/today', getTodaySchedules);

router.route('/:id')
  .put(updateSchedule)
  .delete(deleteSchedule);

module.exports = router;
