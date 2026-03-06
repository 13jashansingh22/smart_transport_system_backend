import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_windowmanager/flutter_windowmanager.dart';
import 'firebase_options.dart';

/// Splash
import 'screens/splash_screen.dart';

/// Roles
import 'screens/role_selection_screen.dart';

/// Main Screens
import 'screens/passenger_screen.dart';
import 'screens/driver_screen.dart';
import 'screens/conductor_screen.dart';

/// Passenger Features
import 'screens/passenger/track_bus_screen.dart';
import 'screens/passenger/routes_screen.dart';
import 'screens/passenger/schedule_screen.dart';
import 'screens/passenger/ticket_screen.dart';
import 'screens/passenger/mytickets_screen.dart';
import 'screens/passenger/history_screen.dart';
import 'screens/passenger/profile_screen.dart';
import 'screens/passenger/alerts_screen.dart';
import 'screens/passenger/ai_features_screen.dart';
import 'screens/admin/transport_control_dashboard_screen.dart';

/// Chatbot
import 'screens/chatbot_screen.dart';

/// Help AI
import 'screens/help_screen.dart';

Future<void> _enableScreenProtection() async {
  if (!kIsWeb && defaultTargetPlatform == TargetPlatform.android) {
    await FlutterWindowManager.addFlags(FlutterWindowManager.FLAG_SECURE);
  }
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  await _enableScreenProtection();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  ThemeData _buildDarkTheme() {
    const colorScheme = ColorScheme.dark(
      primary: Color(0xFFFF3D00),
      secondary: Color(0xFFFF9100),
      surface: Color(0xFF1A1110),
      onSurface: Color(0xFFFFE9E2),
      error: Color(0xFFFF1744),
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: const Color(0xFF130B0A),
      appBarTheme: const AppBarTheme(
        centerTitle: true,
        elevation: 0,
        backgroundColor: Color(0xFF1F1210),
        foregroundColor: Color(0xFFFFE9E2),
      ),
      cardTheme: CardThemeData(
        color: const Color(0xFF251715),
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: const Color(0xFF241816),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFF5C3328)),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          minimumSize: const Size.fromHeight(52),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          textStyle: const TextStyle(),
        ),
      ),
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: Color(0xFFFF1744),
        foregroundColor: Colors.white,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: "Smart Transport System",
      themeMode: ThemeMode.dark,
      darkTheme: _buildDarkTheme(),
      theme: _buildDarkTheme(),
      home: const SplashScreen(),
      routes: {
        /// Roles
        '/roles': (context) => const RoleSelectionScreen(),

        '/passenger': (context) => const PassengerScreen(),
        '/driver': (context) => const DriverScreen(),
        '/conductor': (context) => const ConductorScreen(),

        /// Passenger
        '/trackbus': (context) => const TrackBusScreen(),
        '/routes': (context) => const RoutesScreen(),
        '/schedule': (context) => const ScheduleScreen(),
        '/tickets': (context) => const TicketScreen(),
        '/mytickets': (context) => const MyTicketsScreen(),
        '/history': (context) => const HistoryScreen(),
        '/profile': (context) => const ProfileScreen(),
        '/alerts': (context) => const AlertsScreen(),
        '/ai-features': (context) => const AIFeaturesScreen(),
        '/admin-control': (context) => const TransportControlDashboardScreen(),

        /// Help + Chatbot
        '/chatbot': (context) => const ChatbotScreen(),
        '/help': (context) => const HelpScreen(),
      },
    );
  }
}
