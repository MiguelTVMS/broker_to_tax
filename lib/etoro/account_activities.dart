import "dart:collection";

import "package:excel/excel.dart";
import "package:logging/logging.dart";

import "account_activity.dart";

class EtoroAccountActivities extends ListBase<EtoroAccountActivity> {
  List<EtoroAccountActivity> _activities = [];
  static final _log = Logger("EtoroAccountActivities");

  @override
  int get length => _activities.length;

  @override
  set length(int newLength) {
    _activities.length = newLength;
  }

  @override
  EtoroAccountActivity operator [](int index) {
    return _activities[index];
  }

  @override
  void operator []=(int index, EtoroAccountActivity value) {
    _activities[index] = value;
  }

  EtoroAccountActivities.fromExcelSheet(Excel excel, [bool skipFirstRow = true]) {
    var sheetName = "Account Activity";
    Sheet? sheet = excel.tables[sheetName];
    if (sheet == null) throw Exception("$sheetName sheet not found");

    _log.fine("Parsing Excel Account Activity sheet");
    List<List<Data?>> excelRows = sheet.rows;

    _activities = excelRows.skip(skipFirstRow ? 1 : 0).map(EtoroAccountActivity.fromExcel).toList();
    _log.info("Found $length eToro Account Activities");
  }
}
