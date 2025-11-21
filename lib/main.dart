import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'firebase_options.dart';
import 'constants/app_constants.dart';
import 'screens/splash_screen.dart';
import 'screens/onboarding/welcome_screen.dart';
import 'screens/onboarding/location_permission_screen.dart';
import 'screens/home/home_screen.dart';
import 'services/auth_service.dart';
import 'services/auth_service_real.dart';
import 'services/location_service.dart';
import 'services/firestore_service.dart';
import 'config/firebase_config.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize Firebase with platform-specific configuration
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  
  if (kDebugMode) {
    debugPrint('✅ Firebase initialized successfully');
    debugPrint('🔧 Real Firebase mode: ${FirebaseConfig.USE_REAL_FIREBASE}');
  }
  
  // Initialize mock data only if using mock Firebase
  if (!FirebaseConfig.USE_REAL_FIREBASE) {
    FirestoreService.initializeMockData();
  }
  
  runApp(const TravellooPlyApp());
}

class TravellooPlyApp extends StatelessWidget {
  const TravellooPlyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        // Use real or mock auth service based on configuration
        ChangeNotifierProvider(
          create: (_) => FirebaseConfig.USE_REAL_FIREBASE 
            ? AuthServiceReal() 
            : AuthService(),
        ),
        ChangeNotifierProvider(create: (_) => LocationService()),
      ],
      child: MaterialApp(
      title: AppConfig.appName,
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        primaryColor: AppColors.primary,
        scaffoldBackgroundColor: AppColors.background,
        colorScheme: ColorScheme.fromSeed(
          seedColor: AppColors.primary,
          primary: AppColors.primary,
          secondary: AppColors.accent,
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.transparent,
          elevation: 0,
          iconTheme: IconThemeData(color: AppColors.textPrimary),
          titleTextStyle: AppStyles.headingSmall,
        ),
        cardTheme: CardThemeData(
          color: AppColors.cardBackground,
          elevation: 4,
          shadowColor: AppColors.shadow,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppStyles.cardRadius),
          ),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primary,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppStyles.buttonRadius),
            ),
            elevation: 2,
          ),
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: Colors.white,
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(AppStyles.buttonRadius),
            borderSide: const BorderSide(color: AppColors.divider),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(AppStyles.buttonRadius),
            borderSide: const BorderSide(color: AppColors.divider),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(AppStyles.buttonRadius),
            borderSide: const BorderSide(color: AppColors.primary, width: 2),
          ),
        ),
      ),
      home: const SplashScreen(),
      routes: {
        '/welcome': (context) => const WelcomeScreen(),
        '/location-permission': (context) => const LocationPermissionScreen(),
        '/home': (context) => const HomeScreen(),
      },
      ),
    );
  }
}
