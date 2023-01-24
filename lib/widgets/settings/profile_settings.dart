import 'package:auto_route/annotations.dart';
import 'package:auto_route/auto_route.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intune/routes/router.gr.dart';
import 'package:intune/widgets/splash.dart';

final _auth = FirebaseAuth.instance;

class ProfileSettings extends StatefulWidget {
  const ProfileSettings({
    Key? key,
  }) : super(key: key);

  @override
  State<ProfileSettings> createState() => _ProfileSettingsState();
}

class _ProfileSettingsState extends State<ProfileSettings> {
  @override
  Widget build(BuildContext context) {
    return Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              //use two shades of gray
              Colors.green.shade500,
              Colors.grey.shade800,
            ],
          ),
        ),
        child: SizedBox(
            height: 300,
            width: double.infinity,
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    // profile picture from 'https://api.dicebear.com/5.x/bottts/png?seed=${_auth.currentUser!.uid}' mask with white circle
                    CircleAvatar(
                      radius: 48,
                      foregroundImage: NetworkImage(
                          'https://api.dicebear.com/5.x/bottts/png?seed=${_auth.currentUser!.uid}'),
                    ),
                    const SizedBox(height: 24),
                    // create a table
                    Text(_auth.currentUser!.displayName ?? '',
                        style: Theme.of(context).textTheme.headline6),
                    const SizedBox(height: 24),
                    // logout button
                    ElevatedButton(
                        onPressed: () async {
                          await _auth.signOut();
                          context.router.pushAndPopUntil(SplashRoute(),
                              predicate: (route) => false);
                        },
                        child: const Text("Logout")),
                  ]),
            )));
  }
}