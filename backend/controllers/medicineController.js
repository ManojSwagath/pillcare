const { Medicine, ReminderSchedule } = require('../models');

exports.createMedicine = async (req, res, next) => {
  try {
    const medicine = await Medicine.create({
      ...req.body,
      patientId: req.user.id
    });

    res.status(201).json({
      success: true,
      data: medicine
    });
  } catch (error) {
    next(error);
  }
};

exports.getMedicines = async (req, res, next) => {
  try {
    const medicines = await Medicine.find({ 
      patientId: req.user.id,
      isActive: true 
    }).sort({ name: 1 });

    res.json({
      success: true,
      count: medicines.length,
      data: medicines
    });
  } catch (error) {
    next(error);
  }
};

exports.getMedicine = async (req, res, next) => {
  try {
    const medicine = await Medicine.findOne({
      _id: req.params.id,
      patientId: req.user.id
    });

    if (!medicine) {
      return res.status(404).json({
        success: false,
        message: 'Medicine not found'
      });
    }

    res.json({
      success: true,
      data: medicine
    });
  } catch (error) {
    next(error);
  }
};

exports.updateMedicine = async (req, res, next) => {
  try {
    const medicine = await Medicine.findOneAndUpdate(
      { _id: req.params.id, patientId: req.user.id },
      req.body,
      { new: true, runValidators: true }
    );

    if (!medicine) {
      return res.status(404).json({
        success: false,
        message: 'Medicine not found'
      });
    }

    res.json({
      success: true,
      data: medicine
    });
  } catch (error) {
    next(error);
  }
};

exports.deleteMedicine = async (req, res, next) => {
  try {
    const medicine = await Medicine.findOneAndUpdate(
      { _id: req.params.id, patientId: req.user.id },
      { isActive: false },
      { new: true }
    );

    if (!medicine) {
      return res.status(404).json({
        success: false,
        message: 'Medicine not found'
      });
    }

    await ReminderSchedule.updateMany(
      { medicineId: req.params.id },
      { isActive: false }
    );

    res.json({
      success: true,
      message: 'Medicine deleted'
    });
  } catch (error) {
    next(error);
  }
};
