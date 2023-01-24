import 'dart:async';

import 'package:flutter/services.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:intune/constants/supabase.dart';
import 'package:intune/util/logger.dart';
import 'package:spotify/spotify.dart';
import 'package:spotify_sdk/spotify_sdk.dart';

final _auth = supabase.auth;

class SpotifyClient {
  static final _clientId = dotenv.get("SPOTIFY_CLIENT_ID");
  static final _clientSecret = dotenv.get("SPOTIFY_CLIENT_SECRET");
  static final _redirectUrl = dotenv.get("SPOTIFY_REDIRECT_URI");
  static final scopes = [
    'user-read-private',
    'user-read-email',
    'app-remote-control',
    'user-modify-playback-state',
    'playlist-read-private',
    'playlist-modify-public',
    'user-read-currently-playing',
  ].join(",");

  static final _credentials = SpotifyApiCredentials(_clientId, _clientSecret);

  static SpotifyApi get spotify => _auth.currentSession!.providerToken != null
      ? SpotifyApi.withAccessToken(_auth.currentSession!.providerToken!)
      : SpotifyApi(_credentials);

  static Future<void> connectToSpotifyRemote() async {
    final accessToken = await getAccessToken();
    await SpotifySdk.connectToSpotifyRemote(
        clientId: dotenv.get("SPOTIFY_CLIENT_ID"),
        redirectUrl: dotenv.get("SPOTIFY_REDIRECT_URI"),
        accessToken: accessToken);
  }

  static Future<String> getAccessToken() async {
    try {
      var authenticationToken = await SpotifySdk.getAccessToken(
          clientId: _clientId, redirectUrl: _redirectUrl, scope: scopes);
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

extension SpotifyApiExtension on SpotifyApi {
  Future<void> getMe() async {
    final me = await this.me.get();
    Log.setStatus('Got a user: ${me.displayName}');
  }
}
