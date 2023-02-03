import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:intune/constants/supabase.dart';
import 'package:intune/routes/router.gr.dart';
import 'package:intune/services/spotify_auth_api.dart';
import 'package:intune/services/supabase/supabase_helper.dart';
import 'package:intune/util/logger.dart';
import 'package:oauth2/oauth2.dart';
import 'package:spotify/spotify.dart';

final _auth = supabase.auth;

class ProfileSettings extends StatefulWidget {
  const ProfileSettings({
    Key? key,
  }) : super(key: key);

  @override
  State<ProfileSettings> createState() => _ProfileSettingsState();
}

class _ProfileSettingsState extends State<ProfileSettings> {
  bool _isLoading = true;

  @override
  Widget build(BuildContext context) {
    return Container();
  }
}
