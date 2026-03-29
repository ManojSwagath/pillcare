import '../models/medicine.dart';
import '../models/dose_history.dart';

class MockData {
  static List<Medicine> getTodayMedicines() {
    return [
      Medicine(
        id: '1',
        name: 'Paracetamol',
        dosage: '500mg - 1 Tablet',
        time: '8:00 AM',
        timeOfDay: MedicineTimeOfDay.morning,
        status: MedicineStatus.taken,
        notes: 'Take with water after breakfast',
      ),
      Medicine(
        id: '2',
        name: 'Metformin',
        dosage: '850mg - 1 Tablet',
        time: '1:00 PM',
        timeOfDay: MedicineTimeOfDay.afternoon,
        status: MedicineStatus.pending,
        notes: 'Take with lunch',
      ),
      Medicine(
        id: '3',
        name: 'Amlodipine',
        dosage: '5mg - 1 Tablet',
        time: '8:00 PM',
        timeOfDay: MedicineTimeOfDay.evening,
        status: MedicineStatus.pending,
        notes: 'Take before dinner',
      ),
      Medicine(
        id: '4',
        name: 'Omeprazole',
        dosage: '20mg - 1 Capsule',
        time: '10:00 PM',
        timeOfDay: MedicineTimeOfDay.night,
        status: MedicineStatus.pending,
        notes: 'Take before bedtime',
      ),
    ];
  }

  static List<Medicine> getAllMedicines() {
    return [
      Medicine(
        id: '1',
        name: 'Paracetamol',
        dosage: '500mg - 1 Tablet',
        time: '8:00 AM',
        timeOfDay: MedicineTimeOfDay.morning,
        notes: 'Pain reliever and fever reducer',
      ),
      Medicine(
        id: '2',
        name: 'Metformin',
        dosage: '850mg - 1 Tablet',
        time: '1:00 PM',
        timeOfDay: MedicineTimeOfDay.afternoon,
        notes: 'Diabetes management',
      ),
      Medicine(
        id: '3',
        name: 'Amlodipine',
        dosage: '5mg - 1 Tablet',
        time: '8:00 PM',
        timeOfDay: MedicineTimeOfDay.evening,
        notes: 'Blood pressure control',
      ),
      Medicine(
        id: '4',
        name: 'Omeprazole',
        dosage: '20mg - 1 Capsule',
        time: '10:00 PM',
        timeOfDay: MedicineTimeOfDay.night,
        notes: 'Acid reflux treatment',
      ),
      Medicine(
        id: '5',
        name: 'Vitamin D3',
        dosage: '1000 IU - 1 Tablet',
        time: '9:00 AM',
        timeOfDay: MedicineTimeOfDay.morning,
        notes: 'Bone health supplement',
      ),
    ];
  }

  static List<DoseHistory> getDoseHistory() {
    final now = DateTime.now();
    return [
      DoseHistory(
        id: '1',
        medicineName: 'Paracetamol',
        dosage: '500mg',
        scheduledTime: now.subtract(const Duration(hours: 4)),
        takenTime: now.subtract(const Duration(hours: 4)),
        status: MedicineStatus.taken,
      ),
      DoseHistory(
        id: '2',
        medicineName: 'Metformin',
        dosage: '850mg',
        scheduledTime: now.subtract(const Duration(hours: 8)),
        takenTime: now.subtract(const Duration(hours: 7, minutes: 45)),
        status: MedicineStatus.taken,
      ),
      DoseHistory(
        id: '3',
        medicineName: 'Amlodipine',
        dosage: '5mg',
        scheduledTime: now.subtract(const Duration(days: 1)),
        status: MedicineStatus.missed,
      ),
      DoseHistory(
        id: '4',
        medicineName: 'Omeprazole',
        dosage: '20mg',
        scheduledTime: now.subtract(const Duration(days: 1, hours: 2)),
        takenTime: now.subtract(const Duration(days: 1, hours: 2)),
        status: MedicineStatus.taken,
      ),
      DoseHistory(
        id: '5',
        medicineName: 'Vitamin D3',
        dosage: '1000 IU',
        scheduledTime: now.subtract(const Duration(days: 1, hours: 8)),
        status: MedicineStatus.skipped,
      ),
      DoseHistory(
        id: '6',
        medicineName: 'Paracetamol',
        dosage: '500mg',
        scheduledTime: now.subtract(const Duration(days: 2)),
        takenTime: now.subtract(const Duration(days: 2)),
        status: MedicineStatus.taken,
      ),
    ];
  }

  static String getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) {
      return 'Good Morning';
    } else if (hour < 17) {
      return 'Good Afternoon';
    } else if (hour < 21) {
      return 'Good Evening';
    } else {
      return 'Good Night';
    }
  }

  static Map<String, dynamic> getCaregiverData() {
    return {
      'patientName': 'Margaret Johnson',
      'patientAge': 72,
      'adherenceRate': 85,
      'todayTaken': 2,
      'todayTotal': 4,
      'alerts': [
        {'type': 'missed', 'medicine': 'Amlodipine', 'time': 'Yesterday 8:00 PM'},
        {'type': 'low_stock', 'medicine': 'Metformin', 'remaining': 5},
      ],
    };
  }
}
