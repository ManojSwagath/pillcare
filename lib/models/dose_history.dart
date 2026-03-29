import 'medicine.dart';

class DoseHistory {
  final String id;
  final String medicineName;
  final String dosage;
  final DateTime scheduledTime;
  final DateTime? takenTime;
  final MedicineStatus status;

  DoseHistory({
    required this.id,
    required this.medicineName,
    required this.dosage,
    required this.scheduledTime,
    this.takenTime,
    required this.status,
  });
}
