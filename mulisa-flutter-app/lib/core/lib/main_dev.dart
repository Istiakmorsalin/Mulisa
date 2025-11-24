// lib/main_dev.dart
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mulisa/core/di/injector.dart';
import 'package:mulisa/core/routes.dart';
import '../../features/splash/view/splash_page.dart';
import '../config.dart';


Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final baseTheme = ThemeData(
    useMaterial3: true,
    colorSchemeSeed: Colors.blueAccent,
  );

  final config = AppConfig(
    env: AppEnv.dev,
    appTitle: 'MULISA (DEV)',
    baseUrl: _getDevBaseUrl(),
    theme: baseTheme.copyWith(
      textTheme: GoogleFonts.robotoTextTheme(baseTheme.textTheme),
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.blue,   // top bar background
        foregroundColor: Colors.white,   // text & icons
        elevation: 10,                    // flat
        centerTitle: true,
      ),
    ),
    showDebugBanner: true,
    enableLogging: true,
  );

  await configureDependencies(config);
  runApp(MulisaApp(config: config));
}

String _getDevBaseUrl() {
  if (Platform.isAndroid) {
    // If using Android Emulator:
    //return 'http://10.0.2.2:8000/api';

    // If using Physical Android Device (uncomment this instead):
    return 'http://10.0.0.79:8000/api';
  }

  // iOS Simulator or other platforms
  return 'http://127.0.0.1:8000/api';
}

class MulisaApp extends StatelessWidget {
  final AppConfig config;
  const MulisaApp({super.key, required this.config});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: config.appTitle,
      debugShowCheckedModeBanner: config.showDebugBanner,
      theme: config.theme,
      initialRoute: SplashPage.routeName, // 👈 Start from splash
      onGenerateRoute: (settings) => AppRoutes.onGenerateRoute(settings, config),
      builder: (context, child) {
        if (config.isProd) return child!;
        // Tiny env badge
        return Stack(
          children: [
            child!,
            Positioned(
              left: 8, bottom: 8,
              child: DecoratedBox(
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.7),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  child: Text('DEV', style: TextStyle(color: Colors.white, fontSize: 11)),
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}
