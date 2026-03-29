const { PatientProfile } = require('../models');

exports.getProfile = async (req, res, next) => {
  try {
    let profile = await PatientProfile.findOne({ userId: req.user.id });
    
    if (!profile) {
      profile = await PatientProfile.create({ userId: req.user.id });
    }

    res.json({
      success: true,
      data: profile
    });
  } catch (error) {
    next(error);
  }
};

exports.updateProfile = async (req, res, next) => {
  try {
    const allowedFields = [
      'age', 'dateOfBirth', 'gender', 'language',
      'emergencyContact', 'medicalConditions', 'allergies'
    ];

    const updates = {};
    allowedFields.forEach(field => {
      if (req.body[field] !== undefined) {
        updates[field] = req.body[field];
      }
    });

    const profile = await PatientProfile.findOneAndUpdate(
      { userId: req.user.id },
      updates,
      { new: true, upsert: true, runValidators: true }
    );

    res.json({
      success: true,
      data: profile
    });
  } catch (error) {
    next(error);
  }
};
