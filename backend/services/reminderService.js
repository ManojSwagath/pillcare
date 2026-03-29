const cron = require('node-cron');
const { ReminderSchedule, DoseLog, AlertHistory, CaregiverLink } = require('../models');
const { parseTime, formatTime } = require('../utils/helpers');

class ReminderService {
  constructor(io) {
    this.io = io;
    this.REMINDER_INTERVAL = 2;
    this.MISSED_THRESHOLD = 5;
  }

  start() {
    cron.schedule('* * * * *', () => {
      this.checkReminders();
    });
    console.log('Reminder service started');
  }

  async checkReminders() {
    try {
      const now = new Date();
      const currentTime = formatTime(now);
      const dayOfWeek = now.getDay();

      const schedules = await ReminderSchedule.find({
        isActive: true,
        $or: [
          { repeatType: 'daily' },
          { repeatType: 'weekly', daysOfWeek: dayOfWeek }
        ]
      }).populate('medicineId patientId');

      for (const schedule of schedules) {
        await this.processSchedule(schedule, now);
      }
    } catch (error) {
      console.error('Reminder check error:', error);
    }
  }

  async processSchedule(schedule, now) {
    const { hours: schedHours, minutes: schedMins } = parseTime(schedule.time);
    const scheduledTime = new Date(now);
    scheduledTime.setHours(schedHours, schedMins, 0, 0);

    const diffMinutes = Math.floor((now - scheduledTime) / 60000);

    if (diffMinutes < 0 || diffMinutes > this.MISSED_THRESHOLD) return;

    let doseLog = await DoseLog.findOne({
      scheduleId: schedule._id,
      scheduledTime: {
        $gte: new Date(scheduledTime.setHours(0, 0, 0, 0)),
        $lte: new Date(scheduledTime.setHours(23, 59, 59, 999))
      }
    });

    if (!doseLog) {
      doseLog = await DoseLog.create({
        patientId: schedule.patientId._id,
        medicineId: schedule.medicineId._id,
        scheduleId: schedule._id,
        scheduledTime: new Date(now.getFullYear(), now.getMonth(), now.getDate(), schedHours, schedMins),
        status: 'pending'
      });
    }

    if (doseLog.status !== 'pending') return;

    if (diffMinutes === 0 || (diffMinutes === this.REMINDER_INTERVAL && doseLog.reminderCount < 2)) {
      await this.triggerReminder(schedule, doseLog);
    }

    if (diffMinutes >= this.MISSED_THRESHOLD && doseLog.status === 'pending') {
      await this.markAsMissed(schedule, doseLog);
    }
  }

  async triggerReminder(schedule, doseLog) {
    doseLog.reminderCount += 1;
    await doseLog.save();

    if (this.io) {
      this.io.to(`patient_${schedule.patientId._id}`).emit('reminder_triggered', {
        doseLogId: doseLog._id,
        medicineId: schedule.medicineId._id,
        medicineName: schedule.medicineId.name,
        dosage: schedule.medicineId.dosage,
        time: schedule.time,
        timeOfDay: schedule.timeOfDay,
        notes: schedule.notes,
        mealInstruction: schedule.mealInstruction
      });
    }

    console.log(`Reminder sent: ${schedule.medicineId.name} for patient ${schedule.patientId.name}`);
  }

  async markAsMissed(schedule, doseLog) {
    doseLog.status = 'missed';
    await doseLog.save();

    const caregiverLinks = await CaregiverLink.find({
      patientId: schedule.patientId._id,
      status: 'active',
      'permissions.receiveAlerts': true
    });

    for (const link of caregiverLinks) {
      await AlertHistory.create({
        patientId: schedule.patientId._id,
        caregiverId: link.caregiverId,
        doseLogId: doseLog._id,
        alertType: 'missed_dose',
        message: `${schedule.patientId.name} missed ${schedule.medicineId.name} at ${schedule.time}`,
        severity: 'high'
      });

      if (this.io) {
        this.io.to(`caregiver_${link.caregiverId}`).emit('dose_missed', {
          patientId: schedule.patientId._id,
          patientName: schedule.patientId.name,
          medicineName: schedule.medicineId.name,
          time: schedule.time
        });
      }
    }

    console.log(`Dose marked missed: ${schedule.medicineId.name}`);
  }
}

module.exports = ReminderService;
