import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mulisa/core/config.dart';
import 'package:mulisa/core/ui/app_shell.dart';
import 'package:mulisa/features/auth/view/login_page.dart';
import 'package:mulisa/features/auth/view/sign_up_page.dart';
import 'package:mulisa/features/auth/vm/auth_cubit.dart';
import 'package:mulisa/features/patient/view/patient_list_page.dart';
import 'package:mulisa/features/patient/vm/patient_cubit.dart';
import 'package:mulisa/features/splash/view/splash_page.dart';
import '../features/CereFlow/view/cereflow_sync.dart';
import '../features/knowledgehub/knowledge_hub_screen.dart';
import '../features/home/view/home_view_page.dart';
import '../features/patient/view/patient_care_page.dart';
import '../features/patient/view/profile/patient_profile_page.dart';
import 'di/injector.dart';
import '../features/scheduler/view/smart_scheduler_page.dart';
import '../features/scheduler/view/smart_scheduler_page.dart';
import '../features/scheduler/vm/smart_scheduler_cubit.dart';
import '../features/scheduler/data/scheduler_repo.dart';
import 'package:provider/provider.dart';


class AppRoutes {
  static Route<dynamic> onGenerateRoute(RouteSettings settings, AppConfig config) {
    switch (settings.name) {
      case '/':
      case SplashPage.routeName:
        return MaterialPageRoute(
          settings: settings,
          builder: (_) => SplashPage(config: config),
        );

      case LoginPage.routeName:
        return MaterialPageRoute(
          settings: settings,
          builder: (_) => BlocProvider<AuthCubit>(
            create: (_) => getIt<AuthCubit>(),
            child: const LoginPage(),
          ),
        );

      case SignUpPage.routeName:
        return MaterialPageRoute(
          settings: settings,
          builder: (_) => BlocProvider<AuthCubit>(
            create: (_) => getIt<AuthCubit>(),
            child: const SignUpPage(),
          ),
        );

      case HomePage.routeName:
        return _wrap(
          settings: settings,
          title: 'Home',
          showBack: false,
          child: const HomePage(),
        );

      case PatientListPage.routeName:
        return MaterialPageRoute(
          settings: settings,
          builder: (_) => BlocProvider<PatientCubit>.value(
            value: getIt<PatientCubit>(),
            child: const PatientListPage(),
          ),
        );

      case PatientCarePage.routeName:
        return MaterialPageRoute(
          settings: settings,
          builder: (ctx) => BlocProvider.value(
            value: getIt<PatientCubit>(),
            child: PatientCarePage.fromArgs(ctx),
          ),
        );

      case PatientProfilePage.routeName:
        return MaterialPageRoute(
          settings: settings,
          builder: (ctx) => MultiProvider(
            providers: [
              BlocProvider.value(
                value: getIt<PatientCubit>(),
              ),
              Provider<SchedulerRepo>(
                create: (_) => getIt<SchedulerRepo>(),
              ),
            ],
            child: PatientProfilePage.fromArgs(ctx),
          ),
        );

    // 👇 NEW: CereFlow Sync route
      case CereFlowSyncPage.routeName:
        return _wrap(
          settings: settings,
          title: 'CereFlow Sync',
          showBack: true,
          child: const CereFlowSyncPage(),
        );

      case KnowledgeHubPage.routeName:
        return _wrap(
          settings: settings,
          title: 'Knowledge Hub',
          showBack: true,
          child: const KnowledgeHubPage(),
        );

      case SmartSchedulerPage.routeName:
        return _wrap(
          settings: settings,
          title: 'Smart Scheduler',
          showBack: true,
          child: const SmartSchedulerPage(), // Remove BlocProvider from here - it's now in the page itself
        );


      default:
        return MaterialPageRoute(
          settings: settings,
          builder: (_) => const Scaffold(
            body: Center(child: Text('Route not found')),
          ),
        );
    }
  }

  /// Helper to wrap any page with the shared AppBar Scaffold.
  static MaterialPageRoute _wrap({
    required RouteSettings settings,
    required Widget child,
    String? title,
    List<Widget>? actions,
    PreferredSizeWidget? bottom,
    bool showBack = true,
  }) {
    return MaterialPageRoute(
      settings: settings,
      builder: (_) => AppShell(
        title: title,
        actions: actions,
        bottom: bottom,
        showBack: showBack,
        child: child,
      ),
    );
  }
}
