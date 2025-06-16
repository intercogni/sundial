import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sundial/models/solar_data.dart';
import 'package:sundial/widgets/bottom_tab.dart';
import 'package:sundial/screens/login_screen.dart';
import 'package:sundial/screens/register_screen.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/foundation.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  
  FlutterError.onError = FirebaseCrashlytics.instance.recordFlutterFatalError;

  
  PlatformDispatcher.instance.onError = (error, stack) {
    FirebaseCrashlytics.instance.recordError(error, stack, fatal: true);
    return true;
  };

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
        brightness: Brightness.dark,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF13162B),
          brightness: Brightness.dark,
          primary: const Color(0xFF13162B),
          secondary: const Color(0xFF3A4058),
        ),
        useMaterial3: true,
      ),
      home: StreamBuilder<User?>(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasData) {
            return const BottomTab();
          }
          return const LoginScreen();
        },
      ),
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
          transitionDuration: const Duration(milliseconds: 333),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            const begin = Offset(0.0, 1.0);
            const end = Offset.zero;
            const curve = Curves.ease;

            var slideTween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
            var scaleTween = Tween(begin: 0.8, end: 1.0).chain(CurveTween(curve: curve));

            return SlideTransition(
              position: animation.drive(slideTween),
              child: ScaleTransition(
                scale: animation.drive(scaleTween),
                child: FadeTransition(
                  opacity: CurvedAnimation(parent: animation, curve: Curves.easeIn),
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
