import 'package:flutter/material.dart';

import 'package:sundial/widgets/bottom_tab.dart';
import 'package:flutter/material.dart';
import 'constants.dart';

void main() {
  runApp(const SundialApp());
}

class SundialApp extends StatelessWidget {
  const SundialApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Sundial',
      theme: ThemeData(
        fontFamily: 'GothamRounded',
        brightness: Brightness.dark,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color.fromARGB(255, 125, 161, 209),
          brightness: Brightness.dark,
          primary: const Color.fromARGB(255, 137, 172, 218),
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
