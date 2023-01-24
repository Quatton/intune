import 'package:flutter/material.dart';

import 'header.dart';
import 'profile.dart';
import 'spotify_stat.dart';

class MePage extends StatelessWidget {
  const MePage({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        children: [SettingsHeader(), ProfileSettings(), SpotifyStat()],
      ),
    );
  }
}

// Use this 'https://i.scdn.co/image/${snapshot.data!.track!.imageUri.raw.split(':').last}' to get the album art