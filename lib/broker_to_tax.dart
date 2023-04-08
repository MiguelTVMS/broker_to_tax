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

    var etoroPositions = EtoroClosedPositions.fromCsv(await file.readAsString());
    print("Found ${etoroPositions.length} eToro Positions");
    return etoroPositions;
  }

  Future<void> calculateGains(BrokerOperations brokerOperations) async {
    // Wait for the exchange rates to be loaded.
    await HistoricalExchangeRates().addFromJsonFilesInDirectory(exchangeDirectory);

    var gains = brokerOperations.toGains();
    print(
        "Found ${gains.length} total gains with a net profit of ${gains.netProfit} USD converted to ${gains.getNetProfitIn(Currency.eur)} ${Currency.eur} with an average exchange rate of ${gains.getAverageOpenExchangeRate(Currency.eur)} on open and ${gains.getAverageCloseExchangeRate(Currency.eur)} on close.");

    var gainsByCrypto = gains.byCrypto;
    print(
        "Found ${gainsByCrypto.length} Crypto gains with a net profit of ${gainsByCrypto.netProfit} USD converted to ${gainsByCrypto.getNetProfitIn(Currency.eur)} ${Currency.eur} with an average exchange rate of ${gainsByCrypto.getAverageOpenExchangeRate(Currency.eur)} on open and ${gainsByCrypto.getAverageCloseExchangeRate(Currency.eur)} on close.");

    var gainsByStock = gains.byStock;
    print(
        "Found ${gainsByStock.length} Stock gains with a net profit of ${gainsByStock.netProfit} USD converted to ${gainsByStock.getNetProfitIn(Currency.eur)} ${Currency.eur} with an average exchange rate of ${gainsByStock.getAverageOpenExchangeRate(Currency.eur)} on open and ${gainsByStock.getAverageCloseExchangeRate(Currency.eur)} on close.");

    var gainsByCFD = gains.byCFD;
    print(
        "Found ${gainsByCFD.length} CFD gains with a net profit of ${gainsByCFD.netProfit} USD converted to ${gainsByCFD.getNetProfitIn(Currency.eur)} ${Currency.eur} with an average exchange rate of ${gainsByCFD.getAverageOpenExchangeRate(Currency.eur)} on open and ${gainsByCFD.getAverageCloseExchangeRate(Currency.eur)} on close.");

    var gainsByETF = gains.byETF;
    print(
        "Found ${gainsByETF.length} ETF gains with a net profit of ${gainsByETF.netProfit} USD converted to ${gainsByETF.getNetProfitIn(Currency.eur)} ${Currency.eur} with an average exchange rate of ${gainsByETF.getAverageOpenExchangeRate(Currency.eur)} on open and ${gainsByETF.getAverageCloseExchangeRate(Currency.eur)} on close.");

    var stockGains = [...gains.byStock, ...gains.byETF];
    print(
        "Found ${stockGains.length} Stock gains by country with a net profit of ${stockGains.netProfit} USD converted to ${stockGains.getNetProfitIn(Currency.eur)} ${Currency.eur} with an average exchange rate of ${stockGains.getAverageOpenExchangeRate(Currency.eur)} on open and ${stockGains.getAverageCloseExchangeRate(Currency.eur)} on close.");

    var stockGainsByCountryReport = [...gains.byStock, ...gains.byETF].groupBy((gain) => gain.sourceCountry);
    print(
        "Found ${stockGainsByCountryReport.length} countries with stock gains with a net profit of ${stockGainsByCountryReport.netProfit} USD converted to ${stockGainsByCountryReport.getNetProfitIn(Currency.eur)} ${Currency.eur} with an average exchange rate of ${stockGainsByCountryReport.getAverageOpenExchangeRate(Currency.eur)} on open and ${stockGainsByCountryReport.getAverageCloseExchangeRate(Currency.eur)} on close.");

    var cryptoGainsReport = gains.byCrypto.groupBy((gain) => gain.name);
    print(
        "Found ${cryptoGainsReport.length} Crypto gains with a net profit of ${cryptoGainsReport.netProfit} USD converted to ${cryptoGainsReport.getNetProfitIn(Currency.eur)} ${Currency.eur} with an average exchange rate of ${cryptoGainsReport.getAverageOpenExchangeRate(Currency.eur)} on open and ${cryptoGainsReport.getAverageCloseExchangeRate(Currency.eur)} on close.");

    var cfdGainsReport = gains.byCFD.groupBy((gain) => gain.type);
    print(
        "Found ${cfdGainsReport.length} CFD gains with a net profit of ${cfdGainsReport.netProfit} USD converted to ${cfdGainsReport.getNetProfitIn(Currency.eur)} ${Currency.eur} with an average exchange rate of ${cfdGainsReport.getAverageOpenExchangeRate(Currency.eur)} on open and ${cfdGainsReport.getAverageCloseExchangeRate(Currency.eur)} on close.");
  }
}
