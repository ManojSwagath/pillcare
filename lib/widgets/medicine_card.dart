import 'package:flutter/material.dart';
import '../models/medicine.dart';
import '../utils/app_colors.dart';
import '../utils/app_text_styles.dart';
import 'status_badge.dart';

class MedicineCard extends StatelessWidget {
  final Medicine medicine;
  final VoidCallback? onTap;
  final bool showStatus;
  final bool isCompact;

  const MedicineCard({
    super.key,
    required this.medicine,
    this.onTap,
    this.showStatus = true,
    this.isCompact = false,
  });

  Color get timeColor {
    switch (medicine.timeOfDay) {
      case MedicineTimeOfDay.morning:
        return AppColors.morningColor;
      case MedicineTimeOfDay.afternoon:
        return AppColors.afternoonColor;
      case MedicineTimeOfDay.evening:
        return AppColors.eveningColor;
      case MedicineTimeOfDay.night:
        return AppColors.nightColor;
    }
  }

  IconData get timeIcon {
    switch (medicine.timeOfDay) {
      case MedicineTimeOfDay.morning:
        return Icons.wb_sunny;
      case MedicineTimeOfDay.afternoon:
        return Icons.wb_cloudy;
      case MedicineTimeOfDay.evening:
        return Icons.wb_twilight;
      case MedicineTimeOfDay.night:
        return Icons.nightlight_round;
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: AppColors.cardShadow,
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: Row(
            children: [
              Container(
                width: 8,
                height: isCompact ? 100 : 140,
                color: timeColor,
              ),
              Expanded(
                child: Padding(
                  padding: EdgeInsets.all(isCompact ? 16 : 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Text(
                              medicine.name,
                              style: isCompact
                                  ? AppTextStyles.bodyLarge.copyWith(
                                      fontWeight: FontWeight.bold,
                                    )
                                  : AppTextStyles.heading3,
                            ),
                          ),
                          if (showStatus) StatusBadge(status: medicine.status),
                        ],
                      ),
                      SizedBox(height: isCompact ? 8 : 12),
                      Text(
                        medicine.dosage,
                        style: AppTextStyles.bodyMedium.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                      SizedBox(height: isCompact ? 8 : 12),
                      Row(
                        children: [
                          Icon(timeIcon, color: timeColor, size: 24),
                          const SizedBox(width: 8),
                          Text(
                            medicine.time,
                            style: AppTextStyles.bodyLarge.copyWith(
                              color: timeColor,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              if (onTap != null)
                Padding(
                  padding: const EdgeInsets.only(right: 16),
                  child: Icon(
                    Icons.chevron_right,
                    color: AppColors.textLight,
                    size: 32,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
