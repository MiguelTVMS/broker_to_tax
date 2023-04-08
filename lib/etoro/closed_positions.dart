import "dart:collection";

import "package:broker_to_tax/parsers.dart";
import "package:broker_to_tax/transaction_type.dart";
import "package:country_code/country_code.dart";
import "package:csv/csv.dart";

import "../entities/broker_operation.dart";
import "../entities/gains.dart";

class EtoroClosedPosition {
  int positionId;
  String action;
  double amount;
  double units;
  DateTime openDate;
  DateTime closeDate;
  int leverage;
  double spread;
  double profit;
  double openRate;
  double closeRate;
  double takeProfitRate;
  double stopLossRate;
  double rolloverFeesAndDividends;
  String? copiedFrom;
  String type;
  String? isin;
  String? notes;

  String get name => action.replaceFirst("Buy", "").replaceFirst("Sell", "").trim();
  String? get country => (isin!.isNotEmpty) ? isin?.substring(0, 2) : null;

  TransactionType get transactionType => {
        "stocks": TransactionType.stock,
        "cfd": TransactionType.cfd,
        "crypto": TransactionType.crypto,
        "etf": TransactionType.etf,
      }[type.toLowerCase()]!;

  EtoroClosedPosition(
      {required this.positionId,
      required this.action,
      required this.amount,
      required this.units,
      required this.openDate,
      required this.closeDate,
      required this.leverage,
      required this.spread,
      required this.profit,
      required this.openRate,
      required this.closeRate,
      required this.takeProfitRate,
      required this.stopLossRate,
      required this.rolloverFeesAndDividends,
      required this.type,
      this.copiedFrom,
      this.isin,
      this.notes});

  factory EtoroClosedPosition.fromCsvRow(List<dynamic> csvRow) {
    return EtoroClosedPosition(
        positionId: csvRow[0],
        action: csvRow[1],
        amount: DynamicParsers.toDouble(csvRow[2]),
        units: DynamicParsers.toDouble(csvRow[3]),
        openDate: DynamicParsers.toDateTime(csvRow[4], "dd/MM/yyyy HH:mm:ss"),
        closeDate: DynamicParsers.toDateTime(csvRow[5], "dd/MM/yyyy HH:mm:ss"),
        leverage: csvRow[6],
        spread: DynamicParsers.toDouble(csvRow[7]),
        profit: DynamicParsers.toDouble(csvRow[8]),
        openRate: DynamicParsers.toDouble(csvRow[9]),
        closeRate: DynamicParsers.toDouble(csvRow[10]),
        takeProfitRate: DynamicParsers.toDouble(csvRow[11]),
        stopLossRate: DynamicParsers.toDouble(csvRow[12]),
        rolloverFeesAndDividends: DynamicParsers.toDouble(csvRow[13]),
        copiedFrom: csvRow[14],
        type: csvRow[15],
        isin: csvRow[16],
        notes: csvRow[17]);
  }

  Gain toGain() {
    return Gain(
        name: name,
        openDate: openDate,
        closeDate: closeDate,
        units: units,
        openRate: openRate,
        closeRate: closeRate,
        feesAndDividends: rolloverFeesAndDividends,
        type: transactionType,
        sourceCountry: CountryCode.parse(country ?? "US"),
        counterpartyCountry: CountryCode.US);
  }
}

class EtoroClosedPositions extends ListBase<EtoroClosedPosition> implements BrokerOperations {
  List<EtoroClosedPosition> _positions = [];

  @override
  get length => _positions.length;

  @override
  set length(int newLength) {
    _positions.length = newLength;
  }

  @override
  EtoroClosedPosition operator [](int index) {
    return _positions[index];
  }

  @override
  void operator []=(int index, EtoroClosedPosition value) {
    _positions[index] = value;
  }

  EtoroClosedPositions.fromCsv({required String csvString, bool skipFirstRow = true}) {
    var csvPositions = CsvToListConverter().convert(csvString);

    // TODO: Create a mapping between the csv columns and the EtoroClosedPosition fields
    _positions = csvPositions.skip(skipFirstRow ? 1 : 0).map(EtoroClosedPosition.fromCsvRow).toList();
  }

  @override
  Iterable<Gain> toGains() => _positions.map((e) => e.toGain());
}
