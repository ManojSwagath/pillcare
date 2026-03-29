const mongoose = require('mongoose');

const reminderScheduleSchema = new mongoose.Schema({
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
  time: {
    type: String,
    required: [true, 'Time is required']
  },
  timeOfDay: {
    type: String,
    enum: ['morning', 'afternoon', 'evening', 'night'],
    required: true
  },
  repeatType: {
    type: String,
    enum: ['daily', 'weekly', 'monthly', 'custom'],
    default: 'daily'
  },
  daysOfWeek: [{
    type: Number,
    min: 0,
    max: 6
  }],
  mealInstruction: {
    type: String,
    enum: ['before_meal', 'after_meal', 'with_meal', 'empty_stomach', 'any'],
    default: 'any'
  },
  notes: {
    type: String
  },
  isActive: {
    type: Boolean,
    default: true
  },
  startDate: {
    type: Date,
    default: Date.now
  },
  endDate: {
    type: Date
  }
}, { timestamps: true });

reminderScheduleSchema.index({ patientId: 1, time: 1 });

module.exports = mongoose.model('ReminderSchedule', reminderScheduleSchema);
