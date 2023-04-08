import "dart:core";

import "package:broker_to_tax/entities/exchange.dart";
import "package:broker_to_tax/entities/transaction_type.dart";
import "package:country_code/country_code.dart";

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

extension Iterables<Gain> on Iterable<Gain> {
  Map<K, List<Gain>> groupBy<K>(K Function(Gain) keyFunction) => fold(<K, List<Gain>>{},
      (Map<K, List<Gain>> map, Gain element) => map..putIfAbsent(keyFunction(element), () => <Gain>[]).add(element));
}

extension GainsExtension on Iterable<Gain> {
  Iterable<Gain> get byCrypto => _getByTransactionType(this, TransactionType.crypto);
  Iterable<Gain> get byStock => _getByTransactionType(this, TransactionType.stock);
  Iterable<Gain> get byCFD => _getByTransactionType(this, TransactionType.cfd);
  Iterable<Gain> get byETF => _getByTransactionType(this, TransactionType.etf);
  Iterable<Gain> get byStocksAndETFs => _getByTransactionTypes(this, [TransactionType.stock, TransactionType.etf]);

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

  static Iterable<Gain> _getByTransactionTypes(Iterable<Gain> gains, Iterable<TransactionType> transactionTypes) =>
      gains.where((gain) => transactionTypes.contains(gain.type));

  static Iterable<Gain> _getByTransactionType(Iterable<Gain> gains, TransactionType transactionType) =>
      gains.where((gain) => gain.type == transactionType);
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
