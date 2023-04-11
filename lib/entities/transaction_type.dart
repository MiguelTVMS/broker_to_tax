enum TransactionType {
  stock("Stock"),
  cfd("CFD"),
  crypto("Crypto"),
  etf("ETF");

  const TransactionType(this.name);

  final String name;

  static TransactionType fromString(String name) {
    return TransactionType.values.firstWhere((e) => e.name == name);
  }

  @override
  String toString() {
    return name;
  }
}
