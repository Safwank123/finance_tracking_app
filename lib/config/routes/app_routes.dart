import 'package:flutter/material.dart';
import '../../features/auth/presentation/screens/splash_screen.dart';
import '../../features/auth/presentation/screens/login_screen.dart';
import '../../features/auth/presentation/screens/register_screen.dart';
import '../../features/home/presentation/screens/home_screen.dart';

enum RouteNames {
  splash,
  register,
  home,
  login
}

extension RouteNamesExtension on RouteNames {
  String get name {
    switch (this) {
      case RouteNames.splash:
        return '/';
      case RouteNames.register:
        return '/register';
      case RouteNames.home:
        return '/home';
      case RouteNames.login:
        return '/login';
    }
  }
}

class AppRoutes {
  static Route<dynamic> onGenerateRoute(RouteSettings settings) {
    if (settings.name == RouteNames.splash.name) {
      return MaterialPageRoute(builder: (_) => const SplashScreen());
    } else if (settings.name == RouteNames.login.name) {
      return MaterialPageRoute(builder: (_) => const LoginScreen());
    } else if (settings.name == RouteNames.register.name) {
      return MaterialPageRoute(builder: (_) => const RegisterScreen());
    } else if (settings.name == RouteNames.home.name) {
      return MaterialPageRoute(builder: (_) => const HomeScreen());
    } else {
      return MaterialPageRoute(
        builder: (_) => Scaffold(
          body: Center(child: Text('No route defined for ${settings.name}')),
        ),
      );
    }
  }
}
