import 'package:flutter/material.dart';
import 'package:intune/services/spotify_auth_api.dart';
import 'package:intune/services/supabase/supabase_helper.dart';
import 'package:intune/util/logger.dart';

import 'package:intune/widgets/friends.dart';
import 'package:intune/widgets/match.dart';
import 'package:intune/widgets/me/me.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _currentIndex = 0;
  final List<Widget> _pages = [
    const FriendsPage(),
    const MatchPage(),
    const MePage(),
  ];

  @override
  void initState() {
    super.initState();

    try {
      final credentials = AuthHelper.getSpotifyCredentials();
      if (credentials != null) SpotifyClient.saveCredentials(credentials);
    } on SupabaseHelperException catch (e) {
      Log.setStatus("Error: ${e.message} Hehe");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (int index) {
          setState(() {
            _currentIndex = index;
          });
        },
        items: const <BottomNavigationBarItem>[
          // friends
          BottomNavigationBarItem(
            icon: Icon(Icons.people),
            label: "Friends",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.search),
            label: "Match",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: "Me",
          ),
          // friends icon
        ],
      ),
      body: SafeArea(
        child: IndexedStack(
          index: _currentIndex,
          children: _pages,
        ),
      ),
    );
  }
}
