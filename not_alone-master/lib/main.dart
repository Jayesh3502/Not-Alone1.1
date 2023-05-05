import 'package:dynamic_color/dynamic_color.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:not_alone/screens/home_screen.dart';
import 'package:not_alone/screens/welcome_screen.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// Its true if the application is compiled in debug mode.
///
/// Use it in place of [kDebugMode] through out the app to check for debug mode.
/// Useful in faking production mode in debug mode by setting it to false.
bool isInDebugMode = kDebugMode;

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return DynamicColorBuilder(
        builder: (ColorScheme? lightDynamic, ColorScheme? darkDynamic) {
      return MaterialApp(
        title: 'Not Alone',
        theme: ThemeData(useMaterial3: true, colorScheme: lightDynamic),
        darkTheme: ThemeData(useMaterial3: true, colorScheme: darkDynamic),
        debugShowCheckedModeBanner: false,
        home: const NotAlone(),
      );
    });
  }
}

class NotAlone extends StatelessWidget {
  const NotAlone({Key? key}) : super(key: key);

  final secureStorage = const FlutterSecureStorage();

  // Check if user is logged in or not in Firebase
  Future<bool> checkLoginStatus() async {
    User? user = FirebaseAuth.instance.currentUser;
    user = await FirebaseAuth.instance.authStateChanges().first;
    if (user != null) {
      return true;
    }
    return false;
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: checkLoginStatus(),
      builder: (BuildContext context, AsyncSnapshot<bool> snapshot) {
        if (snapshot.data == false) {
          return const WelcomeScreen();
        }
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
              body: Center(child: CircularProgressIndicator()));
        }
        return const HomeScreen();
      },
    );
  }
}
