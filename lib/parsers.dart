import "package:excel/excel.dart";
import "package:intl/intl.dart";

class ExcelParsers {
  static DateTime toDateTime(Data? data, String formatString) {
    if (data!.value.runtimeType == DateCellValue) {
      var dateValue = data as DateCellValue;
      return dateValue.asDateTimeUtc();
    } else if (data.value.runtimeType == TextCellValue) {
      return DynamicParsers.toDateTime(data.value.toString(), formatString);
    } else {
      throw Exception("Unknown type: $data.runtimeType");
    }
  }

  static int toInteger(Data? data) {
    if (data!.value.runtimeType == IntCellValue) {
      return (data.value as IntCellValue).value;
    } else if (data.value.runtimeType == TextCellValue) {
      return DynamicParsers.toInteger(data.value.toString());
    } else {
      throw Exception("Unknown type: $data.runtimeType");
    }
  }

  static int? toIntegerOrNull(Data? data) {
    if (data == null) return null;
    return toInteger(data);
  }

  static double toDouble(Data? data) {
    if (data!.value.runtimeType == DoubleCellValue) {
      return (data.value as DoubleCellValue).value;
    } else if (data.value.runtimeType == IntCellValue) {
      return toInteger(data).toDouble();
    } else if (data.value.runtimeType == TextCellValue) {
      return DynamicParsers.toDouble(data.value.toString());
    } else {
      throw Exception("Unknown type: $data.runtimeType");
    }
  }
}

class DynamicParsers {
  static DateTime toDateTime(dynamic value, String formatString) {
    var dateFormat = DateFormat(formatString);
    if (value is String) {
      return dateFormat.parse(value);
    } else if (value is DateTime) {
      return value;
    } else {
      throw Exception("Unknown type: $value.runtimeType");
    }
  }

  static int toInteger(dynamic value) {
    if (value is String) {
      var integerString = value.trim().replaceAll(",", "");

      if (integerString.startsWith("(") && integerString.endsWith(")")) {
        integerString = integerString.replaceAll("(", "").replaceAll(")", "");
        integerString = "-$integerString";
      }
      return int.parse(integerString);
    } else if (value is int) {
      return value;
    } else if (value is int) {
      return value.toInt();
    } else {
      throw Exception("Unknown type: $value.runtimeType");
    }
  }

  static double toDouble(dynamic value) {
    if (value is String) {
      var doubleString = value.trim().replaceAll(",", "");

      if (doubleString.startsWith("(") && doubleString.endsWith(")")) {
        doubleString = doubleString.replaceAll("(", "").replaceAll(")", "");
        doubleString = "-$doubleString";
      }
      return double.parse(doubleString);
    } else if (value is double) {
      return value;
    } else if (value is int) {
      return value.toDouble();
    } else {
      throw Exception("Unknown type: $value.runtimeType");
    }
  }
}
