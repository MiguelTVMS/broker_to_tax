import "dart:io";

import "package:args/command_runner.dart";

import "../../entities/exchange.dart";

abstract class BaseCommand extends Command {
  String? sourceFile;
  Iterable<FileSystemEntity>? exchangeFiles;

  BaseCommand() {
    argParser.addOption("file", abbr: "f", help: "The file to parse.", callback: (filePath) {
      if (filePath == null) throw UsageException("Please specify a file to parse.", usage);
      if (!File(filePath).existsSync()) throw UsageException("File \"$filePath\" not found.", usage);
      sourceFile = filePath;
    });

    argParser.addOption("exchange-directory",
        help: "The directory containing the exchange rates", defaultsTo: "data/exchange", callback: (directoryPath) {
      if (directoryPath == null) {
        throw UsageException("Please specify a directory where the exchange data is located.", usage);
      }
      var directory = Directory(directoryPath);
      if (!directory.existsSync()) {
        throw UsageException("Directory \"$directoryPath\" not found.", usage);
      }
      exchangeFiles = directory.listSync(recursive: false).where((event) => event.path.endsWith(".json")).toList();
      if (exchangeFiles != null && exchangeFiles!.isEmpty) {
        throw UsageException("No exchange files found in \"$directoryPath\".", usage);
      }
    });
  }

  @override
  Future<void> run() async {
    await HistoricalExchangeRates().addFromJsonFilesInDirectory(exchangeFiles!);
  }
}
