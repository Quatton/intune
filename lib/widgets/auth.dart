import 'dart:async';

import 'package:auto_route/auto_route.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:intune/constants/supabase.dart';
import 'package:intune/routes/router.gr.dart';
import 'package:intune/services/spotify_auth_api.dart';
import 'package:intune/widgets/common/banner.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Entrypoint example for various sign-in flows with Firebase.
class LoginPage extends StatefulWidget {
  const LoginPage({super.key, this.onResult});

  final void Function(bool)? onResult;

  @override
  State<StatefulWidget> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  GlobalKey<FormState> formKey = GlobalKey<FormState>();
  String error = '';
  String verificationId = '';

  bool _isLoading = false;
  bool _redirecting = false;
  late final TextEditingController _emailController;
  late final StreamSubscription<AuthState> _authStateSubscription;

  void setIsLoading() {
    setState(() {
      _isLoading = !_isLoading;
    });
  }

  @override
  void initState() {
    _emailController = TextEditingController();
    _authStateSubscription = supabase.auth.onAuthStateChange.listen((data) {
      if (_redirecting) return;
      final session = data.session;
      if (session != null) {
        _redirecting = true;
        AutoRouter.of(context).replace(const HomeRoute());
      }
    });
    super.initState();
  }

  @override
  void dispose() {
    _emailController.dispose();
    _authStateSubscription.cancel();
    super.dispose();
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
        child: Center(
          child: SingleChildScrollView(
            child: Center(
              child: Column(
                // set mainAxisSize to screen size
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // placeholder banner with logo and app title: Intune and a placeholder logo using the icon of music
                  const LogoBanner(),
                  ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 300),
                    child: AnimatedSwitcher(
                      duration: const Duration(milliseconds: 200),
                      child: _isLoading
                          ? Container(
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(9999),
                                color: Theme.of(context).primaryColor,
                              ),
                              width: double.infinity,
                              height: 60,
                              child: const Center(
                                child: CircularProgressIndicator.adaptive(),
                              ))
                          : SizedBox(
                              height: 60,
                              width: double.infinity,
                              child: ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.green,
                                  ),
                                  onPressed: _isLoading ? null : _signIn,
                                  child: Text(
                                    "Continue with Spotify",
                                    style:
                                        Theme.of(context).textTheme.bodyText1,
                                  )),
                            ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _signIn() async {
    setState(() {
      _isLoading = true;
    });
    try {
      await supabase.auth.signInWithOAuth(Provider.spotify,
          scopes: SpotifyClient.scopes,
          redirectTo: !kIsWeb ? dotenv.get("SPOTIFY_REDIRECT_URI") : null);
    } on AuthException catch (error) {
      context.showErrorSnackBar(message: error.message);
    } catch (error) {
      context.showErrorSnackBar(message: 'Unexpected error occurred');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }
}
