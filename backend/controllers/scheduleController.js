const { ReminderSchedule, Medicine, DoseLog } = require('../models');
const { getTimeOfDay, parseTime } = require('../utils/helpers');

exports.createSchedule = async (req, res, next) => {
  try {
    const { medicineId, time, repeatType, daysOfWeek, mealInstruction, notes } = req.body;

    const medicine = await Medicine.findOne({
      _id: medicineId,
      patientId: req.user.id
    });

    if (!medicine) {
      return res.status(404).json({
        success: false,
        message: 'Medicine not found'
      });
    }

    const { hours } = parseTime(time);
    const timeOfDay = getTimeOfDay(hours);

    const schedule = await ReminderSchedule.create({
      patientId: req.user.id,
      medicineId,
      time,
      timeOfDay,
      repeatType: repeatType || 'daily',
      daysOfWeek,
      mealInstruction,
      notes
    });

    res.status(201).json({
      success: true,
      data: schedule
    });
  } catch (error) {
    next(error);
  }
};

exports.getSchedules = async (req, res, next) => {
  try {
    const schedules = await ReminderSchedule.find({
      patientId: req.user.id,
      isActive: true
    })
    .populate('medicineId', 'name dosage color')
    .sort({ time: 1 });

    res.json({
      success: true,
      count: schedules.length,
      data: schedules
    });
  } catch (error) {
    next(error);
  }
};

exports.getTodaySchedules = async (req, res, next) => {
  try {
    const today = new Date();
    const dayOfWeek = today.getDay();

    const schedules = await ReminderSchedule.find({
      patientId: req.user.id,
      isActive: true,
      $or: [
        { repeatType: 'daily' },
        { repeatType: 'weekly', daysOfWeek: dayOfWeek }
      ]
    })
    .populate('medicineId', 'name dosage color instructions')
    .sort({ time: 1 });

    const startOfDay = new Date(today.setHours(0, 0, 0, 0));
    const endOfDay = new Date(today.setHours(23, 59, 59, 999));

    const doseLogs = await DoseLog.find({
      patientId: req.user.id,
      scheduledTime: { $gte: startOfDay, $lte: endOfDay }
    });

    const schedulesWithStatus = schedules.map(schedule => {
      const log = doseLogs.find(
        d => d.scheduleId.toString() === schedule._id.toString()
      );
      return {
        ...schedule.toObject(),
        status: log ? log.status : 'pending',
        doseLogId: log ? log._id : null
      };
    });

    res.json({
      success: true,
      count: schedulesWithStatus.length,
      data: schedulesWithStatus
    });
  } catch (error) {
    next(error);
  }
};

exports.updateSchedule = async (req, res, next) => {
  try {
    const schedule = await ReminderSchedule.findOneAndUpdate(
      { _id: req.params.id, patientId: req.user.id },
      req.body,
      { new: true, runValidators: true }
    );

    if (!schedule) {
      return res.status(404).json({
        success: false,
        message: 'Schedule not found'
      });
    }

    res.json({
      success: true,
      data: schedule
    });
  } catch (error) {
    next(error);
  }
};

exports.deleteSchedule = async (req, res, next) => {
  try {
    const schedule = await ReminderSchedule.findOneAndUpdate(
      { _id: req.params.id, patientId: req.user.id },
      { isActive: false },
      { new: true }
    );

    if (!schedule) {
      return res.status(404).json({
        success: false,
        message: 'Schedule not found'
      });
    }

    res.json({
      success: true,
      message: 'Schedule deleted'
    });
  } catch (error) {
    next(error);
  }
};
