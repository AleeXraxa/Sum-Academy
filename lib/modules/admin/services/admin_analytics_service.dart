import 'package:sum_academy/core/services/api_client.dart';
import 'package:sum_academy/modules/admin/models/chart_series.dart';

class AdminAnalyticsService {
  final ApiClient _client = ApiClient();

  Future<ChartSeries> fetchRevenueChart({
    required String range,
    required String interval,
    DateTime? from,
    DateTime? to,
  }) async {
    final response = await _client.get(
      '/admin/revenue-chart',
      auth: true,
      query: _buildQuery(range: range, interval: interval, from: from, to: to),
    );
    return _parseSeries(response['data'] ?? response);
  }

  Future<ChartSeries> fetchEnrollmentChart({
    required String range,
    DateTime? from,
    DateTime? to,
  }) async {
    final response = await _client.get(
      '/admin/top-courses',
      auth: true,
      query: _buildQuery(range: range, from: from, to: to),
    );
    return _parseSeries(
      response['data'] ?? response,
      labelKeys: const [
        'course',
        'courseTitle',
        'courseName',
        'title',
        'name',
        'label',
      ],
      valueKeys: const ['enrollments', 'count', 'total', 'value'],
    );
  }

  Map<String, dynamic> _buildQuery({
    required String range,
    String? interval,
    DateTime? from,
    DateTime? to,
  }) {
    final query = <String, dynamic>{};
    if (from != null && to != null) {
      query['from'] = _formatDate(from);
      query['to'] = _formatDate(to);
    } else {
      query['range'] = range;
    }
    if (interval != null) {
      query['groupBy'] = interval;
      query['interval'] = interval;
    }
    return query;
  }

  String _formatDate(DateTime date) {
    return '${date.year.toString().padLeft(4, '0')}-'
        '${date.month.toString().padLeft(2, '0')}-'
        '${date.day.toString().padLeft(2, '0')}';
  }

  ChartSeries _parseSeries(
    dynamic payload, {
    List<String> labelKeys = const [
      'label',
      'date',
      'day',
      'month',
      'name',
      'title',
      'period',
      'x',
    ],
    List<String> valueKeys = const [
      'value',
      'amount',
      'count',
      'total',
      'revenue',
      'y',
    ],
  }) {
    if (payload == null) {
      return ChartSeries.empty();
    }

    dynamic data = payload;
    if (payload is Map<String, dynamic>) {
      if (payload['data'] != null) data = payload['data'];
      if (payload['series'] != null) data = payload['series'];
      if (payload['points'] != null) data = payload['points'];
      if (payload['items'] != null) data = payload['items'];
      if (payload['labels'] is List && payload['values'] is List) {
        final labels = List<String>.from(payload['labels']);
        final values = (payload['values'] as List)
            .map((value) => _toDouble(value) ?? 0)
            .toList();
        return _buildSeries(values, labels, payload['max']);
      }
    }

    if (data is Map<String, dynamic>) {
      final labels = <String>[];
      final values = <double>[];
      data.forEach((key, value) {
        final doubleValue = _toDouble(value);
        if (doubleValue == null) return;
        labels.add(key);
        values.add(doubleValue);
      });
      return _buildSeries(values, labels, null);
    }

    if (data is List) {
      if (data.isEmpty) {
        return ChartSeries.empty();
      }
      if (data.first is num) {
        final values = data.map((value) => _toDouble(value) ?? 0).toList();
        final labels =
            List.generate(values.length, (index) => '${index + 1}');
        return _buildSeries(values, labels, null);
      }
      if (data.first is Map) {
        final labels = <String>[];
        final values = <double>[];
        for (final item in data) {
          if (item is! Map) continue;
          final label = _normalizeLabel(_extractValue(item, labelKeys));
          final value = _extractValue(item, valueKeys);
          if (label == null || value == null) continue;
          labels.add(label);
          values.add(_toDouble(value) ?? 0);
        }
        return _buildSeries(values, labels, null);
      }
    }

    return ChartSeries.empty();
  }

  ChartSeries _buildSeries(
    List<double> values,
    List<String> labels,
    dynamic maxValue,
  ) {
    if (values.isEmpty || labels.isEmpty) {
      return ChartSeries.empty();
    }
    final paired = <_SeriesPoint>[];
    for (var i = 0; i < values.length; i++) {
      final label = i < labels.length ? labels[i] : '${i + 1}';
      paired.add(_SeriesPoint(label, values[i]));
    }

    final allDates = paired.every((point) => point.asDate != null);
    if (allDates) {
      paired.sort((a, b) => a.asDate!.compareTo(b.asDate!));
    } else {
      final allNumbers = paired.every((point) => point.asNumber != null);
      if (allNumbers) {
        paired.sort((a, b) => a.asNumber!.compareTo(b.asNumber!));
      }
    }

    final sortedValues = paired.map((point) => point.value).toList();
    final sortedLabels = paired.map((point) => point.label).toList();

    final max = _toDouble(maxValue) ??
        sortedValues.reduce((a, b) => a > b ? a : b);
    final normalizedMax = max < 4 ? 4.0 : max;
    final safeLabels = sortedLabels.length == sortedValues.length
        ? sortedLabels
        : List.generate(sortedValues.length, (index) => '${index + 1}');
    return ChartSeries(
      values: sortedValues,
      labels: safeLabels,
      maxY: normalizedMax,
    );
  }

  dynamic _extractValue(Map item, List<String> keys) {
    for (final key in keys) {
      if (item.containsKey(key)) return item[key];
    }
    return null;
  }

  String? _normalizeLabel(dynamic value) {
    if (value == null) return null;
    if (value is Map) {
      final nested = _extractValue(value, const [
        'title',
        'name',
        'label',
        'courseTitle',
        'courseName',
        'course',
      ]);
      return _normalizeLabel(nested);
    }
    final label = value.toString().trim();
    if (label.isEmpty) return null;
    return label;
  }

  double? _toDouble(dynamic value) {
    if (value == null) return null;
    if (value is num) return value.toDouble();
    return double.tryParse(value.toString());
  }
}

class _SeriesPoint {
  final String label;
  final double value;
  final DateTime? asDate;
  final double? asNumber;

  _SeriesPoint(this.label, this.value)
      : asDate = DateTime.tryParse(label),
        asNumber = double.tryParse(label);
}
