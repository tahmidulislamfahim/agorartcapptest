import 'package:flutter/material.dart';
import 'package:agorartcapptest/core/constants/app_color.dart';

class AppStyle {
  static BoxDecoration glassDecoration({
    double borderRadius = 16.0,
    Color bgColor = AppColor.cardBg,
    Color borderColor = AppColor.cardBorder,
  }) {
    return BoxDecoration(
      color: bgColor,
      borderRadius: BorderRadius.circular(borderRadius),
      border: Border.all(color: borderColor, width: 1.0),
      boxShadow: const [
        BoxShadow(
          color: AppColor.shadowBlack,
          blurRadius: 10,
          offset: Offset(0, 4),
        ),
      ],
    );
  }

  static BoxDecoration bgGradientDecoration = const BoxDecoration(
    gradient: RadialGradient(
      center: Alignment(-0.8, -0.8),
      radius: 1.2,
      colors: [
        AppColor.bgGradientStart,
        AppColor.bgGradientEnd,
      ],
    ),
  );
}
