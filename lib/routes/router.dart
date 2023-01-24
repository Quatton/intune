// Create Material Auto Router

import 'package:auto_route/annotations.dart';
import 'package:auto_route/auto_route.dart';
import 'package:intune/routes/guard.dart';
import 'package:intune/widgets/auth.dart';
import 'package:intune/widgets/home.dart';
import 'package:intune/widgets/splash.dart';

@MaterialAutoRouter(
  replaceInRouteName: 'Page,Route',
  // Generate the routes with the specified routes
  routes: <AutoRoute>[
    // MaterialRoute page and initial set to true
    AutoRoute(page: SplashPage, path: '/', initial: true),
    AutoRoute(page: LoginPage, path: '/login'),
    AutoRoute(page: HomePage, path: '/home', guards: [AuthGuard])
  ],
)
class $AppRouter {}
