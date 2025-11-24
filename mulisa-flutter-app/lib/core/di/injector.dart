// lib/core/di/injector.dart
import 'package:get_it/get_it.dart';
import 'package:dio/dio.dart';

import '../config.dart';
import '../network/dio_client.dart';
import '../db/app_database.dart';

// Auth
import '../../features/auth/data/auth_local_store.dart';
import '../../features/auth/data/auth_service.dart';
import '../../features/auth/data/user_dao.dart';
import '../../features/auth/vm/auth_cubit.dart';

// Patient repos
import '../../features/patient/data/ipatient_repo.dart';
import '../../features/patient/data/patient_api_dao.dart';
import '../../features/patient/data/patient_local_dao.dart';
import '../../features/patient/vm/patient_cubit.dart';

// Vitals
import '../../features/vitals/data/ivitals_repo.dart';
import '../../features/vitals/data/vitals_api_dao.dart';
import '../../features/vitals/vm/vitals_cubit.dart';

// Scheduler
import '../../features/scheduler/data/scheduler_repo.dart';
import '../../features/scheduler/vm/smart_scheduler_cubit.dart';

final getIt = GetIt.instance;

Future<void> configureDependencies(AppConfig config) async {
  // === AppConfig ===
  if (getIt.isRegistered<AppConfig>()) {
    getIt.unregister<AppConfig>();
  }
  getIt.registerSingleton<AppConfig>(config);

  // === DB (for local stores that truly need it) ===
  final appDb = await AppDatabase.create();
  _registerLazySingleton<AppDatabase>(() => appDb);

  // === Local stores / DAOs (local) ===
  _registerLazySingleton<AuthLocalStore>(() => AuthLocalStore(getIt<AppDatabase>()));
  _registerLazySingleton<UserDao>(() => UserDao(getIt<AppDatabase>().db));

  // === Network (env-aware) ===
  _registerLazySingleton<Dio>(() {
    return Dio(
      BaseOptions(
        baseUrl: config.baseUrl, // e.g. http://10.0.0.79:8000/api
        connectTimeout: const Duration(seconds: 10),
        receiveTimeout: const Duration(seconds: 15),
        headers: const {'Accept': 'application/json'},
      ),
    );
  });

  _registerLazySingleton<DioClient>(() {
    final dio = getIt<Dio>();
    final local = getIt<AuthLocalStore>();
    return DioClient.from(
      dio,
      local,
      enableLogging: config.enableLogging,
    );
  });

  // === Patient repos ===
  _registerLazySingleton<PatientApiDao>(() => PatientApiDao(getIt<DioClient>()));
  _registerLazySingleton<PatientLocalDao>(() => PatientLocalDao(getIt<AppDatabase>()));
  _registerLazySingleton<IPatientRepo>(() => getIt<PatientApiDao>());

  // === Vitals repos ===
  _registerLazySingleton<VitalsApiDao>(() => VitalsApiDao(getIt<DioClient>()));
  _registerLazySingleton<IVitalsRepo>(() => getIt<VitalsApiDao>());

  // === Services ===
  _registerLazySingleton<AuthService>(() => AuthService(
    getIt<DioClient>(),
    getIt<UserDao>(),
  ));

  // === Scheduler Repo ===
  _registerLazySingleton<SchedulerRepo>(() => SchedulerRepo(getIt<DioClient>()));

  // === Cubits ===
  getIt.registerFactory<AuthCubit>(() => AuthCubit(
    getIt<AuthService>(),
    getIt<AuthLocalStore>(),
  ));

  getIt.registerFactory<PatientCubit>(() => PatientCubit(getIt<IPatientRepo>()));

  getIt.registerFactory<VitalsCubit>(() => VitalsCubit(getIt<IVitalsRepo>()));

  // Smart Scheduler Cubit - Use factoryParam to pass patientId from the page
  getIt.registerFactoryParam<SmartSchedulerCubit, String, void>(
        (userId, _) => SmartSchedulerCubit(
      schedulerRepo: getIt<SchedulerRepo>(),
      patientRepo: getIt<IPatientRepo>(), // Add this line
      userId: userId,
    ),
  );
}

// Helper to avoid duplicate registrations during hot restarts in dev.
void _registerLazySingleton<T extends Object>(T Function() factory) {
  if (getIt.isRegistered<T>()) {
    getIt.unregister<T>();
  }
  getIt.registerLazySingleton<T>(factory);
}