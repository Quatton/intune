import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:intune/constants/supabase.dart';
import 'package:intune/services/spotify_api.dart';
import 'package:spotify/spotify.dart' as spotify;
import 'package:supabase_flutter/supabase_flutter.dart';

part 'supabase_auth.dart';
part 'supabase_database.dart';

class SupabaseHelperException implements Exception {
  final String message;
  SupabaseHelperException(this.message);
}
