import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'core/routes/app_routes.dart';
import 'core/routes/app_router.dart';
import 'core/theme/app_theme.dart';
import 'controllers/auth_controller.dart';
import 'controllers/locale_controller.dart';
import 'controllers/theme_controller.dart';
import 'views/auth/login_screen.dart';
import 'views/splash/splash_screen.dart';

class ChefUnitPlusApp extends StatefulWidget {
  const ChefUnitPlusApp({super.key});

  @override
  State<ChefUnitPlusApp> createState() => _ChefUnitPlusAppState();
}

class _ChefUnitPlusAppState extends State<ChefUnitPlusApp> {
  bool _bootstrapped = false;
  final _navigatorKey = GlobalKey<NavigatorState>();
  AuthState? _lastState;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted && !_bootstrapped) {
        _bootstrapped = true;
        context.read<AuthController>().bootstrap();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final authState = context.select<AuthController, AuthState>((a) => a.state);
    final themeMode = context.watch<ThemeController>().mode;
    final locale = context.watch<LocaleController>().locale;

    if (_lastState != null &&
        _lastState != authState &&
        authState == AuthState.unauthenticated) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _navigatorKey.currentState?.pushNamedAndRemoveUntil(
          AppRoutes.login,
          (route) => false,
        );
      });
    }
    _lastState = authState;

    return MaterialApp(
      title: 'ChefUnitPlus',
      debugShowCheckedModeBanner: false,
      navigatorKey: _navigatorKey,
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      themeMode: themeMode,
      locale: locale,
      onGenerateInitialRoutes: (initialRoute) {
        return [
          MaterialPageRoute(
            builder: (_) => const SplashScreen(),
            settings: const RouteSettings(name: AppRoutes.splash),
          ),
        ];
      },
      onGenerateRoute: AppRouter.onGenerateRoute,
      onUnknownRoute: (settings) => MaterialPageRoute(
        builder: (_) => const LoginScreen(),
      ),
    );
  }
}