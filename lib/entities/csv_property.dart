class CsvProperty {
  final String name;
  final int? currencyParameterIndex;
  bool get isMethod => currencyParameterIndex != null;

  const CsvProperty(this.name, {this.currencyParameterIndex});

  @override
  String toString() =>
      "$name ${(currencyParameterIndex != null) ? "with currencyParameterIndex $currencyParameterIndex" : ""}";
}
