import 'package:flutter/material.dart';
import 'package:peche/screen/home_screen.dart';
import '../screen/login_screen.dart';
import '../screen/view/ficherman_management_view.dart';


class AppRoutes {
  // Route names
  static const String login = '/login';
  static const String dashboard = '/dashboard';
  static const String home = '/home';
  static const String fishermanManagement ='/fishermanManagement';

  // Route generator
  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case login:
        return MaterialPageRoute(builder: (_) => const LoginScreen());

      case home:
        return MaterialPageRoute(builder: (_) => const HomeScreen());

      case AppRoutes.fishermanManagement:
        return MaterialPageRoute(
          builder: (_) => const FishermanManagementView(),
        );
      default:
        return MaterialPageRoute(
          builder: (_) => Scaffold(
            body: Center(
              child: Text('Aucune route définie pour ${settings.name}'),
            ),
          ),
        );
    }
  }
}