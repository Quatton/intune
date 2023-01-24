import 'package:flutter/material.dart';
import 'package:intune/services/spotify_auth_api.dart';
import 'package:spotify/spotify.dart' hide Image;

class SpotifyStat extends StatelessWidget {
  const SpotifyStat({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text("My Top Artists"),
      FutureBuilder<Iterable<Artist>>(
        future: SpotifyClient.spotify.me.topArtists(),
        builder: (BuildContext context, AsyncSnapshot snapshot) {
          return ConstrainedBox(
            constraints: BoxConstraints(
                maxWidth: MediaQuery.of(context).size.width * 0.95),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.grey.shade900,
                borderRadius: BorderRadius.circular(8),
              ),
              height: 400,
              child: ListView.separated(
                itemCount: 5,
                separatorBuilder: (BuildContext context, int index) {
                  // return a straight line divider
                  return Divider(
                    height: 2,
                    color: Colors.grey.shade800,
                  );
                },
                itemBuilder: (BuildContext context, int index) {
                  return SizedBox(
                    height: 60,
                    child: Row(
                      children: [
                        Text("${index + 1}",
                            style: Theme.of(context).textTheme.headline6),
                        if (snapshot.hasData)
                          Image.network(
                            snapshot.data![index].images.first.url,
                            width: 50,
                            height: 50,
                          ),
                        if (snapshot.hasData) Text(snapshot.data![index].name),
                      ],
                    ),
                  );
                },
              ),
            ),
          );
        },
      ),
    ]);
  }
}
