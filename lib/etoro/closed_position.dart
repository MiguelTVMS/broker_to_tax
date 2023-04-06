import "package:country_code/country_code.dart";

import "../entities/broker_operation.dart";
import "../entities/gains.dart";
import "../parsers.dart";
import "../transaction_type.dart";

class EtoroClosedPosition implements BrokerOperation {
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

  String? get country => isin?.substring(0, 2);
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

  @override
  Gain toGain() {
    return Gain(
      name: action,
      openDate: openDate,
      closeDate: closeDate,
      units: units,
      openRate: openRate,
      closeRate: closeRate,
      feesAndDividends: rolloverFeesAndDividends,
      type: transactionType,
      sourceCountry: CountryCode.parse(country ?? "US"),
      counterpartyCountry: CountryCode.US,
    );
  }
}
