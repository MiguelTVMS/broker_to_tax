enum GroupBy {
  none("None", "none", true),
  sourceCountry("Source Country", "source-country");
  //counterpartCountry("Counterpart Country", "counterpart-country");

  const GroupBy(this.name, this.commandArgument, [this.isDefault = false]);

  final String name;
  final String commandArgument;
  final bool isDefault;

  String get fileNamePart => commandArgument.replaceAll("-", "_");

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

extension GroupsByExtension on Iterable<GroupBy> {
  GroupBy get defaultsTo => firstWhere((e) => e.isDefault);
}
