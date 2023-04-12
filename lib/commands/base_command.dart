import "dart:io";

import "package:args/command_runner.dart";
import "package:logging/logging.dart";
import "../entities/gains.dart";
import "crypto_sub_command.dart";
import "etf_sub_command.dart";
import "stocks_sub_command.dart";
import "../entities/transaction_type.dart";
import "../entities/exchange.dart";

import "cfd_sub_command.dart";

abstract class BaseCommand extends Command {
  final Logger log;

  String? sourceFile;
  Iterable<FileSystemEntity>? exchangeFiles;
  Iterable<TransactionType>? selectedTransactionTypes;

  BaseCommand(this.log) {
    log.finer("Running constructor.");

    addSubcommand(StockSubCommand(this));
    addSubcommand(CFDSubCommand(this));
    addSubcommand(ETFSubCommand(this));
    addSubcommand(CryptoSubCommand(this));

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

    // argParser.addMultiOption("transaction-types",
    //     abbr: "t",
    //     help: "The calculations to perform. You can specify multiple calculations.",
    //     allowed: transactionTypes,
    //     defaultsTo: ["All"], callback: (calculations) {
    //   if (calculations.isEmpty) {
    //     throw UsageException("Please specify at least one calculation to perform.", usage);
    //   }
    //   if (calculations.contains("All")) {
    //     selectedTransactionTypes = TransactionType.values;
    //   } else {
    //     selectedTransactionTypes =
    //         calculations.map((e) => TransactionType.values.firstWhere((element) => element.name == e)).toList();
    //   }
    // });
  }

  Iterable<String> get transactionTypes => ["All", ...TransactionType.values.map((e) => e.name)];

  @override
  Future<void> run() async {}

  Future<void> readExchangeData() async {
    await HistoricalExchangeRates().addFromJsonFilesInDirectory(exchangeFiles!);
  }

  Future<Iterable<Gain>> getGains();
}
