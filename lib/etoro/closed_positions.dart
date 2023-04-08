import "dart:collection";
import "package:csv/csv.dart";

import "../entities/broker_operation.dart";
import "../entities/gains.dart";
import "closed_position.dart";

class EtoroClosedPositions extends ListBase<EtoroClosedPosition> implements BrokerOperations {
  List<EtoroClosedPosition> _positions = [];

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
    var csvPositions = CsvToListConverter().convert(csvString);

    // TODO: Create a mapping between the csv columns and the EtoroClosedPosition fields
    _positions = csvPositions.skip(skipFirstRow ? 1 : 0).map(EtoroClosedPosition.fromCsvRow).toList();
  }

  @override
  Iterable<Gain> toGains() => _positions.map((e) => e.toGain());
}
