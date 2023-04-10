import "dart:io";

import "package:args/command_runner.dart";
import "package:broker_to_tax/etoro/commands/etoro_command.dart";

void main(List<String> arguments) async {
  // ignore: unused_local_variable
  var runner = CommandRunner("brokertotax", "Converts broker data to a format that can be imported into tax software.")
    ..addCommand(EtoroCommand())
    ..run(arguments).catchError((error) {
      if (error is! UsageException) throw error;
      print(error);
      exit(64); // Exit code 64 indicates a usage error.
    });
}
