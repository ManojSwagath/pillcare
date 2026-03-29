import 'package:flutter/material.dart';
import '../utils/app_colors.dart';
import '../utils/app_text_styles.dart';

class BigButton extends StatelessWidget {
  final String text;
  final IconData? icon;
  final Color backgroundColor;
  final Color textColor;
  final VoidCallback onPressed;
  final double height;
  final double? width;
  final bool isOutlined;

  const BigButton({
    super.key,
    required this.text,
    this.icon,
    required this.backgroundColor,
    this.textColor = Colors.white,
    required this.onPressed,
    this.height = 72,
    this.width,
    this.isOutlined = false,
  });

  factory BigButton.primary({
    required String text,
    IconData? icon,
    required VoidCallback onPressed,
    double height = 72,
    double? width,
  }) {
    return BigButton(
      text: text,
      icon: icon,
      backgroundColor: AppColors.primary,
      onPressed: onPressed,
      height: height,
      width: width,
    );
  }

  factory BigButton.success({
    required String text,
    IconData? icon,
    required VoidCallback onPressed,
    double height = 72,
    double? width,
  }) {
    return BigButton(
      text: text,
      icon: icon,
      backgroundColor: AppColors.success,
      onPressed: onPressed,
      height: height,
      width: width,
    );
  }

  factory BigButton.danger({
    required String text,
    IconData? icon,
    required VoidCallback onPressed,
    double height = 72,
    double? width,
  }) {
    return BigButton(
      text: text,
      icon: icon,
      backgroundColor: AppColors.danger,
      onPressed: onPressed,
      height: height,
      width: width,
    );
  }

  factory BigButton.outlined({
    required String text,
    IconData? icon,
    required VoidCallback onPressed,
    Color borderColor = AppColors.primary,
    double height = 72,
    double? width,
  }) {
    return BigButton(
      text: text,
      icon: icon,
      backgroundColor: borderColor,
      textColor: borderColor,
      onPressed: onPressed,
      height: height,
      width: width,
      isOutlined: true,
    );
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: height,
      width: width ?? double.infinity,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: isOutlined ? Colors.white : backgroundColor,
          foregroundColor: textColor,
          elevation: isOutlined ? 0 : 4,
          shadowColor: backgroundColor.withValues(alpha: 0.4),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: isOutlined
                ? BorderSide(color: backgroundColor, width: 2)
                : BorderSide.none,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (icon != null) ...[
              Icon(icon, size: 32, color: textColor),
              const SizedBox(width: 12),
            ],
            Text(
              text,
              style: AppTextStyles.buttonLarge.copyWith(color: textColor),
            ),
          ],
        ),
      ),
    );
  }
}
