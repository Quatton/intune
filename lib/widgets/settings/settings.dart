import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intune/widgets/settings/profile_settings.dart';

import 'header.dart';

final _auth = FirebaseAuth.instance;

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        children: [
          SettingsHeader(),
          ProfileSettings(),
          SizedBox(
              width: double.infinity,
              height: 80,
              child: Container(
                  color: Theme.of(context).primaryColor,
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text("Connection with Spotify",
                                style: Theme.of(context).textTheme.bodyText1),
                            ElevatedButton(
                                onPressed: () {}, child: const Text("Connect"))
                          ],
                        ),
                      ],
                    ),
                  )))
        ],
      ),
    );
  }
}



// Use this 'https://i.scdn.co/image/${snapshot.data!.track!.imageUri.raw.split(':').last}' to get the album art