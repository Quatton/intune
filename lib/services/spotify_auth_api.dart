import 'dart:async';
import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:intune/constants/supabase.dart';
import 'package:intune/util/logger.dart';
import 'package:oauth2_client/access_token_response.dart';
import 'package:oauth2_client/oauth2_client.dart';
import 'package:oauth2_client/oauth2_helper.dart';
import 'package:oauth2_client/spotify_oauth2_client.dart';
import 'package:spotify/spotify.dart';
import 'package:spotify_sdk/spotify_sdk.dart';
import 'package:oauth2/src/client.dart';
import 'package:oauth2/src/credentials.dart';

final _auth = supabase.auth;

class SpotifyClient {
  static final _clientId = dotenv.get("SPOTIFY_CLIENT_ID");
  static final _clientSecret = dotenv.get("SPOTIFY_CLIENT_SECRET");
  static final _redirectUrl = dotenv.get("SPOTIFY_REDIRECT_URI");
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

  static final _credentials = SpotifyApiCredentials(_clientId, _clientSecret);
  static SpotifyApi spotify = SpotifyApi(_credentials);

  static final _client = SpotifyOAuth2Client(
      redirectUri: _redirectUrl, customUriScheme: "com.quattonary.intune");
  static final helper = OAuth2Helper(
    _client,
    grantType: OAuth2Helper.authorizationCode,
    clientId: _clientId,
    enablePKCE: true,
    scopes: scopes,
  );

  static Future<void> connectToSpotifyRemote() async {
    final accessToken = await _getAccessToken();
    await SpotifySdk.connectToSpotifyRemote(
        clientId: dotenv.get("SPOTIFY_CLIENT_ID"),
        redirectUrl: dotenv.get("SPOTIFY_REDIRECT_URI"),
        accessToken: accessToken);
  }

  static Future<String> _getAccessToken() async {
    try {
      var authenticationToken = await SpotifySdk.getAccessToken(
          clientId: _clientId,
          redirectUrl: _redirectUrl,
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

  static Future<AccessTokenResponse> getAccessToken(
      BuildContext context) async {
    // final grant = SpotifyApi.authorizationCodeGrant(_credentials);

    // final authUri = grant.getAuthorizationUrl(
    //   Uri.parse(_redirectUrl),
    //   scopes: scopes, // scopes are optional
    // );

    // AutoRouter.of(context).push(WebViewRoute(launchUrl: authUri));

    final response = await _client.getTokenWithAuthCodeFlow(
        enablePKCE: true, clientId: _clientId, scopes: scopes);

    spotify = SpotifyApi(SpotifyApiCredentials(_clientId, _clientSecret,
        accessToken: response.accessToken,
        refreshToken: response.refreshToken,
        expiration: response.expirationDate,
        scopes: scopes));
    final creds = await spotify.getCredentials();
    Log.setStatus(creds.canRefresh.toString());
    return response;
  }
}
