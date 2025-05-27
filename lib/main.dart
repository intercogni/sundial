import 'package:flutter/material.dart';

import 'package:sundial/screens/home.dart';

void main() {
  runApp(const SundialApp());
}

class SundialApp extends StatelessWidget {
  const SundialApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Sundial',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color.fromARGB(255, 195, 28, 28),
        ),
      ),
      initialRoute: 'home',
      routes: {
        'home': (context) => const HomeScreen(title: 'Sundial Home Screen'),
        // 'login': (context) => const LoginScreen(),
        // 'register': (context) => const RegisterScreen(),
      },
    );
  }
}
