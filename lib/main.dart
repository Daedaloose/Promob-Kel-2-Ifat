import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'screens/welcome_screen.dart';
import 'screens/login_screen.dart';
import 'screens/home_screen.dart';
import 'screens/ai_chat_screen.dart';
import 'screens/mood_detection_screen.dart';
import 'screens/comfort_food_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
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
    return MaterialApp(
      title: 'Peaceful Mind',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        fontFamily: 'Nunito',
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFFB5D5C5),
          primary: const Color(0xFFB5D5C5),
          secondary: const Color(0xFF2D2D2D),
        ),
        useMaterial3: true,
      ),
      initialRoute: '/welcome',
      routes: {
        '/welcome':   (context) => const WelcomeScreen(),
        '/login':     (context) => const LoginScreen(),
        '/home':      (context) => const HomeScreen(),
        '/ai-chat':   (context) => const AiChatScreen(),
        '/mood-scan': (context) => const MoodDetectionScreen(),
        '/comfort-food': (context) => const ComfortFoodScreen(),
      },
    );
  }
}
