import 'dart:async';

import 'package:flutter/services.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:intune/constants/supabase.dart';
import 'package:intune/services/supabase/supabase_helper.dart';
import 'package:intune/util/logger.dart';
import 'package:oauth2_client/oauth2_helper.dart';
import 'package:oauth2_client/spotify_oauth2_client.dart';
import 'package:spotify/spotify.dart';
import 'package:spotify_sdk/spotify_sdk.dart';

final _auth = supabase.auth;

class SpotifyClient {
  static final clientId = dotenv.get("SPOTIFY_CLIENT_ID");
  static final clientSecret = dotenv.get("SPOTIFY_CLIENT_SECRET");
  static final redirectUrl = dotenv.get("SPOTIFY_REDIRECT_URI");
  static final _apiRoute = "https://api.spotify.com/v1/";
  static final scopes = [
    'user-read-private',
    'user-read-email',
    'app-remote-control',
    'user-modify-playback-state',
    'playlist-read-private',
    'playlist-modify-public',
    'user-read-currently-playing',
    'user-read-playback-position',
    'user-top-read',
    'user-read-recently-played',
  ];

  static SpotifyApiCredentials credentials =
      SpotifyApiCredentials(clientId, clientSecret);
  static SpotifyApi _spotify = SpotifyApi(credentials);

  static SpotifyApi get spotify {
    return SpotifyApi(credentials);
  }

  static final _client = SpotifyOAuth2Client(
      redirectUri: redirectUrl, customUriScheme: "com.quattonary.intune");
  static final helper = OAuth2Helper(
    _client,
    grantType: OAuth2Helper.authorizationCode,
    clientId: clientId,
    enablePKCE: true,
    scopes: scopes,
  );

  static Future<void> connectToSpotifyRemote() async {
    final credentials = await spotify.getCredentials();
    final accessToken = credentials.accessToken ?? await getAccessToken();
    if (accessToken == null) throw Exception("No access token found");
    await SpotifySdk.connectToSpotifyRemote(
        clientId: dotenv.get("SPOTIFY_CLIENT_ID"),
        redirectUrl: dotenv.get("SPOTIFY_REDIRECT_URI"),
        accessToken: accessToken);
  }

  static Future<String> _getAccessToken() async {
    try {
      var authenticationToken = await SpotifySdk.getAccessToken(
          clientId: clientId,
          redirectUrl: redirectUrl,
          scope: scopes.join(', '));
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

  static Future<String?> getAccessToken() async {
    // final grant = SpotifyApi.authorizationCodeGrant(_credentials);

    // final authUri = grant.getAuthorizationUrl(
    //   Uri.parse(_redirectUrl),
    //   scopes: scopes, // scopes are optional
    // );

    // AutoRouter.of(context).push(WebViewRoute(launchUrl: authUri));

    final response = await _client.getTokenWithAuthCodeFlow(
        webAuthOpts: {'preferEphemeral': true},
        enablePKCE: true,
        clientId: clientId,
        scopes: scopes);

    final credentials = SpotifyApiCredentials(clientId, clientSecret,
        accessToken: response.accessToken,
        refreshToken: response.refreshToken,
        expiration: response.expirationDate,
        scopes: scopes);

    saveCredentials(credentials);
    return response.accessToken;
  }

  static Future<void> saveCredentials(
      SpotifyApiCredentials newCredentials) async {
    credentials = newCredentials;
    final creds = await spotify.getCredentials();
    Log.setStatus(creds.canRefresh.toString());
  }

  static Future<void> refreshCredentials() async {
    if (credentials.expiration != null &&
        DateTime.now().isBefore(credentials.expiration!)) return;
    final creds = await spotify.getCredentials();
    await saveCredentials(creds);
  }

  static Future<void> disconnect() async {
    credentials = SpotifyApiCredentials(clientId, clientSecret);
    AuthHelper.deleteSpotifyCredentials();
    DatabaseHelper.deleteSpotifyLink();
    final creds = await spotify.getCredentials();
    Log.setStatus(creds.canRefresh.toString());
  }
}
