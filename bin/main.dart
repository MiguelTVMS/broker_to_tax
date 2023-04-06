import "dart:io";

import "package:args/args.dart";
import "package:broker_to_tax/broker_to_tax.dart";

var parser = ArgParser()
  ..addSeparator("Arguments and options:")
  ..addOption("file", abbr: "f", help: "The file to parse")
  ..addOption("exchange-directory", help: "The directory containing the exchange rates", defaultsTo: "data/exchange")
  ..addFlag("help", abbr: "h", negatable: false, help: "Prints this help text");

void printHelp() {
  print("Broker to Tax");
  print("Converts broker data to a format that can be imported into tax software");
  print("");
  // print("Arguments and options:");
  // print("");
  print(parser.usage);
}

void main(List<String> arguments) async {
  var exitCode = 0; // presume success

  ArgResults argResults = parser.parse(arguments);

  if (argResults.wasParsed("help")) {
    printHelp();
    exit(0);
  }

  if (!argResults.wasParsed("file")) {
    print("Please specify a file to parse");
    printHelp();
    exit(1);
  }

  if (!argResults.wasParsed("exchange-directory")) {
    print("Please specify a directory containing the exchange rates");
    printHelp();
    exit(1);
  }

  var brokerToTax = BrokerToTax(argResults["file"], argResults["exchange-directory"]);

  try {
    await brokerToTax.run();
  } on Exception catch (e) {
    print(e);
    exitCode = 1;
  }
  exit(exitCode);
}
