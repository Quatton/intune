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

  static spotify.SpotifyApiCredentials? getSpotifyCredentials() {
    try {
      final user = _auth.currentUser;
      if (user == null) throw SupabaseHelperException("No user found");
      final credentials = user.userMetadata!;
      return spotify.SpotifyApiCredentials(
        dotenv.get("SPOTIFY_CLIENT_ID"),
        dotenv.get("SPOTIFY_CLIENT_SECRET"),
        scopes: SpotifyClient.scopes,
        accessToken: credentials['accessToken'],
        refreshToken: credentials['refreshToken'],
        expiration: DateTime.tryParse(credentials['expiration']),
      );
    } on SupabaseHelperException {
      rethrow;
    } catch (error) {
      throw SupabaseHelperException(
          "Unable to get userMetadata: ${_auth.currentUser?.userMetadata}");
    }
  }

  static Future<void> deleteSpotifyCredentials() async {
    try {
      await _auth.updateUser(UserAttributes(
        data: {'accessToken': null, 'refreshToken': null, 'expiration': null},
      ));
    } catch (error) {
      throw SupabaseHelperException(
          "Error Deleting Spotify Credentials: ${error.toString()}");
    }
  }
}
