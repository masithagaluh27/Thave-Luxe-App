// app_color.dart
import 'package:flutter/material.dart';

class AppColors {
  // Main colors
  static const Color primaryGold = Color(0xFFD4AF37);
  static const Color darkBackground = Color(0xFF1A1A1A);
  static const Color lightText = Color(0xFFFFFFFF);
  static const Color subtleGrey = Color(0xFFAAAAAA);

  // Home Screen specific colors (adjusting for consistency)
  static const Color backgroundLight = Color(0xFFF5F5F5);
  // Renamed/Reassigned backgroundGradientEnd for clarity in light theme
  static const Color backgroundGradientLight = Color(0xFFE0E0E0);
  static const Color textDark = Color(0xFF333333);
  static const Color subtleText = Color(0xFF757575);
  static const Color searchBarBackground = Color(0xFFE0E0E0);
  static const Color searchBarBorder = Color(0xFFBDBDBD);
  // Reassigned cardBackgroundLight to general cardBackground
  static const Color imagePlaceholderLight = Color(0xFFEEEEEE);
  static const Color accentGrey = Color(0xFF9E9E9E);
  static const Color cardBackgroundDark = Color(0xFF2C2C2C);
  static const Color shadowColor = Color(
    0x1A000000,
  ); // Added for consistent shadows (10% black opacity)

  // Status/Action colors
  static const Color errorRed = Color.fromARGB(255, 238, 6, 6);
  static const Color redAccent = Color(0xFFE57373);
  static const Color green = Color(0xFF66BB6A); // Used for discounts now
  static const Color blue = Color(0xFF42A5F5);
  static const Color orange = Color(0xFFFF9800);

  // --- NEW COLORS ADDED BELOW ---

  // Dark Theme UI Enhancements
  static const Color backgroundGradientStartDark = Color(
    0xFF121212,
  ); // Slightly darker start for gradients
  static const Color borderGold = Color(
    0xFFB8860B,
  ); // A slightly darker, richer gold for borders/accents
  static const Color dividerDark = Color(
    0xFF424242,
  ); // For subtle dividers in dark mode
  static const Color iconColorDark = Color(
    0xFFE0E0E0,
  ); // General icon color for dark backgrounds (original from app_color.dart)
  static const Color accentBlue = Color(
    0xFF4CAF50,
  ); // A green for success or "new" tags, different from the primary gold
  static const Color successGreen = Color(
    0xFF4CAF50,
  ); // Explicit green for success messages

  // Text colors for specific scenarios
  static const Color disabledText = Color(
    0xFF616161,
  ); // For disabled buttons or input hints

  // --- Initialized previously unassigned static vars based on light theme needs ---
  static const Color iconDark = Color(
    0xFF333333,
  ); // Dark icon for light backgrounds
  static const Color textLight = Color(
    0xFFFFFFFF,
  ); // White text for use on dark/primary accents
  static const Color cardBackground = Color(
    0xFFFFFFFF,
  ); // Default white background for cards/containers in light mode

  // NEW COLOR ADDED
  static const Color subtleBorder = Color(
    0xFFE0E0E0,
  ); // A very light grey for subtle borders in light theme
}
