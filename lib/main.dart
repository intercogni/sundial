import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sundial/models/solar_data.dart';
import 'package:sundial/widgets/bottom_tab.dart';
import 'package:sundial/screens/login_screen.dart';
import 'package:sundial/screens/register_screen.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  SolarData();
  runApp(
    ChangeNotifierProvider(
      create: (context) => SolarData(),
      child: const SundialApp(),
    ),
  );
}

class SundialApp extends StatelessWidget {
  const SundialApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Sundial',
      theme: ThemeData(
        fontFamily: 'GothamRounded',
        brightness: Brightness.light,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF1E3F05),
          brightness: Brightness.light,
          primary: const Color(0xFF1E3F05),
          secondary: const Color.fromARGB(
            255,
            178,
            246,
            255,
          ), // Pastel Orange AccentR
        ),
        useMaterial3: true,
      ),
      initialRoute: '/login',
      routes: {
        '/login': (context) => const LoginScreen(),
        '/register': (context) => const RegisterScreen(),
        '/home': (context) => const BottomTab(),
      },
    );
  }
}
