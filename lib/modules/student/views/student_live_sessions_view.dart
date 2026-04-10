import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:sum_academy/app/theme.dart';
import 'package:sum_academy/modules/student/controllers/student_live_sessions_controller.dart';
import 'package:sum_academy/modules/student/models/student_live_session.dart';
import 'package:sum_academy/modules/student/views/student_course_video_view.dart';

class StudentLiveSessionsView extends StatelessWidget {
  const StudentLiveSessionsView({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<StudentLiveSessionsController>();
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor =
        isDark ? SumAcademyTheme.white : SumAcademyTheme.darkBase;

    return Obx(() {
      return RefreshIndicator(
        color: SumAcademyTheme.brandBlue,
        onRefresh: controller.refresh,
        child: ListView(
          padding: EdgeInsets.fromLTRB(20.w, 16.h, 20.w, 28.h),
          physics: const AlwaysScrollableScrollPhysics(
            parent: BouncingScrollPhysics(),
          ),
          children: [
            _HeaderRow(textColor: textColor),
            SizedBox(height: 6.h),
            Text(
              'Upcoming and live sessions are shown here. After a session ends, the lecture will appear in your course content.',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: textColor.withOpacityFloat(0.65),
                    height: 1.35,
                  ),
            ),
            SizedBox(height: 14.h),
            if (controller.isLoading.value)
              const _Skeleton()
            else if (controller.errorMessage.value.isNotEmpty)
              _ErrorState(
                message: controller.errorMessage.value,
                onRetry: controller.fetchSessions,
              )
            else if (controller.sessions.isEmpty)
              const _EmptyState()
            else
              ...controller.sessions.map(
                (session) => Padding(
                  padding: EdgeInsets.only(bottom: 12.h),
                  child: _LiveSessionCard(session: session),
                ),
              ),
          ],
        ),
      );
    });
  }
}

class _HeaderRow extends StatelessWidget {
  final Color textColor;

  const _HeaderRow({required this.textColor});

  @override
  Widget build(BuildContext context) {
    final scaffoldState = Scaffold.maybeOf(context);
    final showMenu = scaffoldState?.hasDrawer ?? false;
    return Row(
      children: [
        if (showMenu)
          IconButton(
            onPressed: () {
              if (scaffoldState?.hasDrawer ?? false) {
                scaffoldState?.openDrawer();
              }
            },
            icon: Icon(
              Icons.menu_rounded,
              size: 20.sp,
              color: textColor.withOpacityFloat(0.7),
            ),
          ),
        if (showMenu) SizedBox(width: 6.w),
        Expanded(
          child: Text(
            'Live Session',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  color: textColor,
                  fontWeight: FontWeight.w700,
                ),
          ),
        ),
      ],
    );
  }
}

class _LiveSessionCard extends StatelessWidget {
  final StudentLiveSession session;

  const _LiveSessionCard({required this.session});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final surface = isDark ? SumAcademyTheme.darkSurface : SumAcademyTheme.white;
    final border = isDark
        ? SumAcademyTheme.white.withOpacityFloat(0.08)
        : SumAcademyTheme.brandBluePale;
    final accent = session.isLive
        ? SumAcademyTheme.success
        : SumAcademyTheme.brandBlue;
    final badgeText = session.isLive ? 'live' : 'scheduled';

    return InkWell(
      borderRadius: BorderRadius.circular(SumAcademyTheme.radiusCard.r),
      onTap: () => Get.to(() => StudentLiveSessionDetailView(session: session)),
      child: Container(
        padding: EdgeInsets.all(16.r),
        decoration: BoxDecoration(
          color: surface,
          borderRadius: BorderRadius.circular(SumAcademyTheme.radiusCard.r),
          border: Border.all(color: border),
          boxShadow: [
            if (!isDark)
              BoxShadow(
                color: SumAcademyTheme.darkBase.withOpacityFloat(0.06),
                blurRadius: 16,
                offset: const Offset(0, 10),
              ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    '${session.courseTitle} - ${session.lecture.title}',
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          color: isDark
                              ? SumAcademyTheme.white
                              : SumAcademyTheme.darkBase,
                          fontWeight: FontWeight.w700,
                        ),
                  ),
                ),
                SizedBox(width: 10.w),
                Container(
                  padding:
                      EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
                  decoration: BoxDecoration(
                    color: accent.withOpacityFloat(0.14),
                    borderRadius: BorderRadius.circular(999),
                    border: Border.all(color: accent.withOpacityFloat(0.25)),
                  ),
                  child: Row(
                    children: [
                      if (session.isLive)
                        Container(
                          width: 7.r,
                          height: 7.r,
                          decoration: BoxDecoration(
                            color: accent,
                            shape: BoxShape.circle,
                          ),
                        ),
                      if (session.isLive) SizedBox(width: 6.w),
                      Text(
                        badgeText,
                        style: Theme.of(context).textTheme.labelSmall?.copyWith(
                              color: accent,
                              fontWeight: FontWeight.w700,
                            ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            SizedBox(height: 8.h),
            Text(
              _classLine(session),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: (isDark
                            ? SumAcademyTheme.white
                            : SumAcademyTheme.darkBase)
                        .withOpacityFloat(0.65),
                  ),
            ),
            SizedBox(height: 10.h),
            _TimeRow(
              icon: Icons.calendar_today_rounded,
              label: _dateLabel(session.startsAt),
            ),
            SizedBox(height: 6.h),
            _TimeRow(
              icon: Icons.access_time_rounded,
              label: _timeRangeLabel(session.startsAt, session.endsAt),
            ),
          ],
        ),
      ),
    );
  }

  String _classLine(StudentLiveSession session) {
    final code = session.classCode.trim();
    final name = session.className.trim();
    if (name.isEmpty) return 'Class session';
    if (code.isEmpty) return name;
    return '$name ($code)';
  }

  String _dateLabel(DateTime? date) {
    if (date == null) return 'Date: TBA';
    return 'Date: ${_formatDate(date)}';
  }

  String _timeRangeLabel(DateTime? start, DateTime? end) {
    if (start == null || end == null) return 'Time: TBA';
    return 'Time: ${_formatTime(start)} – ${_formatTime(end)}';
  }
}

class StudentLiveSessionDetailView extends StatelessWidget {
  final StudentLiveSession session;

  const StudentLiveSessionDetailView({super.key, required this.session});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor =
        isDark ? SumAcademyTheme.white : SumAcademyTheme.darkBase;
    final surface = isDark ? SumAcademyTheme.darkSurface : SumAcademyTheme.white;
    final border = isDark
        ? SumAcademyTheme.white.withOpacityFloat(0.08)
        : SumAcademyTheme.brandBluePale;
    final accent =
        session.isLive ? SumAcademyTheme.success : SumAcademyTheme.brandBlue;
    final canJoin = _canJoinNow(session);
    final buttonLabel = session.isLive ? 'Join Session' : 'Join Session';

    return Scaffold(
      body: SafeArea(
        child: ListView(
          padding: EdgeInsets.fromLTRB(20.w, 12.h, 20.w, 28.h),
          children: [
            Row(
              children: [
                IconButton(
                  onPressed: () => Get.back(),
                  icon: Icon(Icons.arrow_back_rounded, color: textColor),
                ),
                Expanded(
                  child: Text(
                    session.lecture.title.isEmpty
                        ? 'Live Session'
                        : session.lecture.title,
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          color: textColor,
                          fontWeight: FontWeight.w700,
                        ),
                  ),
                ),
                Container(
                  padding:
                      EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
                  decoration: BoxDecoration(
                    color: accent.withOpacityFloat(0.14),
                    borderRadius: BorderRadius.circular(999),
                    border: Border.all(color: accent.withOpacityFloat(0.25)),
                  ),
                  child: Row(
                    children: [
                      if (session.isLive)
                        Container(
                          width: 7.r,
                          height: 7.r,
                          decoration: BoxDecoration(
                            color: accent,
                            shape: BoxShape.circle,
                          ),
                        ),
                      if (session.isLive) SizedBox(width: 6.w),
                      Text(
                        session.isLive ? 'live' : 'scheduled',
                        style: Theme.of(context).textTheme.labelSmall?.copyWith(
                              color: accent,
                              fontWeight: FontWeight.w700,
                            ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            SizedBox(height: 14.h),
            Text(
              '${session.courseTitle} • ${_classLine(session)}',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: textColor.withOpacityFloat(0.65),
                  ),
            ),
            SizedBox(height: 14.h),
            Container(
              padding: EdgeInsets.all(16.r),
              decoration: BoxDecoration(
                color: surface,
                borderRadius: BorderRadius.circular(SumAcademyTheme.radiusCard.r),
                border: Border.all(color: border),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _DetailLine(
                    label: 'Join opens',
                    value: _formatFull(session.joinOpensAt),
                  ),
                  SizedBox(height: 10.h),
                  _DetailLine(
                    label: 'Starts at',
                    value: _formatFull(session.startsAt),
                  ),
                  SizedBox(height: 10.h),
                  _DetailLine(
                    label: 'Ends at',
                    value: _formatFull(session.endsAt),
                  ),
                ],
              ),
            ),
            SizedBox(height: 16.h),
            Container(
              padding: EdgeInsets.all(14.r),
              decoration: BoxDecoration(
                color: SumAcademyTheme.errorLight,
                borderRadius: BorderRadius.circular(18.r),
                border: Border.all(
                  color: SumAcademyTheme.error.withOpacityFloat(0.25),
                ),
              ),
              child: Text(
                'Live session rules: Pause, seek and leaving this page are blocked while session is live. Keep this page open until session ends.',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: SumAcademyTheme.darkBase.withOpacityFloat(0.75),
                      height: 1.35,
                      fontWeight: FontWeight.w600,
                    ),
              ),
            ),
            SizedBox(height: 16.h),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: canJoin
                    ? () => Get.to(
                          () => StudentCourseVideoView(
                            courseId: session.courseId,
                            lecture: session.lecture,
                            onCompleted: () {},
                          ),
                        )
                    : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: SumAcademyTheme.brandBlue,
                  foregroundColor: SumAcademyTheme.white,
                  padding: EdgeInsets.symmetric(vertical: 12.h),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(18.r),
                  ),
                ),
                child: Text(buttonLabel),
              ),
            ),
            if (!canJoin) ...[
              SizedBox(height: 10.h),
              Text(
                _joinDisabledReason(session),
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: textColor.withOpacityFloat(0.65),
                      height: 1.35,
                      fontWeight: FontWeight.w600,
                    ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  String _classLine(StudentLiveSession session) {
    final code = session.classCode.trim();
    final name = session.className.trim();
    if (name.isEmpty) return 'Class session';
    if (code.isEmpty) return name;
    return '$name ($code)';
  }

  String _formatFull(DateTime? date) {
    if (date == null) return 'TBA';
    return '${_formatDate(date)}, ${_formatTime(date)}';
  }

  bool _canJoinNow(StudentLiveSession session) {
    final now = DateTime.now();
    final joinOpensAt = session.joinOpensAt;
    final startsAt = session.startsAt;
    final endsAt = session.endsAt;

    if (endsAt != null && now.isAfter(endsAt)) return false;
    if (joinOpensAt != null && now.isBefore(joinOpensAt)) return false;
    if (joinOpensAt == null && startsAt != null && now.isBefore(startsAt)) {
      return false;
    }
    return session.lecture.videoUrl.trim().isNotEmpty;
  }

  String _joinDisabledReason(StudentLiveSession session) {
    final now = DateTime.now();
    final joinOpensAt = session.joinOpensAt;
    final startsAt = session.startsAt;
    final endsAt = session.endsAt;
    if (endsAt != null && now.isAfter(endsAt)) {
      return 'This live session has ended. Pull to refresh to see the recording in your class content.';
    }
    if (joinOpensAt != null && now.isBefore(joinOpensAt)) {
      return 'Join opens at ${_formatDate(joinOpensAt)}, ${_formatTime(joinOpensAt)}.';
    }
    if (startsAt != null && now.isBefore(startsAt)) {
      return 'Session starts at ${_formatDate(startsAt)}, ${_formatTime(startsAt)}.';
    }
    return 'Session link is not available yet.';
  }
}

class _DetailLine extends StatelessWidget {
  final String label;
  final String value;

  const _DetailLine({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor =
        isDark ? SumAcademyTheme.white : SumAcademyTheme.darkBase;
    return Row(
      children: [
        SizedBox(
          width: 90.w,
          child: Text(
            label,
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  color: textColor.withOpacityFloat(0.55),
                  fontWeight: FontWeight.w700,
                  letterSpacing: 1.2,
                ),
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: textColor.withOpacityFloat(0.8),
                  fontWeight: FontWeight.w600,
                ),
          ),
        ),
      ],
    );
  }
}

class _TimeRow extends StatelessWidget {
  final IconData icon;
  final String label;

  const _TimeRow({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final color = (isDark ? SumAcademyTheme.white : SumAcademyTheme.darkBase)
        .withOpacityFloat(0.65);
    return Row(
      children: [
        Icon(icon, size: 16.sp, color: color),
        SizedBox(width: 8.w),
        Expanded(
          child: Text(
            label,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: color,
                  fontWeight: FontWeight.w600,
                ),
          ),
        ),
      ],
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final surface = isDark ? SumAcademyTheme.darkSurface : SumAcademyTheme.white;
    final border = isDark
        ? SumAcademyTheme.white.withOpacityFloat(0.08)
        : SumAcademyTheme.brandBluePale;
    return Container(
      padding: EdgeInsets.all(16.r),
      decoration: BoxDecoration(
        color: surface,
        borderRadius: BorderRadius.circular(SumAcademyTheme.radiusCard.r),
        border: Border.all(color: border),
      ),
      child: Text(
        'No upcoming live sessions right now.',
        style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: (isDark
                      ? SumAcademyTheme.white
                      : SumAcademyTheme.darkBase)
                  .withOpacityFloat(0.7),
            ),
      ),
    );
  }
}

class _ErrorState extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;

  const _ErrorState({required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(16.r),
      decoration: BoxDecoration(
        color: SumAcademyTheme.errorLight,
        borderRadius: BorderRadius.circular(18.r),
        border: Border.all(color: SumAcademyTheme.error.withOpacityFloat(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Unable to load live sessions',
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  color: SumAcademyTheme.error,
                  fontWeight: FontWeight.w600,
                ),
          ),
          SizedBox(height: 6.h),
          Text(
            message,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: SumAcademyTheme.darkBase.withOpacityFloat(0.7),
                ),
          ),
          SizedBox(height: 10.h),
          OutlinedButton(
            onPressed: onRetry,
            style: OutlinedButton.styleFrom(
              foregroundColor: SumAcademyTheme.brandBlue,
              side: const BorderSide(color: SumAcademyTheme.brandBluePale),
            ),
            child: const Text('Retry'),
          ),
        ],
      ),
    );
  }
}

class _Skeleton extends StatelessWidget {
  const _Skeleton();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: List.generate(
        2,
        (index) => Padding(
          padding: EdgeInsets.only(bottom: 12.h),
          child: Container(
            height: 112.h,
            decoration: BoxDecoration(
              color: SumAcademyTheme.white,
              borderRadius: BorderRadius.circular(SumAcademyTheme.radiusCard.r),
              border: Border.all(color: SumAcademyTheme.brandBluePale),
            ),
          ),
        ),
      ),
    );
  }
}

String _formatDate(DateTime date) {
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
  final day = date.day.toString().padLeft(2, '0');
  final month = months[date.month - 1];
  final year = date.year.toString();
  return '$day $month $year';
}

String _formatTime(DateTime date) {
  var hour = date.hour;
  final minute = date.minute.toString().padLeft(2, '0');
  final suffix = hour >= 12 ? 'PM' : 'AM';
  hour = hour % 12;
  if (hour == 0) hour = 12;
  return '$hour:$minute $suffix';
}
