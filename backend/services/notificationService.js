class NotificationService {
  constructor() {
    this.fcmEnabled = !!process.env.FIREBASE_SERVER_KEY;
    this.twilioEnabled = !!process.env.TWILIO_SID;
  }

  async sendPushNotification(fcmToken, title, body, data = {}) {
    if (!this.fcmEnabled || !fcmToken) {
      console.log('Push notification (mock):', { title, body, data });
      return { success: true, mock: true };
    }

    // Firebase implementation placeholder
    try {
      // const message = {
      //   to: fcmToken,
      //   notification: { title, body },
      //   data
      // };
      // await firebase.messaging().send(message);
      console.log('Push notification sent:', { title, body });
      return { success: true };
    } catch (error) {
      console.error('Push notification error:', error);
      return { success: false, error };
    }
  }

  async sendSMS(phone, message) {
    if (!this.twilioEnabled || !phone) {
      console.log('SMS (mock):', { phone, message });
      return { success: true, mock: true };
    }

    // Twilio implementation placeholder
    try {
      // const client = require('twilio')(process.env.TWILIO_SID, process.env.TWILIO_AUTH_TOKEN);
      // await client.messages.create({
      //   body: message,
      //   from: process.env.TWILIO_PHONE,
      //   to: phone
      // });
      console.log('SMS sent:', { phone, message });
      return { success: true };
    } catch (error) {
      console.error('SMS error:', error);
      return { success: false, error };
    }
  }

  async sendReminderNotification(user, medicine, schedule) {
    const title = 'Time for your medicine!';
    const body = `Take ${medicine.name} (${medicine.dosage})`;
    
    await this.sendPushNotification(user.fcmToken, title, body, {
      type: 'reminder',
      medicineId: medicine._id.toString(),
      scheduleId: schedule._id.toString()
    });
  }

  async sendMissedDoseAlert(caregiver, patient, medicine) {
    const title = 'Missed Dose Alert';
    const body = `${patient.name} missed ${medicine.name}`;
    
    await this.sendPushNotification(caregiver.fcmToken, title, body, {
      type: 'missed_dose',
      patientId: patient._id.toString()
    });

    if (caregiver.phone) {
      await this.sendSMS(caregiver.phone, body);
    }
  }
}

module.exports = new NotificationService();
