import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:sum_academy/app/theme.dart';
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
    // If user enters near start time, start without waiting for first tick.
    _maybeStartNow();
  }

  @override
  void dispose() {
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
        // Only late-join seek while session is actively running.
        var seekSeconds = 0;
        if (widget.session.isLive) {
          try {
            final sync = await controller.syncSession(widget.session);
            final isRunning = sync['isRunning'] == true;
            final elapsed = sync['elapsedSeconds'];
            if (isRunning && elapsed is int) seekSeconds = elapsed;
            if (isRunning && elapsed is num) seekSeconds = elapsed.toInt();
          } catch (_) {}
        }

        await Get.off(
          () => StudentLiveSessionPlayerView(
            session: widget.session,
            playbackUrl: recordingUrl,
            initialSeekSeconds: seekSeconds.clamp(0, 24 * 60 * 60),
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
    final textColor =
        isDark ? SumAcademyTheme.white : SumAcademyTheme.darkBase;

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.fromLTRB(20.w, 14.h, 20.w, 22.h),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  IconButton(
                    onPressed: _isJoining ? null : () => Get.back(),
                    icon: Icon(
                      Icons.arrow_back_rounded,
                      color: textColor,
                    ),
                  ),
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
              SizedBox(height: 10.h),
              Text(
                widget.session.topic,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: textColor,
                      fontWeight: FontWeight.w700,
                    ),
              ),
              SizedBox(height: 6.h),
              Text(
                widget.session.className.trim().isEmpty
                    ? widget.session.batchCode
                    : '${widget.session.className} (${widget.session.batchCode})',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: textColor.withOpacityFloat(0.65),
                      fontWeight: FontWeight.w600,
                    ),
              ),
              SizedBox(height: 22.h),
              Center(
                child: Container(
                  padding:
                      EdgeInsets.symmetric(horizontal: 22.w, vertical: 18.h),
                  decoration: BoxDecoration(
                    color: (isDark
                            ? SumAcademyTheme.darkSurface
                            : SumAcademyTheme.white)
                        .withOpacityFloat(0.95),
                    borderRadius: BorderRadius.circular(22.r),
                    border: Border.all(
                      color: SumAcademyTheme.brandBlue.withOpacityFloat(0.15),
                    ),
                    boxShadow: [
                      if (!isDark)
                        BoxShadow(
                          color: SumAcademyTheme.darkBase.withOpacityFloat(0.06),
                          blurRadius: 20,
                          offset: const Offset(0, 12),
                        ),
                    ],
                  ),
                  child: Column(
                    children: [
                      Text(
                        _startAt == null
                            ? 'Starting soon'
                            : (_waitingForJoinWindow ? 'Join opens in' : 'Starts in'),
                        style: Theme.of(context).textTheme.labelLarge?.copyWith(
                              color: SumAcademyTheme.brandBlue,
                              fontWeight: FontWeight.w800,
                            ),
                      ),
                      SizedBox(height: 10.h),
                      Text(
                        _startAt == null
                            ? '--:--'
                            : _formatDuration(_remaining),
                        style: Theme.of(context).textTheme.displaySmall?.copyWith(
                              color: textColor,
                              fontWeight: FontWeight.w900,
                              letterSpacing: 1.6,
                            ),
                      ),
                      if (_totalStudents > 0) ...[
                        SizedBox(height: 10.h),
                        Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: 10.w,
                            vertical: 6.h,
                          ),
                          decoration: BoxDecoration(
                            color: SumAcademyTheme.brandBlue.withOpacityFloat(0.10),
                            borderRadius: BorderRadius.circular(999),
                            border: Border.all(
                              color: SumAcademyTheme.brandBlue.withOpacityFloat(0.18),
                            ),
                          ),
                          child: Text(
                            'Joined: $_joinedCount/$_totalStudents',
                            style: Theme.of(context).textTheme.labelSmall?.copyWith(
                                  color: SumAcademyTheme.brandBlue,
                                  fontWeight: FontWeight.w800,
                                ),
                          ),
                        ),
                      ],
                      SizedBox(height: 10.h),
                      Text(
                        'Keep this page open. Video will start automatically.',
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: textColor.withOpacityFloat(0.65),
                              height: 1.35,
                              fontWeight: FontWeight.w600,
                            ),
                      ),
                      if (_isJoining) ...[
                        SizedBox(height: 14.h),
                        SizedBox(
                          height: 18.r,
                          width: 18.r,
                          child: const CircularProgressIndicator(strokeWidth: 2),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
              const Spacer(),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton(
                  onPressed: _isJoining ? null : () => Get.back(),
                  style: OutlinedButton.styleFrom(
                    padding: EdgeInsets.symmetric(vertical: 12.h),
                    foregroundColor: textColor.withOpacityFloat(0.8),
                    side: BorderSide(
                      color: SumAcademyTheme.brandBlue.withOpacityFloat(0.22),
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(18.r),
                    ),
                  ),
                  child: const Text('Back'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
