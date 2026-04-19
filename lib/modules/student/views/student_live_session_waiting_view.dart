import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:sum_academy/app/theme.dart';
import 'package:sum_academy/core/services/secure_screen_service.dart';
import 'package:sum_academy/core/utils/network_error.dart';
import 'package:sum_academy/modules/student/controllers/student_live_sessions_controller.dart';
import 'package:sum_academy/modules/student/models/student_session.dart';
import 'package:sum_academy/modules/student/views/student_live_session_player_view.dart';
import 'package:url_launcher/url_launcher.dart';

class StudentLiveSessionWaitingView extends StatefulWidget {
  final StudentSession session;

  const StudentLiveSessionWaitingView({super.key, required this.session});

  @override
  State<StudentLiveSessionWaitingView> createState() =>
      _StudentLiveSessionWaitingViewState();
}

class _StudentLiveSessionWaitingViewState
    extends State<StudentLiveSessionWaitingView> {
  Timer? _timer;
  Timer? _statusTimer;
  Duration _remaining = Duration.zero;
  bool _isJoining = false;
  bool _didStart = false;
  DateTime? _targetStartAt;
  bool _waitingForJoinWindow = false;
  int _joinedCount = 0;
  int _totalStudents = 0;

  DateTime? get _startAt => _targetStartAt;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      SecureScreenService.enable();
    });
    final joinOpensAt = widget.session.joinOpensAt;
    if (joinOpensAt != null && DateTime.now().isBefore(joinOpensAt)) {
      _targetStartAt = joinOpensAt;
      _waitingForJoinWindow = true;
    } else {
      _targetStartAt = widget.session.startAt;
      _waitingForJoinWindow = false;
    }
    _recomputeRemaining();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      _recomputeRemaining();
      if (_remaining.inSeconds <= 0) {
        _maybeStartNow();
      }
    });
    _joinedCount = widget.session.joinedCount;
    _totalStudents = widget.session.totalStudents;
    if (!widget.session.isClientComputed) {
      _statusTimer = Timer.periodic(const Duration(seconds: 10), (_) async {
        if (!mounted) return;
        final controller = Get.find<StudentLiveSessionsController>();
        try {
          final latest = await controller.fetchSessionStatus(widget.session.id);
          if (!mounted) return;
          setState(() {
            _joinedCount = latest.joinedCount;
            _totalStudents = latest.totalStudents;
          });
        } catch (_) {}
      });
    }
    // If user enters near start time, start without waiting for first tick.
    _maybeStartNow();
  }

  @override
  void dispose() {
    SecureScreenService.disable();
    _timer?.cancel();
    _statusTimer?.cancel();
    super.dispose();
  }

  void _recomputeRemaining() {
    final startAt = _startAt;
    if (startAt == null) {
      setState(() => _remaining = Duration.zero);
      return;
    }
    final now = DateTime.now();
    final diff = startAt.difference(now);
    setState(() => _remaining = diff.isNegative ? Duration.zero : diff);
  }

  Future<void> _maybeStartNow() async {
    if (!mounted) return;
    if (_didStart) return;
    final startAt = _startAt;
    if (startAt != null && DateTime.now().isBefore(startAt)) return;
    _didStart = true;
    await _startSession();
  }

  Future<void> _startSession() async {
    if (!mounted) return;
    if (_isJoining) return;
    setState(() => _isJoining = true);

    final controller = Get.find<StudentLiveSessionsController>();
    try {
      if (widget.session.isClientComputed) {
        final url = widget.session.recordingUrl.trim();
        if (url.isEmpty) {
          setState(() => _isJoining = false);
          await showAppErrorDialog(
            title: 'Live Session',
            message: 'Session video is not available yet.',
          );
          if (mounted) Get.back();
          return;
        }
        await Get.to(
          () => StudentLiveSessionPlayerView(
            session: widget.session,
            playbackUrl: url,
            initialSeekSeconds: 0,
          ),
        );
        if (mounted) Get.back();
        return;
      }

      final joinData = await controller.joinSession(widget.session);
      if (joinData['canPlay'] == false) {
        final waiting = joinData['waiting'] == true;
        final startAtText = joinData['startAt']?.toString().trim() ?? '';
        final parsedStartAt = startAtText.isEmpty ? null : DateTime.tryParse(startAtText);
        if (waiting && parsedStartAt != null) {
          // Backend says the session isn't playable yet; keep counting down.
          setState(() {
            _isJoining = false;
            _didStart = false;
            _waitingForJoinWindow = false;
            _targetStartAt = parsedStartAt.toLocal();
          });
          _recomputeRemaining();
          return;
        }

        setState(() => _isJoining = false);
        await showAppErrorDialog(
          title: 'Live Session',
          message: 'Session is not available to join yet.',
        );
        if (mounted) Get.back();
        return;
      }

      final link = widget.session.meetingLink.trim();
      if (link.isNotEmpty) {
        final uri = Uri.tryParse(link);
        if (uri != null) {
          final launched = await launchUrl(
            uri,
            mode: LaunchMode.externalApplication,
          );
          if (launched) {
            if (mounted) Get.back();
            return;
          }
        }
      }

      final recordingUrl = widget.session.recordingUrl.trim();
      if (recordingUrl.isNotEmpty) {
        await Get.off(
          () => StudentLiveSessionPlayerView(
            session: widget.session,
            playbackUrl: recordingUrl,
            // For MP4 "live" playback, seeking causes heavy buffering.
            // Start from beginning for smooth playback until HLS is available.
            initialSeekSeconds: 0,
          ),
        );
        return;
      }

      setState(() => _isJoining = false);
      await showAppErrorDialog(
        title: 'Live Session',
        message: 'Session link is not available yet.',
      );
      if (mounted) Get.back();
    } catch (e) {
      setState(() => _isJoining = false);
      await showAppErrorDialog(
        title: 'Live Session',
        message: e.toString().replaceFirst('Exception: ', ''),
      );
      if (mounted) Get.back();
    }
  }

  String _formatDuration(Duration duration) {
    final totalSeconds = duration.inSeconds;
    final hours = totalSeconds ~/ 3600;
    final minutes = (totalSeconds % 3600) ~/ 60;
    final seconds = totalSeconds % 60;
    if (hours > 0) {
      return '${hours.toString().padLeft(2, '0')}:'
          '${minutes.toString().padLeft(2, '0')}:'
          '${seconds.toString().padLeft(2, '0')}';
    }
    return '${minutes.toString().padLeft(2, '0')}:'
        '${seconds.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDark ? SumAcademyTheme.white : SumAcademyTheme.darkBase;

    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
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
          child: Padding(
            padding: EdgeInsets.fromLTRB(20.w, 14.h, 20.w, 22.h),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    IconButton(
                      onPressed: _isJoining ? null : () => Get.back(),
                      icon: Icon(Icons.arrow_back_rounded, color: textColor),
                      style: IconButton.styleFrom(
                        backgroundColor: isDark ? SumAcademyTheme.darkSurface : SumAcademyTheme.white,
                        padding: EdgeInsets.all(12.r),
                      ),
                    ),
                    SizedBox(width: 12.w),
                    Expanded(
                      child: Text(
                        'Waiting Room',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                              color: textColor,
                              fontWeight: FontWeight.w800,
                            ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 32.h),
                
                // Session Info
                Text(
                  widget.session.topic.trim().isEmpty ? 'Live Interactive Session' : widget.session.topic,
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        color: textColor,
                        fontWeight: FontWeight.w900,
                        fontSize: 24.sp,
                      ),
                ),
                SizedBox(height: 8.h),
                Row(
                  children: [
                    Icon(Icons.school_outlined, size: 16.sp, color: SumAcademyTheme.brandBlue),
                    SizedBox(width: 8.w),
                    Text(
                      widget.session.className.trim().isEmpty
                          ? widget.session.batchCode
                          : '${widget.session.className} • ${widget.session.batchCode}',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: textColor.withOpacityFloat(0.55),
                            fontWeight: FontWeight.w700,
                          ),
                    ),
                  ],
                ),
                
                const Spacer(),
                
                // Central Countdown Arena
                Center(
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      // Animated Pulse Effect
                      const _CountdownPulse(),
                      
                      // The Card
                      Container(
                        width: 0.85.sw,
                        padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 32.h),
                        decoration: BoxDecoration(
                          color: isDark ? SumAcademyTheme.darkSurface : SumAcademyTheme.white,
                          borderRadius: BorderRadius.circular(32.r),
                          border: Border.all(
                            color: SumAcademyTheme.brandBlue.withOpacityFloat(0.1),
                            width: 2,
                          ),
                          boxShadow: [
                            if (!isDark)
                              BoxShadow(
                                color: SumAcademyTheme.brandBlue.withOpacityFloat(0.08),
                                blurRadius: 40,
                                offset: const Offset(0, 20),
                              ),
                          ],
                        ),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              _startAt == null
                                  ? 'PREPARING STUDIO'
                                  : (_waitingForJoinWindow ? 'DOORS OPEN IN' : 'BROADCAST STARTS IN'),
                              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                                    color: SumAcademyTheme.brandBlue,
                                    fontWeight: FontWeight.w800,
                                    letterSpacing: 2,
                                  ),
                            ),
                            SizedBox(height: 16.h),
                            Text(
                              _startAt == null ? '--:--' : _formatDuration(_remaining),
                              style: Theme.of(context).textTheme.displayLarge?.copyWith(
                                    color: textColor,
                                    fontWeight: FontWeight.w900,
                                    fontSize: 48.sp,
                                    letterSpacing: -1,
                                  ),
                            ),
                            SizedBox(height: 24.h),
                            if (_totalStudents > 0) ...[
                              Container(
                                padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
                                decoration: BoxDecoration(
                                  color: SumAcademyTheme.brandBlue.withOpacityFloat(0.08),
                                  borderRadius: BorderRadius.circular(16.r),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(Icons.people_alt_rounded, size: 14.sp, color: SumAcademyTheme.brandBlue),
                                    SizedBox(width: 8.w),
                                    Text(
                                      '$_joinedCount Students Waiting',
                                      style: Theme.of(context).textTheme.labelSmall?.copyWith(
                                            color: SumAcademyTheme.brandBlue,
                                            fontWeight: FontWeight.w800,
                                          ),
                                    ),
                                  ],
                                ),
                              ),
                              SizedBox(height: 20.h),
                            ],
                            Text(
                              'Please stay on this screen.\nThe session will launch automatically.',
                              textAlign: TextAlign.center,
                              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                    color: textColor.withOpacityFloat(0.5),
                                    height: 1.5,
                                    fontWeight: FontWeight.w600,
                                  ),
                            ),
                            if (_isJoining) ...[
                              SizedBox(height: 20.h),
                              LinearProgressIndicator(
                                backgroundColor: SumAcademyTheme.brandBlue.withOpacityFloat(0.1),
                                valueColor: const AlwaysStoppedAnimation(SumAcademyTheme.brandBlue),
                                borderRadius: BorderRadius.circular(10.r),
                                minHeight: 4.h,
                              ),
                              SizedBox(height: 8.h),
                              Text(
                                'Syncing with studio...',
                                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                                      color: SumAcademyTheme.brandBlue,
                                      fontWeight: FontWeight.w700,
                                    ),
                              ),
                            ],
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                
                const Spacer(),
                
                // Footer
                SizedBox(
                  width: double.infinity,
                  height: 54.h,
                  child: OutlinedButton(
                    onPressed: _isJoining ? null : () => Get.back(),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: textColor.withOpacityFloat(0.6),
                      side: BorderSide(color: isDark ? SumAcademyTheme.darkBorder : SumAcademyTheme.brandBluePale),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(SumAcademyTheme.radiusButton.r),
                      ),
                    ),
                    child: const Text('Exit Waiting Room', style: TextStyle(fontWeight: FontWeight.w700)),
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

class _CountdownPulse extends StatefulWidget {
  const _CountdownPulse();

  @override
  State<_CountdownPulse> createState() => _CountdownPulseState();
}

class _CountdownPulseState extends State<_CountdownPulse> with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat();
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
        return Stack(
          alignment: Alignment.center,
          children: List.generate(2, (index) {
            final delay = index * 0.5;
            final progress = (_controller.value + delay) % 1.0;
            return Container(
              width: 0.85.sw + (progress * 100.w),
              height: 280.h + (progress * 100.h),
              decoration: BoxDecoration(
                border: Border.all(
                  color: SumAcademyTheme.brandBlue.withOpacityFloat(0.15 * (1 - progress)),
                  width: 2,
                ),
                borderRadius: BorderRadius.circular(40.r),
              ),
            );
          }),
        );
      },
    );
  }
}
