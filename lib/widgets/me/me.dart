import 'package:flutter/material.dart';

import 'header.dart';
import 'profile.dart';

class MePage extends StatelessWidget {
  const MePage({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        children: [
          SettingsHeader(),
          ProfileSettings(),
        ],
      ),
    );
  }
}



// Use this 'https://i.scdn.co/image/${snapshot.data!.track!.imageUri.raw.split(':').last}' to get the album art