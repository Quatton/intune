import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:intune/constants/supabase.dart';
import 'package:intune/routes/router.gr.dart';
import 'package:intune/services/spotify_auth_api.dart';
import 'package:spotify/spotify.dart';

final _auth = supabase.auth;

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
            child: FutureBuilder<User>(
                future: SpotifyClient.spotify.me.get(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
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
                            foregroundImage: NetworkImage(snapshot
                                    .data?.images![0].url ??
                                'https://api.dicebear.com/5.x/bottts/png?seed=${_auth.currentUser!.id}'),
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
                            ElevatedButton(
                                onPressed: () async {
                                  await _auth.signOut();
                                  context.router.pushAndPopUntil(
                                      const SplashRoute(),
                                      predicate: (route) => false);
                                },
                                child: const Text("Logout"))
                          else
                            ElevatedButton(
                                onPressed: () async {
                                  await SpotifyClient.getAccessToken(context);

                                  setState(() {});
                                },
                                child: const Text("Connect to Spotify"))
                        ]),
                  );
                })));
  }
}
