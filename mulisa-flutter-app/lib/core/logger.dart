import 'package:flutter/foundation.dart';
import 'package:intl/intl.dart';

enum LogLevel { debug, info, warning, error }

class Logger {
  static final DateFormat _tsFormat = DateFormat('yyyy-MM-dd HH:mm:ss.SSS');

  static void _log(
    LogLevel level,
    String message, [
    Object? error,
    StackTrace? stackTrace,
  ]) {
    final timestamp = _tsFormat.format(DateTime.now());
    final levelStr = level.name.toUpperCase().padRight(5);
    final logMsg = '[$timestamp] [$levelStr] $message';
    if (error != null) {
      debugPrint('$logMsg\nError: $error');
    } else {
      debugPrint(logMsg);
    }
    if (stackTrace != null) {
      debugPrint(stackTrace.toString());
    }
  }

  static void d(String message, [Object? error, StackTrace? stackTrace]) =>
      _log(LogLevel.debug, message, error, stackTrace);
  static void i(String message, [Object? error, StackTrace? stackTrace]) =>
      _log(LogLevel.info, message, error, stackTrace);
  static void w(String message, [Object? error, StackTrace? stackTrace]) =>
      _log(LogLevel.warning, message, error, stackTrace);
  static void e(String message, [Object? error, StackTrace? stackTrace]) =>
      _log(LogLevel.error, message, error, stackTrace);
}
