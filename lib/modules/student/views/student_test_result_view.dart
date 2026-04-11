import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:sum_academy/app/theme.dart';

class StudentTestResultView extends StatelessWidget {
  final Map<String, dynamic> finishResponse;
  final Map<String, dynamic> rankingResponse;

  const StudentTestResultView({
    super.key,
    required this.finishResponse,
    required this.rankingResponse,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDark ? SumAcademyTheme.white : SumAcademyTheme.darkBase;

    final data = (finishResponse['data'] is Map)
        ? Map<String, dynamic>.from(finishResponse['data'])
        : <String, dynamic>{};

    final score = _readDouble(data, const ['score', 'marks', 'obtainedMarks']);
    final total = _readDouble(data, const ['total', 'totalMarks', 'maxMarks']);
    final percentFromApi =
        _readDouble(data, const ['percent', 'percentage']) / 100;
    final percent = total > 0 ? (score / total) : percentFromApi;
    final percentValue = percent.isNaN ? 0.0 : percent.clamp(0.0, 1.0);

    final rankData = (rankingResponse['data'] is Map)
        ? Map<String, dynamic>.from(rankingResponse['data'])
        : <String, dynamic>{};
    final myRank = _readInt(rankData, const ['rank', 'position', 'myRank']);
    final totalParticipants =
        _readInt(rankData, const ['total', 'totalParticipants', 'participants']);

    return Scaffold(
      body: SafeArea(
        child: ListView(
          padding: EdgeInsets.fromLTRB(20.w, 16.h, 20.w, 28.h),
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    'Test Result',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          color: textColor,
                          fontWeight: FontWeight.w800,
                        ),
                  ),
                ),
                TextButton(
                  onPressed: () => Get.back(),
                  child: const Text('Done'),
                ),
              ],
            ),
            SizedBox(height: 16.h),
            Container(
              padding: EdgeInsets.all(16.r),
              decoration: BoxDecoration(
                color: isDark ? SumAcademyTheme.darkSurface : SumAcademyTheme.white,
                borderRadius: BorderRadius.circular(SumAcademyTheme.radiusCard.r),
                border: Border.all(
                  color: isDark
                      ? SumAcademyTheme.white.withOpacityFloat(0.08)
                      : SumAcademyTheme.brandBluePale,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${(percentValue * 100).round()}%',
                    style: Theme.of(context).textTheme.displaySmall?.copyWith(
                          color: SumAcademyTheme.brandBlue,
                          fontWeight: FontWeight.w800,
                        ),
                  ),
                  SizedBox(height: 6.h),
                  Text(
                    total > 0
                        ? 'Score: ${score.toStringAsFixed(0)} / ${total.toStringAsFixed(0)}'
                        : 'Score saved',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: textColor.withOpacityFloat(0.75),
                          fontWeight: FontWeight.w600,
                        ),
                  ),
                  SizedBox(height: 12.h),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(12.r),
                    child: LinearProgressIndicator(
                      value: percentValue,
                      minHeight: 10.h,
                      backgroundColor: SumAcademyTheme.brandBluePale,
                      valueColor: const AlwaysStoppedAnimation(
                        SumAcademyTheme.brandBlue,
                      ),
                    ),
                  ),
                  SizedBox(height: 14.h),
                  Row(
                    children: [
                      Expanded(
                        child: _MiniStat(
                          label: 'Rank',
                          value: myRank > 0 ? '#$myRank' : 'N/A',
                        ),
                      ),
                      SizedBox(width: 12.w),
                      Expanded(
                        child: _MiniStat(
                          label: 'Participants',
                          value: totalParticipants > 0
                              ? totalParticipants.toString()
                              : 'N/A',
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _MiniStat extends StatelessWidget {
  final String label;
  final String value;

  const _MiniStat({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final surface = isDark ? SumAcademyTheme.darkSurface : SumAcademyTheme.white;
    final border = isDark
        ? SumAcademyTheme.white.withOpacityFloat(0.08)
        : SumAcademyTheme.brandBluePale;
    final textColor = isDark ? SumAcademyTheme.white : SumAcademyTheme.darkBase;

    return Container(
      padding: EdgeInsets.all(14.r),
      decoration: BoxDecoration(
        color: surface,
        borderRadius: BorderRadius.circular(18.r),
        border: Border.all(color: border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  color: textColor.withOpacityFloat(0.55),
                  fontWeight: FontWeight.w700,
                  letterSpacing: 1.2,
                ),
          ),
          SizedBox(height: 6.h),
          Text(
            value,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: textColor,
                  fontWeight: FontWeight.w800,
                ),
          ),
        ],
      ),
    );
  }
}

double _readDouble(Map<String, dynamic> map, List<String> keys) {
  for (final key in keys) {
    final value = map[key];
    if (value == null) continue;
    if (value is num) return value.toDouble();
    if (value is String) {
      final parsed = double.tryParse(value.replaceAll(',', '').trim());
      if (parsed != null) return parsed;
    }
  }
  return 0;
}

int _readInt(Map<String, dynamic> map, List<String> keys) {
  for (final key in keys) {
    final value = map[key];
    if (value == null) continue;
    if (value is int) return value;
    if (value is num) return value.toInt();
    if (value is String) {
      final parsed = int.tryParse(value.trim());
      if (parsed != null) return parsed;
    }
  }
  return 0;
}

