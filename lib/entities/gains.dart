import "dart:core";
import "dart:mirrors";

import "package:broker_to_tax/entities/exchange.dart";
import "package:broker_to_tax/entities/transaction_type.dart";
import "package:country_code/country_code.dart";
import "package:csv/csv.dart";
import "package:logging/logging.dart";
import "csv_property.dart";

class Gain {
  @CsvProperty("Name")
  String name;

  @CsvProperty("Open Date")
  DateTime openDate;

  @CsvProperty("Close Date")
  DateTime closeDate;

  @CsvProperty("Units")
  double units;

  @CsvProperty("Open Rate")
  double openRate;

  @CsvProperty("Close Rate")
  double closeRate;

  @CsvProperty("Fees & Dividends")
  double feesAndDividends;

  @CsvProperty("Type")
  TransactionType type;

  @CsvProperty("Source Country")
  CountryCode sourceCountry;

  @CsvProperty("Counterparty Country")
  CountryCode counterpartyCountry;

  double? _openValue;
  @CsvProperty("Open Value")
  double get openValue => _openValue ??= units * openRate;

  double? _closeValue;
  @CsvProperty("Close Value")
  double get closeValue => _closeValue ??= units * closeRate;

  double? _grossProfit;
  @CsvProperty("Gross Profit")
  double get grossProfit => _grossProfit ??= closeValue - openValue;

  double? _netProfit;
  @CsvProperty("Net Profit")
  double get netProfit => _netProfit ??= closeValue - openValue + feesAndDividends;

  ExchangeRate? _openExchangeRate;
  //@GainCsvProperty("Open Exchange Rate")
  ExchangeRate get openExchangeRate => _openExchangeRate ??= HistoricalExchangeRates()[openDate]!;

  ExchangeRate? _closeExchangeRate;
  //@GainCsvProperty("Close Exchange Rate")
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

  @CsvProperty("Converted Open Value", currencyParameterIndex: 0)
  double getOpenValueIn(Currency symbol) => openExchangeRate.convert(openValue, symbol);

  @CsvProperty("Converted Close Value", currencyParameterIndex: 0)
  double getCloseValueIn(Currency symbol) => closeExchangeRate.convert(closeValue, symbol);

  @CsvProperty("Converted Fees and Dividends", currencyParameterIndex: 0)
  double getFeesAndDividendsIn(Currency symbol) => closeExchangeRate.convert(feesAndDividends, symbol);

  @CsvProperty("Converted Gross Profit", currencyParameterIndex: 0)
  double getGrossProfitIn(Currency symbol) => getCloseValueIn(symbol) - getOpenValueIn(symbol);

  @CsvProperty("Converted Net Profit", currencyParameterIndex: 0)
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
    Map<String, CsvProperty> columns = <String, CsvProperty>{};

    var classMirror = reflectClass(Gain);
    for (var v in classMirror.declarations.values
        .where((e) => e.metadata.where((m) => m.reflectee is CsvProperty).isNotEmpty)) {
      _log.finer("Found GainCsvProperty metadata in ${v.simpleName}");
      var name = MirrorSystem.getName(v.simpleName);
      columns[name] = v.metadata.where((meta) => meta.reflectee is CsvProperty).first.reflectee as CsvProperty;
      _log.finest("Added column $name named ${columns[name]}");
    }

    if (addHeader) {
      _log.fine("Adding header");
      csvRows.add(columns.values.map((e) => e.name).toList());
    }

    forEach((gain) {
      var gainMirror = reflect(gain);
      var csvCols = <dynamic>[];
      columns.forEach((key, value) {
        if (value.isMethod) {
          //TODO: Support more than one parameter
          var params = <dynamic>[currency];
          var methodMirror = gainMirror.invoke(Symbol(key), params);
          csvCols.add(methodMirror.reflectee);
        } else {
          var variableMirror = gainMirror.getField(Symbol(key));
          csvCols.add(variableMirror.reflectee);
        }
      });
      csvRows.add(csvCols);
    });

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
