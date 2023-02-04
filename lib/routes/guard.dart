import 'package:auto_route/auto_route.dart';
import 'package:intune/constants/supabase.dart';
import 'package:intune/routes/router.gr.dart';
import 'package:intune/services/spotify_api.dart';

class AuthGuard extends AutoRouteGuard {
  @override
  void onNavigation(NavigationResolver resolver, StackRouter router) {
    // the navigation is paused until resolver.next() is called with either
    // true to resume/continue navigation or false to abort navigation
    if (supabase.auth.currentUser != null) {
      // if user is authenticated we continue
      resolver.next(true);
    } else {
      // we redirect the user to our login page
      router.push(LoginRoute(onResult: (success) {
        resolver.next(success);
      }));
    }
  }
}
