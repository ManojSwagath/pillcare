import 'package:flutter/material.dart';
import '../models/medicine.dart';
import '../utils/app_colors.dart';
import '../utils/app_text_styles.dart';
import 'big_button.dart';

class ReminderModal extends StatelessWidget {
  final Medicine medicine;
  final VoidCallback onTaken;
  final VoidCallback onNotTaken;

  const ReminderModal({
    super.key,
    required this.medicine,
    required this.onTaken,
    required this.onNotTaken,
  });

  static Future<void> show(
    BuildContext context, {
    required Medicine medicine,
    required VoidCallback onTaken,
    required VoidCallback onNotTaken,
  }) {
    return showDialog(
      context: context,
      barrierDismissible: false,
      barrierColor: Colors.black87,
      builder: (context) => ReminderModal(
        medicine: medicine,
        onTaken: () {
          Navigator.of(context).pop();
          onTaken();
        },
        onNotTaken: () {
          Navigator.of(context).pop();
          onNotTaken();
        },
      ),
    );
  }

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

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.all(16),
      child: Container(
        width: double.infinity,
        constraints: const BoxConstraints(maxWidth: 400),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(32),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(32),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    AppColors.primary,
                    AppColors.primaryDark,
                  ],
                ),
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(32),
                  topRight: Radius.circular(32),
                ),
              ),
              child: Column(
                children: [
                  Container(
                    width: 100,
                    height: 100,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black26,
                          blurRadius: 20,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),
                    child: Icon(
                      Icons.medication,
                      size: 56,
                      color: AppColors.primary,
                    ),
                  ),
                  const SizedBox(height: 24),
                  Text(
                    '⏰ Time for your medicine!',
                    style: AppTextStyles.bodyLarge.copyWith(
                      color: Colors.white70,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(32),
              child: Column(
                children: [
                  Text(
                    medicine.name,
                    style: AppTextStyles.heading1.copyWith(
                      fontSize: 36,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 12,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.background,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Text(
                      medicine.dosage,
                      style: AppTextStyles.heading3.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.access_time_filled,
                        color: timeColor,
                        size: 32,
                      ),
                      const SizedBox(width: 12),
                      Text(
                        medicine.time,
                        style: AppTextStyles.heading2.copyWith(
                          color: timeColor,
                        ),
                      ),
                    ],
                  ),
                  if (medicine.notes != null) ...[
                    const SizedBox(height: 24),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withValues(alpha: 0.08),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: AppColors.primary.withValues(alpha: 0.2),
                        ),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.info_outline,
                            color: AppColors.primary,
                            size: 28,
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Text(
                              medicine.notes!,
                              style: AppTextStyles.bodyMedium.copyWith(
                                color: AppColors.textPrimary,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                  const SizedBox(height: 32),
                  BigButton.success(
                    text: 'TAKEN',
                    icon: Icons.check_circle,
                    onPressed: onTaken,
                    height: 80,
                  ),
                  const SizedBox(height: 16),
                  BigButton.danger(
                    text: 'NOT TAKEN',
                    icon: Icons.cancel,
                    onPressed: onNotTaken,
                    height: 80,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
