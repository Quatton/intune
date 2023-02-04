import 'package:flutter/material.dart';
import 'package:intune/services/spotify_api.dart';
import 'package:intune/util/logger.dart';
import 'package:spotify/spotify.dart' hide Image;

class TopArtists extends StatelessWidget {
  static const _padding = 16.0;
  static const _imageSize = 80.0;
  static const _dividerHeight = 2.0;
  static final _rowHeight = _imageSize + _padding * 2;
  static final _topArtistCount = 5;
  static final _topTrackCount = 5;
  static final _containerHeight = _rowHeight * _topArtistCount +
      _dividerHeight * (_topArtistCount - 1) +
      _padding * 2;

  const TopArtists({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(24.0),
          child: Text("My Top Artists",
              style: Theme.of(context).textTheme.headline5),
        ),
        FutureBuilder<Iterable<Artist>>(
          future: SpotifyClient.spotify.me
              .topArtists(_topArtistCount, 0, 'medium_term'),
          builder: (BuildContext context, snapshot) {
            if (snapshot.hasError) {
              Log.setStatus('TopArtists: ${snapshot.error}');
            }

            return SizedBox(
              width: MediaQuery.of(context).size.width * 0.95,
              child: Table(
                defaultVerticalAlignment: TableCellVerticalAlignment.middle,
                columnWidths: const {
                  0: FixedColumnWidth(50),
                  1: FixedColumnWidth(_imageSize + _padding * 2),
                  2: FlexColumnWidth(),
                },
                children:
                    List<int>.generate(_topArtistCount, (int index) => index)
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
                        padding: const EdgeInsets.all(_padding),
                        child: Image.network(artist!.images![0].url!,
                            width: _imageSize, height: _imageSize),
                      )
                    else
                      Padding(
                        padding: const EdgeInsets.all(_padding),
                        child: Container(
                          width: _imageSize,
                          height: _imageSize,
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
      ],
    );
  }
}
