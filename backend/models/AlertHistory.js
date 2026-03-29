const mongoose = require('mongoose');

const alertHistorySchema = new mongoose.Schema({
  patientId: {
    type: mongoose.Schema.Types.ObjectId,
    ref: 'User',
    required: true
  },
  caregiverId: {
    type: mongoose.Schema.Types.ObjectId,
    ref: 'User'
  },
  doseLogId: {
    type: mongoose.Schema.Types.ObjectId,
    ref: 'DoseLog'
  },
  alertType: {
    type: String,
    enum: ['missed_dose', 'low_stock', 'no_response', 'emergency', 'reminder'],
    required: true
  },
  message: {
    type: String,
    required: true
  },
  severity: {
    type: String,
    enum: ['low', 'medium', 'high', 'critical'],
    default: 'medium'
  },
  isRead: {
    type: Boolean,
    default: false
  },
  notificationSent: {
    push: { type: Boolean, default: false },
    sms: { type: Boolean, default: false },
    email: { type: Boolean, default: false }
  }
}, { timestamps: true });

alertHistorySchema.index({ caregiverId: 1, isRead: 1 });
alertHistorySchema.index({ patientId: 1, createdAt: -1 });

module.exports = mongoose.model('AlertHistory', alertHistorySchema);
