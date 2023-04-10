import "dart:io";

import "package:args/command_runner.dart";
import "package:broker_to_tax/commands/etoro_command.dart";
import "package:logging/logging.dart";

final _log = Logger("Main");

void setLogger(String? value) {
  if (value == null) throw UsageException("Please specify a log level.", "log-level");
  switch (value.toUpperCase()) {
    case "FINEST":
      Logger.root.level = Level.FINEST;
      break;
    case "FINER":
      Logger.root.level = Level.FINER;
      break;
    case "FINE":
      Logger.root.level = Level.FINE;
      break;
    case "INFO":
      Logger.root.level = Level.INFO;
      break;
    default:
      throw UsageException("Invalid log level \"$value\".", "log-level");
  }
}

void logListener(LogRecord record) {
  if (record.level == Level.INFO && Logger.root.level == Level.INFO) {
    print(record.message);
    return;
  }

  var logMessage = "${record.level.name}: ${record.time}: ${record.loggerName}: ${record.message}.";

  if (record.object != null) {
    logMessage += " Object: ${record.object}";
  }

  if (record.error != null) {
    logMessage += " Error: ${record.error}";
  }
  if (record.stackTrace != null) {
    logMessage += " Stack trace: ${record.stackTrace}";
  }

  if (record.level >= Level.SEVERE) {
    stderr.writeln(logMessage);
  } else {
    stdout.writeln(logMessage);
  }
}

void main(List<String> arguments) async {
  Logger.root.onRecord.listen(logListener);
  Logger.root.level = Platform.environment["LOG_LEVEL"] == "FINEST" ? Level.FINEST : Level.INFO;
  // ignore: unused_local_variable
  var runner = CommandRunner("brokertotax", "Converts broker data to a format that can be imported into tax software.")
    ..argParser.addOption("log-level",
        abbr: "l",
        help: "The log level to use. Valid values are: info, fine, finer, finest.",
        defaultsTo: "info",
        allowed: ["info", "fine", "finer", "finest"],
        callback: (setLogger))
    ..addCommand(EtoroCommand())
    ..run(arguments).catchError((error) {
      if (error is! UsageException) {
        _log.shout("An unexpected error occurred.", error);
        exit(1);
      }
      print(error);
      exit(64); // Exit code 64 indicates a usage error.
    });
}
