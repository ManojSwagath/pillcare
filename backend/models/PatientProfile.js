const mongoose = require('mongoose');

const patientProfileSchema = new mongoose.Schema({
  userId: {
    type: mongoose.Schema.Types.ObjectId,
    ref: 'User',
    required: true,
    unique: true
  },
  age: {
    type: Number,
    min: 1,
    max: 150
  },
  dateOfBirth: {
    type: Date
  },
  gender: {
    type: String,
    enum: ['male', 'female', 'other']
  },
  language: {
    type: String,
    default: 'en'
  },
  emergencyContact: {
    name: String,
    phone: String,
    relationship: String
  },
  medicalConditions: [{
    type: String
  }],
  allergies: [{
    type: String
  }]
}, { timestamps: true });

module.exports = mongoose.model('PatientProfile', patientProfileSchema);
