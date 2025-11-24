import 'package:logger/logger.dart';

import 'logger.dart' hide Logger;

class AppLogger {
  static final logger = Logger(
    printer: PrettyPrinter(
      methodCount: 2, // number of stack trace lines
      errorMethodCount: 8, // number of stack trace lines for errors
      lineLength: 120, // width of output
      colors: true, // colorize log output
      printEmojis: true, // include emojis
      printTime: true, // include timestamp
    ),
  );
}
