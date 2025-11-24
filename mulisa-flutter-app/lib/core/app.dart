import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mulisa/core/config.dart';

import '../features/auth/view/login_page.dart';
import '../features/auth/vm/auth_cubit.dart';
import '../features/patient/vm/patient_cubit.dart';
import '../features/splash/view/splash_page.dart';
import 'di/injector.dart';
import 'routes.dart';

class MulisaApp extends StatelessWidget {
  final AppConfig config;
  const MulisaApp({super.key, required this.config});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (_) => getIt<AuthCubit>()..checkSession()),
        BlocProvider(create: (_) => getIt<PatientCubit>()..load()),
      ],
      child: MaterialApp(
        title: config.appTitle,
        debugShowCheckedModeBanner: config.showDebugBanner,
        theme: config.theme, // define in AppConfig
        initialRoute: SplashPage.routeName,
        onGenerateRoute: (settings) => AppRoutes.onGenerateRoute(settings, config),
        builder: (context, child) {
          if (config.isProd) return child!;
          // Small DEV/STAGING badge overlay
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
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    child: Text(
                      config.env.name.toUpperCase(),
                      style: const TextStyle(color: Colors.white, fontSize: 11),
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
