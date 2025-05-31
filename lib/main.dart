import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sundial/models/solar_data.dart';
import 'package:sundial/widgets/bottom_tab.dart';

void main() {
  SolarData();
  runApp(
    ChangeNotifierProvider(
      create: (context) => SolarData(),
      child: const SundialApp(),
    ),
  );
}

class SundialApp extends StatelessWidget {
  const SundialApp({Key? key}) : super(key: key);

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
      home: const BottomTab(),
    );
  }
}
