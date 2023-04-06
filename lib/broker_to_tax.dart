import "dart:io";

import "entities/broker_operation.dart";
import "entities/exchange.dart";
import "entities/gains.dart";
import "etoro/closed_positions.dart";

class BrokerToTax {
  /// The path to the file to parse.
  String filePath;
  String exchangeDirectory;

  BrokerToTax(this.filePath, this.exchangeDirectory);

  Future<void> run() async {
    BrokerOperations etoroOperations = await readDataSource();
    await calculateGains(etoroOperations);
  }

  Future<EtoroClosedPositions> readDataSource() async {
    var file = File(filePath);

    if (!await file.exists()) {
      throw Exception("File does not exist: $filePath");
    }

    var etoroPositions = EtoroClosedPositions.fromCsv(csvString: await file.readAsString());
    print("Found ${etoroPositions.length} eToro Positions");
    return etoroPositions;
  }

  Future<void> calculateGains(BrokerOperations brokerOperations) async {
    // Wait for the exchange rates to be loaded.
    await HistoricalExchangeRates.initialize(exchangeDirectory);

    var gains = brokerOperations.toGains();
    print(
        "Found ${gains.length} total gains with a net profit of ${gains.netProfit} USD converted to ${gains.getNetProfitIn(MoneySymbol.eur)} ${MoneySymbol.eur} with an average exchange rate of ${gains.getAverageOpenExchangeRate(MoneySymbol.eur)} on open and ${gains.getAverageCloseExchangeRate(MoneySymbol.eur)} on close.");

    var gainsByCrypto = gains.byCrypto;
    print(
        "Found ${gainsByCrypto.length} Crypto gains with a net profit of ${gainsByCrypto.netProfit} USD converted to ${gainsByCrypto.getNetProfitIn(MoneySymbol.eur)} ${MoneySymbol.eur} with an average exchange rate of ${gainsByCrypto.getAverageOpenExchangeRate(MoneySymbol.eur)} on open and ${gainsByCrypto.getAverageCloseExchangeRate(MoneySymbol.eur)} on close.");

    var gainsByStock = gains.byStock;
    print(
        "Found ${gainsByStock.length} Stock gains with a net profit of ${gainsByStock.netProfit} USD converted to ${gainsByStock.getNetProfitIn(MoneySymbol.eur)} ${MoneySymbol.eur} with an average exchange rate of ${gainsByStock.getAverageOpenExchangeRate(MoneySymbol.eur)} on open and ${gainsByStock.getAverageCloseExchangeRate(MoneySymbol.eur)} on close.");

    var gainsByCFD = gains.byCFD;
    print(
        "Found ${gainsByCFD.length} CFD gains with a net profit of ${gainsByCFD.netProfit} USD converted to ${gainsByCFD.getNetProfitIn(MoneySymbol.eur)} ${MoneySymbol.eur} with an average exchange rate of ${gainsByCFD.getAverageOpenExchangeRate(MoneySymbol.eur)} on open and ${gainsByCFD.getAverageCloseExchangeRate(MoneySymbol.eur)} on close.");

    var gainsByETF = gains.byETF;
    print(
        "Found ${gainsByETF.length} ETF gains with a net profit of ${gainsByETF.netProfit} USD converted to ${gainsByETF.getNetProfitIn(MoneySymbol.eur)} ${MoneySymbol.eur} with an average exchange rate of ${gainsByETF.getAverageOpenExchangeRate(MoneySymbol.eur)} on open and ${gainsByETF.getAverageCloseExchangeRate(MoneySymbol.eur)} on close.");

    var stockGains = [...gains.byStock, ...gains.byETF];
    print(
        "Found ${stockGains.length} Stock gains by country with a net profit of ${stockGains.netProfit} USD converted to ${stockGains.getNetProfitIn(MoneySymbol.eur)} ${MoneySymbol.eur} with an average exchange rate of ${stockGains.getAverageOpenExchangeRate(MoneySymbol.eur)} on open and ${stockGains.getAverageCloseExchangeRate(MoneySymbol.eur)} on close.");

    var stockGainsByCountryReport = [...gains.byStock, ...gains.byETF].groupBy((gain) => gain.sourceCountry);
    print(
        "Found ${stockGainsByCountryReport.length} countries with stock gains with a net profit of ${stockGainsByCountryReport.netProfit} USD converted to ${stockGainsByCountryReport.getNetProfitIn(MoneySymbol.eur)} ${MoneySymbol.eur} with an average exchange rate of ${stockGainsByCountryReport.getAverageOpenExchangeRate(MoneySymbol.eur)} on open and ${stockGainsByCountryReport.getAverageCloseExchangeRate(MoneySymbol.eur)} on close.");

    var cryptoGainsReport = gains.byCrypto.groupBy((gain) => gain.name);
    print(
        "Found ${cryptoGainsReport.length} Crypto gains with a net profit of ${cryptoGainsReport.netProfit} USD converted to ${cryptoGainsReport.getNetProfitIn(MoneySymbol.eur)} ${MoneySymbol.eur} with an average exchange rate of ${cryptoGainsReport.getAverageOpenExchangeRate(MoneySymbol.eur)} on open and ${cryptoGainsReport.getAverageCloseExchangeRate(MoneySymbol.eur)} on close.");

    var cfdGainsReport = gains.byCFD.groupBy((gain) => gain.type);
    print(
        "Found ${cfdGainsReport.length} CFD gains with a net profit of ${cfdGainsReport.netProfit} USD converted to ${cfdGainsReport.getNetProfitIn(MoneySymbol.eur)} ${MoneySymbol.eur} with an average exchange rate of ${cfdGainsReport.getAverageOpenExchangeRate(MoneySymbol.eur)} on open and ${cfdGainsReport.getAverageCloseExchangeRate(MoneySymbol.eur)} on close.");
  }
}
