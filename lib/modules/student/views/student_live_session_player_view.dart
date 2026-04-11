import 'dart:async';

import 'package:better_player/better_player.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:sum_academy/app/theme.dart';
import 'package:sum_academy/core/utils/network_error.dart';
import 'package:sum_academy/modules/student/controllers/student_live_sessions_controller.dart';
import 'package:sum_academy/modules/student/models/student_session.dart';

class _MinimalLiveControls extends StatelessWidget {
  final BetterPlayerController controller;

  const _MinimalLiveControls({required this.controller});

  @override
  Widget build(BuildContext context) {
    final video = controller.videoPlayerController;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final iconColor = Colors.white.withOpacityFloat(0.95);

    if (video == null) return const SizedBox.shrink();

    return ValueListenableBuilder(
      valueListenable: video,
      builder: (context, value, child) {
        final volume = value.volume;
        final isMuted = volume <= 0.001;

        return Stack(
          children: [
            Positioned(
              right: 8.w,
              bottom: 8.h,
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 4.h),
                decoration: BoxDecoration(
                  color: (isDark ? Colors.black : Colors.black)
                      .withOpacityFloat(0.35),
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      visualDensity: VisualDensity.compact,
                      padding: EdgeInsets.zero,
                      constraints: BoxConstraints.tight(Size(34.r, 34.r)),
                      icon: Icon(
                        isMuted ? Icons.volume_off_rounded : Icons.volume_up_rounded,
                        color: iconColor,
                        size: 18.sp,
                      ),
                      onPressed: () async {
                        final next = isMuted ? 1.0 : 0.0;
                        await controller.setVolume(next);
                      },
                    ),
                    SizedBox(width: 2.w),
                    IconButton(
                      visualDensity: VisualDensity.compact,
                      padding: EdgeInsets.zero,
                      constraints: BoxConstraints.tight(Size(34.r, 34.r)),
                      icon: Icon(
                        controller.isFullScreen
                            ? Icons.fullscreen_exit_rounded
                            : Icons.fullscreen_rounded,
                        color: iconColor,
                        size: 18.sp,
                      ),
                      onPressed: controller.toggleFullScreen,
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

class StudentLiveSessionPlayerView extends StatefulWidget {
  final StudentSession session;
  final String playbackUrl;

  const StudentLiveSessionPlayerView({
    super.key,
    required this.session,
    required this.playbackUrl,
  });

  @override
  State<StudentLiveSessionPlayerView> createState() =>
      _StudentLiveSessionPlayerViewState();
}

class _StudentLiveSessionPlayerViewState extends State<StudentLiveSessionPlayerView>
    with WidgetsBindingObserver {
  late final BetterPlayerController _playerController;
  late final void Function(BetterPlayerEvent event) _eventListener;
  bool _finishHandled = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);

    _playerController = BetterPlayerController(
      BetterPlayerConfiguration(
        autoPlay: true,
        fit: BoxFit.contain,
        aspectRatio: 16 / 9,
        allowedScreenSleep: false,
        controlsConfiguration: BetterPlayerControlsConfiguration(
          // Custom controls to avoid play/replay overlay.
          customControlsBuilder: (controller, onPlayerVisibilityChanged) {
            onPlayerVisibilityChanged(true);
            return _MinimalLiveControls(controller: controller);
          },
          playerTheme: BetterPlayerTheme.custom,
          showControls: true,
          showControlsOnInitialize: true,
          loadingWidget: SizedBox.shrink(),
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
          // Ensure our custom controls don't auto-hide.
          controlsHideTime: const Duration(days: 365),
        ),
      ),
      betterPlayerDataSource: BetterPlayerDataSource(
        BetterPlayerDataSourceType.network,
        widget.playbackUrl,
      ),
    );
    _eventListener = _handlePlayerEvent;
    _playerController.addEventsListener(_eventListener);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _playerController.removeEventsListener(_eventListener);
    _playerController.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused) {
      // Best-effort: keep session access consistent (backend may use this).
      unawaited(_leaveSession());
    }
    super.didChangeAppLifecycleState(state);
  }

  Future<void> _leaveSession() async {
    if (!Get.isRegistered<StudentLiveSessionsController>()) return;
    try {
      final controller = Get.find<StudentLiveSessionsController>();
      await controller.leaveSession(widget.session);
    } catch (_) {
      // Ignore (best-effort).
    }
  }

  void _handlePlayerEvent(BetterPlayerEvent event) {
    if (!mounted) return;
    if (event.betterPlayerEventType != BetterPlayerEventType.finished) return;
    if (_finishHandled) return;
    _finishHandled = true;
    unawaited(_handleFinished());
  }

  Future<void> _handleFinished() async {
    await _leaveSession();
    if (!mounted) return;
    await showAppSuccessDialog(
      title: 'Live Session',
      message: 'You have completely watched this session.',
    );
    if (Get.isRegistered<StudentLiveSessionsController>()) {
      final controller = Get.find<StudentLiveSessionsController>();
      unawaited(controller.fetchSessions(silent: true));
    }
    if (mounted) Get.back();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bg =
        isDark ? SumAcademyTheme.darkBase : SumAcademyTheme.surfaceSecondary;
    final textColor =
        isDark ? SumAcademyTheme.white : SumAcademyTheme.darkBase;

    return Scaffold(
      backgroundColor: bg,
      body: SafeArea(
        child: ListView(
          padding: EdgeInsets.fromLTRB(20.w, 10.h, 20.w, 26.h),
          children: [
            Row(
              children: [
                IconButton(
                  onPressed: () async {
                    await _leaveSession();
                    if (mounted) Get.back();
                  },
                  icon: Icon(Icons.arrow_back_rounded, color: textColor),
                ),
                Expanded(
                  child: Text(
                    widget.session.topic.trim().isEmpty
                        ? 'Live Session'
                        : widget.session.topic.trim(),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          color: textColor,
                          fontWeight: FontWeight.w800,
                        ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 10.h),
            ClipRRect(
              borderRadius: BorderRadius.circular(18.r),
              child: AspectRatio(
                aspectRatio: 16 / 9,
                child: BetterPlayer(controller: _playerController),
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
          ],
        ),
      ),
    );
  }
}
