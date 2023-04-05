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

  double get openValue => units * openRate;
  double get closeValue => units * closeRate;
  double get grossProfit => closeValue - openValue;
  double get netProfit => closeValue - openValue - feesAndDividends;

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
}

extension MapGainsExtension<K> on Map<K, List<Gain>> {
  double get totalOpenValue => values.fold(0, (double sum, List<Gain> gains) => sum + gains.totalOpenValue);
  double get totalCloseValue => values.fold(0, (double sum, List<Gain> gains) => sum + gains.totalCloseValue);
  double get grossProfit => values.fold(0, (double sum, List<Gain> gains) => sum + gains.grossProfit);
  double get netProfit => values.fold(0, (double sum, List<Gain> gains) => sum + gains.netProfit);
  double get totalFeesAndDividends =>
      values.fold(0, (double sum, List<Gain> gains) => sum + gains.totalFeesAndDividends);
}
