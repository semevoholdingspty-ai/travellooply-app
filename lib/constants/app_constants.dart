import 'package:flutter/material.dart';

/// Travellooply App Constants
/// Brand colors, configuration, and app-wide settings

class AppColors {
  // Primary Brand Colors
  static const Color primary = Color(0xFF1A73E8); // Travel Blue
  static const Color accent = Color(0xFFFF9F1C); // Social Orange
  static const Color background = Color(0xFFF5F7FA);
  static const Color textPrimary = Color(0xFF2B2B2B);
  static const Color textSecondary = Color(0xFF6F6F6F);
  
  // Gradient Colors
  static const List<Color> primaryGradient = [
    Color(0xFF1A73E8), // Blue
    Color(0xFF4A90E2), // Mid Blue
    Color(0xFFFF9F1C), // Orange
  ];
  
  static const List<Color> accentGradient = [
    Color(0xFFFF9F1C), // Orange
    Color(0xFFFFB84D), // Light Orange
  ];
  
  // Status Colors
  static const Color success = Color(0xFF4CAF50);
  static const Color warning = Color(0xFFFFA726);
  static const Color error = Color(0xFFF44336);
  static const Color info = Color(0xFF2196F3);
  
  // UI Element Colors
  static const Color cardBackground = Colors.white;
  static const Color divider = Color(0xFFE0E0E0);
  static const Color shadow = Color(0x1A000000);
  
  // Activity Type Colors
  static const Map<String, Color> activityColors = {
    'Explore': Color(0xFF9C27B0), // Purple
    'Socialize': Color(0xFFFF5722), // Deep Orange
    'Eat': Color(0xFF4CAF50), // Green
    'Walk': Color(0xFF03A9F4), // Light Blue
    'Nightlife': Color(0xFF673AB7), // Deep Purple
    'Chill': Color(0xFF009688), // Teal
    'Coffee': Color(0xFF795548), // Brown
    'Photography': Color(0xFFFF9800), // Orange
    'Museums': Color(0xFF607D8B), // Blue Grey
    'Shopping': Color(0xFFE91E63), // Pink
  };
}

class AppConfig {
  // App Information
  static const String appName = 'Travellooply';
  static const String appVersion = '1.0.0';
  static const String appTagline = 'Connect with Travelers Around You';
  
  // Circle Configuration
  static const int minCircleMembers = 2;
  static const int maxCircleMembers = 10;
  static const int circleLifetimeHours = 24;
  static const double minProximityMeters = 300;
  static const double maxProximityMeters = 1200;
  static const double defaultProximityMeters = 800;
  
  // Micro-Event Configuration
  static const int minEventDuration = 20; // minutes
  static const int maxEventDuration = 60; // minutes
  static const int defaultEventDuration = 30; // minutes
  static const int minEventParticipants = 2;
  static const int maxEventParticipants = 10;
  
  // Chat Configuration
  static const int messageAutoDeleteHours = 24;
  static const int maxMessageLength = 500;
  
  // Location Update Configuration
  static const int locationUpdateIntervalSeconds = 30;
  static const double significantLocationChangeMeta = 50.0; // meters
  
  // Trust Score Configuration
  static const int defaultTrustScore = 50;
  static const int maxTrustScore = 100;
  static const int minTrustScore = 0;
  
  // Premium Features
  static const bool premiumEnabled = true;
  static const double premiumMonthlyPrice = 9.99;
  static const double premiumYearlyPrice = 79.99;
}

class AppStyles {
  // Border Radius
  static const double cardRadius = 18.0;
  static const double buttonRadius = 12.0;
  static const double chipRadius = 20.0;
  
  // Spacing
  static const double spacingXS = 4.0;
  static const double spacingS = 8.0;
  static const double spacingM = 16.0;
  static const double spacingL = 24.0;
  static const double spacingXL = 32.0;
  
  // Icon Sizes
  static const double iconSizeSmall = 18.0;
  static const double iconSizeMedium = 24.0;
  static const double iconSizeLarge = 32.0;
  static const double iconSizeXLarge = 48.0;
  
  // Text Styles
  static const TextStyle headingLarge = TextStyle(
    fontSize: 32,
    fontWeight: FontWeight.bold,
    color: AppColors.textPrimary,
    fontFamily: 'Inter',
  );
  
  static const TextStyle headingMedium = TextStyle(
    fontSize: 24,
    fontWeight: FontWeight.bold,
    color: AppColors.textPrimary,
    fontFamily: 'Inter',
  );
  
  static const TextStyle headingSmall = TextStyle(
    fontSize: 20,
    fontWeight: FontWeight.w600,
    color: AppColors.textPrimary,
    fontFamily: 'Inter',
  );
  
  static const TextStyle bodyLarge = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.normal,
    color: AppColors.textPrimary,
    fontFamily: 'Inter',
  );
  
  static const TextStyle bodyMedium = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.normal,
    color: AppColors.textPrimary,
    fontFamily: 'Inter',
  );
  
  static const TextStyle bodySmall = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.normal,
    color: AppColors.textSecondary,
    fontFamily: 'Inter',
  );
  
  static const TextStyle buttonText = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w600,
    color: Colors.white,
    fontFamily: 'Inter',
  );
  
  // Shadows
  static const BoxShadow cardShadow = BoxShadow(
    color: AppColors.shadow,
    blurRadius: 8,
    offset: Offset(0, 2),
  );
  
  static const BoxShadow buttonShadow = BoxShadow(
    color: AppColors.shadow,
    blurRadius: 6,
    offset: Offset(0, 2),
  );
}

class AppAssets {
  static const String appIcon = 'assets/icon/app_icon.png';
}

/// Activity Types
class ActivityTypes {
  static const List<String> all = [
    'Explore',
    'Socialize',
    'Eat',
    'Walk',
    'Nightlife',
    'Chill',
    'Coffee',
    'Photography',
    'Museums',
    'Shopping',
  ];
  
  static Color getColor(String type) {
    return AppColors.activityColors[type] ?? AppColors.primary;
  }
  
  static IconData getIcon(String type) {
    switch (type) {
      case 'Explore':
        return Icons.explore;
      case 'Socialize':
        return Icons.people;
      case 'Eat':
        return Icons.restaurant;
      case 'Walk':
        return Icons.directions_walk;
      case 'Nightlife':
        return Icons.nightlife;
      case 'Chill':
        return Icons.weekend;
      case 'Coffee':
        return Icons.local_cafe;
      case 'Photography':
        return Icons.camera_alt;
      case 'Museums':
        return Icons.museum;
      case 'Shopping':
        return Icons.shopping_bag;
      default:
        return Icons.circle;
    }
  }
}

/// Social Vibe Options
class SocialVibes {
  static const String introvert = 'Introvert';
  static const String friendly = 'Friendly';
  static const String highlySocial = 'Highly Social';
  
  static const List<String> all = [
    introvert,
    friendly,
    highlySocial,
  ];
  
  static IconData getIcon(String vibe) {
    switch (vibe) {
      case introvert:
        return Icons.person_outline;
      case friendly:
        return Icons.people_outline;
      case highlySocial:
        return Icons.groups;
      default:
        return Icons.person;
    }
  }
  
  static String getDescription(String vibe) {
    switch (vibe) {
      case introvert:
        return 'Prefer smaller, quieter gatherings';
      case friendly:
        return 'Enjoy meeting new people in relaxed settings';
      case highlySocial:
        return 'Love large groups and active social scenes';
      default:
        return '';
    }
  }
}

/// Event Status
class EventStatus {
  static const String upcoming = 'upcoming';
  static const String active = 'active';
  static const String completed = 'completed';
  static const String cancelled = 'cancelled';
}

/// Circle Status
class CircleStatus {
  static const String active = 'active';
  static const String expired = 'expired';
  static const String dissolved = 'dissolved';
}
