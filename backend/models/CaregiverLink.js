const mongoose = require('mongoose');

const caregiverLinkSchema = new mongoose.Schema({
  patientId: {
    type: mongoose.Schema.Types.ObjectId,
    ref: 'User',
    required: true
  },
  caregiverId: {
    type: mongoose.Schema.Types.ObjectId,
    ref: 'User',
    required: true
  },
  status: {
    type: String,
    enum: ['pending', 'active', 'inactive'],
    default: 'active'
  },
  permissions: {
    viewMedicines: { type: Boolean, default: true },
    viewHistory: { type: Boolean, default: true },
    receiveAlerts: { type: Boolean, default: true },
    manageMedicines: { type: Boolean, default: false }
  }
}, { timestamps: true });

caregiverLinkSchema.index({ patientId: 1, caregiverId: 1 }, { unique: true });

module.exports = mongoose.model('CaregiverLink', caregiverLinkSchema);
