import 'package:firebase_auth/firebase_auth.dart';

class FirebaseLogin {
  static final FirebaseAuth _auth = FirebaseAuth.instance;

  static Future<void> signInAnonymously() async {
    try {
      final UserCredential authResult = await _auth.signInAnonymously();
      final User user = authResult.user!;
      print('${user.uid} signed in anonymously');
    } catch (e) {
      print(e.toString());
    }
  }

  static Future<void> signOut() async {
    await FirebaseAuth.instance.signOut();
  }
}
