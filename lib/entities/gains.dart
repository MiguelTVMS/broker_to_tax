import "dart:collection";

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
  ExchangeRate get openExchangeRate => _openExchangeRate ??= HistoricalExchangeRates.getByDate(openDate);

  ExchangeRate? _closeExchangeRate;
  ExchangeRate get closeExchangeRate => _closeExchangeRate ??= HistoricalExchangeRates.getByDate(closeDate);

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

  double getOpenValueIn(MoneySymbol symbol) => openExchangeRate.convert(openValue, symbol)!;

  double getCloseValueIn(MoneySymbol symbol) => closeExchangeRate.convert(openValue, symbol)!;

  double getFeesAndDividendsIn(MoneySymbol symbol) => closeExchangeRate.convert(feesAndDividends, symbol)!;

  double getGrossProfitIn(MoneySymbol symbol) => getCloseValueIn(symbol) - getOpenValueIn(symbol);

  double getNetProfitIn(MoneySymbol symbol) =>
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

  Gains get byCrypto => where((gain) => gain.type == TransactionType.crypto).toGains();
  Gains get byStock => where((gain) => gain.type == TransactionType.stock).toGains();
  Gains get byCFD => where((gain) => gain.type == TransactionType.cfd).toGains();
  Gains get byETF => where((gain) => gain.type == TransactionType.etf).toGains();
  Gains get byStocksAndETFs =>
      where((gain) => gain.type == TransactionType.stock || gain.type == TransactionType.etf).toGains();

  double get totalOpenValue => fold(0, (double sum, Gain gain) => sum + gain.openValue);
  double get totalCloseValue => fold(0, (double sum, Gain gain) => sum + gain.closeValue);
  double get grossProfit => fold(0, (double sum, Gain gain) => sum + gain.grossProfit);
  double get netProfit => fold(0, (double sum, Gain gain) => sum + gain.netProfit);
  double get totalFeesAndDividends => fold(0, (double sum, Gain gain) => sum + gain.feesAndDividends);

  double getTotalOpenValueIn(MoneySymbol symbol) =>
      fold(0, (double sum, Gain gain) => sum + gain.getOpenValueIn(symbol));
  double getTotalCloseValueIn(MoneySymbol symbol) =>
      fold(0, (double sum, Gain gain) => sum + gain.getCloseValueIn(symbol));
  double getGrossProfitIn(MoneySymbol symbol) =>
      fold(0, (double sum, Gain gain) => sum + gain.getGrossProfitIn(symbol));
  double getNetProfitIn(MoneySymbol symbol) => fold(0, (double sum, Gain gain) => sum + gain.getNetProfitIn(symbol));
  double getTotalFeesAndDividendsIn(MoneySymbol symbol) =>
      fold(0, (double sum, Gain gain) => sum + gain.getFeesAndDividendsIn(symbol));
}

extension Iterables<Gain> on Iterable<Gain> {
  Map<K, List<Gain>> groupBy<K>(K Function(Gain) keyFunction) => fold(<K, List<Gain>>{},
      (Map<K, List<Gain>> map, Gain element) => map..putIfAbsent(keyFunction(element), () => <Gain>[]).add(element));
}

extension GainsExtension on Iterable<Gain> {
  Iterable<Gain> get byCrypto => where((gain) => gain.type == TransactionType.crypto);
  Iterable<Gain> get byStock => where((gain) => gain.type == TransactionType.stock);
  Iterable<Gain> get byCFD => where((gain) => gain.type == TransactionType.cfd);
  Iterable<Gain> get byETF => where((gain) => gain.type == TransactionType.etf);
  Iterable<Gain> get byStocksAndETFs =>
      where((gain) => gain.type == TransactionType.stock || gain.type == TransactionType.etf);

  double get totalOpenValue => fold(0, (double sum, Gain gain) => sum + gain.openValue);
  double get totalCloseValue => fold(0, (double sum, Gain gain) => sum + gain.closeValue);
  double get grossProfit => fold(0, (double sum, Gain gain) => sum + gain.grossProfit);
  double get netProfit => fold(0, (double sum, Gain gain) => sum + gain.netProfit);
  double get totalFeesAndDividends => fold(0, (double sum, Gain gain) => sum + gain.feesAndDividends);

  double getTotalOpenValueIn(MoneySymbol symbol) =>
      fold(0, (double sum, Gain gain) => sum + gain.getOpenValueIn(symbol));
  double getTotalCloseValueIn(MoneySymbol symbol) =>
      fold(0, (double sum, Gain gain) => sum + gain.getCloseValueIn(symbol));
  double getGrossProfitIn(MoneySymbol symbol) =>
      fold(0, (double sum, Gain gain) => sum + gain.getGrossProfitIn(symbol));
  double getNetProfitIn(MoneySymbol symbol) => fold(0, (double sum, Gain gain) => sum + gain.getNetProfitIn(symbol));
  double getTotalFeesAndDividendsIn(MoneySymbol symbol) =>
      fold(0, (double sum, Gain gain) => sum + gain.getFeesAndDividendsIn(symbol));

  Gains toGains() => Gains()..addAll(this);
}

extension MapGainsExtension<K> on Map<K, List<Gain>> {
  double get totalOpenValue => values.fold(0, (double sum, List<Gain> gains) => sum + gains.totalOpenValue);
  double get totalCloseValue => values.fold(0, (double sum, List<Gain> gains) => sum + gains.totalCloseValue);
  double get grossProfit => values.fold(0, (double sum, List<Gain> gains) => sum + gains.grossProfit);
  double get netProfit => values.fold(0, (double sum, List<Gain> gains) => sum + gains.netProfit);
  double get totalFeesAndDividends =>
      values.fold(0, (double sum, List<Gain> gains) => sum + gains.totalFeesAndDividends);

  double getTotalOpenValueIn(MoneySymbol symbol) =>
      values.fold(0, (double sum, List<Gain> gains) => sum + gains.getTotalOpenValueIn(symbol));
  double getTotalCloseValueIn(MoneySymbol symbol) =>
      values.fold(0, (double sum, List<Gain> gains) => sum + gains.getTotalCloseValueIn(symbol));
  double getGrossProfitIn(MoneySymbol symbol) =>
      values.fold(0, (double sum, List<Gain> gains) => sum + gains.getGrossProfitIn(symbol));
  double getNetProfitIn(MoneySymbol symbol) =>
      values.fold(0, (double sum, List<Gain> gains) => sum + gains.getNetProfitIn(symbol));
  double getTotalFeesAndDividendsIn(MoneySymbol symbol) =>
      values.fold(0, (double sum, List<Gain> gains) => sum + gains.getTotalFeesAndDividendsIn(symbol));
}
