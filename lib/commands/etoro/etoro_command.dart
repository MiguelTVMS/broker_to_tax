import "dart:io";

import "package:logging/logging.dart";

import "../../entities/currency.dart";
import "../../entities/gains.dart";
import "../../entities/transaction_type.dart";
import "../../etoro/closed_positions.dart";
import "../base_command.dart";

class EtoroCommand extends BaseCommand {
  static final _log = Logger("EtoroCommand");

  @override
  String get description => "Convert eToro data to a format that can be imported into tax software";

  @override
  String get name => "etoro";

  @override
  List<String> get aliases => [
        "eToro",
        "Etoro",
        "ETORO",
      ];

  EtoroCommand() : super(_log);

  @override
  Future<void> run() async {
    await super.run();
  }

  Future<void> generateData(Iterable<Gain> gains, TransactionType transactionType, Currency currency) async {
    _log.fine("Getting $transactionType transactions");
    var output = gains.getByTransactionType(transactionType);
    _log.finer(
        "Found ${output.length} $transactionType gains with a net profit of ${output.netProfit} USD converted to ${output.getNetProfitIn(currency)} $currency with an average exchange rate of ${output.getAverageOpenExchangeRate(currency)} on open and ${output.getAverageCloseExchangeRate(currency)} on close.");
    _log.fine("Writing $transactionType transactions to file");
    var filename = "${transactionType.toString().toLowerCase()}_gains.csv";
    await File(filename).writeAsString(output.toCsvString(currency));
    _log.info("Wrote ${output.length} $transactionType gains converted to $currency to file $filename");
  }

  Future<EtoroClosedPositions> readDataSource() async {
    await super.readExchangeData();
    var file = File(sourceFile!);
    return EtoroClosedPositions.fromCsv(await file.readAsString());
  }

  @override
  Future<Iterable<Gain>> getGains() async {
    var etoroPositions = await readDataSource();
    return etoroPositions.toGains();
  }
}
