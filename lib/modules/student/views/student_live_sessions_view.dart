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



    return Obx(() {
      final isDark = Theme.of(context).brightness == Brightness.dark;
      final textColor = isDark ? SumAcademyTheme.white : SumAcademyTheme.darkBase;

      return Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: isDark
                ? [SumAcademyTheme.darkBase, SumAcademyTheme.darkSurface]
                : [SumAcademyTheme.surfaceSecondary, SumAcademyTheme.white],
          ),
        ),
        child: RefreshIndicator(
          color: SumAcademyTheme.brandBlue,
          onRefresh: controller.refresh,
          child: ListView(
            padding: EdgeInsets.fromLTRB(20.w, 16.h, 20.w, 28.h),
            physics: const AlwaysScrollableScrollPhysics(
              parent: BouncingScrollPhysics(),
            ),
            children: [
              StudentDashboardHeader(
                subtitle: 'Live Sessions',
                actions: [
                  _LiveIndicator(isAnyLive: controller.sessions.any((s) => s.isLive)),
                ],
              ),
              SizedBox(height: 10.h),
              Text(
                'Join live interactive workshops and view your recent class recordings.',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: textColor.withOpacityFloat(0.6),
                      height: 1.4,
                    ),
              ),
              SizedBox(height: 20.h),
              const _FilterRow(),
              SizedBox(height: 20.h),
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
                    padding: EdgeInsets.only(bottom: 14.h),
                    child: _LiveSessionCard(session: session),
                  ),
                ),
            ],
          ),
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

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      physics: const BouncingScrollPhysics(),
      child: Row(
        children: [
          _FilterChip(
            id: 'all',
            label: 'All Sessions',
            isSelected: controller.selectedFilter.value == 'all',
            onTap: () => controller.setFilter('all'),
          ),
          SizedBox(width: 10.w),
          _FilterChip(
            id: 'live',
            label: 'Live Now',
            isSelected: controller.selectedFilter.value == 'live',
            onTap: () => controller.setFilter('live'),
            isLive: true,
          ),
          SizedBox(width: 10.w),
          _FilterChip(
            id: 'upcoming',
            label: 'Upcoming',
            isSelected: controller.selectedFilter.value == 'upcoming',
            onTap: () => controller.setFilter('upcoming'),
          ),
        ],
      ),
    );
  }
}

class _FilterChip extends StatelessWidget {
  final String id;
  final String label;
  final bool isSelected;
  final VoidCallback onTap;
  final bool isLive;

  const _FilterChip({
    required this.id,
    required this.label,
    required this.isSelected,
    required this.onTap,
    this.isLive = false,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final color = isLive ? SumAcademyTheme.success : SumAcademyTheme.brandBlue;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      curve: Curves.easeInOut,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(14.r),
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 10.h),
            decoration: BoxDecoration(
              color: isSelected
                  ? color
                  : (isDark ? SumAcademyTheme.darkSurface : SumAcademyTheme.white),
              borderRadius: BorderRadius.circular(14.r),
              border: Border.all(
                color: isSelected
                    ? color
                    : (isDark
                        ? SumAcademyTheme.darkBorder
                        : SumAcademyTheme.brandBluePale),
                width: 1.5,
              ),
              boxShadow: [
                if (isSelected && !isDark)
                  BoxShadow(
                    color: color.withOpacityFloat(0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
              ],
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (isLive) ...[
                  Container(
                    width: 8.r,
                    height: 8.r,
                    decoration: BoxDecoration(
                      color: isSelected ? SumAcademyTheme.white : color,
                      shape: BoxShape.circle,
                    ),
                  ),
                  SizedBox(width: 8.w),
                ],
                Text(
                  label,
                  style: Theme.of(context).textTheme.labelMedium?.copyWith(
                        color: isSelected
                            ? SumAcademyTheme.white
                            : (isDark
                                ? SumAcademyTheme.white
                                : SumAcademyTheme.darkBase),
                        fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
                      ),
                ),
              ],
            ),
          ),
        ),
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
    final border = isDark ? SumAcademyTheme.darkBorder : SumAcademyTheme.brandBluePale;

    final badge = _badgeFor(session);
    final isLive = badge == _SessionBadge.live;
    final accent = isLive ? SumAcademyTheme.success : SumAcademyTheme.brandBlue;

    return Container(
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: surface,
        borderRadius: BorderRadius.circular(SumAcademyTheme.radiusCard.r),
        border: Border.all(color: border),
        boxShadow: [
          if (!isDark)
            BoxShadow(
              color: SumAcademyTheme.darkBase.withOpacityFloat(0.06),
              blurRadius: 20.r,
              offset: Offset(0, 8.h),
            ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => Get.to(() => StudentLiveSessionDetailView(session: session)),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Standard 6px accent banner
              Container(
                height: 6.h,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [accent, accent.withOpacityFloat(0.7)],
                  ),
                ),
              ),
              Padding(
                padding: EdgeInsets.all(18.r),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                session.topic.trim().isEmpty
                                    ? 'Studio Live Session'
                                    : session.topic,
                                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                                      color: isDark
                                          ? SumAcademyTheme.white
                                          : SumAcademyTheme.darkBase,
                                      fontWeight: FontWeight.w700,
                                      fontSize: 16.sp,
                                    ),
                              ),
                              SizedBox(height: 6.h),
                              Text(
                                _classLine(session),
                                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                      color: (isDark
                                              ? SumAcademyTheme.white
                                              : SumAcademyTheme.darkBase)
                                          .withOpacityFloat(0.55),
                                      fontWeight: FontWeight.w600,
                                    ),
                              ),
                            ],
                          ),
                        ),
                        SizedBox(width: 12.w),
                        _StatusBadge(badge: badge, accent: accent),
                      ],
                    ),
                    SizedBox(height: 18.h),
                    Row(
                      children: [
                        _SessionInfo(
                          icon: Icons.calendar_today_rounded,
                          label: _formatDate(session.startAt ?? DateTime.now()),
                        ),
                        SizedBox(width: 16.w),
                        _SessionInfo(
                          icon: Icons.access_time_rounded,
                          label: _formatTime(session.startAt ?? DateTime.now()),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _classLine(StudentSession session) {
    final name = session.className.trim();
    final code = session.batchCode.trim();
    if (name.isEmpty && code.isEmpty) return 'General Session';
    if (name.isEmpty) return code;
    if (code.isEmpty) return name;
    return '$name • $code';
  }
}

class _StatusBadge extends StatelessWidget {
  final _SessionBadge badge;
  final Color accent;

  const _StatusBadge({required this.badge, required this.accent});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 5.h),
      decoration: BoxDecoration(
        color: accent.withOpacityFloat(0.12),
        borderRadius: BorderRadius.circular(10.r),
        border: Border.all(color: accent.withOpacityFloat(0.2)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (badge == _SessionBadge.live) ...[
            _LivePulse(color: accent),
            SizedBox(width: 6.w),
          ],
          Text(
            badge == _SessionBadge.live ? 'LIVE' : badge.name.toUpperCase(),
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  color: accent,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 0.5,
                ),
          ),
        ],
      ),
    );
  }
}

class _SessionInfo extends StatelessWidget {
  final IconData icon;
  final String label;

  const _SessionInfo({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final color = (isDark ? SumAcademyTheme.white : SumAcademyTheme.darkBase)
        .withOpacityFloat(0.6);
    return Row(
      children: [
        Icon(icon, size: 14.sp, color: color),
        SizedBox(width: 6.w),
        Text(
          label,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: color,
                fontWeight: FontWeight.w600,
              ),
        ),
      ],
    );
  }
}

class _LivePulse extends StatefulWidget {
  final Color color;
  const _LivePulse({required this.color});

  @override
  State<_LivePulse> createState() => _LivePulseState();
}

class _LivePulseState extends State<_LivePulse> with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Container(
          width: 8.r,
          height: 8.r,
          decoration: BoxDecoration(
            color: widget.color.withOpacityFloat(0.5 + (_controller.value * 0.5)),
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: widget.color.withOpacityFloat(0.3 * _controller.value),
                blurRadius: 6 * _controller.value,
                spreadRadius: 2 * _controller.value,
              ),
            ],
          ),
        );
      },
    );
  }
}

class _LiveIndicator extends StatelessWidget {
  final bool isAnyLive;
  const _LiveIndicator({required this.isAnyLive});

  @override
  Widget build(BuildContext context) {
    if (!isAnyLive) return const SizedBox.shrink();
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
      decoration: BoxDecoration(
        color: SumAcademyTheme.success.withOpacityFloat(0.1),
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: SumAcademyTheme.success.withOpacityFloat(0.2)),
      ),
      child: Row(
        children: [
          const _LivePulse(color: SumAcademyTheme.success),
          SizedBox(width: 6.w),
          Text(
            'ACTIVE',
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  color: SumAcademyTheme.success,
                  fontWeight: FontWeight.w800,
                ),
          ),
        ],
      ),
    );
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
    final textColor = isDark ? SumAcademyTheme.white : SumAcademyTheme.darkBase;
    final surface = isDark ? SumAcademyTheme.darkSurface : SumAcademyTheme.white;
    final border = isDark ? SumAcademyTheme.darkBorder : SumAcademyTheme.brandBluePale;
    
    final badge = _badgeFor(session);
    final accent = badge == _SessionBadge.live ? SumAcademyTheme.success : SumAcademyTheme.brandBlue;

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: isDark
                ? [SumAcademyTheme.darkBase, SumAcademyTheme.darkSurface]
                : [SumAcademyTheme.surfaceSecondary, SumAcademyTheme.white],
          ),
        ),
        child: SafeArea(
          child: ListView(
            padding: EdgeInsets.fromLTRB(20.w, 12.h, 20.w, 100.h),
            physics: const BouncingScrollPhysics(),
            children: [
              Row(
                children: [
                  IconButton(
                    onPressed: () => Get.back(),
                    icon: Icon(Icons.arrow_back_rounded, color: textColor),
                    style: IconButton.styleFrom(
                      backgroundColor: isDark ? SumAcademyTheme.darkSurface : SumAcademyTheme.white,
                      padding: EdgeInsets.all(12.r),
                    ),
                  ),
                  SizedBox(width: 12.w),
                  Expanded(
                    child: Text(
                      'Session Details',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            color: textColor,
                            fontWeight: FontWeight.w800,
                          ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 24.h),
              
              // Detail Card with Banner
              Container(
                clipBehavior: Clip.antiAlias,
                decoration: BoxDecoration(
                  color: surface,
                  borderRadius: BorderRadius.circular(SumAcademyTheme.radiusCard.r),
                  border: Border.all(color: border),
                  boxShadow: [
                    if (!isDark)
                      BoxShadow(
                        color: SumAcademyTheme.darkBase.withOpacityFloat(0.06),
                        blurRadius: 20.r,
                        offset: Offset(0, 10.h),
                      ),
                  ],
                ),
                child: Column(
                  children: [
                    Container(
                      height: 6.h,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(colors: [accent, accent.withOpacityFloat(0.7)]),
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.all(20.r),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _StatusBadge(badge: badge, accent: accent),
                          SizedBox(height: 16.h),
                          Text(
                            session.topic.trim().isEmpty ? 'Live Interactive Session' : session.topic,
                            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                  color: textColor,
                                  fontWeight: FontWeight.w800,
                                  fontSize: 22.sp,
                                  height: 1.2,
                                ),
                          ),
                          SizedBox(height: 8.h),
                          Text(
                            _classLine(session),
                            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                  color: textColor.withOpacityFloat(0.5),
                                  fontWeight: FontWeight.w600,
                                ),
                          ),
                          SizedBox(height: 24.h),
                          Divider(color: border, height: 1),
                          SizedBox(height: 16.h),
                          _DetailLine(
                            icon: Icons.person_outline_rounded,
                            label: 'INSTRUCTOR',
                            value: session.teacherName.trim().isEmpty ? 'Pending' : session.teacherName,
                          ),
                          SizedBox(height: 14.h),
                          _DetailLine(
                            icon: Icons.calendar_today_rounded,
                            label: 'DATE',
                            value: session.startAt == null ? 'TBA' : _formatDate(session.startAt!),
                          ),
                          SizedBox(height: 14.h),
                          _DetailLine(
                            icon: Icons.access_time_rounded,
                            label: 'SCHEDULE',
                            value: (session.startAt == null || session.endAt == null)
                                ? 'TBA'
                                : '${_formatTime(session.startAt!)} - ${_formatTime(session.endAt!)}',
                          ),
                          if (session.totalStudents > 0) ...[
                             SizedBox(height: 14.h),
                             _DetailLine(
                               icon: Icons.group_outlined,
                               label: 'ATTENDANCE',
                               value: '${session.joinedCount} Joined / ${session.totalStudents} Expected',
                             ),
                          ],
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              
              SizedBox(height: 20.h),
              
              // Rules Card
              Container(
                padding: EdgeInsets.all(18.r),
                decoration: BoxDecoration(
                  color: SumAcademyTheme.warningLight.withOpacityFloat(0.5),
                  borderRadius: BorderRadius.circular(SumAcademyTheme.radiusCard.r),
                  border: Border.all(color: SumAcademyTheme.warning.withOpacityFloat(0.15)),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(Icons.info_outline_rounded, color: SumAcademyTheme.warning, size: 20.sp),
                    SizedBox(width: 12.w),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Session Guidelines',
                            style: TextStyle(
                              color: SumAcademyTheme.warning,
                              fontWeight: FontWeight.w800,
                              fontSize: 14.sp,
                            ),
                          ),
                          SizedBox(height: 4.h),
                          Text(
                            'Controls like seeking and pausing are disabled during the live broadcast. Please ensure a stable internet connection.',
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                  color: SumAcademyTheme.darkBase.withOpacityFloat(0.6),
                                  height: 1.4,
                                  fontWeight: FontWeight.w500,
                                ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              
              SizedBox(height: 32.h),
              
              // Action Button
              SizedBox(
                width: double.infinity,
                height: 56.h,
                child: ElevatedButton(
                  onPressed: _isPrimaryEnabled(session) ? () => _handlePrimaryAction() : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: SumAcademyTheme.brandBlue,
                    foregroundColor: SumAcademyTheme.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(SumAcademyTheme.radiusButton.r),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(_actionIcon(session)),
                      SizedBox(width: 10.w),
                      Text(
                        _primaryLabel(session),
                        style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.w800),
                      ),
                    ],
                  ),
                ),
              ),
              
              if (!_isPrimaryEnabled(session)) ...[
                SizedBox(height: 12.h),
                Center(
                  child: Text(
                    _disabledReason(session),
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: textColor.withOpacityFloat(0.5),
                          fontWeight: FontWeight.w600,
                        ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  IconData _actionIcon(StudentSession session) {
    if (session.hasEnded) return Icons.play_circle_fill_rounded;
    return Icons.bolt_rounded;
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
  final IconData icon;
  final String label;
  final String value;

  const _DetailLine({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDark ? SumAcademyTheme.white : SumAcademyTheme.darkBase;

    return Row(
      children: [
        Container(
          padding: EdgeInsets.all(8.r),
          decoration: BoxDecoration(
            color: SumAcademyTheme.brandBlue.withOpacityFloat(0.08),
            borderRadius: BorderRadius.circular(10.r),
          ),
          child: Icon(icon, size: 16.sp, color: SumAcademyTheme.brandBlue),
        ),
        SizedBox(width: 14.w),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                      color: textColor.withOpacityFloat(0.4),
                      fontWeight: FontWeight.w700,
                      letterSpacing: 1.1,
                      fontSize: 10.sp,
                    ),
              ),
              SizedBox(height: 2.h),
              Text(
                value,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: textColor.withOpacityFloat(0.85),
                      fontWeight: FontWeight.w700,
                    ),
              ),
            ],
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
    return Center(
      child: Padding(
        padding: EdgeInsets.only(top: 60.h),
        child: Column(
          children: [
            Container(
              padding: EdgeInsets.all(24.r),
              decoration: BoxDecoration(
                color: SumAcademyTheme.brandBlue.withOpacityFloat(0.05),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.videocam_off_rounded,
                size: 48.sp,
                color: SumAcademyTheme.brandBlue.withOpacityFloat(0.4),
              ),
            ),
            SizedBox(height: 16.h),
            Text(
              'No live sessions scheduled',
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    color: isDark ? SumAcademyTheme.white : SumAcademyTheme.darkBase,
                    fontWeight: FontWeight.w700,
                  ),
            ),
            SizedBox(height: 6.h),
            Text(
              'Check back later for new workshops.',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: (isDark ? SumAcademyTheme.white : SumAcademyTheme.darkBase)
                        .withOpacityFloat(0.5),
                  ),
            ),
          ],
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
      padding: EdgeInsets.all(20.r),
      decoration: BoxDecoration(
        color: SumAcademyTheme.errorLight.withOpacityFloat(0.4),
        borderRadius: BorderRadius.circular(SumAcademyTheme.radiusCard.r),
        border: Border.all(color: SumAcademyTheme.error.withOpacityFloat(0.2)),
      ),
      child: Column(
        children: [
          Icon(Icons.error_outline_rounded, color: SumAcademyTheme.error, size: 32.sp),
          SizedBox(height: 12.h),
          Text(
            'Sync Error',
            style: TextStyle(
              color: SumAcademyTheme.error,
              fontWeight: FontWeight.w800,
              fontSize: 16.sp,
            ),
          ),
          SizedBox(height: 6.h),
          Text(
            message,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: SumAcademyTheme.darkBase.withOpacityFloat(0.6),
              fontSize: 13.sp,
            ),
          ),
          SizedBox(height: 20.h),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: onRetry,
              style: ElevatedButton.styleFrom(
                backgroundColor: SumAcademyTheme.error,
                foregroundColor: SumAcademyTheme.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12.r),
                ),
              ),
              child: const Text('Try Refreshing'),
            ),
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
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Column(
      children: List.generate(
        3,
        (index) => Padding(
          padding: EdgeInsets.only(bottom: 14.h),
          child: Container(
            height: 140.h,
            width: double.infinity,
            decoration: BoxDecoration(
              color: isDark ? SumAcademyTheme.darkSurface : SumAcademyTheme.white,
              borderRadius: BorderRadius.circular(SumAcademyTheme.radiusCard.r),
              border: Border.all(
                color: isDark ? SumAcademyTheme.darkBorder : SumAcademyTheme.brandBluePale,
              ),
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
