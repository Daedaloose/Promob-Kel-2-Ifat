import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:peaceful_mind/screens/welcome_screen.dart';
import 'package:peaceful_mind/screens/login_screen.dart';
import 'package:peaceful_mind/screens/signup_screen.dart';
import 'package:peaceful_mind/screens/home_screen.dart';
import 'package:peaceful_mind/screens/ai_chat_screen.dart';
import 'package:peaceful_mind/screens/mood_detection_screen.dart';
import 'package:peaceful_mind/screens/comfort_food_screen.dart';
import 'services/theme_service.dart';
import 'services/notification_service.dart';

import 'package:flutter/foundation.dart' show kIsWeb;
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  if (kIsWeb) {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.web,
    );
  } else {
    await Firebase.initializeApp();
  }
  
  await NotificationService.init();
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
    ),
  );
  runApp(const PeacefulMindApp());
}

class PeacefulMindApp extends StatelessWidget {
  const PeacefulMindApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<ThemeMode>(
      valueListenable: ThemeService.themeNotifier,
      builder: (context, mode, child) {
        return MaterialApp(
      title: 'Peaceful Mind',
      debugShowCheckedModeBanner: false,
      themeMode: mode,
      theme: ThemeData(
        textTheme: GoogleFonts.fredokaTextTheme(ThemeData.light().textTheme),
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFFB5D5C5),
          primary: const Color(0xFFB5D5C5),
          secondary: const Color(0xFF2D2D2D),
        ),
        useMaterial3: true,
      ),
      darkTheme: ThemeData(
        brightness: Brightness.dark,
        textTheme: GoogleFonts.fredokaTextTheme(ThemeData.dark().textTheme),
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFFB5D5C5),
          brightness: Brightness.dark,
        ),
      ),

      initialRoute: '/welcome',
      routes: {
        '/welcome':   (context) => const WelcomeScreen(),
        '/login':     (context) => const LoginScreen(),
        '/signup':    (context) => const SignUpScreen(),
        '/home':      (context) => const HomeScreen(),
        '/ai-chat':   (context) => const AiChatScreen(),
        '/mood-scan': (context) => const MoodDetectionScreen(),
        '/comfort-food': (context) => const ComfortFoodScreen(),
      },
        );
      },
    );
  }
}
