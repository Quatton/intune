part of 'supabase_helper.dart';

final _auth = supabase.auth;

class AuthHelper {
  static Future<void> updateSpotifyCredentials(
      {required spotify.SpotifyApiCredentials credentials}) async {
    try {
      final res = await _auth.updateUser(UserAttributes(
        data: {
          'accessToken': credentials.accessToken,
          'refreshToken': credentials.refreshToken,
          'expiration': credentials.expiration.toString()
        },
      ));
    } catch (error) {
      throw SupabaseHelperException(
          "Error Updating Spotify Credentials: ${error.toString()}");
    }
  }
}

extension SpotifyUser on User {
  spotify.SpotifyApiCredentials get credentials {
    try {
      final credentials = _auth.currentUser!.userMetadata!;
      return spotify.SpotifyApiCredentials(
        dotenv.get("SPOTIFY_CLIENT_ID"),
        dotenv.get("SPOTIFY_CLIENT_SECRET"),
        scopes: SpotifyClient.scopes,
        accessToken: credentials['accessToken'],
        refreshToken: credentials['refreshToken'],
        expiration: DateTime.tryParse(credentials['expiration']),
      );
    } catch (e) {
      return spotify.SpotifyApiCredentials(
        dotenv.get("SPOTIFY_CLIENT_ID"),
        dotenv.get("SPOTIFY_CLIENT_SECRET"),
      );
    }
  }
}
