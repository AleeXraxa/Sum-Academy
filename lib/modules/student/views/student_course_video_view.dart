import 'package:better_player/better_player.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:sum_academy/app/theme.dart';
import 'package:sum_academy/core/services/secure_screen_service.dart';
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
  late final void Function(BetterPlayerEvent event) _eventListener;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      SecureScreenService.enable();
    });
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
  }

  @override
  void dispose() {
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
    }
  }

  void _handlePlayerEvent(BetterPlayerEvent event) {
    final controller = _playerController.videoPlayerController;
    if (controller == null) return;
    final value = controller.value;
    if (!value.initialized) return;
    final duration = value.duration;
    if (duration == null || duration.inMilliseconds <= 0) return;
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
      _markComplete(silent: true);
    }
  }

  Future<void> _markComplete({bool silent = false}) async {
    if (_isCompleting) return;
    if (widget.lecture.id.trim().isEmpty) {
      if (!silent) {
        await showAppErrorDialog(
          title: 'Lecture',
          message: 'Unable to mark this lecture complete.',
        );
      }
      return;
    }
    setState(() => _isCompleting = true);
    try {
      await _service.markLectureComplete(
        courseId: widget.courseId,
        lectureId: widget.lecture.id,
      );
      widget.onCompleted?.call();
      if (mounted && !silent) {
        await showAppSuccessDialog(
          title: 'Completed',
          message: 'Lecture marked as complete.',
        );
      }
    } catch (_) {
      if (mounted && !silent) {
        await showAppErrorDialog(
          title: 'Lecture',
          message: 'Unable to mark as complete. Please try again.',
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isCompleting = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final textColor = SumAcademyTheme.darkBase;
    final storedProgress = widget.lecture.progress > 0
        ? widget.lecture.progress
        : (widget.lecture.isCompleted ? 1.0 : 0.0);
    final progressValue = _playbackProgress > storedProgress
        ? _playbackProgress
        : storedProgress;
    final progressPercent = (progressValue * 100).clamp(0, 100).round();
    final isCompleted = widget.lecture.isCompleted || progressValue >= 1;
    final canMarkComplete = progressValue >= 0.8;

    return Scaffold(
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
                  onPressed: () => Get.back(),
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
    );
  }
}
