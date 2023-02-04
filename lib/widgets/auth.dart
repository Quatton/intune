import 'dart:async';

import 'package:auto_route/auto_route.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_web_auth_2/flutter_web_auth_2.dart';
import 'package:intune/constants/supabase.dart';
import 'package:intune/routes/router.gr.dart';
import 'package:intune/services/spotify_auth_api.dart';
import 'package:intune/services/supabase/supabase_helper.dart';
import 'package:intune/util/logger.dart';
import 'package:intune/widgets/common/banner.dart';
import 'package:spotify/spotify.dart';
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
  GlobalKey<FormState> emailFormKey = GlobalKey<FormState>();
  GlobalKey<FormState> otpFormKey = GlobalKey<FormState>();
  String error = '';
  String verificationId = '';

  bool _isMagicLinkSent = false;
  bool _isLoading = false;
  bool _redirecting = false;
  late final TextEditingController _emailController;
  late final TextEditingController _otpController;
  late final StreamSubscription<AuthState> _authStateSubscription;

  void setIsLoading() {
    setState(() {
      _isLoading = !_isLoading;
    });
  }

  @override
  void initState() {
    _emailController = TextEditingController();
    _otpController = TextEditingController();
    _authStateSubscription = supabase.auth.onAuthStateChange.listen((data) {
      if (_redirecting) return;
      final session = data.session;
      if (session != null) {
        _redirecting = true;
        AutoRouter.of(context).replace(const HomeRoute());
      }
      Log.setStatus("damn in");
    });
    super.initState();
  }

  @override
  void dispose() {
    _emailController.dispose();
    _otpController.dispose();
    _authStateSubscription.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GestureDetector(
        onTap: () {
          FocusScope.of(context).unfocus();
        },
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
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const LogoBanner(),
                        _isMagicLinkSent
                            ? Form(
                                key: otpFormKey,
                                child: ConstrainedBox(
                                    constraints:
                                        const BoxConstraints(maxWidth: 400),
                                    child: Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          Text(
                                              "Check your email for login instruction!",
                                              style: Theme.of(context)
                                                  .textTheme
                                                  .bodyLarge),
                                          SizedBox(height: 20),
                                          TextFormField(
                                            controller: _otpController,
                                            decoration: const InputDecoration(
                                              labelText: '6-digit OTP',
                                              border: OutlineInputBorder(),
                                            ),
                                            validator: (value) => value !=
                                                        null &&
                                                    value.isNotEmpty
                                                ? value.length == 6
                                                    ? null
                                                    : "Please input 6-digit code"
                                                : 'Required',
                                          ),
                                          const SizedBox(height: 20),
                                          ConstrainedBox(
                                            constraints: const BoxConstraints(
                                                maxWidth: 300),
                                            child: AnimatedSwitcher(
                                              duration: const Duration(
                                                  milliseconds: 200),
                                              child: _isLoading
                                                  ? Container(
                                                      decoration: BoxDecoration(
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(9999),
                                                        color: Theme.of(context)
                                                            .primaryColor,
                                                      ),
                                                      width: double.infinity,
                                                      height: 60,
                                                      child: const Center(
                                                        child:
                                                            CircularProgressIndicator
                                                                .adaptive(),
                                                      ))
                                                  : SizedBox(
                                                      height: 60,
                                                      width: double.infinity,
                                                      child: ElevatedButton(
                                                          style: ElevatedButton
                                                              .styleFrom(
                                                            backgroundColor:
                                                                Theme.of(
                                                                        context)
                                                                    .primaryColor,
                                                          ),
                                                          onPressed: _isLoading
                                                              ? null
                                                              : _verifyOTP,
                                                          child: Text(
                                                            "Verify OTP",
                                                            style: Theme.of(
                                                                    context)
                                                                .textTheme
                                                                .bodyText1,
                                                          )),
                                                    ),
                                            ),
                                          ),
                                          SizedBox(height: 20),
                                          ElevatedButton.icon(
                                              onPressed: () {
                                                setState(() {
                                                  _isMagicLinkSent = false;
                                                  _otpController.clear();
                                                });
                                              },
                                              icon: Icon(Icons.replay_outlined),
                                              label: Text(
                                                  "Try another login method"))
                                        ])),
                              )
                            : Form(
                                key: emailFormKey,
                                autovalidateMode:
                                    AutovalidateMode.onUserInteraction,
                                child: ConstrainedBox(
                                  constraints:
                                      const BoxConstraints(maxWidth: 400),
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Visibility(
                                        visible: error.isNotEmpty,
                                        child: MaterialBanner(
                                          backgroundColor: Theme.of(context)
                                              .colorScheme
                                              .error,
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
                                                style: TextStyle(
                                                    color: Colors.white),
                                              ),
                                            )
                                          ],
                                          contentTextStyle: const TextStyle(
                                              color: Colors.white),
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
                                        constraints:
                                            const BoxConstraints(maxWidth: 300),
                                        child: AnimatedSwitcher(
                                          duration:
                                              const Duration(milliseconds: 200),
                                          child: _isLoading
                                              ? Container(
                                                  decoration: BoxDecoration(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            9999),
                                                    color: Theme.of(context)
                                                        .primaryColor,
                                                  ),
                                                  width: double.infinity,
                                                  height: 60,
                                                  child: const Center(
                                                    child:
                                                        CircularProgressIndicator
                                                            .adaptive(),
                                                  ))
                                              : SizedBox(
                                                  height: 60,
                                                  width: double.infinity,
                                                  child: ElevatedButton(
                                                      style: ElevatedButton
                                                          .styleFrom(
                                                        backgroundColor:
                                                            Theme.of(context)
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
                                        constraints:
                                            const BoxConstraints(maxWidth: 300),
                                        child: AnimatedSwitcher(
                                          duration:
                                              const Duration(milliseconds: 200),
                                          child: _isLoading
                                              ? Container(
                                                  decoration: BoxDecoration(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            9999),
                                                    color: Theme.of(context)
                                                        .primaryColor,
                                                  ),
                                                  width: double.infinity,
                                                  height: 60,
                                                  child: const Center(
                                                    child:
                                                        CircularProgressIndicator
                                                            .adaptive(),
                                                  ))
                                              : SizedBox(
                                                  height: 60,
                                                  width: double.infinity,
                                                  child: ElevatedButton(
                                                      style: ElevatedButton
                                                          .styleFrom(
                                                        backgroundColor:
                                                            Colors.green,
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
                      ],
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
      final response = await supabase.auth.getOAuthSignInUrl(
          provider: Provider.spotify,
          redirectTo: !kIsWeb ? dotenv.get("SPOTIFY_REDIRECT_URI") : null,
          scopes: SpotifyClient.scopes.join(', '));

      // User login through the web
      final result = await FlutterWebAuth2.authenticate(
          preferEphemeral: true,
          url: response.url.toString(),
          callbackUrlScheme: "com.quattonary.intune");

      // Now we have the result but if we get session first,
      // The homepage might load without the accessToken

      // Parse the result
      var url = Uri.parse(result);
      if (url.hasQuery) {
        final decoded = result.toString().replaceAll('#', '&');
        url = Uri.parse(decoded);
      } else {
        final decoded = result.toString().replaceAll('#', '?');
        url = Uri.parse(decoded);
      }

      // Retrieve two tokens and assume that it will expire in 3600 seconds
      // It NEEDs to have these two or we just call error
      final String accessToken = url.queryParameters['provider_token']!;
      final String refreshToken =
          url.queryParameters['provider_refresh_token']!;
      final DateTime expiration =
          DateTime.now().add(const Duration(seconds: 3600));

      final spotifyCredentials = SpotifyApiCredentials(
          SpotifyClient.clientId, SpotifyClient.clientSecret,
          accessToken: accessToken,
          refreshToken: refreshToken,
          expiration: expiration,
          scopes: SpotifyClient.scopes);

      // Now our SpotifyClient can call endpoints!
      SpotifyClient.saveCredentials(spotifyCredentials);

      // And finally load our session up because we can't update db w/o login
      await supabase.auth.getSessionFromUrl(Uri.parse(result));

      // Save that onto our database
      await DatabaseHelper.updateSpotifyLink(credentials: spotifyCredentials);

      // This should flow flawlessly.
    } on SupabaseHelperException catch (error) {
      Log.setStatus(error.message);
    } on AuthException catch (error) {
      Log.setStatus(error.message);
      context.showErrorSnackBar(message: error.message);
      setState(() {
        _isLoading = false;
      });
    } catch (error) {
      Log.setStatus(error.toString());
      context.showErrorSnackBar(message: 'Unexpected error occurred');

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
      if (emailFormKey.currentState?.validate() ?? false) {
        await supabase.auth.signInWithOtp(
          email: _emailController.text,
          emailRedirectTo: kIsWeb
              ? null
              : dotenv.get("SUPABASE_REDIRECT_URL",
                  fallback: "com.quattonary.intune://login-callback"),
        );
        if (mounted) {
          setState(() {
            _isMagicLinkSent = true;
          });
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

  Future<void> _verifyOTP() async {
    setState(() {
      _isLoading = true;
    });
    try {
      if (otpFormKey.currentState?.validate() ?? false) {
        await supabase.auth.verifyOTP(
            type: OtpType.magiclink,
            token: _otpController.text,
            email: _emailController.text);
      }
    } on AuthException catch (error) {
      try {
        await supabase.auth.verifyOTP(
            type: OtpType.signup,
            token: _otpController.text,
            email: _emailController.text);
      } on AuthException catch (error) {
        context.showErrorSnackBar(message: error.message);
      } catch (error) {
        context.showErrorSnackBar(message: error.toString());
      }
    } catch (error) {
      context.showErrorSnackBar(message: error.toString());
    }
    if (mounted) {
      setState(() {
        _isLoading = false;
      });
    }
  }
}
