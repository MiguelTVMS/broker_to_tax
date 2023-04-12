import "package:args/command_runner.dart";
import "package:logging/logging.dart";

import "../entities/exchange.dart";
import "../entities/transaction_type.dart";
import "base_command.dart";
import "base_sub_command.dart";

class StockSubCommand extends BaseSubCommand {
  static final _log = Logger("StocksSubCommand");
  String? groupBy;

  @override
  String get description => "Convert stock data to a format that can be imported into tax software";

  @override
  String get name => "stock";

  StockSubCommand(BaseCommand baseCommand) : super(baseCommand, _log) {
    _log.finer("Running constructor.");

    argParser.addOption("group-by",
        abbr: "g",
        help: "The grouping to use in the stock transactions.",
        allowed: ["source-country", "counterpart-country"],
        defaultsTo: "source-country", callback: (groupBy) {
      if (groupBy == null) throw UsageException("Please specify at least one grouping to perform.", usage);
      this.groupBy = groupBy;
    });
  }

  @override
  Future<void> run() async {
    _log.info("Running command.");
    generateData(await baseCommand.getGains(), TransactionType.stock, Currency.eur);
  }
}
