// lib/core/app_config.dart
import 'package:flutter/material.dart';

enum AppEnv { dev, staging, prod }

class AppConfig {
  final AppEnv env;
  final String appTitle;
  final String baseUrl; // no trailing slash
  final ThemeData theme;
  final bool showDebugBanner;
  final bool enableLogging;

  const AppConfig({
    required this.env,
    required this.appTitle,
    required this.baseUrl,
    required this.theme,
    this.showDebugBanner = false,
    this.enableLogging = false,
  });

  bool get isProd => env == AppEnv.prod;
}
