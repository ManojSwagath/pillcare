import 'package:flutter/material.dart';
import '../models/medicine.dart';
import '../utils/app_colors.dart';
import '../utils/app_text_styles.dart';

class StatusBadge extends StatelessWidget {
  final MedicineStatus status;
  final double fontSize;

  const StatusBadge({
    super.key,
    required this.status,
    this.fontSize = 14,
  });

  Color get backgroundColor {
    switch (status) {
      case MedicineStatus.taken:
        return AppColors.success;
      case MedicineStatus.pending:
        return AppColors.warning;
      case MedicineStatus.missed:
        return AppColors.danger;
      case MedicineStatus.skipped:
        return AppColors.textSecondary;
    }
  }

  String get text {
    switch (status) {
      case MedicineStatus.taken:
        return 'TAKEN';
      case MedicineStatus.pending:
        return 'PENDING';
      case MedicineStatus.missed:
        return 'MISSED';
      case MedicineStatus.skipped:
        return 'SKIPPED';
    }
  }

  IconData get icon {
    switch (status) {
      case MedicineStatus.taken:
        return Icons.check_circle;
      case MedicineStatus.pending:
        return Icons.schedule;
      case MedicineStatus.missed:
        return Icons.cancel;
      case MedicineStatus.skipped:
        return Icons.skip_next;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: backgroundColor.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: backgroundColor, width: 1.5),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: backgroundColor, size: fontSize + 4),
          const SizedBox(width: 6),
          Text(
            text,
            style: AppTextStyles.caption.copyWith(
              color: backgroundColor,
              fontWeight: FontWeight.bold,
              fontSize: fontSize,
            ),
          ),
        ],
      ),
    );
  }
}
