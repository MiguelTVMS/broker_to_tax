import "package:excel/excel.dart";

import "../parsers.dart";

class EtoroAccountActivity {
  int? positionId;
  DateTime date;
  String type;
  double amount;

  EtoroAccountActivity({
    required this.positionId,
    required this.date,
    required this.type,
    required this.amount,
  });

  factory EtoroAccountActivity.fromExcel(List<Data?> excelRow) {
    return EtoroAccountActivity(
      positionId: ExcelParsers.toIntegerOrNull(excelRow[8]),
      date: ExcelParsers.toDateTime(excelRow[0], "dd/MM/yyyy HH:mm:ss"),
      type: excelRow[1]!.value.toString(),
      amount: ExcelParsers.toDouble(excelRow[3]),
    );
  }
}
