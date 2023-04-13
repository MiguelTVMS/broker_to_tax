import "package:logging/logging.dart";

import "../entities/transaction_type.dart";
import "base_command.dart";
import "base_sub_command.dart";

class CryptoSubCommand extends BaseSubCommand {
  static final _log = Logger("CryptoSubCommand");

  @override
  String get description => "Convert crypto data to a format that can be imported into tax software";

  @override
  String get name => "crypto";

  @override
  List<String> get aliases => ["Crypto", "Cryptos", "CRYPTO", "CRYPTOS"];

  @override
  TransactionType get transactionType => TransactionType.crypto;

  CryptoSubCommand(BaseCommand baseCommand) : super(baseCommand, _log) {
    _log.finer("Running constructor.");
  }

  @override
  Future<void> run() async {
    _log.info("Running command.");
    generateData(await baseCommand.getGains());
  }
}
