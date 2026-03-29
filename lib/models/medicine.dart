enum MedicineStatus { pending, taken, missed, skipped }

enum MedicineTimeOfDay { morning, afternoon, evening, night }

class Medicine {
  final String id;
  final String name;
  final String dosage;
  final String time;
  final MedicineTimeOfDay timeOfDay;
  final MedicineStatus status;
  final String? notes;
  final String? imageAsset;

  Medicine({
    required this.id,
    required this.name,
    required this.dosage,
    required this.time,
    required this.timeOfDay,
    this.status = MedicineStatus.pending,
    this.notes,
    this.imageAsset,
  });

  Medicine copyWith({
    String? id,
    String? name,
    String? dosage,
    String? time,
    MedicineTimeOfDay? timeOfDay,
    MedicineStatus? status,
    String? notes,
    String? imageAsset,
  }) {
    return Medicine(
      id: id ?? this.id,
      name: name ?? this.name,
      dosage: dosage ?? this.dosage,
      time: time ?? this.time,
      timeOfDay: timeOfDay ?? this.timeOfDay,
      status: status ?? this.status,
      notes: notes ?? this.notes,
      imageAsset: imageAsset ?? this.imageAsset,
    );
  }
}
