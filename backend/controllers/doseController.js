const { DoseLog, AlertHistory, CaregiverLink } = require('../models');

exports.respondToDose = async (req, res, next) => {
  try {
    const { doseLogId, status, notes } = req.body;

    const doseLog = await DoseLog.findOneAndUpdate(
      { _id: doseLogId, patientId: req.user.id },
      {
        status,
        responseTime: new Date(),
        notes
      },
      { new: true }
    ).populate('medicineId', 'name dosage');

    if (!doseLog) {
      return res.status(404).json({
        success: false,
        message: 'Dose log not found'
      });
    }

    // Emit socket event
    const io = req.app.get('io');
    if (io) {
      io.to(`patient_${req.user.id}`).emit('dose_update', {
        doseLogId: doseLog._id,
        status: doseLog.status,
        medicineName: doseLog.medicineId.name
      });

      // Notify caregivers
      const caregiverLinks = await CaregiverLink.find({
        patientId: req.user.id,
        status: 'active'
      });

      caregiverLinks.forEach(link => {
        io.to(`caregiver_${link.caregiverId}`).emit('patient_dose_update', {
          patientId: req.user.id,
          doseLogId: doseLog._id,
          status: doseLog.status,
          medicineName: doseLog.medicineId.name
        });
      });
    }

    // Create alert if skipped/missed
    if (status === 'skipped' || status === 'missed') {
      const caregiverLinks = await CaregiverLink.find({
        patientId: req.user.id,
        status: 'active',
        'permissions.receiveAlerts': true
      });

      for (const link of caregiverLinks) {
        await AlertHistory.create({
          patientId: req.user.id,
          caregiverId: link.caregiverId,
          doseLogId: doseLog._id,
          alertType: status === 'missed' ? 'missed_dose' : 'no_response',
          message: `Patient ${status} ${doseLog.medicineId.name}`,
          severity: 'high'
        });
      }
    }

    res.json({
      success: true,
      data: doseLog
    });
  } catch (error) {
    next(error);
  }
};

exports.getDoseHistory = async (req, res, next) => {
  try {
    const { page = 1, limit = 20, status } = req.query;
    
    const query = { patientId: req.user.id };
    if (status) query.status = status;

    const doseLogs = await DoseLog.find(query)
      .populate('medicineId', 'name dosage color')
      .sort({ scheduledTime: -1 })
      .skip((page - 1) * limit)
      .limit(parseInt(limit));

    const total = await DoseLog.countDocuments(query);

    res.json({
      success: true,
      count: doseLogs.length,
      total,
      pages: Math.ceil(total / limit),
      data: doseLogs
    });
  } catch (error) {
    next(error);
  }
};

exports.getTodayDoses = async (req, res, next) => {
  try {
    const today = new Date();
    const startOfDay = new Date(today.setHours(0, 0, 0, 0));
    const endOfDay = new Date(today.setHours(23, 59, 59, 999));

    const doseLogs = await DoseLog.find({
      patientId: req.user.id,
      scheduledTime: { $gte: startOfDay, $lte: endOfDay }
    })
    .populate('medicineId', 'name dosage color instructions')
    .populate('scheduleId', 'time timeOfDay mealInstruction notes')
    .sort({ scheduledTime: 1 });

    res.json({
      success: true,
      count: doseLogs.length,
      data: doseLogs
    });
  } catch (error) {
    next(error);
  }
};

exports.getAdherenceStats = async (req, res, next) => {
  try {
    const { days = 7 } = req.query;
    const startDate = new Date();
    startDate.setDate(startDate.getDate() - parseInt(days));

    const doseLogs = await DoseLog.find({
      patientId: req.user.id,
      scheduledTime: { $gte: startDate }
    });

    const total = doseLogs.length;
    const taken = doseLogs.filter(d => d.status === 'taken').length;
    const missed = doseLogs.filter(d => d.status === 'missed').length;
    const skipped = doseLogs.filter(d => d.status === 'skipped').length;
    const pending = doseLogs.filter(d => d.status === 'pending').length;

    const adherenceRate = total > 0 ? Math.round((taken / (total - pending)) * 100) : 0;

    res.json({
      success: true,
      data: {
        total,
        taken,
        missed,
        skipped,
        pending,
        adherenceRate,
        period: `${days} days`
      }
    });
  } catch (error) {
    next(error);
  }
};
