const { CaregiverLink, User, DoseLog, AlertHistory, PatientProfile } = require('../models');

exports.linkPatient = async (req, res, next) => {
  try {
    const { patientEmail } = req.body;

    const patient = await User.findOne({ email: patientEmail, role: 'patient' });
    if (!patient) {
      return res.status(404).json({
        success: false,
        message: 'Patient not found'
      });
    }

    const existingLink = await CaregiverLink.findOne({
      patientId: patient._id,
      caregiverId: req.user.id
    });

    if (existingLink) {
      return res.status(400).json({
        success: false,
        message: 'Already linked to this patient'
      });
    }

    const link = await CaregiverLink.create({
      patientId: patient._id,
      caregiverId: req.user.id
    });

    res.status(201).json({
      success: true,
      data: link
    });
  } catch (error) {
    next(error);
  }
};

exports.getPatients = async (req, res, next) => {
  try {
    const links = await CaregiverLink.find({
      caregiverId: req.user.id,
      status: 'active'
    }).populate('patientId', 'name email phone');

    const patientsWithStats = await Promise.all(
      links.map(async (link) => {
        const today = new Date();
        const startOfDay = new Date(today.setHours(0, 0, 0, 0));
        const endOfDay = new Date(today.setHours(23, 59, 59, 999));

        const todayDoses = await DoseLog.find({
          patientId: link.patientId._id,
          scheduledTime: { $gte: startOfDay, $lte: endOfDay }
        });

        const profile = await PatientProfile.findOne({ userId: link.patientId._id });

        return {
          ...link.toObject(),
          profile,
          todayStats: {
            total: todayDoses.length,
            taken: todayDoses.filter(d => d.status === 'taken').length,
            missed: todayDoses.filter(d => d.status === 'missed').length,
            pending: todayDoses.filter(d => d.status === 'pending').length
          }
        };
      })
    );

    res.json({
      success: true,
      count: patientsWithStats.length,
      data: patientsWithStats
    });
  } catch (error) {
    next(error);
  }
};

exports.getPatientDetails = async (req, res, next) => {
  try {
    const { patientId } = req.params;

    const link = await CaregiverLink.findOne({
      patientId,
      caregiverId: req.user.id,
      status: 'active'
    });

    if (!link) {
      return res.status(403).json({
        success: false,
        message: 'Not authorized to view this patient'
      });
    }

    const patient = await User.findById(patientId).select('-password');
    const profile = await PatientProfile.findOne({ userId: patientId });

    const sevenDaysAgo = new Date();
    sevenDaysAgo.setDate(sevenDaysAgo.getDate() - 7);

    const recentDoses = await DoseLog.find({
      patientId,
      scheduledTime: { $gte: sevenDaysAgo }
    }).populate('medicineId', 'name dosage');

    const total = recentDoses.length;
    const taken = recentDoses.filter(d => d.status === 'taken').length;
    const adherenceRate = total > 0 ? Math.round((taken / total) * 100) : 0;

    res.json({
      success: true,
      data: {
        patient,
        profile,
        stats: {
          weeklyAdherence: adherenceRate,
          totalDoses: total,
          takenDoses: taken
        }
      }
    });
  } catch (error) {
    next(error);
  }
};

exports.getAlerts = async (req, res, next) => {
  try {
    const { unreadOnly } = req.query;
    
    const query = { caregiverId: req.user.id };
    if (unreadOnly === 'true') query.isRead = false;

    const alerts = await AlertHistory.find(query)
      .populate('patientId', 'name')
      .populate('doseLogId')
      .sort({ createdAt: -1 })
      .limit(50);

    res.json({
      success: true,
      count: alerts.length,
      data: alerts
    });
  } catch (error) {
    next(error);
  }
};

exports.markAlertRead = async (req, res, next) => {
  try {
    const alert = await AlertHistory.findOneAndUpdate(
      { _id: req.params.id, caregiverId: req.user.id },
      { isRead: true },
      { new: true }
    );

    if (!alert) {
      return res.status(404).json({
        success: false,
        message: 'Alert not found'
      });
    }

    res.json({
      success: true,
      data: alert
    });
  } catch (error) {
    next(error);
  }
};

exports.unlinkPatient = async (req, res, next) => {
  try {
    const link = await CaregiverLink.findOneAndUpdate(
      { patientId: req.params.patientId, caregiverId: req.user.id },
      { status: 'inactive' },
      { new: true }
    );

    if (!link) {
      return res.status(404).json({
        success: false,
        message: 'Link not found'
      });
    }

    res.json({
      success: true,
      message: 'Patient unlinked'
    });
  } catch (error) {
    next(error);
  }
};
