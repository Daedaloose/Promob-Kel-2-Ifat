import 'package:flutter/material.dart';

class AppColors {
  // Primary sage green palette (from reference)
  static const Color sageLight = Color(0xFFD4E8D8);
  static const Color sageMedium = Color(0xFFB5D5C5);
  static const Color sageDark = Color(0xFF8BBF9F);
  static const Color sageDeep = Color(0xFF5A9E7A);

  // Background
  static const Color backgroundGreen = Color(0xFFCFE3D4);
  static const Color backgroundCream = Color(0xFFF5EFE8);
  static const Color cardWhite = Color(0xFFFFFFFF);
  static const Color cardGreen = Color(0xFFE8F3EB);

  // Text colors
  static const Color textDark = Color(0xFF1A1A1A);
  static const Color textDarkBrown = Color(0xFF2D2D2D);
  static const Color textGrey = Color(0xFF8A8A8A);
  static const Color textLight = Color(0xFFB0B0B0);

  // Accent colors
  static const Color accentOrange = Color(0xFFE8834A);
  static const Color accentOrangeLight = Color(0xFFF5A96B);
  static const Color accentPink = Color(0xFFE8A5A5);
  static const Color accentYellow = Color(0xFFF5D77A);

  // Dark elements
  static const Color darkButton = Color(0xFF1A1A1A);
  static const Color darkCard = Color(0xFF2A2A2A);

  // Navigation
  static const Color navBackground = Color(0xFF1A1A1A);
}

class AppTextStyles {
  static const String fontFamily = 'Nunito';

  static const TextStyle heading1 = TextStyle(
    fontFamily: fontFamily,
    fontSize: 36,
    fontWeight: FontWeight.w900,
    color: AppColors.textDark,
    height: 1.1,
    letterSpacing: -0.5,
  );

  static const TextStyle heading2 = TextStyle(
    fontFamily: fontFamily,
    fontSize: 28,
    fontWeight: FontWeight.w800,
    color: AppColors.textDark,
    height: 1.2,
  );

  static const TextStyle heading3 = TextStyle(
    fontFamily: fontFamily,
    fontSize: 22,
    fontWeight: FontWeight.w700,
    color: AppColors.textDark,
    height: 1.3,
  );

  static const TextStyle body = TextStyle(
    fontFamily: fontFamily,
    fontSize: 15,
    fontWeight: FontWeight.w400,
    color: AppColors.textGrey,
    height: 1.5,
  );

  static const TextStyle bodyBold = TextStyle(
    fontFamily: fontFamily,
    fontSize: 15,
    fontWeight: FontWeight.w700,
    color: AppColors.textDark,
  );

  static const TextStyle caption = TextStyle(
    fontFamily: fontFamily,
    fontSize: 12,
    fontWeight: FontWeight.w400,
    color: AppColors.textLight,
  );

  static const TextStyle button = TextStyle(
    fontFamily: fontFamily,
    fontSize: 16,
    fontWeight: FontWeight.w800,
    color: Colors.white,
    letterSpacing: 0.5,
  );
}
