import 'dart:io';

import 'package:auto_route/auto_route.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_signin_button/flutter_signin_button.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:intune/routes/router.gr.dart';
import 'package:intune/widgets/common/banner.dart';

typedef OAuthSignIn = void Function();

final FirebaseAuth _auth = FirebaseAuth.instance;

/// Helper class to show a snackbar using the passed context.
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

/// The mode of the current auth session, either [AuthMode.login] or [AuthMode.register].
// ignore: public_member_api_docs
enum AuthMode { login, register, phone }

extension on AuthMode {
  String get label => this == AuthMode.login
      ? 'Sign in'
      : this == AuthMode.phone
          ? 'Sign in'
          : 'Register';
}

class LoginPage extends StatefulWidget {
  const LoginPage({super.key, this.onResult});

  final void Function(bool)? onResult;

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  bool _isAuthenticated = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
        child: Scaffold(
            body: StreamBuilder(
                stream: FirebaseAuth.instance.authStateChanges(),
                builder: (context, snapshot) {
                  if (snapshot.hasData) {
                    _isAuthenticated = true;
                  }
                  if (_isAuthenticated) {
                    AutoRouter.of(context).replace(const HomeRoute());
                    widget.onResult?.call(true);
                    return const RedirectHome();
                  } else {
                    return const LoginForm();
                  }
                })));
  }
}

class RedirectHome extends StatelessWidget {
  // ignore: public_member_api_docs
  const RedirectHome({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: const [
            Text('Redirecting to home page'),
          ],
        ),
      ),
    );
  }
}

/// Entrypoint example for various sign-in flows with Firebase.
class LoginForm extends StatefulWidget {
  // ignore: public_member_api_docs
  const LoginForm({super.key});
  @override
  State<StatefulWidget> createState() => _LoginFormState();
}

class _LoginFormState extends State<LoginForm> {
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  TextEditingController phoneController = TextEditingController();

  GlobalKey<FormState> formKey = GlobalKey<FormState>();
  String error = '';
  String verificationId = '';

  AuthMode mode = AuthMode.login;

  bool isLoading = false;

  void setIsLoading() {
    setState(() {
      isLoading = !isLoading;
    });
  }

  late Map<Buttons, OAuthSignIn> authButtons;

  @override
  void initState() {
    super.initState();
    if (!kIsWeb && Platform.isMacOS) {
      authButtons = {
        Buttons.Apple: () => _handleMultiFactorException(
              _signInWithApple,
            ),
      };
    } else {
      authButtons = {
        //   Buttons.Apple: () => _handleMultiFactorException(
        //         _signInWithApple,
        //       ),
        Buttons.Google: () => _handleMultiFactorException(
              _signInWithGoogle,
            ),
        //   Buttons.GitHub: () => _handleMultiFactorException(
        //         _signInWithGitHub,
        //       ),
        //   Buttons.Microsoft: () => _handleMultiFactorException(
        //         _signInWithMicrosoft,
        //       ),
        //   Buttons.Twitter: () => _handleMultiFactorException(
        //         _signInWithTwitter,
        //       ),
        //   Buttons.Yahoo: () => _handleMultiFactorException(
        //         _signInWithYahoo,
        //       ),
      };
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
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
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: SafeArea(
                    child: Form(
                      key: formKey,
                      autovalidateMode: AutovalidateMode.onUserInteraction,
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 400),
                        child: Column(
                          children: [
                            Visibility(
                              visible: error.isNotEmpty,
                              child: MaterialBanner(
                                backgroundColor: Theme.of(context).errorColor,
                                content: Text(error),
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
                            const SizedBox(height: 20),
                            SizedBox(
                              height: 240,
                              child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    if (mode != AuthMode.phone)
                                      Column(
                                        children: [
                                          TextFormField(
                                            controller: emailController,
                                            decoration: const InputDecoration(
                                                hintText: 'Email',
                                                border: OutlineInputBorder()),
                                            validator: (value) =>
                                                value != null &&
                                                        value.isNotEmpty
                                                    ? null
                                                    : 'Required',
                                          ),
                                          const SizedBox(height: 20),
                                          TextFormField(
                                            controller: passwordController,
                                            obscureText: true,
                                            decoration: const InputDecoration(
                                              hintText: 'Password',
                                              border: OutlineInputBorder(),
                                            ),
                                            validator: (value) =>
                                                value != null &&
                                                        value.isNotEmpty
                                                    ? null
                                                    : 'Required',
                                          ),
                                        ],
                                      ),
                                    if (mode == AuthMode.phone)
                                      TextFormField(
                                        controller: phoneController,
                                        decoration: const InputDecoration(
                                          hintText: '+12345678910',
                                          labelText: 'Phone number',
                                          border: OutlineInputBorder(),
                                        ),
                                        validator: (value) =>
                                            value != null && value.isNotEmpty
                                                ? null
                                                : 'Required',
                                      ),
                                  ]),
                            ),
                            const SizedBox(height: 20),
                            SizedBox(
                              width: double.infinity,
                              height: 60,
                              child: ElevatedButton(
                                onPressed: isLoading
                                    ? null
                                    : () => _handleMultiFactorException(
                                          _emailAndPassword,
                                        ),
                                child: isLoading
                                    ? const CircularProgressIndicator.adaptive()
                                    : Text(mode.label),
                              ),
                            ),
                            TextButton(
                              onPressed: _resetPassword,
                              child: const Text('Forgot password?'),
                            ),
                            ...authButtons.keys
                                .map(
                                  (button) => Padding(
                                    padding:
                                        const EdgeInsets.symmetric(vertical: 5),
                                    child: AnimatedSwitcher(
                                      duration:
                                          const Duration(milliseconds: 200),
                                      child: isLoading
                                          ? Container(
                                              decoration: BoxDecoration(
                                                borderRadius:
                                                    BorderRadius.circular(9999),
                                                color: Theme.of(context)
                                                    .primaryColor,
                                              ),
                                              width: double.infinity,
                                              height: 60,
                                              child: const Center(
                                                child: CircularProgressIndicator
                                                    .adaptive(),
                                              ))
                                          : SizedBox(
                                              width: double.infinity,
                                              height: 60,
                                              child: SignInButton(
                                                button,
                                                onPressed: authButtons[button]!,
                                              ),
                                            ),
                                    ),
                                  ),
                                )
                                .toList(),
                            const SizedBox(height: 20),
                            SizedBox(
                              width: double.infinity,
                              height: 60,
                              child: OutlinedButton(
                                onPressed: isLoading
                                    ? null
                                    : () {
                                        if (mode != AuthMode.phone) {
                                          setState(() {
                                            mode = AuthMode.phone;
                                          });
                                        } else {
                                          setState(() {
                                            mode = AuthMode.login;
                                          });
                                        }
                                      },
                                child: isLoading
                                    ? const CircularProgressIndicator.adaptive()
                                    : Text(
                                        mode != AuthMode.phone
                                            ? 'Sign in with Phone Number'
                                            : 'Sign in with Email and Password',
                                      ),
                              ),
                            ),
                            const SizedBox(height: 20),
                            SizedBox(
                                height: 60,
                                child: mode != AuthMode.phone
                                    ? RichText(
                                        text: TextSpan(
                                          style: Theme.of(context)
                                              .textTheme
                                              .bodyText1,
                                          children: [
                                            TextSpan(
                                              text: mode == AuthMode.login
                                                  ? "Don't have an account? "
                                                  : 'You have an account? ',
                                            ),
                                            TextSpan(
                                              text: mode == AuthMode.login
                                                  ? 'Register now'
                                                  : 'Click to login',
                                              style: const TextStyle(
                                                  color: Colors.blue),
                                              recognizer: TapGestureRecognizer()
                                                ..onTap = () {
                                                  setState(() {
                                                    mode =
                                                        mode == AuthMode.login
                                                            ? AuthMode.register
                                                            : AuthMode.login;
                                                  });
                                                },
                                            ),
                                          ],
                                        ),
                                      )
                                    : null),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future _resetPassword() async {
    String? email;
    await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Send'),
            ),
          ],
          content: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('Enter your email'),
              const SizedBox(height: 20),
              TextFormField(
                onChanged: (value) {
                  email = value;
                },
              ),
            ],
          ),
        );
      },
    );

    if (email != null) {
      try {
        await _auth.sendPasswordResetEmail(email: email!);
        ScaffoldSnackbar.of(context).show('Password reset email is sent');
      } catch (e) {
        ScaffoldSnackbar.of(context).show('Error resetting');
      }
    }
  }

  Future<void> _anonymousAuth() async {
    setIsLoading();

    try {
      await _auth.signInAnonymously();
    } on FirebaseAuthException catch (e) {
      setState(() {
        error = '${e.message}';
      });
    } catch (e) {
      setState(() {
        error = '$e';
      });
    } finally {
      setIsLoading();
    }
  }

  Future<void> _handleMultiFactorException(
    Future<void> Function() authFunction,
  ) async {
    setIsLoading();
    try {
      await authFunction();
    } on FirebaseAuthMultiFactorException catch (e) {
      setState(() {
        error = '${e.message}';
      });
      final firstHint = e.resolver.hints.first;
      if (firstHint is! PhoneMultiFactorInfo) {
        return;
      }
      final auth = FirebaseAuth.instance;
      await auth.verifyPhoneNumber(
        multiFactorSession: e.resolver.session,
        multiFactorInfo: firstHint,
        verificationCompleted: (_) {},
        verificationFailed: print,
        codeSent: (String verificationId, int? resendToken) async {
          final smsCode = await getSmsCodeFromUser(context);

          if (smsCode != null) {
            // Create a PhoneAuthCredential with the code
            final credential = PhoneAuthProvider.credential(
              verificationId: verificationId,
              smsCode: smsCode,
            );

            try {
              await e.resolver.resolveSignIn(
                PhoneMultiFactorGenerator.getAssertion(
                  credential,
                ),
              );
            } on FirebaseAuthException catch (e) {
              if (kDebugMode) {
                print(e.message);
              }
            }
          }
        },
        codeAutoRetrievalTimeout: print,
      );
    } on FirebaseAuthException catch (e) {
      setState(() {
        error = '${e.message}';
      });
    } catch (e) {
      setState(() {
        error = '$e';
      });
    } finally {
      setIsLoading();
    }
  }

  Future<void> _emailAndPassword() async {
    if (formKey.currentState?.validate() ?? false) {
      setIsLoading();
      if (mode == AuthMode.login) {
        await _auth.signInWithEmailAndPassword(
          email: emailController.text,
          password: passwordController.text,
        );
      } else if (mode == AuthMode.register) {
        await _auth.createUserWithEmailAndPassword(
          email: emailController.text,
          password: passwordController.text,
        );
      } else {
        await _phoneAuth();
      }
    }
  }

  Future<void> _phoneAuth() async {
    if (mode != AuthMode.phone) {
      setState(() {
        mode = AuthMode.phone;
      });
    } else {
      if (kIsWeb) {
        final confirmationResult =
            await _auth.signInWithPhoneNumber(phoneController.text);
        final smsCode = await getSmsCodeFromUser(context);

        if (smsCode != null) {
          await confirmationResult.confirm(smsCode);
        }
      } else {
        await _auth.verifyPhoneNumber(
          phoneNumber: phoneController.text,
          verificationCompleted: (_) {},
          verificationFailed: (e) {
            setState(() {
              error = '${e.message}';
            });
          },
          codeSent: (String verificationId, int? resendToken) async {
            final smsCode = await getSmsCodeFromUser(context);

            if (smsCode != null) {
              // Create a PhoneAuthCredential with the code
              final credential = PhoneAuthProvider.credential(
                verificationId: verificationId,
                smsCode: smsCode,
              );

              try {
                // Sign the user in (or link) with the credential
                await _auth.signInWithCredential(credential);
              } on FirebaseAuthException catch (e) {
                setState(() {
                  error = e.message ?? '';
                });
              }
            }
          },
          codeAutoRetrievalTimeout: (e) {
            setState(() {
              error = e;
            });
          },
        );
      }
    }
  }

  Future<void> _signInWithGoogle() async {
    // Trigger the authentication flow
    final googleUser = await GoogleSignIn().signIn();

    // Obtain the auth details from the request
    final googleAuth = await googleUser?.authentication;

    if (googleAuth != null) {
      // Create a new credential
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      // Once signed in, return the UserCredential
      await _auth.signInWithCredential(credential);
    }
  }

  Future<void> _signInWithTwitter() async {
    TwitterAuthProvider twitterProvider = TwitterAuthProvider();

    if (kIsWeb) {
      await _auth.signInWithPopup(twitterProvider);
    } else {
      await _auth.signInWithProvider(twitterProvider);
    }
  }

  Future<void> _signInWithApple() async {
    final appleProvider = AppleAuthProvider();
    appleProvider.addScope('email');

    if (kIsWeb) {
      // Once signed in, return the UserCredential
      await _auth.signInWithPopup(appleProvider);
    } else {
      await _auth.signInWithProvider(appleProvider);
    }
  }

  Future<void> _signInWithYahoo() async {
    final yahooProvider = YahooAuthProvider();

    if (kIsWeb) {
      // Once signed in, return the UserCredential
      await _auth.signInWithPopup(yahooProvider);
    } else {
      await _auth.signInWithProvider(yahooProvider);
    }
  }

  Future<void> _signInWithGitHub() async {
    final githubProvider = GithubAuthProvider();

    if (kIsWeb) {
      await _auth.signInWithPopup(githubProvider);
    } else {
      await _auth.signInWithProvider(githubProvider);
    }
  }

  Future<void> _signInWithMicrosoft() async {
    final microsoftProvider = MicrosoftAuthProvider();

    if (kIsWeb) {
      await _auth.signInWithPopup(microsoftProvider);
    } else {
      await _auth.signInWithProvider(microsoftProvider);
    }
  }
}

Future<String?> getSmsCodeFromUser(BuildContext context) async {
  String? smsCode;

  // Update the UI - wait for the user to enter the SMS code
  await showDialog<String>(
    context: context,
    barrierDismissible: false,
    builder: (context) {
      return AlertDialog(
        title: const Text('SMS code:'),
        actions: [
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: const Text('Sign in'),
          ),
          OutlinedButton(
            onPressed: () {
              smsCode = null;
              Navigator.of(context).pop();
            },
            child: const Text('Cancel'),
          ),
        ],
        content: Container(
          padding: const EdgeInsets.all(20),
          child: TextField(
            onChanged: (value) {
              smsCode = value;
            },
            textAlign: TextAlign.center,
            autofocus: true,
          ),
        ),
      );
    },
  );

  return smsCode;
}