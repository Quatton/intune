import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:intune/auth.dart';
import 'package:intune/layout.dart';
import 'firebase_options.dart';

//import google fonts
import 'package:google_fonts/google_fonts.dart';

Future main() async {
  await dotenv.load(fileName: ".env");

  WidgetsFlutterBinding.ensureInitialized();
  // We're using the manual installation on non-web platforms since Google sign in plugin doesn't yet support Dart initialization.
  // See related issue: https://github.com/flutter/flutter/issues/96391

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(const Intune());
}

class Intune extends StatelessWidget {
  const Intune({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const Home();
  }
}

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  bool _loading = false;
  bool _isLoggedIn = false;

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        title: 'Intune',
        debugShowCheckedModeBanner: false,
        theme: ThemeData.dark(useMaterial3: true).copyWith(
            brightness: Brightness.dark,
            textTheme: GoogleFonts.montserratTextTheme(const TextTheme(
              headline1: TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
              headline2: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
              headline3: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              bodyText1: TextStyle(fontSize: 18),
            )),
            // default button theme to be circular border
            buttonTheme: const ButtonThemeData(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.all(Radius.circular(30)),
              ),
            ),
            cardColor: Colors.grey[800],
            colorScheme: ColorScheme.fromSwatch(primarySwatch: Colors.green)),
        // Check if logged in with Firebase Auth
        home: StreamBuilder<User?>(
            stream: FirebaseAuth.instance.authStateChanges(),
            builder: (context, snapshot) {
              _isLoggedIn = false;
              if (snapshot.hasData) {
                _isLoggedIn = true;
              }
              return _isLoggedIn ? const Layout() : const Auth();
            }));
  }
}
