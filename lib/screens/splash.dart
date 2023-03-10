import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:intune/constants/supabase.dart';
import 'package:intune/routes/router.gr.dart';
import 'package:intune/services/spotify_api.dart';

import '../widgets/common/banner.dart';

class SplashPage extends StatefulWidget {
  const SplashPage({super.key});

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> {
  bool _redirectCalled = false;
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _redirect();
  }

  Future<void> _redirect() async {
    await Future.delayed(Duration.zero);
    if (_redirectCalled || !mounted) {
      return;
    }

    _redirectCalled = true;
    final session = supabase.auth.currentSession;
    if (session != null) {
      context.router.replace(const HomeRoute());
    }
  }

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
                  !_redirectCalled
                      ? SizedBox(
                          height: 60,
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
                            child: Text('Get Started',
                                style: Theme.of(context).textTheme.bodyText1),
                          ),
                        )
                      : Container(),
                ])));
  }
}

// good bye ;-;
