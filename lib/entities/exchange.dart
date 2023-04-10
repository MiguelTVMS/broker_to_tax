import "dart:collection";
import "dart:convert";
import "dart:io";

import "../parsers.dart";

enum Currency {
  usd("USD"),
  eur("EUR");

  const Currency(this.name);

  final String name;

  static Currency fromString(String name) {
    return Currency.values.firstWhere((e) => e.name == name);
  }

  @override
  String toString() {
    return name;
  }
}

/// Historical exchange rates.
///
/// To initialize, call [HistoricalExchangeRates.addFromJsonFilesInDirectory] with await.
/// This is a singleton implementation of [DailyExchangeRates].
class HistoricalExchangeRates extends DailyExchangeRates {
  static HistoricalExchangeRates? _instance;
  HistoricalExchangeRates._();
  factory HistoricalExchangeRates() => _instance ??= HistoricalExchangeRates._();

  /// Adds exchange rates from a list of JSON files.
  ///
  /// The files in [exchangeFiles] must contain a JSON object with the date as key and the exchange rates as value.
  Future<void> addFromJsonFilesInDirectory(Iterable<FileSystemEntity> exchangeFiles) async {
    for (var file in exchangeFiles) {
      HistoricalExchangeRates().addFromJsonString(await (file as File).readAsString());
    }
  }
}

/// A map of exchange rates for a specific date.
///
/// To initialize, call [DailyExchangeRates.initialize] with await.
class DailyExchangeRates {
  final Map<String, ExchangeRate> _map = {};

  void addFromJsonString(String json) {
    var jsonObject = jsonDecode(json);
    jsonObject.forEach((kDate, vExchangeRates) {
      var exchangeRate = ExchangeRate();
      var valueMap = vExchangeRates as Map<String, dynamic>;
      valueMap.forEach((kMoneySymbol, vDouble) {
        exchangeRate[Currency.fromString(kMoneySymbol)] = DynamicParsers.toDouble(vDouble);
      });

      // Add base exchange rate if not present.
      if (!exchangeRate.containsKey(ExchangeRate.baseExchangeRate)) exchangeRate[ExchangeRate.baseExchangeRate] = 1.0;

      this[kDate] = exchangeRate;
    });
  }

  double convert(double value, Currency to, DateTime when, [Currency from = ExchangeRate.baseExchangeRate]) {
    if (from == to) return value;
    var exchangeRate = this[when];

    if (exchangeRate == null) throw Exception("No exchange rate found for date $when.");
    return exchangeRate.convert(value, to, from);
  }

  String _getKeyString(Object? key) {
    if (key is DateTime) {
      return key.toString().substring(0, 10);
    } else if (key is String) {
      return key;
    } else {
      throw Exception("Key must be of type DateTime or String.");
    }
  }

  ExchangeRate? operator [](Object key) => _map[_getKeyString(key)];

  void operator []=(Object key, ExchangeRate value) => _map[_getKeyString(key)] = value;
}

class ExchangeRate extends MapBase<Currency, double> {
  final Map<Currency, double> _map = {};
  static const Currency baseExchangeRate = Currency.usd;

  @override
  double? operator [](Object? key) => _map[key];

  @override
  void operator []=(Currency key, double value) => _map[key] = value;

  @override
  void clear() => _map.clear();

  @override
  Iterable<Currency> get keys => _map.keys;

  @override
  double? remove(Object? key) => _map.remove(key);

  double convert(double value, Currency to, [Currency from = baseExchangeRate]) =>
      (from == to) ? value : (value / this[from]!) * this[to]!;

  static fromJson(String s) {
    var exchangeRate = ExchangeRate();
    var json = jsonDecode(s);
    exchangeRate[Currency.eur] = json["EUR"];
    return exchangeRate;
  }
}
