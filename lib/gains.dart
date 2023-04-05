class GainReportLine {
  String name;
  int operations;
  double openAmount;
  double closeAmount;
  double feesAndDividends;

  double get grossProfit => closeAmount - openAmount;
  double get netProfit => closeAmount - openAmount - feesAndDividends;

  GainReportLine(
      {required this.name,
      required this.operations,
      required this.openAmount,
      required this.closeAmount,
      required this.feesAndDividends});
}

class GainReport {
  List<GainReportLine> lines = [];

  get totalOperations => lines.fold(0, (total, line) => total + line.operations);
  get totalOpenAmount => lines.fold(0.0, (total, line) => total + line.openAmount);
  get totalCloseAmount => lines.fold(0.0, (total, line) => total + line.closeAmount);
  get totalFeesAndDividends => lines.fold(0.0, (total, line) => total + line.feesAndDividends);
  get totalGrossProfit => lines.fold(0.0, (total, line) => total + line.grossProfit);
  get totalNetProfit => lines.fold(0.0, (total, line) => total + line.netProfit);

  get length => lines.length;
}
