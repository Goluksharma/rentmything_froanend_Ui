import 'package:flutter/material.dart';
import '../pages/register_page.dart';
import '../pages/profile_page.dart';
import '../layout/main_layout.dart';
import '../models/user.dart';

class AppRoutes {
  static const String home = '/home';
  static const String login = '/login';
  static const String register = '/register';
  static const String profile = '/profile';

  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case home:
        final userMap = settings.arguments as Map<String, dynamic>?;
        return MaterialPageRoute(
          builder: (_) =>
              MainLayout(isLoggedIn: userMap != null, userData: userMap),
        );

      case login:
        return MaterialPageRoute(
          builder: (_) => const MainLayout(isLoggedIn: false),
        );

      case register:
        return MaterialPageRoute(builder: (_) => const RegisterPage());

      case profile:
        final userMap = settings.arguments as Map<String, dynamic>;
        final user = User.fromMap(userMap);
        return MaterialPageRoute(builder: (_) => ProfilePage(user: user));

      default:
        return MaterialPageRoute(
          builder: (_) => const MainLayout(isLoggedIn: false),
        );
    }
  }
}
