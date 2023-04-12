import "package:logging/logging.dart";

import "../entities/exchange.dart";
import "../entities/transaction_type.dart";
import "base_command.dart";
import "base_sub_command.dart";

class CFDSubCommand extends BaseSubCommand {
  static final _log = Logger("CFDsSubCommand");

  @override
  String get description => "Convert CFD data to a format that can be imported into tax software";

  @override
  String get name => "cfd";

  CFDSubCommand(BaseCommand baseCommand) : super(baseCommand, _log) {
    _log.finer("Running constructor.");
  }

  @override
  Future<void> run() async {
    _log.info("Running command.");
    generateData(await baseCommand.getGains(), TransactionType.crypto, Currency.eur);
  }
}
