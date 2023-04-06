import "dart:collection";
import "dart:core";

import "package:broker_to_tax/entities/exchange.dart";
import "package:country_code/country_code.dart";

import "../transaction_type.dart";

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
  ExchangeRate get openExchangeRate => _openExchangeRate ??= DailyExchangeRates()[openDate]!;

  ExchangeRate? _closeExchangeRate;
  ExchangeRate get closeExchangeRate => _closeExchangeRate ??= DailyExchangeRates()[openDate]!;

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

class Gains extends ListBase<Gain> {
  final List<Gain> _gains = [];

  @override
  int get length => _gains.length;

  @override
  set length(int newLength) {
    _gains.length = newLength;
  }

  @override
  Gain operator [](int index) => _gains[index];

  @override
  void operator []=(int index, Gain value) {
    _gains[index] = value;
  }

  Gains get byCrypto => getByTransactionType(this, TransactionType.crypto);
  Gains get byStock => getByTransactionType(this, TransactionType.stock);
  Gains get byCFD => getByTransactionType(this, TransactionType.cfd);
  Gains get byETF => getByTransactionType(this, TransactionType.etf);
  Gains get byStocksAndETFs => getByTransactionTypes(this, [TransactionType.stock, TransactionType.etf]);

  double get totalOpenValue => calculateTotalOpenValue(this);
  double get totalCloseValue => calculateTotalCloseValue(this);
  double get grossProfit => calculateGrossProfit(this);
  double get netProfit => calculateNetProfit(this);
  double get totalFeesAndDividends => calculateTotalFeesAndDividends(this);

  double getTotalOpenValueIn(Currency symbol) => calculateTotalOpenValueIn(this, symbol);
  double getTotalCloseValueIn(Currency symbol) => calculateTotalCloseValueIn(this, symbol);
  double getGrossProfitIn(Currency symbol) => calculateGrossProfitIn(this, symbol);
  double getNetProfitIn(Currency symbol) => calculateNetProfitIn(this, symbol);
  double getTotalFeesAndDividendsIn(Currency symbol) => calculateTotalFeesAndDividendsIn(this, symbol);
  double getAverageOpenExchangeRate(Currency symbol) => calculateAverageOpenExchangeRate(this, symbol);
  double getAverageCloseExchangeRate(Currency symbol) => calculateAverageCloseExchangeRate(this, symbol);

  static Gains getByTransactionTypes(Iterable<Gain> gains, Iterable<TransactionType> transactionTypes) =>
      Gains()..addAll(gains.where((gain) => transactionTypes.contains(gain.type)));

  static Gains getByTransactionType(Iterable<Gain> gains, TransactionType transactionType) =>
      Gains()..addAll(gains.where((gain) => gain.type == transactionType));

  static double calculateTotalOpenValue(Iterable<Gain> gains) =>
      gains.fold(0, (double sum, Gain gain) => sum + gain.openValue);

  static double calculateTotalCloseValue(Iterable<Gain> gains) =>
      gains.fold(0, (double sum, Gain gain) => sum + gain.closeValue);

  static double calculateGrossProfit(Iterable<Gain> gains) =>
      gains.fold(0, (double sum, Gain gain) => sum + gain.grossProfit);

  static double calculateNetProfit(Iterable<Gain> gains) =>
      gains.fold(0, (double sum, Gain gain) => sum + gain.netProfit);

  static double calculateTotalFeesAndDividends(Iterable<Gain> gains) =>
      gains.fold(0, (double sum, Gain gain) => sum + gain.feesAndDividends);

  static double calculateTotalOpenValueIn(Iterable<Gain> gains, Currency symbol) =>
      gains.fold(0, (double sum, Gain gain) => sum + gain.getOpenValueIn(symbol));

  static double calculateTotalCloseValueIn(Iterable<Gain> gains, Currency symbol) =>
      gains.fold(0, (double sum, Gain gain) => sum + gain.getCloseValueIn(symbol));

  static double calculateGrossProfitIn(Iterable<Gain> gains, Currency symbol) =>
      gains.fold(0, (double sum, Gain gain) => sum + gain.getGrossProfitIn(symbol));

  static double calculateNetProfitIn(Iterable<Gain> gains, Currency symbol) =>
      gains.fold(0, (double sum, Gain gain) => sum + gain.getNetProfitIn(symbol));

  static double calculateTotalFeesAndDividendsIn(Iterable<Gain> gains, Currency symbol) =>
      gains.fold(0, (double sum, Gain gain) => sum + gain.getFeesAndDividendsIn(symbol));

  static double calculateAverageOpenExchangeRate(Iterable<Gain> gains, Currency symbol) {
    double total = 0;
    double totalUnits = 0;
    for (Gain gain in gains) {
      total += gain.units * gain.openExchangeRate.convert(1, symbol);
      totalUnits += gain.units;
    }
    return total / totalUnits;
  }

  static double calculateAverageCloseExchangeRate(Iterable<Gain> gains, Currency symbol) {
    double total = 0;
    double totalUnits = 0;
    for (Gain gain in gains) {
      total += gain.units * gain.closeExchangeRate.convert(1, symbol);
      totalUnits += gain.units;
    }
    return total / totalUnits;
  }
}

extension Iterables<Gain> on Iterable<Gain> {
  Map<K, List<Gain>> groupBy<K>(K Function(Gain) keyFunction) => fold(<K, List<Gain>>{},
      (Map<K, List<Gain>> map, Gain element) => map..putIfAbsent(keyFunction(element), () => <Gain>[]).add(element));
}

extension GainsExtension on Iterable<Gain> {
  Iterable<Gain> get byCrypto => Gains.getByTransactionType(this, TransactionType.crypto);
  Iterable<Gain> get byStock => Gains.getByTransactionType(this, TransactionType.stock);
  Iterable<Gain> get byCFD => Gains.getByTransactionType(this, TransactionType.cfd);
  Iterable<Gain> get byETF => Gains.getByTransactionType(this, TransactionType.etf);
  Iterable<Gain> get byStocksAndETFs => Gains.getByTransactionTypes(this, [TransactionType.stock, TransactionType.etf]);

  double get totalOpenValue => Gains.calculateTotalOpenValue(this);
  double get totalCloseValue => Gains.calculateTotalCloseValue(this);
  double get grossProfit => Gains.calculateGrossProfit(this);
  double get netProfit => Gains.calculateNetProfit(this);
  double get totalFeesAndDividends => Gains.calculateTotalFeesAndDividends(this);

  double getTotalOpenValueIn(Currency symbol) => Gains.calculateTotalOpenValueIn(this, symbol);
  double getTotalCloseValueIn(Currency symbol) => Gains.calculateTotalCloseValueIn(this, symbol);
  double getGrossProfitIn(Currency symbol) => Gains.calculateGrossProfitIn(this, symbol);
  double getNetProfitIn(Currency symbol) => Gains.calculateNetProfitIn(this, symbol);
  double getTotalFeesAndDividendsIn(Currency symbol) => Gains.calculateTotalFeesAndDividendsIn(this, symbol);

  double getAverageCloseExchangeRate(Currency symbol) => Gains.calculateAverageCloseExchangeRate(this, symbol);
  double getAverageOpenExchangeRate(Currency symbol) => Gains.calculateAverageOpenExchangeRate(this, symbol);

  //Gains toGains() => Gains()..addAll(this);
}

extension MapGainsExtension<K> on Map<K, List<Gain>> {
  double get totalOpenValue =>
      values.fold(0, (double sum, List<Gain> gains) => sum + Gains.calculateTotalOpenValue(gains));
  double get totalCloseValue =>
      values.fold(0, (double sum, List<Gain> gains) => sum + Gains.calculateTotalCloseValue(gains));
  double get grossProfit => values.fold(0, (double sum, List<Gain> gains) => sum + Gains.calculateGrossProfit(gains));
  double get netProfit => values.fold(0, (double sum, List<Gain> gains) => sum + Gains.calculateNetProfit(gains));
  double get totalFeesAndDividends =>
      values.fold(0, (double sum, List<Gain> gains) => sum + Gains.calculateTotalFeesAndDividends(gains));

  double getTotalOpenValueIn(Currency symbol) =>
      values.fold(0, (double sum, List<Gain> gains) => sum + Gains.calculateTotalOpenValueIn(gains, symbol));
  double getTotalCloseValueIn(Currency symbol) =>
      values.fold(0, (double sum, List<Gain> gains) => sum + Gains.calculateTotalCloseValueIn(gains, symbol));
  double getGrossProfitIn(Currency symbol) =>
      values.fold(0, (double sum, List<Gain> gains) => sum + Gains.calculateGrossProfitIn(gains, symbol));
  double getNetProfitIn(Currency symbol) =>
      values.fold(0, (double sum, List<Gain> gains) => sum + Gains.calculateNetProfitIn(gains, symbol));
  double getTotalFeesAndDividendsIn(Currency symbol) =>
      values.fold(0, (double sum, List<Gain> gains) => sum + Gains.calculateTotalFeesAndDividendsIn(gains, symbol));
  double getAverageCloseExchangeRate(Currency symbol) =>
      values.fold(0, (double sum, List<Gain> gains) => sum + Gains.calculateAverageCloseExchangeRate(gains, symbol));
  double getAverageOpenExchangeRate(Currency symbol) =>
      values.fold(0, (double sum, List<Gain> gains) => sum + Gains.calculateAverageOpenExchangeRate(gains, symbol));
}
