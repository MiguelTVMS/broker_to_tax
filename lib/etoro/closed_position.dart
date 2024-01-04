import "package:country_code/country_code.dart";
import "package:excel/excel.dart";

import "../entities/broker_operation.dart";
import "../entities/fee.dart";
import "../entities/gains.dart";
import "../parsers.dart";
import "../entities/transaction_type.dart";
import "account_activities.dart";

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
  Map<DateTime, double>? fees;
  double? netDividends;
  double? netDividendTaxAmount;
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

  factory EtoroClosedPosition.fromExcelRow(List<Data?> excelRow) {
    return EtoroClosedPosition(
        positionId: ExcelParsers.toInteger(excelRow[0]),
        action: excelRow[1]!.value.toString(),
        amount: ExcelParsers.toDouble(excelRow[2]),
        units: ExcelParsers.toDouble(excelRow[3]),
        openDate: ExcelParsers.toDateTime(excelRow[4], "dd/MM/yyyy HH:mm:ss"),
        closeDate: ExcelParsers.toDateTime(excelRow[5], "dd/MM/yyyy HH:mm:ss"),
        leverage: ExcelParsers.toInteger(excelRow[6]),
        spread: ExcelParsers.toDouble(excelRow[7]),
        profit: ExcelParsers.toDouble(excelRow[8]),
        openRate: ExcelParsers.toDouble(excelRow[9]),
        closeRate: ExcelParsers.toDouble(excelRow[10]),
        takeProfitRate: ExcelParsers.toDouble(excelRow[11]),
        stopLossRate: ExcelParsers.toDouble(excelRow[12]),
        rolloverFeesAndDividends: ExcelParsers.toDouble(excelRow[13]),
        copiedFrom: excelRow[14]!.value.toString(),
        type: excelRow[15]!.value.toString(),
        isin: excelRow[16]!.value.toString(),
        notes: excelRow[17]?.value.toString());
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
      fees: fees?.entries.map((e) => Fee(date: e.key, amount: e.value)).toList(),
      type: transactionType,
      sourceCountry: CountryCode.parse(country ?? "US"),
      counterpartyCountry: CountryCode.US,
    );
  }

  void crossData(EtoroAccountActivities activities) {
    addFees(activities);
  }

  void addFees(EtoroAccountActivities activities) {
    activities.where((a) => a.type.toLowerCase().contains("fee") && a.positionId == positionId).forEach((f) {
      fees ??= {};
      fees![f.date] = f.amount;
    });
  }
}
