import 'package:flutter/material.dart';
import '../models/medicine.dart';
import '../utils/app_colors.dart';
import '../utils/app_text_styles.dart';
import '../widgets/big_button.dart';

class ReminderPopup extends StatefulWidget {
  final Medicine medicine;
  final VoidCallback onTaken;
  final VoidCallback onNotTaken;

  const ReminderPopup({
    super.key,
    required this.medicine,
    required this.onTaken,
    required this.onNotTaken,
  });

  @override
  State<ReminderPopup> createState() => _ReminderPopupState();
}

class _ReminderPopupState extends State<ReminderPopup>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _fadeAnimation;

  Color get timeColor {
    switch (widget.medicine.timeOfDay) {
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
    switch (widget.medicine.timeOfDay) {
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
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOutBack),
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOut),
    );

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _handleTaken() {
    _controller.reverse().then((_) {
      Navigator.of(context).pop();
      widget.onTaken();
    });
  }

  void _handleNotTaken() {
    _controller.reverse().then((_) {
      Navigator.of(context).pop();
      widget.onNotTaken();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          return Container(
            color: Colors.black.withValues(alpha: 0.85 * _fadeAnimation.value),
            child: SafeArea(
              child: Transform.scale(
                scale: _scaleAnimation.value,
                child: Opacity(
                  opacity: _fadeAnimation.value,
                  child: child,
                ),
              ),
            ),
          );
        },
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const SizedBox(height: 40),
                    Container(
                      width: 160,
                      height: 160,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.primary.withValues(alpha: 0.4),
                            blurRadius: 40,
                            spreadRadius: 10,
                          ),
                        ],
                      ),
                      child: Icon(
                        Icons.medication,
                        size: 80,
                        color: AppColors.primary,
                      ),
                    ),
                    const SizedBox(height: 40),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 12,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(30),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.notifications_active,
                              color: Colors.white, size: 24),
                          const SizedBox(width: 12),
                          Text(
                            'Time for your medicine!',
                            style: AppTextStyles.bodyLarge.copyWith(
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 32),
                    Text(
                      widget.medicine.name,
                      style: AppTextStyles.heading1.copyWith(
                        color: Colors.white,
                        fontSize: 44,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 20),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 28,
                        vertical: 16,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        widget.medicine.dosage,
                        style: AppTextStyles.heading3.copyWith(
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ),
                    const SizedBox(height: 32),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(timeIcon, color: timeColor, size: 40),
                        const SizedBox(width: 16),
                        Text(
                          widget.medicine.time,
                          style: AppTextStyles.heading1.copyWith(
                            color: timeColor,
                          ),
                        ),
                      ],
                    ),
                    if (widget.medicine.notes != null) ...[
                      const SizedBox(height: 32),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(24),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: Colors.white.withValues(alpha: 0.2),
                          ),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              Icons.lightbulb_outline,
                              color: AppColors.warning,
                              size: 32,
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Text(
                                widget.medicine.notes!,
                                style: AppTextStyles.bodyLarge.copyWith(
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                    const SizedBox(height: 48),
                  ],
                ),
              ),
            ),
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(32),
                  topRight: Radius.circular(32),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black26,
                    blurRadius: 20,
                    offset: const Offset(0, -4),
                  ),
                ],
              ),
              child: SafeArea(
                top: false,
                child: Column(
                  children: [
                    BigButton(
                      text: 'TAKEN',
                      icon: Icons.check_circle,
                      backgroundColor: AppColors.success,
                      onPressed: _handleTaken,
                      height: 88,
                    ),
                    const SizedBox(height: 16),
                    BigButton(
                      text: 'NOT TAKEN',
                      icon: Icons.cancel,
                      backgroundColor: AppColors.danger,
                      onPressed: _handleNotTaken,
                      height: 88,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
