// lib/main_prod.dart
import 'package:flutter/material.dart';

import 'package:mulisa/core/di/injector.dart';
import 'package:mulisa/core/routes.dart';

import '../../features/auth/view/login_page.dart';
import '../../features/splash/view/splash_page.dart';
import '../config.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final config = AppConfig(
    env: AppEnv.prod,
    appTitle: 'MULISA',
    baseUrl: 'https://example.com/api',
    theme: ThemeData(useMaterial3: true, colorSchemeSeed: Colors.blue),
    showDebugBanner: false,
    enableLogging: true,
  );

  await configureDependencies(config);
  runApp(MulisaApp(config: config));
}

class MulisaApp extends StatelessWidget {
  final AppConfig config;
  const MulisaApp({super.key, required this.config});

  @override
  Widget build(BuildContext context) => MaterialApp(
    title: config.appTitle,
    debugShowCheckedModeBanner: config.showDebugBanner,
    theme: config.theme,
    initialRoute: SplashPage.routeName, // 👈 Start from splash
    onGenerateRoute: (settings) => AppRoutes.onGenerateRoute(settings, config),
  );
}
