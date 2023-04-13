import "dart:io";

import "package:args/command_runner.dart";
import "package:logging/logging.dart";
import "../entities/currency.dart";
import "../entities/gains.dart";
import "crypto_sub_command.dart";
import "etf_sub_command.dart";
import "stocks_sub_command.dart";
import "../entities/transaction_type.dart";
import "../entities/exchange.dart";

import "cfd_sub_command.dart";

abstract class BaseCommand extends Command {
  final Logger log;

  Iterable<FileSystemEntity>? exchangeFiles;
  String? sourceFile;

  BaseCommand(this.log) {
    log.finer("Running BaseCommand constructor.");

    addSubcommand(StockSubCommand(this));
    addSubcommand(CFDSubCommand(this));
    addSubcommand(ETFSubCommand(this));
    addSubcommand(CryptoSubCommand(this));
  }

  Future<void> readExchangeData() async {
    await HistoricalExchangeRates().addFromJsonFilesInDirectory(exchangeFiles!);
  }

  Future<Iterable<Gain>> getGains();
}
