import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:intune/constants/supabase.dart';
import 'package:intune/routes/router.gr.dart';
import 'package:intune/services/spotify_api.dart';
import 'package:intune/util/logger.dart';
import 'package:spotify/spotify.dart' hide Image;

class Profile extends StatefulWidget {
  const Profile({
    Key? key,
  }) : super(key: key);

  @override
  State<Profile> createState() => _ProfileState();
}

class _ProfileState extends State<Profile> {
  @override
  Widget build(BuildContext context) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Container(
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
              child: FutureBuilder<User>(
                  future: SpotifyClient.spotify.me.get(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    }

                    String profileUrl;
                    try {
                      profileUrl = snapshot.data!.images![0].url!;
                    } catch (e) {
                      Log.setStatus("No profile will use robots");
                      profileUrl =
                          'https://api.dicebear.com/5.x/bottts/png?seed=${supabase.auth.currentUser!.id}';
                    }

                    return Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            // profile picture from 'https://api.dicebear.com/5.x/bottts/png?seed=${_auth.currentUser!.uid}' mask with white circle
                            CircleAvatar(
                              radius: 48,
                              foregroundImage: NetworkImage(profileUrl),
                            ),
                            const SizedBox(height: 24),
                            // create a table
                            if (snapshot.hasData)
                              Text("${snapshot.data!.displayName}",
                                  style: Theme.of(context).textTheme.headline6)
                            else
                              const Text("You're not connected to Spotify!"),

                            const SizedBox(height: 24),
                            // logout button
                            if (snapshot.hasData)
                              ElevatedButton.icon(
                                  icon: const Icon(Icons.logout_rounded),
                                  onPressed: () {
                                    supabase.auth.signOut();
                                    context.router.pushAndPopUntil(
                                        const SplashRoute(),
                                        predicate: (route) => false);
                                  },
                                  label: Text('Logout'))
                            else
                              ElevatedButton(
                                  onPressed: () async {
                                    await SpotifyClient.getAccessToken();

                                    setState(() {});
                                  },
                                  child: const Text("Connect to Spotify"))
                          ]),
                    );
                  }))),
    ]);
  }
}
