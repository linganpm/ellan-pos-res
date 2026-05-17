import 'package:flutter/material.dart';
import 'package:pos_tablet/presentation/screens/welcome_screen.dart';
import 'package:pos_tablet/presentation/screens/sign_in_screen.dart';
import 'package:pos_tablet/presentation/screens/store_list_screen.dart';
import 'package:pos_tablet/presentation/screens/home_screen.dart';

/// Centralised route names and route generation for the application.
///
/// Use `AppRoutes.name` constants across the app to avoid stringly-typed
/// navigation and to keep a single source of truth for routes.
class AppRoutes {
  static const String onboarding = 'onboarding';
  static const String login = 'login';
  static const String storeList = 'storeList';
  static const String home = 'home';

  /// A simple map suitable for passing to [MaterialApp.routes].
  static Map<String, WidgetBuilder> get routes => {
        onboarding: (context) => const WelcomeScreen(),
        login: (context) => const SignInScreen(),
        storeList: (context) => const StoreListScreen(),
        home: (context) => const HomeScreen(),
      };

  /// A route generator which can be used with [MaterialApp.onGenerateRoute]
  /// if you need more complex logic later (arguments, guards, transitions).
  static Route<dynamic>? generate(RouteSettings settings) {
    switch (settings.name) {
      case onboarding:
        return MaterialPageRoute(builder: (_) => const WelcomeScreen());
      case login:
        return MaterialPageRoute(builder: (_) => const SignInScreen());
      case storeList:
        return MaterialPageRoute(builder: (_) => const StoreListScreen());
      case home:
        return MaterialPageRoute(builder: (_) => const HomeScreen());
      default:
        return null;
    }
  }
}

