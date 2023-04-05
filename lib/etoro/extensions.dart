import "../transaction_type.dart";
import "closed_position.dart";

extension TransactionTypeParsing on TransactionType {
  static TransactionType fromEtoro(EtoroClosedPosition etoroPosition) {
    if (etoroPosition.type.toLowerCase() == "stocks") {
      return TransactionType.stock;
    } else if (etoroPosition.type.toLowerCase() == "cfd") {
      return TransactionType.cfd;
    } else if (etoroPosition.type.toLowerCase() == "crypto") {
      return TransactionType.crypto;
    } else if (etoroPosition.type.toLowerCase() == "etf") {
      return TransactionType.etf;
    } else {
      throw Exception("Unknown transaction type: ${etoroPosition.type}");
    }
  }
}
