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
  late final bool _isReplayLocked;
  static const int _seekStepSeconds = 10;
  Duration _currentPosition = Duration.zero;
  Duration _totalDuration = Duration.zero;
  double? _scrubValue;
  bool _isScrubbing = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      SecureScreenService.enable();
    });
    _isReplayLocked =
        widget.lecture.isCompleted && !widget.lecture.canRewatch;
    final rawProgress = widget.lecture.progress.clamp(0.0, 1.0);
    final canReplay = widget.lecture.canRewatch;
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
        autoPlay: !_isReplayLocked,
        fit: BoxFit.contain,
        aspectRatio: 16 / 9,
        allowedScreenSleep: false,
        controlsConfiguration: BetterPlayerControlsConfiguration(
          // Use custom controls to avoid default overlays and show only:
          // back/forward 10s + volume + fullscreen.
          playerTheme: BetterPlayerTheme.custom,
          showControls: true,
          showControlsOnInitialize: true,
          controlsHideTime: const Duration(days: 365),
          customControlsBuilder: (controller, onPlayerVisibilityChanged) {
            onPlayerVisibilityChanged(true);
            return _MinimalSeekControls(
              controller: controller,
              seekStepSeconds: _seekStepSeconds,
            );
          },
          loadingWidget: const SizedBox.shrink(),
          loadingColor: Colors.transparent,
          enableOverflowMenu: false,
          enablePlayPause: false,
          enableSkips: false,
          enableProgressText: false,
          enableProgressBar: false,
          enableProgressBarDrag: false,
          enableAudioTracks: false,
          enableSubtitles: false,
          enablePlaybackSpeed: false,
          enablePip: false,
          enableRetry: false,
          enableQualities: false,
          enableFullscreen: true,
          enableMute: true,
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
    if (_isReplayLocked) {
      WidgetsBinding.instance.addPostFrameCallback((_) async {
        await showAppErrorDialog(
          title: 'Lecture Locked',
          message:
              'This lecture is locked after completion. Ask admin to unlock for rewatch.',
        );
        if (mounted) {
          Get.back();
        }
      });
    }
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
    if (_isReplayLocked) return;
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
    final clampedPosition = position < Duration.zero
        ? Duration.zero
        : (position > duration ? duration : position);
    final progress = (position.inMilliseconds / duration.inMilliseconds).clamp(
      0.0,
      1.0,
    );
    if (!mounted) return;
    if (progress != _playbackProgress ||
        (!_isScrubbing && (_currentPosition != clampedPosition || _totalDuration != duration))) {
      setState(() {
        _playbackProgress = progress;
        if (!_isScrubbing) {
          _currentPosition = clampedPosition;
          _totalDuration = duration;
        } else {
          // Keep total duration fresh even while scrubbing.
          _totalDuration = duration;
        }
      });
    }
    if (progress >= 0.98 && !_autoMarked && !widget.lecture.isCompleted) {
      _autoMarked = true;
      unawaited(_markComplete(silent: true));
    }
  }

  String _formatClock(Duration duration) {
    final seconds = duration.inSeconds.clamp(0, 24 * 60 * 60);
    final h = seconds ~/ 3600;
    final m = (seconds % 3600) ~/ 60;
    final s = seconds % 60;
    if (h > 0) {
      return '${h.toString().padLeft(2, '0')}:${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}';
    }
    return '${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}';
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
    final durationMs =
        duration.inMilliseconds <= 0 ? 0 : duration.inMilliseconds;
    final positionMs = position.inMilliseconds.clamp(0, durationMs);
    final fallbackPercent = (_playbackProgress * 100).clamp(0.0, 100.0);
    final fraction = durationMs == 0 ? 0 : positionMs / durationMs;
    if (durationMs == 0) {
      return (
        percent: fallbackPercent.toDouble(),
        currentTimeSec: 0,
        durationSec: 0,
      );
    }
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
      var percent = snapshot.percent;
      if (percent <= 0 && _playbackProgress > 0) {
        percent = (_playbackProgress * 100).clamp(0.0, 100.0).toDouble();
      }
      if (_playbackProgress >= 0.98) {
        percent = 100;
      }
      var durationSec = snapshot.durationSec;
      var currentTimeSec = snapshot.currentTimeSec;
      if (durationSec <= 0 && percent > 0) {
        durationSec = 1;
        currentTimeSec = (percent / 100).clamp(0.0, 1.0);
      }
      await _service.markLectureComplete(
        courseId: widget.courseId,
        lectureId: widget.lecture.id,
        watchedPercent: percent,
        currentTimeSec: currentTimeSec,
        durationSec: durationSec,
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
    var percent = snapshot.percent;
    if (percent <= 0) return;
    if (percent <= _lastReportedProgress + 1) return;
    var durationSec = snapshot.durationSec;
    var currentTimeSec = snapshot.currentTimeSec;
    if (durationSec <= 0 && percent > 0) {
      durationSec = 1;
      currentTimeSec = (percent / 100).clamp(0.0, 1.0);
    }
    _isReportingProgress = true;
    _lastReportedProgress = percent;
    try {
      await _service.reportLectureProgress(
        courseId: widget.courseId,
        lectureId: widget.lecture.id,
        watchedPercent: percent,
        currentTimeSec: currentTimeSec,
        durationSec: durationSec,
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
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor =
        isDark ? SumAcademyTheme.white : SumAcademyTheme.darkBase;
    final surface = isDark ? SumAcademyTheme.darkSurface : SumAcademyTheme.white;
    final border =
        isDark ? SumAcademyTheme.darkBorder : SumAcademyTheme.brandBluePale;
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
    final statusLabel = isCompleted
        ? 'Completed'
        : progressPercent > 0
            ? 'In Progress'
            : 'Not Started';
    final statusColor =
        isCompleted ? SumAcademyTheme.success : SumAcademyTheme.brandBlue;

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
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 6.h),
                    decoration: BoxDecoration(
                      color: statusColor.withOpacityFloat(0.15),
                      borderRadius: BorderRadius.circular(14.r),
                      border: Border.all(
                        color: statusColor.withOpacityFloat(0.4),
                      ),
                    ),
                    child: Text(
                      statusLabel,
                      style: Theme.of(context).textTheme.labelSmall?.copyWith(
                            color: statusColor,
                            fontWeight: FontWeight.w600,
                          ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 14.h),
              Container(
                decoration: BoxDecoration(
                  color: surface,
                  borderRadius: BorderRadius.circular(18.r),
                  border: Border.all(color: border),
                  boxShadow: [
                    if (!isDark)
                      BoxShadow(
                        color: SumAcademyTheme.darkBase.withOpacityFloat(0.08),
                        blurRadius: 18,
                        offset: const Offset(0, 10),
                      ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(18.r),
                  child: AspectRatio(
                    aspectRatio: 16 / 9,
                    child: BetterPlayer(controller: _playerController),
                  ),
                ),
              ),
              SizedBox(height: 10.h),
              Container(
                padding: EdgeInsets.fromLTRB(14.w, 12.h, 14.w, 12.h),
                decoration: BoxDecoration(
                  color: surface,
                  borderRadius: BorderRadius.circular(16.r),
                  border: Border.all(color: border),
                ),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Text(
                          _formatClock(
                            _isScrubbing
                                ? Duration(
                                    milliseconds:
                                        ((_totalDuration.inMilliseconds) *
                                                (_scrubValue ?? 0))
                                            .round(),
                                  )
                                : _currentPosition,
                          ),
                          style: Theme.of(context).textTheme.labelSmall?.copyWith(
                                color: textColor.withOpacityFloat(0.75),
                                fontWeight: FontWeight.w700,
                              ),
                        ),
                        const Spacer(),
                        Text(
                          _formatClock(_totalDuration),
                          style: Theme.of(context).textTheme.labelSmall?.copyWith(
                                color: textColor.withOpacityFloat(0.75),
                                fontWeight: FontWeight.w700,
                              ),
                        ),
                      ],
                    ),
                    SizedBox(height: 6.h),
                    SliderTheme(
                      data: SliderTheme.of(context).copyWith(
                        trackHeight: 4.h,
                        overlayShape:
                            RoundSliderOverlayShape(overlayRadius: 16.r),
                        thumbShape:
                            RoundSliderThumbShape(enabledThumbRadius: 7.r),
                        activeTrackColor: SumAcademyTheme.brandBlue,
                        inactiveTrackColor:
                            SumAcademyTheme.brandBluePale.withOpacityFloat(0.9),
                        thumbColor: SumAcademyTheme.brandBlue,
                        overlayColor:
                            SumAcademyTheme.brandBlue.withOpacityFloat(0.12),
                      ),
                      child: Slider(
                        value: (_totalDuration.inMilliseconds <= 0)
                            ? 0
                            : (_isScrubbing
                                ? (_scrubValue ?? 0)
                                : (_currentPosition.inMilliseconds /
                                        _totalDuration.inMilliseconds)
                                    .clamp(0.0, 1.0)),
                        onChanged: (_totalDuration.inMilliseconds <= 0 || _isReplayLocked)
                            ? null
                            : (v) {
                                setState(() {
                                  _isScrubbing = true;
                                  _scrubValue = v;
                                });
                              },
                        onChangeEnd: (_totalDuration.inMilliseconds <= 0 || _isReplayLocked)
                            ? null
                            : (v) {
                                final targetMillis =
                                    (_totalDuration.inMilliseconds * v).round();
                                final target =
                                    Duration(milliseconds: targetMillis);
                                _playerController.seekTo(target);
                                setState(() {
                                  _isScrubbing = false;
                                  _scrubValue = null;
                                  _currentPosition = target;
                                });
                              },
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 16.h),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
                decoration: BoxDecoration(
                  color: surface,
                  borderRadius: BorderRadius.circular(16.r),
                  border: Border.all(color: border),
                  boxShadow: [
                    if (!isDark)
                      BoxShadow(
                        color: SumAcademyTheme.darkBase.withOpacityFloat(0.06),
                        blurRadius: 16,
                        offset: const Offset(0, 8),
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
                            'Lecture progress',
                            style:
                                Theme.of(context).textTheme.labelLarge?.copyWith(
                                      color: textColor,
                                      fontWeight: FontWeight.w600,
                                    ),
                          ),
                        ),
                        Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: 10.w,
                            vertical: 6.h,
                          ),
                          decoration: BoxDecoration(
                            color: SumAcademyTheme.brandBluePale,
                            borderRadius: BorderRadius.circular(12.r),
                          ),
                          child: Text(
                            '$progressPercent%',
                            style: Theme.of(context).textTheme.labelSmall?.copyWith(
                                  color: SumAcademyTheme.brandBlue,
                                  fontWeight: FontWeight.w600,
                                ),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 12.h),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(10.r),
                      child: LinearProgressIndicator(
                        value: progressValue,
                        minHeight: 7.h,
                        backgroundColor: SumAcademyTheme.brandBluePale,
                        valueColor: const AlwaysStoppedAnimation(
                          SumAcademyTheme.brandBlue,
                        ),
                      ),
                    ),
                    SizedBox(height: 8.h),
                    Row(
                      children: [
                        Icon(
                          Icons.play_circle_outline_rounded,
                          size: 16.sp,
                          color: textColor.withOpacityFloat(0.5),
                        ),
                        SizedBox(width: 6.w),
                        Text(
                          '$progressPercent% completed',
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                color: textColor.withOpacityFloat(0.6),
                              ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              SizedBox(height: 14.h),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 10.h),
                decoration: BoxDecoration(
                  color: SumAcademyTheme.brandBluePale,
                  borderRadius: BorderRadius.circular(14.r),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.lock_clock_rounded,
                      size: 16.sp,
                      color: SumAcademyTheme.brandBlue,
                    ),
                    SizedBox(width: 8.w),
                    Expanded(
                      child: Text(
                        'Watch at least 80% to unlock completion.',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: SumAcademyTheme.brandBlue,
                              fontWeight: FontWeight.w600,
                            ),
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 14.h),
              SizedBox(
                height: 48.h,
                child: ElevatedButton(
                  onPressed: _isCompleting || isCompleted || !canMarkComplete
                      ? null
                      : _markComplete,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: SumAcademyTheme.brandBlue,
                    foregroundColor: SumAcademyTheme.white,
                    disabledBackgroundColor:
                        SumAcademyTheme.brandBluePale,
                    disabledForegroundColor:
                        SumAcademyTheme.brandBlue.withOpacityFloat(0.6),
                    shape: RoundedRectangleBorder(
                      borderRadius:
                          BorderRadius.circular(SumAcademyTheme.radiusButton.r),
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

class _MinimalSeekControls extends StatelessWidget {
  final BetterPlayerController controller;
  final int seekStepSeconds;

  const _MinimalSeekControls({
    required this.controller,
    required this.seekStepSeconds,
  });

  @override
  Widget build(BuildContext context) {
    final video = controller.videoPlayerController;
    if (video == null) return const SizedBox.shrink();

    final isDark = Theme.of(context).brightness == Brightness.dark;
    final iconColor = Colors.white.withOpacityFloat(0.95);

    Future<void> seekBy(int deltaSeconds) async {
      final value = video.value;
      final current = value.position;
      final duration = value.duration ?? Duration.zero;
      final next = current + Duration(seconds: deltaSeconds);
      final clamped = next < Duration.zero
          ? Duration.zero
          : (duration != Duration.zero && next > duration ? duration : next);
      await controller.seekTo(clamped);
    }

    return ValueListenableBuilder(
      valueListenable: video,
      builder: (context, value, child) {
        final volume = value.volume;
        final isMuted = volume <= 0.001;
        final isPlaying = value.isPlaying;

        return Stack(
          children: [
            Positioned(
              left: 10.w,
              right: 10.w,
              bottom: 10.h,
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 6.h),
                decoration: BoxDecoration(
                  color: (isDark ? Colors.black : Colors.black)
                      .withOpacityFloat(0.35),
                  borderRadius: BorderRadius.circular(999),
                  border: Border.all(
                    color: Colors.white.withOpacityFloat(0.10),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          visualDensity: VisualDensity.compact,
                          padding: EdgeInsets.zero,
                          constraints: BoxConstraints.tight(Size(36.r, 36.r)),
                          icon: Icon(
                            Icons.replay_10_rounded,
                            color: iconColor,
                            size: 20.sp,
                          ),
                          onPressed: () => seekBy(-seekStepSeconds),
                        ),
                        SizedBox(width: 6.w),
                        IconButton(
                          visualDensity: VisualDensity.compact,
                          padding: EdgeInsets.zero,
                          constraints: BoxConstraints.tight(Size(36.r, 36.r)),
                          icon: Icon(
                            isPlaying
                                ? Icons.pause_circle_filled_rounded
                                : Icons.play_circle_fill_rounded,
                            color: iconColor,
                            size: 22.sp,
                          ),
                          onPressed: () async {
                            if (isPlaying) {
                              await controller.pause();
                            } else {
                              await controller.play();
                            }
                          },
                        ),
                        SizedBox(width: 6.w),
                        IconButton(
                          visualDensity: VisualDensity.compact,
                          padding: EdgeInsets.zero,
                          constraints: BoxConstraints.tight(Size(36.r, 36.r)),
                          icon: Icon(
                            Icons.forward_10_rounded,
                            color: iconColor,
                            size: 20.sp,
                          ),
                          onPressed: () => seekBy(seekStepSeconds),
                        ),
                      ],
                    ),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          visualDensity: VisualDensity.compact,
                          padding: EdgeInsets.zero,
                          constraints: BoxConstraints.tight(Size(36.r, 36.r)),
                          icon: Icon(
                            isMuted
                                ? Icons.volume_off_rounded
                                : Icons.volume_up_rounded,
                            color: iconColor,
                            size: 20.sp,
                          ),
                          onPressed: () async {
                            final next = isMuted ? 1.0 : 0.0;
                            await controller.setVolume(next);
                          },
                        ),
                        SizedBox(width: 6.w),
                        IconButton(
                          visualDensity: VisualDensity.compact,
                          padding: EdgeInsets.zero,
                          constraints: BoxConstraints.tight(Size(36.r, 36.r)),
                          icon: Icon(
                            controller.isFullScreen
                                ? Icons.fullscreen_exit_rounded
                                : Icons.fullscreen_rounded,
                            color: iconColor,
                            size: 20.sp,
                          ),
                          onPressed: controller.toggleFullScreen,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}
