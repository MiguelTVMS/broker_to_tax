import "dart:collection";
import "dart:convert";
import "dart:io";

enum MoneySymbol {
  usd("USD"),
  eur("EUR");

  const MoneySymbol(this.name);

  final String name;

  static MoneySymbol fromString(String name) {
    return MoneySymbol.values.firstWhere((e) => e.name == name);
  }

  @override
  String toString() {
    return name;
  }
}

/// A map of exchange rates for a specific date.
/// This is a singleton class that is initialized once.
/// To initialize, call [HistoricalExchangeRates.initialize] with await.
class HistoricalExchangeRates extends MapBase<String, ExchangeRate> {
  final Map<String, ExchangeRate> _map = {};

  static HistoricalExchangeRates? _instance;

  static get isInitialized => _instance != null;

  /// Returns the exchange rate for the given [date].
  ///
  /// [date] The date of the exchange rate in the format "yyyy-MM-dd".
  /// Returns null if no exchange rate is found.
  static ExchangeRate getByDateString(String date) {
    if (!isInitialized) throw Exception("HistoricalExchangeRates is not initialized.");
    if (!_instance!.containsKey(date)) throw Exception("No exchange rate found for date $date");
    return _instance![date]!;
  }

  /// Returns the exchange rate for the given [date].
  ///
  /// [date] The date of the exchange rate.
  /// Returns null if no exchange rate is found.
  static ExchangeRate getByDate(DateTime date) => getByDateString(date.toString().substring(0, 10));

  static Future<void> initialize(String directory) async {
    if (directory.isEmpty) throw Exception("Directory should not be empty.");

    var instance = HistoricalExchangeRates();
    var exchangeFiles = await instance._getExchangeRatesFiles(directory);
    await instance._fillHistoricalData(exchangeFiles);
    HistoricalExchangeRates._instance = instance;
  }

  Future<Iterable<FileSystemEntity>> _getExchangeRatesFiles(String directory) async {
    return await Directory(directory).list(recursive: false).where((event) => event.path.endsWith(".json")).toList();
  }

  Future<void> _fillHistoricalData(Iterable<FileSystemEntity> files) async {
    for (var file in files) {
      Map<String, dynamic> jsonObject = jsonDecode(await (file as File).readAsString());
      jsonObject.forEach((key, value) {
        var exchangeRate = ExchangeRate();
        var valueMap = value as Map<String, dynamic>;
        valueMap.forEach((key, value) {
          exchangeRate[MoneySymbol.fromString(key)] = value;
        });
        this[key] = exchangeRate;
      });
      var exchangeRate = jsonObject;
      //this[exchangeRate.date] = exchangeRate;
    }
  }

  @override
  ExchangeRate? operator [](Object? key) => _map[key];

  @override
  void operator []=(String key, ExchangeRate value) => _map[key] = value;

  @override
  void clear() => _map.clear();

  @override
  Iterable<String> get keys => _map.keys;

  @override
  ExchangeRate? remove(Object? key) => _map.remove(key);
}

class ExchangeRate extends MapBase<MoneySymbol, double> {
  final Map<MoneySymbol, double> _map = {};

  @override
  double? operator [](Object? key) => _map[key];

  @override
  void operator []=(MoneySymbol key, double value) => _map[key] = value;

  @override
  void clear() => _map.clear();

  @override
  Iterable<MoneySymbol> get keys => _map.keys;

  @override
  double? remove(Object? key) => _map.remove(key);

  double? convert(double? value, MoneySymbol to) {
    if (value == null) return null;

    if (to == MoneySymbol.usd) return value;

    return value * this[to]!;
  }

  static fromJson(String s) {
    var exchangeRate = ExchangeRate();
    var json = jsonDecode(s);
    exchangeRate[MoneySymbol.eur] = json["EUR"];
    return exchangeRate;
  }
}
