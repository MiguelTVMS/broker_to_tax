import "dart:io";

import "package:args/command_runner.dart";
import "package:logging/logging.dart";

import "../entities/gains.dart";
import "../entities/group_by.dart";
import "base_command.dart";
import "base_sub_command.dart";

abstract class BaseGroupBySubCommand extends BaseSubCommand {
  GroupBy groupBy = GroupBy.values.defaultsTo;

  BaseGroupBySubCommand(BaseCommand baseCommand, Logger log) : super(baseCommand, log) {
    log.finer("Running BaseGroupBySubCommand constructor.");

    argParser.addOption("group-by",
        abbr: "g",
        help: "The grouping to use in the stock transactions.",
        allowed: GroupBy.values.map((e) => e.commandArgument),
        defaultsTo: GroupBy.values.defaultsTo.commandArgument, callback: (groupBy) {
      if (groupBy == null || groupBy.isEmpty) throw UsageException("Please specify a grouping.", usage);
      this.groupBy = GroupBy.fromCommandArgumentString(groupBy);
    });
  }

  Future<void> generateGroupedData(Iterable<Gain> gains) async {
    log.fine("Getting $transactionType transactions grouped by $groupBy");

    var output = gains.getByTransactionType(transactionType).groupBy((g) {
      switch (groupBy) {
        case GroupBy.sourceCountry:
          return g.sourceCountry;
        default:
          throw Exception("Unknown grouping $groupBy");
      }
    });

    //log.finer(
    //    "Found ${output.length} $transactionType gains with a net profit of ${output.netProfit} USD converted to ${output.getNetProfitIn(currency)} $currency with an average exchange rate of ${output.getAverageOpenExchangeRate(currency)} on open and ${output.getAverageCloseExchangeRate(currency)} on close.");

    log.fine("Writing $transactionType transactions to file");
    var filename = "${transactionType.toString().toLowerCase()}_gains_grouped_by_${groupBy.fileNamePart}.csv";
    await File(filename).writeAsString(output.toCsvString(currency));
    log.info("Wrote ${output.length} $transactionType gains converted to $currency to file $filename");
  }
}
