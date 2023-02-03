import 'package:flutter/material.dart';
import 'package:intune/services/spotify_auth_api.dart';
import 'package:intune/util/logger.dart';
import 'package:spotify/spotify.dart' hide Image;

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
                final artist = snapshot.data?.elementAt(index);
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
