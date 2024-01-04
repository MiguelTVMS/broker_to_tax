import "dart:collection";
import "dart:io";
import "package:csv/csv.dart";
import "package:excel/excel.dart";
import "package:logging/logging.dart";

import "../entities/broker_operation.dart";
import "../entities/gains.dart";
import "account_activities.dart";
import "closed_position.dart";

class EtoroClosedPositions extends ListBase<EtoroClosedPosition> implements BrokerOperations {
  List<EtoroClosedPosition> _positions = [];
  static final _log = Logger("EtoroClosedPositions");

  @override
  get length => _positions.length;

  @override
  set length(int newLength) {
    _positions.length = newLength;
  }

  @override
  EtoroClosedPosition operator [](int index) {
    return _positions[index];
  }

  @override
  void operator []=(int index, EtoroClosedPosition value) {
    _positions[index] = value;
  }

  static fromExcelFile(String excelFilePath) {
    var xlsxFile = File(excelFilePath);
    if (!xlsxFile.existsSync()) throw Exception("File not found: $excelFilePath");

    _log.info("Reading file: $excelFilePath");
    var excel = Excel.decodeBytes(File(excelFilePath).readAsBytesSync());

    var activities = EtoroAccountActivities.fromExcelSheet(excel);
    var positions = EtoroClosedPositions.fromExcelTables(excel);

    positions.crossData(activities);

    return positions;
  }

  EtoroClosedPositions.fromExcelTables(Excel excel, [bool skipFirstRow = true]) {
    var sheetName = "Closed Positions";
    Sheet? sheet = excel.tables[sheetName];
    if (sheet == null) throw Exception("$sheetName sheet not found");

    _log.fine("Parsing Closed Positions Excel sheet");
    List<List<Data?>> excelRows = sheet.rows;

    _positions = excelRows.skip(skipFirstRow ? 1 : 0).map(EtoroClosedPosition.fromExcelRow).toList();
    _log.info("Found $length eToro Closed Positions");
  }

  EtoroClosedPositions.fromCsv(String csvString, [bool skipFirstRow = true]) {
    _log.fine("Parsing CSV string");
    var csvPositions = CsvToListConverter().convert(csvString);

    // TODO: Create a mapping between the csv columns and the EtoroClosedPosition fields
    _positions = csvPositions.skip(skipFirstRow ? 1 : 0).map(EtoroClosedPosition.fromCsvRow).toList();
    _log.info("Found $length eToro Positions");
  }

  crossData(EtoroAccountActivities activities) {
    _log.fine("Crossing data");
    for (var position in _positions) {
      position.crossData(activities);
    }
    _log.finer("Crossed data for $length eToro positions");
  }

  @override
  Iterable<Gain> toGains() {
    _log.fine("Converting to gains");
    var gains = _positions.map((e) => e.toGain());
    _log.finer("Converted ${gains.length} gains from $length eToro operations");
    return gains;
  }
}
