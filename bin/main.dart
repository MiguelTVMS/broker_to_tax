import "dart:io";

import "package:args/args.dart";
import "package:broker_to_tax/broker_to_tax.dart";

var parser = ArgParser()..addOption("file", abbr: "f", mandatory: true, help: "The file to parse");

void main(List<String> arguments) async {
  var exitCode = 0; // presume success

  ArgResults argResults = parser.parse(arguments);

  print('Chosen path is ${argResults['file']}');

  var brokerToTax = BrokerToTax(argResults["file"]);

  try {
    await brokerToTax.run();
  } on Exception catch (e) {
    print(e);
    exitCode = 1;
  }
  exit(exitCode);
}
