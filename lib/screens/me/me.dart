import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:intune/constants/supabase.dart';
import 'package:intune/routes/router.gr.dart';
import 'package:intune/services/spotify_api.dart';

import 'header.dart';
import 'profile.dart';
import 'profile.dart';

class MePage extends StatelessWidget {
  const MePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Me')),
      body: SingleChildScrollView(
        child: Column(
          children: [Profile()],
        ),
      ),
    );
  }
}

// Use this 'https://i.scdn.co/image/${snapshot.data!.track!.imageUri.raw.split(':').last}' to get the album art