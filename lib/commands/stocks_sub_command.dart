import "package:logging/logging.dart";

import "../entities/group_by.dart";
import "../entities/transaction_type.dart";
import "base_command.dart";
import "base_group_by_sub_command.dart";

class StockSubCommand extends BaseGroupBySubCommand {
  static final _log = Logger("StocksSubCommand");

  @override
  String get description => "Convert stock data to a format that can be imported into tax software";

  @override
  String get name => "stock";

  @override
  List<String> get aliases => ["Stocks", "Stock", "STOCK", "STOCKS"];

  @override
  TransactionType get transactionType => TransactionType.stock;

  StockSubCommand(BaseCommand baseCommand) : super(baseCommand, _log);

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
