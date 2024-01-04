import "dart:core";

import "currency.dart";
import "exchange.dart";
import "fee.dart";
import "transaction_type.dart";
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
  Iterable<Fee>? fees;
  TransactionType type;
  CountryCode sourceCountry;
  CountryCode counterpartyCountry;

  double? _openValue;
  double get openValue => _openValue ??= units * openRate;

  double? _closeValue;
  double get closeValue => _closeValue ??= units * closeRate;

  double? _profit;
  double get profit => _profit ??= closeValue - openValue;

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
      required this.fees,
      required this.type,
      required this.sourceCountry,
      required this.counterpartyCountry});

  double getOpenValueIn(Currency symbol) => openExchangeRate.convert(openValue, symbol);

  double getCloseValueIn(Currency symbol) => closeExchangeRate.convert(closeValue, symbol);

  double getFeesSum() => fees.getFeesSum();

  double getFeesSumIn(Currency symbol) => fees.getFeesSumIn(symbol);

  double getProfitIn(Currency symbol) => getCloseValueIn(symbol) - getOpenValueIn(symbol);

  //TODO: Validate net profit calculation
  double getNetProfit() => closeValue - openValue - getFeesSum();

  //TODO: Validate net profit calculation
  double getNetProfitIn(Currency symbol) => getCloseValueIn(symbol) - getOpenValueIn(symbol) - getFeesSumIn(symbol);
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
  double get totalProfit => fold(0, (double sum, Gain gain) => sum + gain.profit);
  double get totalFees => fold(0, (double sum, Gain gain) => sum + gain.getFeesSum());
  //TODO: Validate net profit calculation
  double get netProfit => fold(0, (double sum, Gain gain) => sum + gain.getNetProfit());

  double getTotalOpenValueIn(Currency symbol) => fold(0, (double sum, Gain gain) => sum + gain.getOpenValueIn(symbol));
  double getTotalCloseValueIn(Currency symbol) =>
      fold(0, (double sum, Gain gain) => sum + gain.getCloseValueIn(symbol));
  double getProfitIn(Currency symbol) => fold(0, (double sum, Gain gain) => sum + gain.getProfitIn(symbol));
  //TODO: Validate net profit calculation
  double getNetProfitIn(Currency symbol) => fold(0, (double sum, Gain gain) => sum + gain.getNetProfitIn(symbol));
  double getTotalFeesIn(Currency symbol) => fold(0, (double sum, Gain gain) => sum + gain.getFeesSumIn(symbol));

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
      "Name",
      "Open Date",
      "Close Date",
      "Units",
      "OpenRate",
      "CloseRate",
      "Fees",
      "Type",
      "Source Country",
      "Counterparty Country",
      "Open Value",
      "Close Value",
      "Gross Profit",
      "Open $currency ExchangeRate",
      "Close $currency ExchangeRate",
      "Open Value in $currency",
      "Close Value in $currency",
      "Fees in $currency",
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
        gain.units.toGainString(),
        gain.openRate.toGainString(),
        gain.closeRate.toGainString(),
        gain.getFeesSum().toGainString(),
        gain.type,
        gain.sourceCountry.alpha2,
        gain.counterpartyCountry.alpha2,
        gain.openValue.toGainString(),
        gain.closeValue.toGainString(),
        gain.profit.toGainString(),
        gain.openExchangeRate[currency],
        gain.closeExchangeRate[currency],
        gain.getOpenValueIn(currency).toGainString(),
        gain.getCloseValueIn(currency).toGainString(),
        gain.getFeesSumIn(currency).toGainString(),
        gain.getProfitIn(currency).toGainString(),
        gain.getNetProfitIn(currency).toGainString()
      ];

      csvRows.add(csvColumns);
    }

    return ListToCsvConverter().convert(csvRows);
  }
}

extension MapGainsExtension<K> on Map<K, List<Gain>> {
  static final _log = Logger("MapGainsExtension");

  double get totalOpenValue => values.fold(0, (double sum, List<Gain> gains) => sum + gains.totalOpenValue);
  double get totalCloseValue => values.fold(0, (double sum, List<Gain> gains) => sum + gains.totalCloseValue);
  double get grossProfit => values.fold(0, (double sum, List<Gain> gains) => sum + gains.totalProfit);
  double get netProfit => values.fold(0, (double sum, List<Gain> gains) => sum + gains.netProfit);
  double get totalFees => values.fold(0, (double sum, List<Gain> gains) => sum + gains.totalFees);

  double getTotalOpenValueIn(Currency symbol) =>
      values.fold(0, (double sum, List<Gain> gains) => sum + gains.getTotalOpenValueIn(symbol));
  double getTotalCloseValueIn(Currency symbol) =>
      values.fold(0, (double sum, List<Gain> gains) => sum + gains.getTotalCloseValueIn(symbol));
  double getGrossProfitIn(Currency symbol) =>
      values.fold(0, (double sum, List<Gain> gains) => sum + gains.getProfitIn(symbol));
  double getNetProfitIn(Currency symbol) =>
      values.fold(0, (double sum, List<Gain> gains) => sum + gains.getNetProfitIn(symbol));
  double getTotalFeesIn(Currency symbol) =>
      values.fold(0, (double sum, List<Gain> gains) => sum + gains.getTotalFeesIn(symbol));
  double getAverageCloseExchangeRate(Currency symbol) =>
      values.fold(0, (double sum, List<Gain> gains) => sum + gains.getAverageCloseExchangeRate(symbol));
  double getAverageOpenExchangeRate(Currency symbol) =>
      values.fold(0, (double sum, List<Gain> gains) => sum + gains.getAverageOpenExchangeRate(symbol));

  String toCsvString(Currency currency, [bool addHeader = true]) {
    _log.fine("Generating CSV for $length gains in $currency grouped by $K");

    List<List<dynamic>> csvRows = <List<dynamic>>[];
    List<String> headerColumns = <String>[
      (keys.first is CountryCode) ? "Country" : K.toString(),
      "Total Open Value",
      "Total Close Value",
      "Gross Profit",
      "Net Profit",
      "Total Fees",
      "Average Open Exchange Rate $currency",
      "Average Close Exchange Rate $currency",
      "Total Open Value in $currency",
      "Total Close Value in $currency",
      "Gross Profit in $currency",
      "Net Profit in $currency",
      "Total Fees in $currency",
    ];

    if (addHeader) {
      _log.fine("Adding header");
      csvRows.add(headerColumns);
    }

    forEach((key, value) {
      List<dynamic> csvColumns = <dynamic>[
        (key is CountryCode) ? key.alpha2 : key.toString(),
        value.totalOpenValue.toGainString(),
        value.totalCloseValue.toGainString(),
        value.totalProfit.toGainString(),
        value.netProfit.toGainString(),
        value.totalFees.toGainString(),
        value.getAverageOpenExchangeRate(currency).toGainString(),
        value.getAverageCloseExchangeRate(currency).toGainString(),
        value.getTotalOpenValueIn(currency).toGainString(),
        value.getTotalCloseValueIn(currency).toGainString(),
        value.getProfitIn(currency).toGainString(),
        value.getNetProfitIn(currency).toGainString(),
        value.getTotalFeesIn(currency).toGainString()
      ];
      csvRows.add(csvColumns);
    });

    return ListToCsvConverter().convert(csvRows);
  }
}

extension DoubleExtension on double {
  String toGainString() => toStringAsFixed(2);
}
