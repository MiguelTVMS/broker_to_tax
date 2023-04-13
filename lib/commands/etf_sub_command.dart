import "package:logging/logging.dart";

import "../entities/group_by.dart";
import "../entities/transaction_type.dart";
import "base_command.dart";
import "base_group_by_sub_command.dart";

class ETFSubCommand extends BaseGroupBySubCommand {
  static final _log = Logger("ETFsSubCommand");

  @override
  String get description => "Convert ETF data to a format that can be imported into tax software";

  @override
  String get name => "etf";

  @override
  List<String> get aliases => ["Etf", "ETF", "ETFs", "etfs", "ETFS"];

  @override
  TransactionType get transactionType => TransactionType.etf;

  ETFSubCommand(BaseCommand baseCommand) : super(baseCommand, _log);

  @override
  Future<void> run() async {
    _log.info("Running command.");
    if (groupBy == GroupBy.none) {
      generateData(await baseCommand.getGains());
    } else if (groupBy == GroupBy.sourceCountry) {
      generateGroupedData(await baseCommand.getGains());
    } else {
      throw Exception("Grouping is not yet supported for stocks.");
    }
  }
}
