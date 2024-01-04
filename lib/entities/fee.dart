import "currency.dart";
import "exchange.dart";

class Fee {
  DateTime date;
  double amount;
  ExchangeRate? _exchangeRate;
  ExchangeRate get exchangeRate => _exchangeRate ??= HistoricalExchangeRates()[date]!;

  Fee({required this.date, required this.amount});

  double getFeeInCurrency(Currency symbol) {
    return amount * exchangeRate.convert(amount, symbol);
  }
}

extension FeeExtension on Iterable<Fee>? {
  double getFeesSum() => this?.map((fee) => fee.amount).reduce((a, b) => a + b) ?? 0;

  double getFeesSumIn(Currency symbol) => this?.map((fee) => fee.getFeeInCurrency(symbol)).reduce((a, b) => a + b) ?? 0;

  double getAverageExchangeRate(Currency symbol) {
    var count = this?.length ?? 0;
    if (count == 0) return 0;
    var sum = this?.map((fee) => fee.getFeeInCurrency(symbol)).reduce((a, b) => a + b) ?? 0;
    return sum / count;
  }
}
