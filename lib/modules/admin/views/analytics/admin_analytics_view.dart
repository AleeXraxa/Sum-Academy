import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:sum_academy/app/theme.dart';
import 'package:sum_academy/modules/admin/controllers/admin_controller.dart';
import 'package:sum_academy/modules/admin/controllers/admin_analytics_controller.dart';
import 'package:sum_academy/modules/admin/models/chart_series.dart';
import 'package:sum_academy/modules/admin/widgets/common/admin_filter_panel.dart';
import 'package:sum_academy/modules/admin/widgets/common/admin_ui.dart';
import 'package:sum_academy/modules/admin/widgets/header/admin_header_row.dart';

class AdminAnalyticsView extends StatefulWidget {
  final AdminController controller;
  final Color textColor;
  final Color surface;
  final bool isDark;
  final String userName;

  const AdminAnalyticsView({
    super.key,
    required this.controller,
    required this.textColor,
    required this.surface,
    required this.isDark,
    required this.userName,
  });

  @override
  State<AdminAnalyticsView> createState() => _AdminAnalyticsViewState();
}

class _AdminAnalyticsViewState extends State<AdminAnalyticsView> {
  final List<String> _ranges = const [
    'Today',
    '7 Days',
    '30 Days',
    '3 Months',
    '1 Year',
  ];
  final List<String> _revenueRanges = const ['Daily', 'Weekly', 'Monthly'];
  late final TextEditingController _fromController;
  late final TextEditingController _toController;

  @override
  void initState() {
    super.initState();
    _fromController = TextEditingController();
    _toController = TextEditingController();
  }

  @override
  void dispose() {
    _fromController.dispose();
    _toController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final analyticsController = Get.find<AdminAnalyticsController>();
    return RefreshIndicator(
      onRefresh: () async {
        await analyticsController.fetchAll();
      },
      color: widget.textColor,
      child: ListView(
        padding: AdminUi.pagePadding(),
        physics: const AlwaysScrollableScrollPhysics(
          parent: BouncingScrollPhysics(),
        ),
        children: [
          AdminHeaderRow(
            textColor: widget.textColor,
            userName: widget.userName,
            isSearchExpanded: false,
            onSearchTap: () {},
            onSearchClose: () {},
            searchController: widget.controller.searchController,
            showSearch: false,
            showProfile: true,
            showNotifications: true,
          ),
          SizedBox(height: 18.h),
          _buildRangeBar(context, analyticsController),
          SizedBox(height: 24.h),
          Text(
            'REVENUE',
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
              color: widget.textColor.withOpacityFloat(0.55),
              letterSpacing: 2.6,
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(height: 6.h),
          Row(
            children: [
              Expanded(
                child: Text(
                  'Revenue Analytics',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    color: widget.textColor,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              Obx(() {
                final selectedIndex = _intervalIndex(
                  analyticsController.revenueInterval.value,
                );
                return Wrap(
                  spacing: 8.w,
                  children: [
                    for (var i = 0; i < _revenueRanges.length; i++)
                      _RangeChip(
                        label: _revenueRanges[i],
                        isSelected: selectedIndex == i,
                        onTap: () => analyticsController.setRevenueInterval(
                          _intervalValue(i),
                        ),
                        isCompact: true,
                      ),
                  ],
                );
              }),
            ],
          ),
          SizedBox(height: 12.h),
          _AnalyticsCard(
            surface: widget.surface,
            child: Obx(() {
              if (analyticsController.isRevenueLoading.value) {
                return _ChartSkeleton(surface: widget.surface);
              }
              return _LineChart(
                series: analyticsController.revenueSeries.value,
                lineColor: SumAcademyTheme.brandBlue,
                textColor: widget.textColor,
              );
            }),
          ),
          SizedBox(height: 26.h),
          Text(
            'Enrollment Analytics',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              color: widget.textColor,
              fontWeight: FontWeight.w700,
            ),
          ),
          SizedBox(height: 6.h),
          Text(
            'Track enrollments by course and daily trends.',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: widget.textColor.withOpacityFloat(0.6),
            ),
          ),
          SizedBox(height: 12.h),
          _AnalyticsCard(
            surface: widget.surface,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Top Courses',
                  style: Theme.of(context).textTheme.labelLarge?.copyWith(
                    color: widget.textColor.withOpacityFloat(0.7),
                    fontWeight: FontWeight.w600,
                  ),
                ),
                SizedBox(height: 12.h),
                Obx(() {
                  if (analyticsController.isEnrollmentLoading.value) {
                    return _ChartSkeleton(surface: widget.surface);
                  }
                  return _BarChart(
                    series: analyticsController.enrollmentSeries.value,
                    barColor: SumAcademyTheme.brandBlue,
                    textColor: widget.textColor,
                  );
                }),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRangeBar(
    BuildContext context,
    AdminAnalyticsController analyticsController,
  ) {
    return AdminFilterPanel(
      surface: widget.surface,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final isWide = constraints.maxWidth > 640;
          final chipWrap = Obx(
            () => Wrap(
              spacing: 10.w,
              runSpacing: 10.h,
              children: [
                for (var i = 0; i < _ranges.length; i++)
                  _RangeChip(
                    label: _ranges[i],
                    isSelected:
                        analyticsController.quickRange.value ==
                        _quickRangeValue(i),
                    onTap: () =>
                        analyticsController.setQuickRange(_quickRangeValue(i)),
                  ),
              ],
            ),
          );

          final dateRow = Row(
            children: [
              Expanded(
                child: _DateField(
                  controller: _fromController,
                  hintText: 'mm/dd/yyyy',
                  onTap: () => _pickDate(
                    _fromController,
                    analyticsController.setFromDate,
                  ),
                ),
              ),
              SizedBox(width: 12.w),
              Text(
                '-',
                style: Theme.of(context).textTheme.labelLarge?.copyWith(
                  color: widget.textColor.withOpacityFloat(0.6),
                  fontWeight: FontWeight.w600,
                ),
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: _DateField(
                  controller: _toController,
                  hintText: 'mm/dd/yyyy',
                  onTap: () =>
                      _pickDate(_toController, analyticsController.setToDate),
                ),
              ),
            ],
          );

          if (isWide) {
            return Row(
              children: [
                Expanded(child: chipWrap),
                SizedBox(width: 16.w),
                SizedBox(width: 320.w, child: dateRow),
              ],
            );
          }

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              chipWrap,
              SizedBox(height: 16.h),
              Text(
                'Custom range',
                style: Theme.of(context).textTheme.labelMedium?.copyWith(
                  color: widget.textColor.withOpacityFloat(0.6),
                  fontWeight: FontWeight.w600,
                ),
              ),
              SizedBox(height: 10.h),
              _DateField(
                controller: _fromController,
                hintText: 'From (mm/dd/yyyy)',
                onTap: () =>
                    _pickDate(_fromController, analyticsController.setFromDate),
              ),
              SizedBox(height: 10.h),
              _DateField(
                controller: _toController,
                hintText: 'To (mm/dd/yyyy)',
                onTap: () =>
                    _pickDate(_toController, analyticsController.setToDate),
              ),
            ],
          );
        },
      ),
    );
  }

  Future<void> _pickDate(
    TextEditingController controller,
    ValueChanged<DateTime> onSelected,
  ) async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: now,
      firstDate: DateTime(now.year - 3),
      lastDate: DateTime(now.year + 1),
    );
    if (picked != null) {
      controller.text =
          '${picked.month.toString().padLeft(2, '0')}/${picked.day.toString().padLeft(2, '0')}/${picked.year}';
      onSelected(picked);
    }
  }

  String _quickRangeValue(int index) {
    switch (index) {
      case 0:
        return 'today';
      case 1:
        return '7d';
      case 2:
        return '30d';
      case 3:
        return '3m';
      case 4:
        return '1y';
      default:
        return '30d';
    }
  }

  int _intervalIndex(String interval) {
    switch (interval) {
      case 'weekly':
        return 1;
      case 'monthly':
        return 2;
      default:
        return 0;
    }
  }

  String _intervalValue(int index) {
    switch (index) {
      case 1:
        return 'weekly';
      case 2:
        return 'monthly';
      default:
        return 'daily';
    }
  }
}

class _RangeChip extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;
  final bool isCompact;

  const _RangeChip({
    required this.label,
    required this.isSelected,
    required this.onTap,
    this.isCompact = false,
  });

  @override
  Widget build(BuildContext context) {
    final background = isSelected
        ? SumAcademyTheme.brandBlue
        : SumAcademyTheme.white;
    final textColor = isSelected
        ? SumAcademyTheme.white
        : SumAcademyTheme.darkBase;
    final borderColor = isSelected
        ? SumAcademyTheme.brandBlue
        : SumAcademyTheme.brandBluePale;

    return InkWell(
      borderRadius: BorderRadius.circular(SumAcademyTheme.radiusPill.r),
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: isCompact ? 12.w : 16.w,
          vertical: isCompact ? 6.h : 8.h,
        ),
        decoration: BoxDecoration(
          color: background,
          borderRadius: BorderRadius.circular(SumAcademyTheme.radiusPill.r),
          border: Border.all(color: borderColor),
        ),
        child: Text(
          label,
          style: Theme.of(context).textTheme.labelLarge?.copyWith(
            color: textColor,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}

class _DateField extends StatelessWidget {
  final TextEditingController controller;
  final String hintText;
  final VoidCallback onTap;

  const _DateField({
    required this.controller,
    required this.hintText,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      readOnly: true,
      onTap: onTap,
      decoration: InputDecoration(
        hintText: hintText,
        suffixIcon: const Icon(Icons.calendar_today_rounded, size: 18),
        isDense: true,
        filled: true,
        fillColor: SumAcademyTheme.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(SumAcademyTheme.radiusPill.r),
          borderSide: const BorderSide(color: SumAcademyTheme.brandBluePale),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(SumAcademyTheme.radiusPill.r),
          borderSide: const BorderSide(color: SumAcademyTheme.brandBluePale),
        ),
        contentPadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
      ),
    );
  }
}

class _AnalyticsCard extends StatelessWidget {
  final Color surface;
  final Widget child;

  const _AnalyticsCard({required this.surface, required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(16.r),
      decoration: AdminUi.cardDecoration(
        surface: surface,
        border: AdminUi.borderColor(context),
      ),
      child: child,
    );
  }
}

class _LineChart extends StatelessWidget {
  final ChartSeries series;
  final Color lineColor;
  final Color textColor;

  const _LineChart({
    required this.series,
    required this.lineColor,
    required this.textColor,
  });

  @override
  Widget build(BuildContext context) {
    final gridColor = SumAcademyTheme.brandBluePale;
    return SizedBox(
      height: 220.h,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: List.generate(5, (index) {
              final value = series.maxY - (series.maxY / 4 * index);
              return Text(
                value.toStringAsFixed(0),
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: textColor.withOpacityFloat(0.5),
                ),
              );
            }),
          ),
          SizedBox(width: 10.w),
          Expanded(
            child: Column(
              children: [
                Expanded(
                  child: CustomPaint(
                    painter: _LineChartPainter(
                      values: series.values,
                      maxY: series.maxY,
                      lineColor: lineColor,
                      gridColor: gridColor,
                    ),
                  ),
                ),
                SizedBox(height: 10.h),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: series.labels
                      .map(
                        (label) => Expanded(
                          child: Padding(
                            padding: EdgeInsets.symmetric(horizontal: 2.w),
                            child: FittedBox(
                              fit: BoxFit.scaleDown,
                              child: Text(
                                _formatAxisLabel(label),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                textAlign: TextAlign.center,
                                style: Theme.of(context).textTheme.bodySmall
                                    ?.copyWith(
                                      color: textColor.withOpacityFloat(0.6),
                                    ),
                              ),
                            ),
                          ),
                        ),
                      )
                      .toList(),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _LineChartPainter extends CustomPainter {
  final List<double> values;
  final double maxY;
  final Color lineColor;
  final Color gridColor;

  _LineChartPainter({
    required this.values,
    required this.maxY,
    required this.lineColor,
    required this.gridColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (values.isEmpty) return;
    const paddingX = 8.0;
    const paddingTop = 6.0;
    const paddingBottom = 6.0;
    final plotWidth = size.width - paddingX * 2;
    final plotHeight = size.height - paddingTop - paddingBottom;
    final paintGrid = Paint()
      ..color = gridColor
      ..strokeWidth = 1;
    final paintLine = Paint()
      ..color = lineColor
      ..strokeWidth = 2.2
      ..style = PaintingStyle.stroke;
    final paintDot = Paint()
      ..color = lineColor
      ..style = PaintingStyle.fill;
    final dotBorder = Paint()
      ..color = SumAcademyTheme.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;

    final horizontalCount = 4;
    for (var i = 0; i <= horizontalCount; i++) {
      final y = paddingTop + plotHeight / horizontalCount * i;
      canvas.drawLine(
        Offset(paddingX, y),
        Offset(paddingX + plotWidth, y),
        paintGrid,
      );
    }
    if (values.length > 1) {
      for (var i = 0; i < values.length; i++) {
        final x = paddingX + plotWidth / (values.length - 1) * i;
        canvas.drawLine(
          Offset(x, paddingTop),
          Offset(x, paddingTop + plotHeight),
          paintGrid,
        );
      }
    }

    final path = Path();
    final points = <Offset>[];
    for (var i = 0; i < values.length; i++) {
      final x = values.length == 1
          ? paddingX + plotWidth / 2
          : paddingX + plotWidth / (values.length - 1) * i;
      final value = values[i].clamp(0, maxY);
      final y = paddingTop + (plotHeight - (value / maxY * plotHeight));
      points.add(Offset(x, y));
    }

    if (points.length == 1) {
      path.moveTo(points.first.dx, points.first.dy);
    } else {
      path.moveTo(points.first.dx, points.first.dy);
      for (var i = 0; i < points.length - 1; i++) {
        final current = points[i];
        final next = points[i + 1];
        final mid = Offset(
          (current.dx + next.dx) / 2,
          (current.dy + next.dy) / 2,
        );
        path.quadraticBezierTo(current.dx, current.dy, mid.dx, mid.dy);
      }
      path.lineTo(points.last.dx, points.last.dy);
    }
    canvas.drawPath(path, paintLine);

    for (final point in points) {
      canvas.drawCircle(point, 4.2, paintDot);
      canvas.drawCircle(point, 4.2, dotBorder);
    }
  }

  @override
  bool shouldRepaint(covariant _LineChartPainter oldDelegate) {
    return oldDelegate.values != values ||
        oldDelegate.maxY != maxY ||
        oldDelegate.lineColor != lineColor ||
        oldDelegate.gridColor != gridColor;
  }
}

class _BarChart extends StatelessWidget {
  final ChartSeries series;
  final Color barColor;
  final Color textColor;

  const _BarChart({
    required this.series,
    required this.barColor,
    required this.textColor,
  });

  @override
  Widget build(BuildContext context) {
    final gridColor = SumAcademyTheme.brandBluePale;
    return SizedBox(
      height: 220.h,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: List.generate(5, (index) {
              final value = series.maxY - (series.maxY / 4 * index);
              return Text(
                value.toStringAsFixed(0),
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: textColor.withOpacityFloat(0.5),
                ),
              );
            }),
          ),
          SizedBox(width: 10.w),
          Expanded(
            child: Column(
              children: [
                Expanded(
                  child: CustomPaint(
                    painter: _BarChartPainter(
                      values: series.values,
                      maxY: series.maxY,
                      barColor: barColor,
                      gridColor: gridColor,
                    ),
                  ),
                ),
                SizedBox(height: 10.h),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: series.labels
                      .map(
                        (label) => Expanded(
                          child: Padding(
                            padding: EdgeInsets.symmetric(horizontal: 2.w),
                            child: FittedBox(
                              fit: BoxFit.scaleDown,
                              child: Text(
                                _formatAxisLabel(label, isCourse: true),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                textAlign: TextAlign.center,
                                style: Theme.of(context).textTheme.bodySmall
                                    ?.copyWith(
                                      color: textColor.withOpacityFloat(0.6),
                                    ),
                              ),
                            ),
                          ),
                        ),
                      )
                      .toList(),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _BarChartPainter extends CustomPainter {
  final List<double> values;
  final double maxY;
  final Color barColor;
  final Color gridColor;

  _BarChartPainter({
    required this.values,
    required this.maxY,
    required this.barColor,
    required this.gridColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (values.isEmpty) return;
    final paintGrid = Paint()
      ..color = gridColor
      ..strokeWidth = 1;
    final paintBar = Paint()
      ..color = barColor
      ..style = PaintingStyle.fill;

    final horizontalCount = 4;
    for (var i = 0; i <= horizontalCount; i++) {
      final y = size.height / horizontalCount * i;
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paintGrid);
    }

    final barWidth = size.width / (values.length * 2);
    for (var i = 0; i < values.length; i++) {
      final value = values[i].clamp(0, maxY);
      final height = value / maxY * size.height;
      final x = (i * 2 + 0.5) * barWidth;
      final rect = RRect.fromRectAndRadius(
        Rect.fromLTWH(x, size.height - height, barWidth, height),
        Radius.circular(6.r),
      );
      canvas.drawRRect(rect, paintBar);
    }
  }

  @override
  bool shouldRepaint(covariant _BarChartPainter oldDelegate) {
    return oldDelegate.values != values ||
        oldDelegate.maxY != maxY ||
        oldDelegate.barColor != barColor ||
        oldDelegate.gridColor != gridColor;
  }
}

class _ChartSkeleton extends StatelessWidget {
  final Color surface;

  const _ChartSkeleton({required this.surface});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 220.h,
      decoration: AdminUi.cardDecoration(
        surface: surface,
        border: AdminUi.borderColor(context),
        showShadow: false,
      ),
    );
  }
}

String _formatAxisLabel(String label, {bool isCourse = false}) {
  final trimmed = label.trim();
  if (trimmed.isEmpty) return '';
  final parsed = DateTime.tryParse(trimmed);
  if (parsed != null) {
    return '${parsed.day} ${_monthShort(parsed.month)}';
  }
  final monthMatch = RegExp(r'^\d{4}-\d{2}$').firstMatch(trimmed);
  if (monthMatch != null) {
    final parts = trimmed.split('-');
    final month = int.tryParse(parts.last);
    if (month != null) return _monthShort(month);
  }
  if (isCourse && trimmed.length > 12) {
    return '${trimmed.substring(0, 12)}…';
  }
  if (trimmed.length > 10) {
    return '${trimmed.substring(0, 10)}…';
  }
  return trimmed;
}

String _monthShort(int month) {
  const months = [
    'Jan',
    'Feb',
    'Mar',
    'Apr',
    'May',
    'Jun',
    'Jul',
    'Aug',
    'Sep',
    'Oct',
    'Nov',
    'Dec',
  ];
  if (month < 1 || month > 12) return '';
  return months[month - 1];
}
