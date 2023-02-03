import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:intune/constants/supabase.dart';
import 'package:intune/routes/router.gr.dart';

import 'header.dart';
import 'profile.dart';
import 'spotify_stat.dart';

class MePage extends StatelessWidget {
  const MePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Me'),

          // insert actions that include logout icon
          actions: <Widget>[
            IconButton(
              icon: const Icon(Icons.logout_rounded),
              tooltip: 'Logout',
              onPressed: () {
                supabase.auth.signOut();
                context.router.pushAndPopUntil(const SplashRoute(),
                    predicate: (route) => false);
              },
            ),
          ]),
      body: SingleChildScrollView(
        child: Column(
          children: [ProfileSettings(), SpotifyStat()],
        ),
      ),
    );
  }
}

// Use this 'https://i.scdn.co/image/${snapshot.data!.track!.imageUri.raw.split(':').last}' to get the album art