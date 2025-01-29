import 'package:flutter/material.dart';

import '../Auth/login_screen.dart';
import '../screens/RegisterScreen.dart';
import '../screens/dashboard_screen.dart';

class AppRouter {
  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case '/login':
        return MaterialPageRoute(builder: (_) => LoginScreen());
      case '/user/register':
        return MaterialPageRoute(builder: (_) => UserRegisterScreen());
      case '/register':
        return MaterialPageRoute(builder: (_) => UserRegisterScreen());
      case '/adminPortal':
        return MaterialPageRoute(builder: (_) => DashboardScreen());
      default:
        return MaterialPageRoute(
          builder: (_) => Scaffold(
            body: Center(
              child: Text('No route defined for ${settings.name}'),
            ),
          ),
        );
    }
  }
}
