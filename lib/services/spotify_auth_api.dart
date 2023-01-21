import 'dart:async';

import 'package:flutter/services.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:intune/util/logger.dart';
import 'package:spotify/spotify.dart';
import 'package:spotify_sdk/spotify_sdk.dart';

class SpotifyClient {
  static final _clientId = dotenv.get("SPOTIFY_CLIENT_ID");
  static final _clientSecret = dotenv.get("SPOTIFY_CLIENT_SECRET");
  static final _redirectUrl = dotenv.get("SPOTIFY_REDIRECT_URI");
  static final _scope = [
    'user-read-private',
    'user-read-email',
    'app-remote-control',
    'user-modify-playback-state',
    'playlist-read-private',
    'playlist-modify-public',
    'user-read-currently-playing',
  ].join(",");
  static final _credentials = SpotifyApiCredentials(_clientId, _clientSecret);

  static SpotifyApi spotify = SpotifyApi(_credentials);

  static Future<void> connectToSpotifyRemote() async {
    final accessToken = await getAccessToken();
    // Connect with Spotify Web API
    SpotifyClient.spotify = SpotifyApi.withAccessToken(accessToken);
    await SpotifySdk.connectToSpotifyRemote(
        clientId: dotenv.get("SPOTIFY_CLIENT_ID"),
        redirectUrl: dotenv.get("SPOTIFY_REDIRECT_URI"),
        accessToken: accessToken);
  }

  static Future<String> getAccessToken() async {
    try {
      var authenticationToken = await SpotifySdk.getAccessToken(
          clientId: _clientId, redirectUrl: _redirectUrl, scope: _scope);
      Log.setStatus('Got a token: $authenticationToken');
      return authenticationToken;
    } on PlatformException catch (e) {
      Log.setStatus(e.code, message: e.message);
      return Future.error('$e.code: $e.message');
    } on MissingPluginException {
      Log.setStatus('not implemented');
      return Future.error('not implemented');
    }
  }
}
