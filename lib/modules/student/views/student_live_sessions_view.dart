import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:sum_academy/app/theme.dart';
import 'package:sum_academy/core/utils/network_error.dart';
import 'package:sum_academy/modules/student/controllers/student_live_sessions_controller.dart';
import 'package:sum_academy/modules/student/models/student_session.dart';
import 'package:sum_academy/modules/student/views/student_live_session_player_view.dart';
import 'package:sum_academy/modules/student/views/student_live_session_waiting_view.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:sum_academy/modules/student/widgets/student_dashboard_header.dart';

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
            StudentDashboardHeader(subtitle: 'Live Session'),
            SizedBox(height: 6.h),
            Text(
              'Upcoming and live sessions are shown here. Ended sessions move to your class recordings automatically.',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: textColor.withOpacityFloat(0.65),
                    height: 1.35,
                  ),
            ),
            SizedBox(height: 12.h),
            const _FilterRow(),
            SizedBox(height: 14.h),
            if (controller.isLoading.value)
              const _Skeleton()
            else if (controller.errorMessage.value.isNotEmpty)
              _ErrorState(
                message: controller.errorMessage.value,
                onRetry: controller.fetchSessions,
              )
            else if (controller.filteredSessions.isEmpty)
              const _EmptyState()
            else
              ...controller.filteredSessions.map(
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



class _FilterRow extends StatelessWidget {
  const _FilterRow();

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<StudentLiveSessionsController>();
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final base =
        isDark ? SumAcademyTheme.white : SumAcademyTheme.darkBase;

    Widget chip({
      required String id,
      required String label,
    }) {
      return Obx(() {
        final selected = controller.selectedFilter.value == id;
        final bg = selected
            ? SumAcademyTheme.brandBlue
            : (isDark ? SumAcademyTheme.darkSurface : SumAcademyTheme.white);
        final fg = selected ? SumAcademyTheme.white : base.withOpacityFloat(0.85);
        final bd = selected
            ? SumAcademyTheme.brandBlue
            : (isDark
                ? SumAcademyTheme.white.withOpacityFloat(0.08)
                : SumAcademyTheme.brandBluePale);
        return InkWell(
          borderRadius: BorderRadius.circular(999),
          onTap: () => controller.setFilter(id),
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 7.h),
            decoration: BoxDecoration(
              color: bg,
              borderRadius: BorderRadius.circular(999),
              border: Border.all(color: bd),
            ),
            child: Text(
              label,
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    color: fg,
                    fontWeight: FontWeight.w800,
                  ),
            ),
          ),
        );
      });
    }

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      physics: const BouncingScrollPhysics(),
      child: Row(
        children: [
          chip(id: 'all', label: 'All'),
          SizedBox(width: 8.w),
          chip(id: 'live', label: 'Live'),
          SizedBox(width: 8.w),
          chip(id: 'upcoming', label: 'Upcoming'),
        ],
      ),
    );
  }
}

class _LiveSessionCard extends StatelessWidget {
  final StudentSession session;

  const _LiveSessionCard({required this.session});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final surface = isDark ? SumAcademyTheme.darkSurface : SumAcademyTheme.white;
    final border = isDark
        ? SumAcademyTheme.white.withOpacityFloat(0.08)
        : SumAcademyTheme.brandBluePale;

    final badge = _badgeFor(session);
    final accent = badge == _SessionBadge.live
        ? SumAcademyTheme.success
        : SumAcademyTheme.brandBlue;
    final badgeText = badge.name;

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
                    session.topic.trim().isEmpty ? 'Live Session' : session.topic,
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
                      if (badge == _SessionBadge.live)
                        Container(
                          width: 7.r,
                          height: 7.r,
                          decoration: BoxDecoration(
                            color: accent,
                            shape: BoxShape.circle,
                          ),
                        ),
                      if (badge == _SessionBadge.live) SizedBox(width: 6.w),
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
              label: _dateLabel(session.startAt),
            ),
            SizedBox(height: 6.h),
            _TimeRow(
              icon: Icons.access_time_rounded,
              label: _timeRangeLabel(session.startAt, session.endAt),
            ),
          ],
        ),
      ),
    );
  }

  String _classLine(StudentSession session) {
    final name = session.className.trim();
    final code = session.batchCode.trim();
    if (name.isEmpty && code.isEmpty) return 'Class session';
    if (name.isEmpty) return code;
    if (code.isEmpty) return name;
    return '$name ($code)';
  }

  String _dateLabel(DateTime? date) {
    if (date == null) return 'Date: TBA';
    return 'Date: ${_formatDate(date)}';
  }

  String _timeRangeLabel(DateTime? start, DateTime? end) {
    if (start == null || end == null) return 'Time: TBA';
    return 'Time: ${_formatTime(start)} - ${_formatTime(end)}';
  }
}

enum _SessionBadge { upcoming, live, ended }

_SessionBadge _badgeFor(StudentSession session) {
  if (session.isLive) return _SessionBadge.live;
  if (session.hasEnded) {
    return _SessionBadge.ended;
  }
  return _SessionBadge.upcoming;
}

class StudentLiveSessionDetailView extends StatelessWidget {
  final StudentSession session;

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
    final badge = _badgeFor(session);
    final accent =
        badge == _SessionBadge.live ? SumAcademyTheme.success : SumAcademyTheme.brandBlue;

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
                    session.topic.trim().isEmpty ? 'Live Session' : session.topic,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          color: textColor,
                          fontWeight: FontWeight.w800,
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
                      if (badge == _SessionBadge.live)
                        Container(
                          width: 7.r,
                          height: 7.r,
                          decoration: BoxDecoration(
                            color: accent,
                            shape: BoxShape.circle,
                          ),
                        ),
                      if (badge == _SessionBadge.live) SizedBox(width: 6.w),
                      Text(
                        badge.name,
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
            Container(
              padding: EdgeInsets.all(16.r),
              decoration: BoxDecoration(
                color: surface,
                borderRadius:
                    BorderRadius.circular(SumAcademyTheme.radiusCard.r),
                border: Border.all(color: border),
                boxShadow: [
                  if (!isDark)
                    BoxShadow(
                      color: SumAcademyTheme.darkBase.withOpacityFloat(0.06),
                      blurRadius: 18,
                      offset: const Offset(0, 12),
                    ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _classLine(session),
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: textColor.withOpacityFloat(0.7),
                          fontWeight: FontWeight.w700,
                        ),
                  ),
                  SizedBox(height: 12.h),
                  _DetailLine(
                    label: 'TEACHER',
                    value: session.teacherName.trim().isEmpty
                        ? '—'
                        : session.teacherName.trim(),
                  ),
                  SizedBox(height: 10.h),
                  _DetailLine(
                    label: 'DATE',
                    value: session.startAt == null
                        ? 'TBA'
                        : _formatDate(session.startAt!),
                  ),
                  SizedBox(height: 10.h),
                  _DetailLine(
                    label: 'TIME',
                    value: (session.startAt == null || session.endAt == null)
                        ? 'TBA'
                        : '${_formatTime(session.startAt!)} - ${_formatTime(session.endAt!)}',
                  ),
                  SizedBox(height: 10.h),
                  _DetailLine(
                    label: 'JOIN',
                    value: session.joinOpensAt == null
                        ? '—'
                        : '${_formatDate(session.joinOpensAt!)}, ${_formatTime(session.joinOpensAt!)}',
                  ),
                  if (session.totalStudents > 0) ...[
                    SizedBox(height: 10.h),
                    _DetailLine(
                      label: 'JOINED',
                      value: '${session.joinedCount}/${session.totalStudents}',
                    ),
                  ],
                ],
              ),
            ),
            SizedBox(height: 14.h),
            Container(
              padding: EdgeInsets.all(14.r),
              decoration: BoxDecoration(
                color: SumAcademyTheme.warningLight,
                borderRadius: BorderRadius.circular(18.r),
                border: Border.all(
                  color: SumAcademyTheme.warning.withOpacityFloat(0.25),
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
                onPressed: _isPrimaryEnabled(session)
                    ? () => _handlePrimaryAction()
                    : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: SumAcademyTheme.brandBlue,
                  foregroundColor: SumAcademyTheme.white,
                  padding: EdgeInsets.symmetric(vertical: 12.h),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(18.r),
                  ),
                ),
                child: Text(_primaryLabel(session)),
              ),
            ),
            if (!_isPrimaryEnabled(session)) ...[
              SizedBox(height: 10.h),
              Text(
                _disabledReason(session),
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

  String _classLine(StudentSession session) {
    final name = session.className.trim();
    final code = session.batchCode.trim();
    if (name.isEmpty && code.isEmpty) return 'Class session';
    if (name.isEmpty) return code;
    if (code.isEmpty) return name;
    return '$name ($code)';
  }

  String _primaryLabel(StudentSession session) {
    if (session.hasEnded) {
      if (session.isLocked) return 'Recording Locked';
      if (session.recordingUrl.trim().isNotEmpty) return 'Watch Recording';
      return 'Session Ended';
    }
    if (session.isLive) return 'Open Session';
    return 'Join Session';
  }

  bool _isPrimaryEnabled(StudentSession session) {
    if (session.hasEnded) {
      return !session.isLocked && session.recordingUrl.trim().isNotEmpty;
    }
    final hasAnyLink =
        session.meetingLink.trim().isNotEmpty || session.recordingUrl.trim().isNotEmpty;
    if (!hasAnyLink) return false;
    return true;
  }

  String _disabledReason(StudentSession session) {
    if (session.hasEnded) {
      if (session.isLocked) {
        return 'Recording is locked. Ask admin to unlock this session.';
      }
      return 'Recording is not available yet.';
    }
    if (session.joinOpensAt != null && DateTime.now().isBefore(session.joinOpensAt!)) {
      return 'Join opens at ${_formatDate(session.joinOpensAt!)}, ${_formatTime(session.joinOpensAt!)}.';
    }
    return 'Session link is not available yet.';
  }

  Future<void> _handlePrimaryAction() async {
    final controller = Get.find<StudentLiveSessionsController>();
    try {
      final now = DateTime.now();

      if (session.isClientComputed) {
        final startAt = session.startAt;
        if (startAt != null && now.isBefore(startAt)) {
          await Get.to(() => StudentLiveSessionWaitingView(session: session));
          return;
        }
        final url = session.recordingUrl.trim();
        if (url.isEmpty) {
          await showAppErrorDialog(
            title: 'Live Session',
            message: 'Session video is not available yet.',
          );
          return;
        }
        await Get.to(
          () => StudentLiveSessionPlayerView(
            session: session,
            playbackUrl: url,
            // For MP4 "live" playback, seeking causes heavy buffering.
            // Start from beginning for smooth playback until HLS is available.
            initialSeekSeconds: 0,
          ),
        );
        return;
      }

      if (session.hasEnded) {
        if (session.isLocked) {
          await showAppErrorDialog(
            title: 'Live Session',
            message: 'Recording is locked. Ask admin to unlock this session.',
          );
          return;
        }
        final url = session.recordingUrl.trim();
        if (url.isEmpty) {
          await showAppErrorDialog(
            title: 'Live Session',
            message: 'Recording is not available yet.',
          );
          return;
        }
        await Get.to(() => StudentLiveSessionPlayerView(session: session, playbackUrl: url));
        return;
      }

      final startAt = session.startAt;
      if (startAt != null && now.isBefore(startAt)) {
        await Get.to(() => StudentLiveSessionWaitingView(session: session));
        return;
      }

      final joinData = await controller.joinSession(session);
      if (joinData['canPlay'] == false) {
        await Get.to(() => StudentLiveSessionWaitingView(session: session));
        return;
      }

      final meeting = session.meetingLink.trim();
      if (meeting.isNotEmpty) {
        final uri = Uri.tryParse(meeting);
        if (uri != null) {
          final launched = await launchUrl(
            uri,
            mode: LaunchMode.externalApplication,
          );
          if (launched) return;
        }
      }

      final recording = session.recordingUrl.trim();
      if (recording.isNotEmpty) {
        await Get.to(
          () => StudentLiveSessionPlayerView(
            session: session,
            playbackUrl: recording,
            // For MP4 "live" playback, seeking causes heavy buffering.
            // Start from beginning for smooth playback until HLS is available.
            initialSeekSeconds: 0,
          ),
        );
        return;
      }

      await showAppErrorDialog(
        title: 'Live Session',
        message: 'Session link is not available yet.',
      );
    } catch (e) {
      await showAppErrorDialog(
        title: 'Live Session',
        message: e.toString().replaceFirst('Exception: ', ''),
      );
    }
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
        'No live sessions right now.',
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
