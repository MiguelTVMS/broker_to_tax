enum GroupBy {
  none("None", "none"),
  operation("Operation", "operation"),
  cryptoCurrency("Crypto Currency", "crypto-currency", GroupBy.operation),
  sourceCountry("Source Country", "source-country");
  //counterpartCountry("Counterpart Country", "counterpart-country");

  const GroupBy(this.name, this.commandArgument, [this._realGroupBy]);

  final String name;
  final String commandArgument;
  final GroupBy? _realGroupBy;

  String get fileNamePart => commandArgument.replaceAll("-", "_");
  GroupBy get realGroupBy => _realGroupBy ?? this;

  factory GroupBy.fromNameString(String name) {
    return GroupBy.values.firstWhere((e) => e.name == name);
  }

  factory GroupBy.fromCommandArgumentString(String commandArgument) {
    return GroupBy.values.firstWhere((e) => e.commandArgument == commandArgument);
  }

  @override
  String toString() {
    return name;
  }
}
