const mongoose = require('mongoose');

const medicineSchema = new mongoose.Schema({
  patientId: {
    type: mongoose.Schema.Types.ObjectId,
    ref: 'User',
    required: true
  },
  name: {
    type: String,
    required: [true, 'Medicine name is required'],
    trim: true
  },
  dosage: {
    type: String,
    required: [true, 'Dosage is required']
  },
  unit: {
    type: String,
    enum: ['mg', 'ml', 'tablet', 'capsule', 'drops'],
    default: 'tablet'
  },
  color: {
    type: String,
    default: '#4A90E2'
  },
  image: {
    type: String
  },
  instructions: {
    type: String
  },
  sideEffects: {
    type: String
  },
  stockCount: {
    type: Number,
    default: 0
  },
  lowStockThreshold: {
    type: Number,
    default: 5
  },
  isActive: {
    type: Boolean,
    default: true
  }
}, { timestamps: true });

module.exports = mongoose.model('Medicine', medicineSchema);
