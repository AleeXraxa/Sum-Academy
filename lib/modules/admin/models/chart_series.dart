class ChartSeries {
  final List<double> values;
  final List<String> labels;
  final double maxY;

  const ChartSeries({
    required this.values,
    required this.labels,
    required this.maxY,
  });

  factory ChartSeries.empty({String labelPrefix = ''}) {
    return ChartSeries(
      values: const [0, 0, 0, 0],
      labels: List.generate(4, (index) => '${labelPrefix}${index + 1}'),
      maxY: 4,
    );
  }
}
