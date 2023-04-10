import "package:broker_to_tax/entities/gains.dart";
import "package:broker_to_tax/etoro/closed_positions.dart";
import "package:test/test.dart";

void main() {
  group("eToro:", () {
    var csvString =
        "Position ID,Action,Amount,Units,Open Date,Close Date,Leverage,Spread,Profit,Open Rate,Close Rate,Take profit rate,Stop lose rate,Rollover Fees and Dividends,Copied From,Type,ISIN,Notes";
    // Stock position
    csvString +=
        "\r\n2316622589,Buy CSX Corp, 1.26 ,0.042770,04/11/2022 13:31:25,21/12/2022 15:49:30,1, 0.00 , 0.07 , 29.46 , 31.07 , 410.96 , 0.00 , 0.00 ,jaynemesis,Stocks,US1264081035,";
    // CFD position
    csvString +=
        "\r\n2336441128,\"Sell Tesla Motors, Inc.\", 1.06 ,0.006112,09/12/2022 14:31:31,21/12/2022 14:46:22,1, 0.00 , 0.21 , 173.42 , 139.33 , 0.00 , 260.12 , 0.00 ,jaynemesis,CFD,,";
    // Crypto position
    csvString +=
        "\r\n1518337297,Buy Cardano, 2.66 ,3.289636,07/03/2022 19:38:28,11/03/2022 07:34:48,1, 0.05 ,(0.04), 0.81 , 0.80 , 0.00 , 0.00 , 0.00 ,GS_Capital,Crypto,,";
    // ETF position
    csvString +=
        "\r\n1308606081,Buy Energy Select Sector SPDR, 3.16 ,0.064914,13/09/2021 13:31:14,07/03/2022 14:31:07,1, 0.00 , 1.78 , 48.68 , 76.03 , 0.00 , 0.00 , 0.06 ,Karlo_s,ETF,US81369Y5069,";

    test("Create closed positions from CSV.", () {
      var positions = EtoroClosedPositions.fromCsv(csvString);

      expect(positions.length, 4);
    });
    test("Convert to Gains", () {
      var positions = EtoroClosedPositions.fromCsv(csvString);
      var gains = positions.toGains();

      expect(positions.length, gains.length);
    });
    test("Open value is correct", () {
      var positions = EtoroClosedPositions.fromCsv(csvString);
      var stockPosition = positions.where((element) => element.type == "Stocks").first;
      var positionOpenValue = stockPosition.openRate * stockPosition.units;

      var gains = positions.toGains();
      var stockGains = gains.byStock.first;
      var gainsOpenValue = stockGains.openValue;

      expect(positionOpenValue, gainsOpenValue);
    });
    test("Close value is correct", () {
      var positions = EtoroClosedPositions.fromCsv(csvString);
      var stockPosition = positions.where((element) => element.type == "Stocks").first;
      var positionCloseValue = stockPosition.closeRate * stockPosition.units;

      var gains = positions.toGains();
      var stockGains = gains.byStock.first;
      var gainsCloseValue = stockGains.closeValue;

      expect(positionCloseValue, gainsCloseValue);
    });
    test("Date parse is correct", () {
      var positions = EtoroClosedPositions.fromCsv(csvString);
      var position = positions.firstWhere((element) => element.positionId == 2316622589);

      // 04/11/2022 13:31:25
      var expectedOpenDate = DateTime(2022, 11, 4, 13, 31, 25);

      // 21/12/2022 15:49:30
      var expectedCloseDate = DateTime(2022, 12, 21, 15, 49, 30);

      expect(position.openDate, expectedOpenDate);
      expect(position.closeDate, expectedCloseDate);
    });
    test("Has Stock position", () {
      var positions = EtoroClosedPositions.fromCsv(csvString);
      var gains = positions.toGains();

      expect(gains.byStock.length, 1);
    });
    test("Has CFD position", () {
      var positions = EtoroClosedPositions.fromCsv(csvString);
      var gains = positions.toGains();

      expect(gains.byCFD.length, 1);
    });
    test("Has Crypto position", () {
      var positions = EtoroClosedPositions.fromCsv(csvString);
      var gains = positions.toGains();

      expect(gains.byCrypto.length, 1);
    });
    test("Has ETF position", () {
      var positions = EtoroClosedPositions.fromCsv(csvString);
      var gains = positions.toGains();

      expect(gains.byETF.length, 1);
    });
  });
}
