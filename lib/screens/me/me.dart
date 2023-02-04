import 'package:flutter/material.dart';
import 'package:intune/screens/me/top_artists.dart';

import 'profile.dart';

class MePage extends StatelessWidget {
  const MePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Me')),
      body: SingleChildScrollView(
        child: Column(
          children: [Profile(), TopArtists()],
        ),
      ),
    );
  }
}

// Use this 'https://i.scdn.co/image/${snapshot.data!.track!.imageUri.raw.split(':').last}' to get the album art