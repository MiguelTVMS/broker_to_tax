import "package:logging/logging.dart";

import "../entities/group_by.dart";
import "../entities/transaction_type.dart";
import "base_command.dart";
import "base_sub_command.dart";

class ETFSubCommand extends BaseSubCommand {
  static final _log = Logger("ETFsSubCommand");

  @override
  String get description => "Convert ETF data to a format that can be imported into tax software";

  @override
  String get name => "etf";

  @override
  List<String> get aliases => ["Etf", "ETF", "ETFs", "etfs", "ETFS"];

  @override
  TransactionType get transactionType => TransactionType.etf;

  ETFSubCommand(BaseCommand baseCommand) : super(baseCommand, _log, [GroupBy.sourceCountry, GroupBy.operation]);
}
