import "package:broker_to_tax/entities/exchange.dart";
import "package:test/test.dart";

void main() {
  var jsonString =
      "{\"2022-12-29\":{\"EUR\":0.93232},\"2022-12-30\":{\"EUR\":0.93225},\"2022-12-31\":{\"EUR\":0.93278}}";

  test("Create DailyExchangeRates from JSON String", () {
    var expected = 0.93225;

    var fromDate = DateTime(2022, 12, 30);

    var dailyExchangeRates = DailyExchangeRates()..addFromJsonString(jsonString);

    var result = dailyExchangeRates[fromDate]![Currency.eur];

    expect(result, expected);
  });
  group("Conversions", () {
    var dailyExchangeRates = DailyExchangeRates()..addFromJsonString(jsonString);
    test("To EUR", () {
      double amount = 2;
      var fromDate = DateTime(2022, 12, 30);

      var expected = amount * 0.93225;

      var result = dailyExchangeRates.convert(amount, Currency.eur, fromDate);

      expect(result, expected);
    });

    test("From EUR To USD", () {
      double amount = 2;
      var fromDate = DateTime(2022, 12, 30);

      var expected = amount / 0.93225;

      var result = dailyExchangeRates.convert(amount, Currency.usd, fromDate, Currency.eur);

      expect(result, expected);
    });
  });
}
