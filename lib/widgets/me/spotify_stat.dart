import 'package:flutter/material.dart';
import 'package:intune/services/spotify_auth_api.dart';
import 'package:intune/util/logger.dart';
import 'package:spotify/spotify.dart' hide Image;

import '../../constants/supabase.dart';

class SpotifyStat extends StatefulWidget {
  static const _padding = 16.0;
  static const _imageSize = 80.0;
  static const _dividerHeight = 2.0;
  static final _rowHeight = _imageSize + _padding * 2;
  static final _topArtistCount = 5;
  static final _topTrackCount = 5;
  static final _containerHeight = _rowHeight * _topArtistCount +
      _dividerHeight * (_topArtistCount - 1) +
      _padding * 2;

  const SpotifyStat({
    Key? key,
  }) : super(key: key);

  @override
  State<SpotifyStat> createState() => _SpotifyStatState();
}

class _SpotifyStatState extends State<SpotifyStat> {
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
                    } on RangeError catch (e) {
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
                              ElevatedButton(
                                  onPressed: () async {
                                    await SpotifyClient.disconnect();
                                    setState(() {});
                                  },
                                  child: const Text("Disconnect"))
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
      Padding(
        padding: const EdgeInsets.all(24.0),
        child: Text("My Top Artists",
            style: Theme.of(context).textTheme.headline5),
      ),
      FutureBuilder<Iterable<Artist>>(
        future: SpotifyClient.spotify.me
            .topArtists(SpotifyStat._topArtistCount, 0, 'medium_term'),
        builder: (BuildContext context, snapshot) {
          if (snapshot.hasError) {
            Log.setStatus('Error: ${snapshot.error}');
          }

          return SizedBox(
            width: MediaQuery.of(context).size.width * 0.95,
            child: Table(
              defaultVerticalAlignment: TableCellVerticalAlignment.middle,
              columnWidths: const {
                0: FixedColumnWidth(50),
                1: FixedColumnWidth(
                    SpotifyStat._imageSize + SpotifyStat._padding * 2),
                2: FlexColumnWidth(),
              },
              children: List<int>.generate(
                      SpotifyStat._topArtistCount, (int index) => index)
                  .map((int index) {
                Artist? artist;
                try {
                  artist = snapshot.data?.elementAt(index);
                } catch (e) {
                  artist = null;
                }
                return TableRow(children: [
                  Center(
                    child: Text("${index + 1}",
                        style: Theme.of(context).textTheme.headline2),
                  ),
                  if (artist?.images?[0].url != null)
                    Padding(
                      padding: const EdgeInsets.all(SpotifyStat._padding),
                      child: Image.network(artist!.images![0].url!,
                          width: SpotifyStat._imageSize,
                          height: SpotifyStat._imageSize),
                    )
                  else
                    Padding(
                      padding: const EdgeInsets.all(SpotifyStat._padding),
                      child: Container(
                        width: SpotifyStat._imageSize,
                        height: SpotifyStat._imageSize,
                        color: Colors.grey.shade800,
                      ),
                    ),
                  if (artist?.name != null)
                    Padding(
                      padding: const EdgeInsets.all(24.0),
                      child: Text(artist!.name!,
                          style: Theme.of(context).textTheme.bodyLarge),
                    )
                  else
                    const SizedBox(),
                ]);
              }).toList(),
            ),
          );
        },
      ),
    ]);
  }
}
