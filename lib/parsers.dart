import "package:intl/intl.dart";

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
