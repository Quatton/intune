import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:intune/routes/guard.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

//import google fonts
import 'package:google_fonts/google_fonts.dart';

import 'routes/router.gr.dart';

Future main() async {
  await dotenv.load(fileName: ".env");

  WidgetsFlutterBinding.ensureInitialized();
  // We're using the manual installation on non-web platforms since Google sign in plugin doesn't yet support Dart initialization.
  // See related issue: https://github.com/flutter/flutter/issues/96391
  const supabaseUrl = 'https://kluwpuvykzdkssrohewj.supabase.co';
  final supabaseKey = dotenv.get('SUPABASE_KEY');
  await Supabase.initialize(url: supabaseUrl, anonKey: supabaseKey);

  runApp(Intune());
}

class Intune extends StatelessWidget {
  Intune({
    Key? key,
  }) : super(key: key);

  final _appRouter = AppRouter(authGuard: AuthGuard());

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
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
      routerDelegate: _appRouter.delegate(),
      routeInformationParser: _appRouter.defaultRouteParser(),
    );
  }
}
