import "dart:io";

import "package:args/command_runner.dart";
import "package:logging/logging.dart";

import "../entities/exchange.dart";
import "../entities/gains.dart";
import "../entities/transaction_type.dart";
import "base_command.dart";

abstract class BaseSubCommand extends Command {
  final BaseCommand baseCommand;
  final Logger log;

  BaseSubCommand(this.baseCommand, this.log);

  Future<void> generateData(Iterable<Gain> gains, TransactionType transactionType, Currency currency) async {
    log.fine("Getting $transactionType transactions");
    var output = gains.getByTransactionType(transactionType);
    log.finer(
        "Found ${output.length} $transactionType gains with a net profit of ${output.netProfit} USD converted to ${output.getNetProfitIn(currency)} $currency with an average exchange rate of ${output.getAverageOpenExchangeRate(currency)} on open and ${output.getAverageCloseExchangeRate(currency)} on close.");
    log.fine("Writing $transactionType transactions to file");
    var filename = "${transactionType.toString().toLowerCase()}_gains.csv";
    await File(filename).writeAsString(output.toCsvString(currency));
    log.info("Wrote ${output.length} $transactionType gains converted to $currency to file $filename");
  }
}
