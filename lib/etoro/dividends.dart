import "dart:collection";

import "package:excel/excel.dart";
import "package:logging/logging.dart";

import "dividend.dart";

class EtoroDividends extends ListBase<EtoroDividend> {
  List<EtoroDividend> _dividends = [];
  static final _log = Logger("EtoroDividends");

  @override
  int get length => _dividends.length;

  @override
  set length(int newLength) {
    _dividends.length = newLength;
  }

  @override
  EtoroDividend operator [](int index) {
    return _dividends[index];
  }

  @override
  void operator []=(int index, EtoroDividend value) {
    _dividends[index] = value;
  }

  EtoroDividends.fromExcelTables(Excel excel, [bool skipFirstRow = true]) {
    var sheetName = "Dividends";
    Sheet? sheet = excel.tables[sheetName];
    if (sheet == null) throw Exception("$sheetName sheet not found");

    _log.fine("Parsing Excel Dividends sheet");
    List<List<Data?>> excelRows = sheet.rows;

    _dividends = excelRows.skip(skipFirstRow ? 1 : 0).map(EtoroDividend.fromExcel).toList();
    _log.info("Found $length eToro Dividends");
  }
}
