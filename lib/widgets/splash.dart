import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:intune/routes/router.gr.dart';

import 'common/banner.dart';

class SplashPage extends StatefulWidget {
  const SplashPage({super.key});

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Container(
            height: double.infinity,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  // Spotify-themed sets of colors
                  Colors.green.shade500,
                  Colors.black,
                ],
              ),
            ),
            child: Column(
                // set mainAxisSize to screen size
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // placeholder banner with logo and app title: Intune and a placeholder logo using the icon of music
                  const LogoBanner(),

                  // login button that will push to login route
                  SizedBox(
                    height: 50,
                    width: 200,
                    child: ElevatedButton(
                      onPressed: () {
                        context.router.replaceNamed('/login');
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green.shade500,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                      ),
                      child: const Text(
                        'Get Started',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ])));
  }
}

// good bye ;-;
