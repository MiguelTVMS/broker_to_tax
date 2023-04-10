import "dart:io";

import "package:logging/logging.dart";

import "../entities/broker_operation.dart";
import "../entities/exchange.dart";
import "../entities/gains.dart";
import "../entities/transaction_type.dart";
import "../etoro/closed_positions.dart";
import "base_command.dart";

class EtoroCommand extends BaseCommand {
  static final _log = Logger("EtoroCommand");

  @override
  String get description => "Convert eToro data to a format that can be imported into tax software";

  @override
  String get name => "etoro";

  EtoroCommand() : super();

  Future<EtoroClosedPositions> readDataSource() async {
    var file = File(sourceFile!);

    var etoroPositions = EtoroClosedPositions.fromCsv(await file.readAsString());
    _log.info("Found ${etoroPositions.length} eToro Positions");
    return etoroPositions;
  }

  @override
  Future<void> run() async {
    await super.run();

    BrokerOperations etoroOperations = await readDataSource();

    _log.fine("Converting to gains");
    var gains = etoroOperations.toGains();
    _log.finer("Converted ${gains.length} gains from ${etoroOperations.length} eToro operations");

    for (var transactionType in selectedTransactionTypes!) {
      generateData(gains, transactionType, Currency.eur);
    }
  }

  Future<void> generateData(Iterable<Gain> gains, TransactionType transactionType, Currency currency) async {
    _log.fine("Getting $transactionType transactions");
    var output = gains.getByTransactionType(transactionType);
    _log.finer(
        "Found ${output.length} $transactionType gains with a net profit of ${output.netProfit} USD converted to ${output.getNetProfitIn(currency)} ${currency} with an average exchange rate of ${output.getAverageOpenExchangeRate(currency)} on open and ${output.getAverageCloseExchangeRate(currency)} on close.");
    _log.fine("Writing $transactionType transactions to file");
    var filename = "${transactionType.toString().toLowerCase()}_gains.csv";
    await File(filename).writeAsString(output.toCsvString(currency));
    _log.info("Wrote ${output.length} $transactionType gains converted to $currency to file $filename");
  }
}
