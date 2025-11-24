// api_base.dart
enum AppEnv { dev, staging, prod }

class ApiBase {
  // IMPORTANT: no trailing slash
  static const String dev = 'http://127.0.0.1:8000/api';
  static const String staging = 'https://staging.example.com/api';
  static const String prod = 'https://example.com/api';

  static AppEnv get _env {
    const raw = String.fromEnvironment('APP_ENV', defaultValue: 'prod');
    switch (raw.toLowerCase()) {
      case 'dev':
        return AppEnv.dev;
      case 'staging':
        return AppEnv.staging;
      case 'prod':
        return AppEnv.prod;
      default:
        return AppEnv.prod;
    }
  }

  static String get baseUrl {
    // If provided, this wins
    const override = String.fromEnvironment('API_BASE_URL', defaultValue: '');
    if (override.isNotEmpty) return _stripTrailingSlash(override);

    switch (_env) {
      case AppEnv.dev:
        return dev;
      case AppEnv.staging:
        return staging;
      case AppEnv.prod:
        return prod;
      default:
        return prod;
    }
  }

  static String _stripTrailingSlash(String url) =>
      url.endsWith('/') ? url.substring(0, url.length - 1) : url;

  static AppEnv get currentEnv => _env;
}

class ApiEndpoints {
  // Auth
  static const String login = '/accounts/login/';
  static const String signup = '/accounts/signup/';
  static const String logout = '/accounts/logout/';

  // Patients
  static const String patients = '/patients/';
  static String patientDetail(String id) => '/patients/$id/';
}
