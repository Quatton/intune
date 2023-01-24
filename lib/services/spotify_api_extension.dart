// create extenstion for SpotifyApi
import 'package:intune/util/logger.dart';
import 'package:spotify/spotify.dart';

extension SpotifyApiExtension on SpotifyApi {
  Future<void> getMe() async {
    final me = await this.me.get();
    Log.setStatus('Got a user: ${me.displayName}');
  }
}
