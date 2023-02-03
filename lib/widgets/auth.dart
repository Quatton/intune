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

class ScaffoldSnackbar {
  // ignore: public_member_api_docs
  ScaffoldSnackbar(this._context);

  /// The scaffold of current context.
  factory ScaffoldSnackbar.of(BuildContext context) {
    return ScaffoldSnackbar(context);
  }

  final BuildContext _context;

  /// Helper method to show a SnackBar.
  void show(String message) {
    ScaffoldMessenger.of(_context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(message),
          behavior: SnackBarBehavior.floating,
        ),
      );
  }
}

class LoginPage extends StatefulWidget {
  const LoginPage({super.key, this.onResult});

  final void Function(bool)? onResult;

  @override
  State<LoginPage> createState() => _LoginPageState();
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
      body: GestureDetector(
        onTap: FocusScope.of(context).unfocus,
        child: Container(
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
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: SafeArea(
                    child: Form(
                      key: formKey,
                      autovalidateMode: AutovalidateMode.onUserInteraction,
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 400),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const LogoBanner(),
                            Visibility(
                              visible: error.isNotEmpty,
                              child: MaterialBanner(
                                backgroundColor:
                                    Theme.of(context).colorScheme.error,
                                content: SelectableText(error),
                                actions: [
                                  TextButton(
                                    onPressed: () {
                                      setState(() {
                                        error = '';
                                      });
                                    },
                                    child: const Text(
                                      'dismiss',
                                      style: TextStyle(color: Colors.white),
                                    ),
                                  )
                                ],
                                contentTextStyle:
                                    const TextStyle(color: Colors.white),
                                padding: const EdgeInsets.all(10),
                              ),
                            ),
                            TextFormField(
                              controller: _emailController,
                              decoration: const InputDecoration(
                                labelText: 'Email',
                                border: OutlineInputBorder(),
                              ),
                              validator: (value) =>
                                  value != null && value.isNotEmpty
                                      ? null
                                      : 'Required',
                            ),
                            const SizedBox(height: 20),
                            ConstrainedBox(
                              constraints: const BoxConstraints(maxWidth: 300),
                              child: AnimatedSwitcher(
                                duration: const Duration(milliseconds: 200),
                                child: _isLoading
                                    ? Container(
                                        decoration: BoxDecoration(
                                          borderRadius:
                                              BorderRadius.circular(9999),
                                          color: Theme.of(context).primaryColor,
                                        ),
                                        width: double.infinity,
                                        height: 60,
                                        child: const Center(
                                          child: CircularProgressIndicator
                                              .adaptive(),
                                        ))
                                    : SizedBox(
                                        height: 60,
                                        width: double.infinity,
                                        child: ElevatedButton(
                                            style: ElevatedButton.styleFrom(
                                              backgroundColor: Theme.of(context)
                                                  .primaryColor,
                                            ),
                                            onPressed: _isLoading
                                                ? null
                                                : _signInWithOtp,
                                            child: Text(
                                              "Continue with Email",
                                              style: Theme.of(context)
                                                  .textTheme
                                                  .bodyText1,
                                            )),
                                      ),
                              ),
                            ),
                            const SizedBox(height: 20),
                            ConstrainedBox(
                              constraints: const BoxConstraints(maxWidth: 300),
                              child: AnimatedSwitcher(
                                duration: const Duration(milliseconds: 200),
                                child: _isLoading
                                    ? Container(
                                        decoration: BoxDecoration(
                                          borderRadius:
                                              BorderRadius.circular(9999),
                                          color: Theme.of(context).primaryColor,
                                        ),
                                        width: double.infinity,
                                        height: 60,
                                        child: const Center(
                                          child: CircularProgressIndicator
                                              .adaptive(),
                                        ))
                                    : SizedBox(
                                        height: 60,
                                        width: double.infinity,
                                        child: ElevatedButton(
                                            style: ElevatedButton.styleFrom(
                                              backgroundColor: Colors.green,
                                            ),
                                            onPressed: _isLoading
                                                ? null
                                                : _signInWithSpotify,
                                            child: Text(
                                              "Continue with Spotify",
                                              style: Theme.of(context)
                                                  .textTheme
                                                  .bodyText1,
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
              ),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _signInWithSpotify() async {
    setState(() {
      _isLoading = true;
    });
    try {
      await supabase.auth.signInWithOAuth(Provider.spotify,
          scopes: SpotifyClient.scopes.join(', '),
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

  Future<void> _signInWithOtp() async {
    setState(() {
      _isLoading = true;
    });
    try {
      if (formKey.currentState?.validate() ?? false) {
        await supabase.auth.signInWithOtp(
          email: _emailController.text,
          emailRedirectTo: kIsWeb
              ? null
              : dotenv.get("SUPABASE_REDIRECT_URL",
                  fallback: "com.quattonary.intune://login-callback"),
        );
        if (mounted) {
          context.showSnackBar(message: 'Check your email for login link!');
          _emailController.clear();
        }
      }
    } on AuthException catch (error) {
      context.showErrorSnackBar(message: error.message);
    } catch (error) {
      context.showErrorSnackBar(message: error.toString());
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }
}
