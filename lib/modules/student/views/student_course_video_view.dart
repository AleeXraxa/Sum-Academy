import 'dart:async';

import 'package:better_player/better_player.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:sum_academy/app/theme.dart';
import 'package:sum_academy/core/services/secure_screen_service.dart';
import 'package:sum_academy/core/services/api_exception.dart';
import 'package:sum_academy/core/utils/network_error.dart';
import 'package:sum_academy/core/widgets/status_dialogs.dart';
import 'package:sum_academy/modules/student/models/student_course_progress.dart';
import 'package:sum_academy/modules/student/services/student_course_progress_service.dart';

class StudentCourseVideoView extends StatefulWidget {
  final String courseId;
  final StudentCourseLecture lecture;
  final VoidCallback? onCompleted;

  const StudentCourseVideoView({
    super.key,
    required this.courseId,
    required this.lecture,
    this.onCompleted,
  });

  @override
  State<StudentCourseVideoView> createState() => _StudentCourseVideoViewState();
}

class _StudentCourseVideoViewState extends State<StudentCourseVideoView>
    with WidgetsBindingObserver {
  late final BetterPlayerController _playerController;
  final _service = StudentCourseProgressService();
  bool _isCompleting = false;
  double _playbackProgress = 0;
  bool _autoMarked = false;
  bool _isMarkedComplete = false;
  double _lastReportedProgress = 0;
  bool _isReportingProgress = false;
  bool _finishHandled = false;
  late final double _resumeFraction;
  bool _initialSeekApplied = false;
  late final void Function(BetterPlayerEvent event) _eventListener;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      SecureScreenService.enable();
    });
    final rawProgress = widget.lecture.progress.clamp(0.0, 1.0);
    final canReplay =
        widget.lecture.canRewatch || !widget.lecture.lockAfterCompletion;
    if (widget.lecture.isCompleted && canReplay) {
      _resumeFraction = 0.0;
    } else if (widget.lecture.isCompleted) {
      _resumeFraction = rawProgress.clamp(0.0, 0.98);
    } else {
      _resumeFraction = rawProgress >= 0.98 ? 0.0 : rawProgress;
    }
    _playbackProgress = _resumeFraction;
    _lastReportedProgress = _resumeFraction * 100;
    _playerController = BetterPlayerController(
      BetterPlayerConfiguration(
        autoPlay: true,
        fit: BoxFit.contain,
        aspectRatio: 16 / 9,
        allowedScreenSleep: false,
        controlsConfiguration: const BetterPlayerControlsConfiguration(
          enableOverflowMenu: false,
          enablePlayPause: false,
          enableSkips: false,
          enableProgressText: false,
          enableProgressBar: false,
          enableAudioTracks: false,
          enableSubtitles: false,
          enablePlaybackSpeed: false,
          enablePip: false,
          enableRetry: false,
          enableQualities: false,
          enableFullscreen: true,
          enableMute: true,
          showControlsOnInitialize: true,
        ),
      ),
      betterPlayerDataSource: BetterPlayerDataSource(
        BetterPlayerDataSourceType.network,
        widget.lecture.videoUrl,
      ),
    );
    _eventListener = _handlePlayerEvent;
    _playerController.addEventsListener(_eventListener);
    _isMarkedComplete = widget.lecture.isCompleted;
  }

  @override
  void dispose() {
    unawaited(_reportProgressIfNeeded());
    SecureScreenService.disable();
    WidgetsBinding.instance.removeObserver(this);
    _playerController.removeEventsListener(_eventListener);
    _playerController.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      SecureScreenService.enable();
    } else if (state == AppLifecycleState.paused ||
        state == AppLifecycleState.inactive) {
      unawaited(_reportProgressIfNeeded());
    }
  }

  void _handlePlayerEvent(BetterPlayerEvent event) {
    if (event.betterPlayerEventType == BetterPlayerEventType.finished) {
      _handleFinishedPlayback();
      return;
    }
    final controller = _playerController.videoPlayerController;
    if (controller == null) return;
    final value = controller.value;
    if (!value.initialized) return;
    final duration = value.duration;
    if (duration == null || duration.inMilliseconds <= 0) return;
    if (!_initialSeekApplied &&
        _resumeFraction > 0.01 &&
        _resumeFraction < 0.99) {
      _initialSeekApplied = true;
      final targetMillis = (duration.inMilliseconds * _resumeFraction).round();
      final target = Duration(milliseconds: targetMillis);
      _playerController.seekTo(target);
    }
    final position = value.position ?? Duration.zero;
    final progress = (position.inMilliseconds / duration.inMilliseconds).clamp(
      0.0,
      1.0,
    );
    if (!mounted) return;
    if (progress != _playbackProgress) {
      setState(() => _playbackProgress = progress);
    }
    if (progress >= 0.98 && !_autoMarked && !widget.lecture.isCompleted) {
      _autoMarked = true;
      unawaited(_markComplete(silent: true));
    }
  }

  double _currentPlaybackPercent() {
    final controller = _playerController.videoPlayerController;
    if (controller == null) return _playbackProgress * 100;
    final value = controller.value;
    if (!value.initialized) return _playbackProgress * 100;
    final duration = value.duration;
    if (duration == null || duration.inMilliseconds == 0) {
      return _playbackProgress * 100;
    }
    final position = value.position ?? Duration.zero;
    final fraction = (position.inMilliseconds / duration.inMilliseconds).clamp(
      0.0,
      1.0,
    );
    return (fraction * 100).clamp(0.0, 100.0).toDouble();
  }

  ({double percent, double currentTimeSec, double durationSec}) _snapshot() {
    final controller = _playerController.videoPlayerController;
    if (controller == null) {
      return (
        percent: _playbackProgress * 100,
        currentTimeSec: 0,
        durationSec: 0,
      );
    }
    final value = controller.value;
    if (!value.initialized) {
      return (
        percent: _playbackProgress * 100,
        currentTimeSec: 0,
        durationSec: 0,
      );
    }
    final duration = value.duration ?? Duration.zero;
    final position = value.position ?? Duration.zero;
    final durationMs = duration.inMilliseconds <= 0
        ? 0
        : duration.inMilliseconds;
    final positionMs = position.inMilliseconds.clamp(0, durationMs);
    final fraction = durationMs == 0 ? 0 : positionMs / durationMs;
    return (
      percent: (fraction * 100).clamp(0.0, 100.0).toDouble(),
      currentTimeSec: positionMs / 1000,
      durationSec: durationMs / 1000,
    );
  }

  Future<bool> _markComplete({bool silent = false}) async {
    if (_isCompleting) return false;
    if (widget.lecture.id.trim().isEmpty) {
      if (!silent) {
        await showAppErrorDialog(
          title: 'Lecture',
          message: 'Unable to mark this lecture complete.',
        );
      }
      return false;
    }
    setState(() => _isCompleting = true);
    try {
      final snapshot = _snapshot();
      final percent = snapshot.percent;
      await _service.markLectureComplete(
        courseId: widget.courseId,
        lectureId: widget.lecture.id,
        watchedPercent: percent,
        currentTimeSec: snapshot.currentTimeSec,
        durationSec: snapshot.durationSec,
      );
      if (mounted) {
        setState(() {
          _isMarkedComplete = true;
          _playbackProgress = 1.0;
        });
      }
      _lastReportedProgress = 100;
      widget.onCompleted?.call();
      if (mounted && !silent) {
        await showAppSuccessDialog(
          title: 'Completed',
          message: 'Lecture marked as complete.',
        );
      }
      return true;
    } on ApiException catch (e) {
      if (mounted && !silent) {
        await showAppErrorDialog(title: 'Lecture', message: e.message);
      }
      return false;
    } catch (_) {
      if (mounted && !silent) {
        await showAppErrorDialog(
          title: 'Lecture',
          message: 'Unable to mark as complete. Please try again.',
        );
      }
      return false;
    } finally {
      if (mounted) {
        setState(() => _isCompleting = false);
      }
    }
  }

  Future<void> _handleFinishedPlayback() async {
    if (_finishHandled) return;
    _finishHandled = true;
    _playerController.pause();
    final wasComplete = _isMarkedComplete || widget.lecture.isCompleted;
    if (!wasComplete) {
      await _markComplete(silent: true);
    }
    if (!mounted) return;
    await showAppSuccessDialog(
      title: 'Lecture Completed',
      message: 'You have completely watched this lecture.',
    );
    if (mounted) {
      Get.back();
    }
  }

  Future<void> _reportProgressIfNeeded() async {
    if (_isReportingProgress) return;
    if (_isMarkedComplete || widget.lecture.isCompleted) return;
    final snapshot = _snapshot();
    final percent = snapshot.percent;
    if (percent <= 0) return;
    if (percent <= _lastReportedProgress + 1) return;
    _isReportingProgress = true;
    _lastReportedProgress = percent;
    try {
      await _service.reportLectureProgress(
        courseId: widget.courseId,
        lectureId: widget.lecture.id,
        watchedPercent: percent,
        currentTimeSec: snapshot.currentTimeSec,
        durationSec: snapshot.durationSec,
      );
      widget.onCompleted?.call();
    } catch (_) {
      // Best-effort: ignore progress report errors.
    } finally {
      _isReportingProgress = false;
    }
  }

  Future<void> _handleBack() async {
    await _reportProgressIfNeeded();
    if (mounted) {
      Get.back();
    }
  }

  @override
  Widget build(BuildContext context) {
    final textColor = SumAcademyTheme.darkBase;
    final storedProgress = widget.lecture.isCompleted
        ? (widget.lecture.canRewatch ? 0.0 : 1.0)
        : (widget.lecture.progress >= 0.98
              ? 0.0
              : (widget.lecture.progress > 0 ? widget.lecture.progress : 0.0));
    final progressValue = _playbackProgress > storedProgress
        ? _playbackProgress
        : storedProgress;
    final progressPercent = (progressValue * 100).clamp(0, 100).round();
    final isCompleted =
        _isMarkedComplete || widget.lecture.isCompleted || progressValue >= 1;
    final canMarkComplete = _playbackProgress >= 0.8;

    return WillPopScope(
      onWillPop: () async {
        await _reportProgressIfNeeded();
        return true;
      },
      child: Scaffold(
        body: SafeArea(
          child: ListView(
            padding: EdgeInsets.fromLTRB(20.w, 12.h, 20.w, 24.h),
            physics: const AlwaysScrollableScrollPhysics(
              parent: BouncingScrollPhysics(),
            ),
            children: [
              Row(
                children: [
                  IconButton(
                    onPressed: _handleBack,
                    icon: Icon(Icons.arrow_back_rounded, color: textColor),
                  ),
                  Expanded(
                    child: Text(
                      widget.lecture.title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: textColor,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 12.h),
              ClipRRect(
                borderRadius: BorderRadius.circular(16.r),
                child: BetterPlayer(controller: _playerController),
              ),
              SizedBox(height: 16.h),
              Container(
                padding: EdgeInsets.all(14.r),
                decoration: BoxDecoration(
                  color: SumAcademyTheme.white,
                  borderRadius: BorderRadius.circular(16.r),
                  border: Border.all(color: SumAcademyTheme.brandBluePale),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Lecture progress',
                      style: Theme.of(context).textTheme.labelLarge?.copyWith(
                        color: textColor,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    SizedBox(height: 10.h),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(10.r),
                      child: LinearProgressIndicator(
                        value: progressValue,
                        minHeight: 6.h,
                        backgroundColor: SumAcademyTheme.brandBluePale,
                        valueColor: const AlwaysStoppedAnimation(
                          SumAcademyTheme.brandBlue,
                        ),
                      ),
                    ),
                    SizedBox(height: 6.h),
                    Text(
                      '$progressPercent% completed',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: textColor.withOpacityFloat(0.6),
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 18.h),
              SizedBox(
                height: 48.h,
                child: ElevatedButton(
                  onPressed: _isCompleting || isCompleted || !canMarkComplete
                      ? null
                      : _markComplete,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: SumAcademyTheme.brandBlue,
                    foregroundColor: SumAcademyTheme.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(18.r),
                    ),
                  ),
                  child: Text(
                    _isCompleting
                        ? 'Marking...'
                        : isCompleted
                        ? 'Completed'
                        : canMarkComplete
                        ? 'Mark as Complete'
                        : 'Watch 80% to complete',
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
