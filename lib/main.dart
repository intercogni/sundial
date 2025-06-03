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
      onGenerateRoute: (settings) {
        WidgetBuilder builder;
        switch (settings.name) {
          case '/login':
            builder = (BuildContext _) => const LoginScreen();
            break;
          case '/register':
            builder = (BuildContext _) => const RegisterScreen();
            break;
          case '/home':
            builder = (BuildContext _) => const BottomTab();
            break;
          default:
            throw Exception('Invalid route: ${settings.name}');
        }
        return PageRouteBuilder(
          pageBuilder: (context, animation, secondaryAnimation) => builder(context),
          transitionDuration: const Duration(milliseconds: 333), // Make animation faster
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            const begin = Offset(0.0, 1.0); // Start from top
            const end = Offset.zero;
            const curve = Curves.ease;

            var slideTween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
            var scaleTween = Tween(begin: 0.8, end: 1.0).chain(CurveTween(curve: curve));

            return SlideTransition(
              position: animation.drive(slideTween),
              child: ScaleTransition(
                scale: animation.drive(scaleTween),
                child: FadeTransition(
                  opacity: CurvedAnimation(parent: animation, curve: Curves.easeIn), // Slight fade in
                  child: child,
                ),
              ),
            );
          },
          settings: settings,
        );
      },
    );
  }
}
