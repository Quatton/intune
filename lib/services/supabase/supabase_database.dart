part of 'supabase_helper.dart';

final _realtime = supabase.realtime;

class DatabaseHelper {
  static Future<void> updateSpotifyLink(
      {spotify.SpotifyApiCredentials? credentials}) async {
    try {
      credentials ??= await SpotifyClient.spotify.getCredentials();

      final spotifyUser = await spotify.SpotifyApi(credentials).me.get();

      await supabase.from("spotify_integration").upsert({
        'spotify_uid': spotifyUser.id,
      }).eq('id', _auth.currentUser!.id);
    } on PostgrestException catch (error) {
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
    } on PostgrestException catch (error) {
      rethrow;
    } catch (error) {
      throw SupabaseHelperException(error.toString());
    }
  }
}
