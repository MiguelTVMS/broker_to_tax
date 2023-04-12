import "package:logging/logging.dart";

import "../entities/exchange.dart";
import "../entities/transaction_type.dart";
import "base_command.dart";
import "base_sub_command.dart";

class ETFSubCommand extends BaseSubCommand {
  static final _log = Logger("ETFsSubCommand");

  @override
  String get description => "Convert ETF data to a format that can be imported into tax software";

  @override
  String get name => "etf";

  ETFSubCommand(BaseCommand baseCommand) : super(baseCommand, _log) {
    _log.finer("Running constructor.");
  }

  @override
  Future<void> run() async {
    _log.info("Running command.");
    generateData(await baseCommand.getGains(), TransactionType.etf, Currency.eur);
  }
}
