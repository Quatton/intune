part of 'supabase_helper.dart';

class DatabaseHelper {
  static Future<void> updateSpotifyLink(
      {required spotify.SpotifyApiCredentials credentials}) async {
    try {
      final spotifyUser = await spotify.SpotifyApi(credentials).me.get();

      await AuthHelper.updateSpotifyCredentials(
        credentials: credentials,
      );

      await supabase.from("spotify_integration").upsert({
        'id': _auth.currentUser!.id,
        'spotify_uid': spotifyUser.id,
      }).eq('id', _auth.currentUser!.id);
    } on PostgrestException catch (error) {
      rethrow;
    } on SupabaseHelperException catch (error) {
      rethrow;
    } catch (error) {
      throw SupabaseHelperException(error.toString());
    }
  }

  static Future<void> deleteSpotifyLink() async {
    try {
      await supabase
          .from("spotify_integration")
          .update({'spotify_uid': null}).eq('id', _auth.currentUser!.id);
      await AuthHelper.deleteSpotifyCredentials();
    } on PostgrestException catch (error) {
      rethrow;
    } catch (error) {
      throw SupabaseHelperException(error.toString());
    }
  }
}
