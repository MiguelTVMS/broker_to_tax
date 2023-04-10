import "dart:core";

import "package:broker_to_tax/entities/exchange.dart";
import "package:broker_to_tax/entities/transaction_type.dart";
import "package:country_code/country_code.dart";
import "package:csv/csv.dart";
import "package:logging/logging.dart";

class Gain {
  String name;
  DateTime openDate;
  DateTime closeDate;
  double units;
  double openRate;
  double closeRate;
  double feesAndDividends;
  TransactionType type;
  CountryCode sourceCountry;
  CountryCode counterpartyCountry;

  double? _openValue;
  double get openValue => _openValue ??= units * openRate;

  double? _closeValue;
  double get closeValue => _closeValue ??= units * closeRate;

  double? _grossProfit;
  double get grossProfit => _grossProfit ??= closeValue - openValue;

  double? _netProfit;
  double get netProfit => _netProfit ??= closeValue - openValue + feesAndDividends;

  ExchangeRate? _openExchangeRate;
  ExchangeRate get openExchangeRate => _openExchangeRate ??= HistoricalExchangeRates()[openDate]!;

  ExchangeRate? _closeExchangeRate;
  ExchangeRate get closeExchangeRate => _closeExchangeRate ??= HistoricalExchangeRates()[openDate]!;

  Gain(
      {required this.name,
      required this.openDate,
      required this.closeDate,
      required this.units,
      required this.openRate,
      required this.closeRate,
      required this.feesAndDividends,
      required this.type,
      required this.sourceCountry,
      required this.counterpartyCountry});

  double getOpenValueIn(Currency symbol) => openExchangeRate.convert(openValue, symbol);

  double getCloseValueIn(Currency symbol) => closeExchangeRate.convert(closeValue, symbol);

  double getFeesAndDividendsIn(Currency symbol) => closeExchangeRate.convert(feesAndDividends, symbol);

  double getGrossProfitIn(Currency symbol) => getCloseValueIn(symbol) - getOpenValueIn(symbol);

  double getNetProfitIn(Currency symbol) =>
      getCloseValueIn(symbol) - getOpenValueIn(symbol) + getFeesAndDividendsIn(symbol);
}

extension GainsExtension on Iterable<Gain> {
  static final _log = Logger("GainsExtension");

  Iterable<Gain> get byCrypto => getByTransactionType(TransactionType.crypto);
  Iterable<Gain> get byStock => getByTransactionType(TransactionType.stock);
  Iterable<Gain> get byCFD => getByTransactionType(TransactionType.cfd);
  Iterable<Gain> get byETF => getByTransactionType(TransactionType.etf);
  Iterable<Gain> get byStocksAndETFs => getByTransactionTypes([TransactionType.stock, TransactionType.etf]);

  double get totalOpenValue => fold(0, (double sum, Gain gain) => sum + gain.openValue);
  double get totalCloseValue => fold(0, (double sum, Gain gain) => sum + gain.closeValue);
  double get grossProfit => fold(0, (double sum, Gain gain) => sum + gain.grossProfit);
  double get netProfit => fold(0, (double sum, Gain gain) => sum + gain.netProfit);
  double get totalFeesAndDividends => fold(0, (double sum, Gain gain) => sum + gain.feesAndDividends);

  double getTotalOpenValueIn(Currency symbol) => fold(0, (double sum, Gain gain) => sum + gain.getOpenValueIn(symbol));
  double getTotalCloseValueIn(Currency symbol) =>
      fold(0, (double sum, Gain gain) => sum + gain.getCloseValueIn(symbol));
  double getGrossProfitIn(Currency symbol) => fold(0, (double sum, Gain gain) => sum + gain.getGrossProfitIn(symbol));
  double getNetProfitIn(Currency symbol) => fold(0, (double sum, Gain gain) => sum + gain.getNetProfitIn(symbol));
  double getTotalFeesAndDividendsIn(Currency symbol) =>
      fold(0, (double sum, Gain gain) => sum + gain.getFeesAndDividendsIn(symbol));

  Map<K, List<Gain>> groupBy<K>(K Function(Gain) keyFunction) => fold(<K, List<Gain>>{},
      (Map<K, List<Gain>> map, Gain element) => map..putIfAbsent(keyFunction(element), () => <Gain>[]).add(element));

  double getAverageCloseExchangeRate(Currency symbol) {
    double total = 0;
    double totalUnits = 0;
    for (Gain gain in this) {
      total += gain.units * gain.closeExchangeRate.convert(1, symbol);
      totalUnits += gain.units;
    }
    return total / totalUnits;
  }

  double getAverageOpenExchangeRate(Currency symbol) {
    double total = 0;
    double totalUnits = 0;
    for (Gain gain in this) {
      total += gain.units * gain.openExchangeRate.convert(1, symbol);
      totalUnits += gain.units;
    }
    return total / totalUnits;
  }

  Iterable<Gain> getByTransactionTypes(Iterable<TransactionType> transactionTypes) =>
      where((gain) => transactionTypes.contains(gain.type));

  Iterable<Gain> getByTransactionType(TransactionType transactionType) => where((gain) => gain.type == transactionType);

  String toCsvString(Currency currency, [bool addHeader = true]) {
    _log.fine("Generating CSV for $length gains in $currency");

    List<List<dynamic>> csvRows = <List<dynamic>>[];
    List<String> headerColumns = <String>[
      "name",
      "Open Date",
      "Close Date",
      "Units",
      "OpenRate",
      "CloseRate",
      "Fees and Dividends",
      "Type",
      "Source Country",
      "Counterparty Country",
      "Open Value",
      "Close Value",
      "Gross Profit",
      "Net Profit",
      "Open $currency ExchangeRate",
      "Close $currency ExchangeRate",
      "Open Value in $currency",
      "Close Value in $currency",
      "Fees and Dividends in $currency",
      "Gross Profit in $currency",
      "Net Profit in $currency"
    ];

    if (addHeader) {
      _log.fine("Adding header");
      csvRows.add(headerColumns);
    }

    for (Gain gain in this) {
      List<dynamic> csvColumns = <dynamic>[
        gain.name,
        gain.openDate,
        gain.closeDate,
        gain.units.toStringAsFixed(2),
        gain.openRate.toStringAsFixed(2),
        gain.closeRate.toStringAsFixed(2),
        gain.feesAndDividends.toStringAsFixed(2),
        gain.type,
        gain.sourceCountry.alpha2,
        gain.counterpartyCountry.alpha2,
        gain.openValue.toStringAsFixed(2),
        gain.closeValue.toStringAsFixed(2),
        gain.grossProfit.toStringAsFixed(2),
        gain.netProfit.toStringAsFixed(2),
        gain.openExchangeRate[currency],
        gain.closeExchangeRate[currency],
        gain.getOpenValueIn(currency).toStringAsFixed(2),
        gain.getCloseValueIn(currency).toStringAsFixed(2),
        gain.getFeesAndDividendsIn(currency).toStringAsFixed(2),
        gain.getGrossProfitIn(currency).toStringAsFixed(2),
        gain.getNetProfitIn(currency).toStringAsFixed(2)
      ];

      csvRows.add(csvColumns);
    }

    return ListToCsvConverter().convert(csvRows);
  }
}

extension MapGainsExtension<K> on Map<K, List<Gain>> {
  double get totalOpenValue => values.fold(0, (double sum, List<Gain> gains) => sum + gains.totalOpenValue);
  double get totalCloseValue => values.fold(0, (double sum, List<Gain> gains) => sum + gains.totalCloseValue);
  double get grossProfit => values.fold(0, (double sum, List<Gain> gains) => sum + gains.grossProfit);
  double get netProfit => values.fold(0, (double sum, List<Gain> gains) => sum + gains.netProfit);
  double get totalFeesAndDividends =>
      values.fold(0, (double sum, List<Gain> gains) => sum + gains.totalFeesAndDividends);
  double getTotalOpenValueIn(Currency symbol) =>
      values.fold(0, (double sum, List<Gain> gains) => sum + gains.getTotalOpenValueIn(symbol));
  double getTotalCloseValueIn(Currency symbol) =>
      values.fold(0, (double sum, List<Gain> gains) => sum + gains.getTotalCloseValueIn(symbol));
  double getGrossProfitIn(Currency symbol) =>
      values.fold(0, (double sum, List<Gain> gains) => sum + gains.getGrossProfitIn(symbol));
  double getNetProfitIn(Currency symbol) =>
      values.fold(0, (double sum, List<Gain> gains) => sum + gains.getNetProfitIn(symbol));
  double getTotalFeesAndDividendsIn(Currency symbol) =>
      values.fold(0, (double sum, List<Gain> gains) => sum + gains.getTotalFeesAndDividendsIn(symbol));
  double getAverageCloseExchangeRate(Currency symbol) =>
      values.fold(0, (double sum, List<Gain> gains) => sum + gains.getAverageCloseExchangeRate(symbol));
  double getAverageOpenExchangeRate(Currency symbol) =>
      values.fold(0, (double sum, List<Gain> gains) => sum + gains.getAverageOpenExchangeRate(symbol));
}
