import "dart:io";

import "entities/gains.dart";
import "etoro/closed_positions.dart";

class BrokerToTax {
  String filePath;

  BrokerToTax(this.filePath);

  Future<void> run() async {
    var file = File(filePath);

    if (!await file.exists()) {
      throw Exception("File does not exist: $filePath");
    }

    var etoroPositions = EtoroClosedPositions.fromCsv(csvString: await file.readAsString());
    print("Found ${etoroPositions.length} eToro Positions");

    var gains = etoroPositions.toGains();
    print("Found ${gains.byCrypto.length} Crypto gains with a net profit of ${gains.byCrypto.netProfit}");
    print("Found ${gains.byStock.length} Stock gains with a net profit of ${gains.byStock.netProfit}");
    print("Found ${gains.byCFD.length} CFD gains with a net profit of ${gains.byCFD.netProfit}");
    print("Found ${gains.byETF.length} ETF gains with a net profit of ${gains.byETF.netProfit}");
    print("Found ${gains.length} total gains with a net profit of ${gains.netProfit}");

    var stockGains = [...gains.byStock, ...gains.byETF];
    print("Found ${stockGains.length} Stock gains by country with a net profit of ${stockGains.netProfit}");
    var stockGainsByCountry = [...gains.byStock, ...gains.byETF].groupBy((gain) => gain.sourceCountry);
    print(
        "Found ${stockGainsByCountry.length} countries with stock gains with a net profit of ${stockGainsByCountry.netProfit}");

    var cryptoGainsReport = gains.byCrypto.groupBy((gain) => gain.name);
    print("Found ${cryptoGainsReport.length} Crypto gains with a net profit of ${cryptoGainsReport.netProfit}");

    var cfdGainsReport = gains.byCFD.groupBy((gain) => gain.type);
    print("Found ${cfdGainsReport.length} CFD gains with a net profit of ${cfdGainsReport.netProfit}");
  }
}
