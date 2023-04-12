import "dart:collection";
import "package:csv/csv.dart";
import "package:logging/logging.dart";

import "../entities/broker_operation.dart";
import "../entities/gains.dart";
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

  EtoroClosedPositions.fromCsv(String csvString, [bool skipFirstRow = true]) {
    _log.fine("Parsing CSV string");
    var csvPositions = CsvToListConverter().convert(csvString);

    // TODO: Create a mapping between the csv columns and the EtoroClosedPosition fields
    _positions = csvPositions.skip(skipFirstRow ? 1 : 0).map(EtoroClosedPosition.fromCsvRow).toList();
    _log.info("Found $length eToro Positions");
  }

  @override
  Iterable<Gain> toGains() {
    _log.fine("Converting to gains");
    var gains = _positions.map((e) => e.toGain());
    _log.finer("Converted ${gains.length} gains from $length eToro operations");
    return gains;
  }
}
