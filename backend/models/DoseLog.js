const mongoose = require('mongoose');

const doseLogSchema = new mongoose.Schema({
  patientId: {
    type: mongoose.Schema.Types.ObjectId,
    ref: 'User',
    required: true
  },
  medicineId: {
    type: mongoose.Schema.Types.ObjectId,
    ref: 'Medicine',
    required: true
  },
  scheduleId: {
    type: mongoose.Schema.Types.ObjectId,
    ref: 'ReminderSchedule',
    required: true
  },
  status: {
    type: String,
    enum: ['pending', 'taken', 'missed', 'skipped'],
    default: 'pending'
  },
  scheduledTime: {
    type: Date,
    required: true
  },
  responseTime: {
    type: Date
  },
  reminderCount: {
    type: Number,
    default: 0
  },
  notes: {
    type: String
  }
}, { timestamps: true });

doseLogSchema.index({ patientId: 1, scheduledTime: -1 });
doseLogSchema.index({ status: 1, scheduledTime: 1 });

module.exports = mongoose.model('DoseLog', doseLogSchema);
