import "package:excel/excel.dart";

import "../parsers.dart";

class EtoroDividend {
  int positionId;
  DateTime date;
  double netReceived;
  double withholdingTaxAmount;

  EtoroDividend({
    required this.positionId,
    required this.date,
    required this.netReceived,
    required this.withholdingTaxAmount,
  });

  factory EtoroDividend.fromExcel(List<Data?> excelRow) {
    return EtoroDividend(
      positionId: ExcelParsers.toInteger(excelRow[7]),
      date: ExcelParsers.toDateTime(excelRow[0], "dd/MM/yyyy"),
      netReceived: ExcelParsers.toDouble(excelRow[2]),
      withholdingTaxAmount: ExcelParsers.toDouble(excelRow[5]),
    );
  }
}
