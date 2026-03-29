require('dotenv').config();
const mongoose = require('mongoose');
const bcrypt = require('bcryptjs');
const connectDB = require('../config/db');
const {
  User,
  PatientProfile,
  CaregiverLink,
  Medicine,
  ReminderSchedule
} = require('../models');

const seedData = async () => {
  try {
    await connectDB();

    // Clear existing data
    await User.deleteMany({});
    await PatientProfile.deleteMany({});
    await CaregiverLink.deleteMany({});
    await Medicine.deleteMany({});
    await ReminderSchedule.deleteMany({});

    console.log('Cleared existing data');

    // Create patient
    const patient = await User.create({
      name: 'Margaret Johnson',
      email: 'patient@pillcare.com',
      password: 'password123',
      role: 'patient',
      phone: '+1234567890'
    });

    // Create patient profile
    await PatientProfile.create({
      userId: patient._id,
      age: 72,
      gender: 'female',
      language: 'en',
      emergencyContact: {
        name: 'John Johnson',
        phone: '+1987654321',
        relationship: 'Son'
      },
      medicalConditions: ['Diabetes', 'Hypertension'],
      allergies: ['Penicillin']
    });

    // Create caregiver
    const caregiver = await User.create({
      name: 'John Johnson',
      email: 'caregiver@pillcare.com',
      password: 'password123',
      role: 'caregiver',
      phone: '+1987654321'
    });

    // Link caregiver to patient
    await CaregiverLink.create({
      patientId: patient._id,
      caregiverId: caregiver._id,
      status: 'active',
      permissions: {
        viewMedicines: true,
        viewHistory: true,
        receiveAlerts: true,
        manageMedicines: true
      }
    });

    // Create medicines
    const paracetamol = await Medicine.create({
      patientId: patient._id,
      name: 'Paracetamol',
      dosage: '500mg - 1 Tablet',
      unit: 'tablet',
      color: '#F39C12',
      instructions: 'Take with water after breakfast',
      stockCount: 30
    });

    const metformin = await Medicine.create({
      patientId: patient._id,
      name: 'Metformin',
      dosage: '850mg - 1 Tablet',
      unit: 'tablet',
      color: '#4A90E2',
      instructions: 'Take with lunch for blood sugar control',
      stockCount: 25
    });

    const amlodipine = await Medicine.create({
      patientId: patient._id,
      name: 'Amlodipine',
      dosage: '5mg - 1 Tablet',
      unit: 'tablet',
      color: '#9B59B6',
      instructions: 'Take before dinner for blood pressure',
      stockCount: 20
    });

    const omeprazole = await Medicine.create({
      patientId: patient._id,
      name: 'Omeprazole',
      dosage: '20mg - 1 Capsule',
      unit: 'capsule',
      color: '#34495E',
      instructions: 'Take before bedtime on empty stomach',
      stockCount: 15
    });

    // Create schedules
    await ReminderSchedule.create({
      patientId: patient._id,
      medicineId: paracetamol._id,
      time: '8:00 AM',
      timeOfDay: 'morning',
      repeatType: 'daily',
      mealInstruction: 'after_meal',
      notes: 'Take with water after breakfast'
    });

    await ReminderSchedule.create({
      patientId: patient._id,
      medicineId: metformin._id,
      time: '1:00 PM',
      timeOfDay: 'afternoon',
      repeatType: 'daily',
      mealInstruction: 'with_meal',
      notes: 'Take with lunch'
    });

    await ReminderSchedule.create({
      patientId: patient._id,
      medicineId: amlodipine._id,
      time: '8:00 PM',
      timeOfDay: 'evening',
      repeatType: 'daily',
      mealInstruction: 'before_meal',
      notes: 'Take before dinner'
    });

    await ReminderSchedule.create({
      patientId: patient._id,
      medicineId: omeprazole._id,
      time: '10:00 PM',
      timeOfDay: 'night',
      repeatType: 'daily',
      mealInstruction: 'empty_stomach',
      notes: 'Take before bedtime'
    });

    console.log('Seed data created successfully!');
    console.log('\nTest accounts:');
    console.log('Patient: patient@pillcare.com / password123');
    console.log('Caregiver: caregiver@pillcare.com / password123');

    process.exit(0);
  } catch (error) {
    console.error('Seed error:', error);
    process.exit(1);
  }
};

seedData();
