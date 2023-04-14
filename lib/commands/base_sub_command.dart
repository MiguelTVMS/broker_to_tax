import "dart:io";

import "package:args/command_runner.dart";
import "package:logging/logging.dart";

import "../entities/currency.dart";
import "../entities/gains.dart";
import "../entities/group_by.dart";
import "../entities/transaction_type.dart";
import "base_command.dart";

abstract class BaseSubCommand extends Command {
  final BaseCommand baseCommand;
  final Logger log;

  GroupBy? _selectedGroupBy;
  GroupBy get groupBy => _selectedGroupBy ??= defaultGrouping;

  Currency currency = Currency.values.defaultsTo;
  Iterable<TransactionType>? selectedTransactionTypes;
  Iterable<GroupBy>? allowedGroupings;
  GroupBy defaultGrouping;

  TransactionType get transactionType;

  BaseSubCommand(this.baseCommand, this.log, [this.allowedGroupings, this.defaultGrouping = GroupBy.none]) {
    argParser.addOption("file", abbr: "f", help: "The file to parse.", callback: (filePath) {
      if (filePath == null) throw UsageException("Please specify a file to parse.", usage);
      if (!File(filePath).existsSync()) throw UsageException("File \"$filePath\" not found.", usage);
      baseCommand.sourceFile = filePath;
    });

    argParser.addOption("exchange-directory",
        help: "The directory containing the exchange rates", defaultsTo: "data/exchange", callback: (directoryPath) {
      if (directoryPath == null) {
        throw UsageException("Please specify a directory where the exchange data is located.", usage);
      }
      var directory = Directory(directoryPath);
      if (!directory.existsSync()) {
        throw UsageException("Directory \"$directoryPath\" not found.", usage);
      }
      baseCommand.exchangeFiles =
          directory.listSync(recursive: false).where((event) => event.path.endsWith(".json")).toList();
      if (baseCommand.exchangeFiles != null && baseCommand.exchangeFiles!.isEmpty) {
        throw UsageException("No exchange files found in \"$directoryPath\".", usage);
      }
    });

    argParser.addOption("currency",
        abbr: "c",
        help: "The currency to use for the gains.",
        allowed: Currency.values.map((e) => e.commandArgument),
        defaultsTo: Currency.values.defaultsTo.commandArgument, callback: (currency) {
      if (currency == null || currency.isEmpty) throw UsageException("Please specify a currency.", usage);
      this.currency = Currency.fromCommandArgumentString(currency);
    });

    if (allowedGroupings != null && allowedGroupings!.length == 1) {
      var groping = allowedGroupings!.first;
      argParser.addFlag("group-by-${groping.commandArgument}",
          abbr: "g",
          help: "Group the gains by ${groping.name.toLowerCase()}.",
          defaultsTo: false,
          negatable: false, callback: (groupBy) {
        if (groupBy) _selectedGroupBy = groping;
      });
    } else if (allowedGroupings != null && allowedGroupings!.length > 1) {
      argParser.addOption("group-by",
          abbr: "g",
          help: "The grouping to use in the gains.",
          allowed: [GroupBy.none.commandArgument, ...allowedGroupings!.map((g) => g.commandArgument)],
          defaultsTo: defaultGrouping.commandArgument, callback: (groupBy) {
        if (groupBy == null || groupBy.isEmpty) throw UsageException("Please specify a grouping.", usage);
        _selectedGroupBy = GroupBy.fromCommandArgumentString(groupBy);
      });
    }
  }

  @override
  Future<void> run() async {
    log.info("Running command.");
    if (groupBy == GroupBy.none) {
      generateData(await baseCommand.getGains());
    } else {
      generateGroupedData(await baseCommand.getGains());
    }
  }

  Future<void> generateData(Iterable<Gain> gains) async {
    log.fine("Getting $transactionType transactions");
    var output = gains.getByTransactionType(transactionType);
    log.finer(
        "Found ${output.length} $transactionType gains with a net profit of ${output.netProfit} USD converted to ${output.getNetProfitIn(currency)} $currency with an average exchange rate of ${output.getAverageOpenExchangeRate(currency)} on open and ${output.getAverageCloseExchangeRate(currency)} on close.");
    log.fine("Writing $transactionType transactions to file");
    var filename = "${transactionType.toString().toLowerCase()}_gains.csv";
    await File(filename).writeAsString(output.toCsvString(currency));
    log.info("Wrote ${output.length} $transactionType gains converted to $currency to file $filename");
  }

  Future<void> generateGroupedData(Iterable<Gain> gains) async {
    log.fine("Getting $transactionType transactions grouped by $groupBy");

    var output = gains.getByTransactionType(transactionType).groupBy((g) {
      switch (groupBy.realGroupBy) {
        case GroupBy.sourceCountry:
          return g.sourceCountry;
        case GroupBy.operation:
          return g.name;
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
