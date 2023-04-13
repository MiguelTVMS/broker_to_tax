enum Currency {
  usd("USD", "usd"),
  eur("EUR", "eur", true);

  const Currency(this.name, this.commandArgument, [this.isDefault = false]);

  final String name;
  final String commandArgument;
  final bool isDefault;

  factory Currency.fromString(String name) {
    return Currency.values.firstWhere((e) => e.name == name);
  }

  factory Currency.fromCommandArgumentString(String commandArgument) {
    return Currency.values.firstWhere((e) => e.commandArgument == commandArgument);
  }

  @override
  String toString() {
    return name;
  }

  String toCommandArgumentString() {
    return commandArgument;
  }
}

extension CurrenciesExtension on Iterable<Currency> {
  Currency get defaultsTo => firstWhere((e) => e.isDefault);
}
