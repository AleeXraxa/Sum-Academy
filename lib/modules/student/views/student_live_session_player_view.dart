import 'dart:async';

import 'package:better_player/better_player.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:sum_academy/app/theme.dart';
import 'package:sum_academy/core/services/secure_screen_service.dart';
import 'package:sum_academy/core/utils/network_error.dart';
import 'package:sum_academy/modules/student/controllers/student_live_sessions_controller.dart';
import 'package:sum_academy/modules/student/controllers/student_courses_controller.dart';
import 'package:sum_academy/modules/student/controllers/student_shell_controller.dart';
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
  final int initialSeekSeconds;

  const StudentLiveSessionPlayerView({
    super.key,
    required this.session,
    required this.playbackUrl,
    this.initialSeekSeconds = 0,
  });

  @override
  State<StudentLiveSessionPlayerView> createState() =>
      _StudentLiveSessionPlayerViewState();
}

class _StudentLiveSessionPlayerViewState extends State<StudentLiveSessionPlayerView>
    with WidgetsBindingObserver {
  BetterPlayerController? _playerController;
  late final void Function(BetterPlayerEvent event) _eventListener;
  bool _finishHandled = false;
  bool _initialSeekApplied = false;
  Timer? _statusTimer;
  int _joinedCount = 0;
  int _totalStudents = 0;
  int _elapsedSeconds = 0;
  int _remainingSeconds = 0;

  String _status = '';
  DateTime? _openedAt;
  int _maxPositionMs = 0;
  int _durationMs = 0;
  bool _startupErrorShown = false;
  String _lastPlayerError = '';


  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _openedAt = DateTime.now();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      SecureScreenService.enable();
    });

    _joinedCount = widget.session.joinedCount;
    _totalStudents = widget.session.totalStudents;
    _elapsedSeconds = widget.session.elapsedSeconds;
    _remainingSeconds = widget.session.remainingSeconds;
    _status = widget.session.status;

    _eventListener = _handlePlayerEvent;
    unawaited(_initPlayer());

    if (!widget.session.isClientComputed) {
      _statusTimer = Timer.periodic(const Duration(seconds: 10), (_) async {
        if (!mounted) return;
        if (!Get.isRegistered<StudentLiveSessionsController>()) return;
        final controller = Get.find<StudentLiveSessionsController>();
        try {
          final latest = await controller.fetchSessionStatus(widget.session.id);
          if (!mounted) return;
          setState(() {
            _joinedCount = latest.joinedCount;
            _totalStudents = latest.totalStudents;
            _elapsedSeconds = latest.elapsedSeconds;
            _remainingSeconds = latest.remainingSeconds;
            _status = latest.status;
          });
        } catch (_) {}
      });
    }

  }

  Future<void> _initPlayer() async {
    final headers = await _maybeAuthHeaders(widget.playbackUrl);
    if (kDebugMode) {
      debugPrint(
        'Live player init -> url=${widget.playbackUrl} '
        'headers=${headers == null ? 'none' : headers.keys.join(',')}',
      );
    }
    final uri = Uri.tryParse(widget.playbackUrl);
    BetterPlayerVideoFormat? formatHint;
    final path = uri?.path.toLowerCase() ?? '';
    if (path.endsWith('.m3u8')) {
      formatHint = BetterPlayerVideoFormat.hls;
    } else if (path.endsWith('.mpd')) {
      formatHint = BetterPlayerVideoFormat.dash;
    } else if (path.endsWith('.mp4') || path.endsWith('.m4v')) {
      formatHint = BetterPlayerVideoFormat.other;
    }

    if (!mounted) return;
    final isLiveStream = widget.session.isLive &&
        (formatHint == BetterPlayerVideoFormat.hls ||
            formatHint == BetterPlayerVideoFormat.dash) &&
        widget.session.status.toLowerCase() == 'active';
    final bufferingConfig = isLiveStream
        ? const BetterPlayerBufferingConfiguration(
            minBufferMs: 20000,
            maxBufferMs: 100000,
            bufferForPlaybackMs: 1200,
            bufferForPlaybackAfterRebufferMs: 2500,
          )
        : const BetterPlayerBufferingConfiguration(
            minBufferMs: 15000,
            maxBufferMs: 60000,
            bufferForPlaybackMs: 1000,
            bufferForPlaybackAfterRebufferMs: 2500,
          );
    final controller = BetterPlayerController(
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
          // Ensure our custom controls don't auto-hide.
          controlsHideTime: const Duration(days: 365),
        ),
      ),
      betterPlayerDataSource: BetterPlayerDataSource(
        BetterPlayerDataSourceType.network,
        widget.playbackUrl,
        headers: headers,
        liveStream: isLiveStream,
        videoFormat: formatHint,
        bufferingConfiguration: bufferingConfig,
        cacheConfiguration: isLiveStream
            ? null
            : const BetterPlayerCacheConfiguration(
                useCache: true,
                maxCacheSize: 200 * 1024 * 1024,
                maxCacheFileSize: 50 * 1024 * 1024,
                preCacheSize: 5 * 1024 * 1024,
              ),
      ),
    );
    controller.addEventsListener(_eventListener);
    setState(() => _playerController = controller);
  }

  Future<Map<String, String>?> _maybeAuthHeaders(String url) async {
    final uri = Uri.tryParse(url);
    if (uri == null) return null;
    final needsAuth = (uri.path.contains('/api/') && uri.host.isNotEmpty);
    if (!needsAuth) return null;

    final user = FirebaseAuth.instance.currentUser;
    final token = await user?.getIdToken();
    if (kDebugMode) {
      debugPrint(
        'Live player auth -> needsAuth=true user=${user?.uid ?? 'null'} token=${token == null ? 'null' : 'present'}',
      );
    }
    if (token == null || token.isEmpty) return null;
    return {'Authorization': 'Bearer $token'};
  }

  @override
  void dispose() {
    SecureScreenService.disable();
    WidgetsBinding.instance.removeObserver(this);
    _statusTimer?.cancel();
    final controller = _playerController;
    if (controller != null) {
      controller.removeEventsListener(_eventListener);
      controller.dispose();
    }
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      SecureScreenService.enable();
    }
    if (state == AppLifecycleState.paused) {
      // Best-effort: keep session access consistent (backend may use this).
      unawaited(_leaveSession());
    }
    super.didChangeAppLifecycleState(state);
  }

  Future<void> _leaveSession() async {
    if (widget.session.isClientComputed) return;
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
    if (event.betterPlayerEventType == BetterPlayerEventType.exception) {
      _lastPlayerError = (event.parameters ?? const {}).toString();
      if (!_startupErrorShown) {
        _startupErrorShown = true;
        unawaited(
          showAppErrorDialog(
            title: 'Live Session',
            message:
                'Unable to start the live video. Please try again.',
          ),
        );
      }
      return;
    }
    if (event.betterPlayerEventType == BetterPlayerEventType.initialized) {
      if (_initialSeekApplied) return;
      final seconds = widget.initialSeekSeconds;
      if (seconds <= 0) {
        _initialSeekApplied = true;
        return;
      }
      _initialSeekApplied = true;
      final controller = _playerController;
      final vp = controller?.videoPlayerController;
      final dur = vp?.value.duration;
      if (controller != null && dur != null && dur.inMilliseconds > 0) {
        final target = Duration(seconds: seconds);
        // If the backend elapsedSeconds is larger than the actual video duration,
        // seeking past end will instantly finish. Clamp or skip the seek.
        if (target >= dur) {
          return;
        }
        unawaited(controller.seekTo(target));
      }
      return;
    }
    if (event.betterPlayerEventType == BetterPlayerEventType.progress) {
      final vp = _playerController?.videoPlayerController;
      final value = vp?.value;
      if (value != null && value.initialized) {
        final duration = value.duration;
        final position = value.position;
        if (duration != null) _durationMs = duration.inMilliseconds;
        if (position != null) {
          final posMs = position.inMilliseconds;
          if (posMs > _maxPositionMs) _maxPositionMs = posMs;
        }
      }
    }
    if (event.betterPlayerEventType != BetterPlayerEventType.finished) return;
    if (_finishHandled) return;
    // Guard: BetterPlayer can emit "finished" immediately if the stream fails or has zero duration.
    final openedAt = _openedAt ?? DateTime.now();
    final secondsSinceOpen = DateTime.now().difference(openedAt).inSeconds;
    final durationMs = _durationMs;
    final maxPosMs = _maxPositionMs;
    final durationOk = durationMs > 1500;
    final nearEnd = durationOk && maxPosMs >= (durationMs * 0.92).round();
    if (secondsSinceOpen < 3 && !nearEnd) {
      if (!_startupErrorShown) {
        _startupErrorShown = true;
        unawaited(
          showAppErrorDialog(
            title: 'Live Session',
            message: 'Unable to start the live video. Please try again.',
          ),
        );
      }
      return;
    }
    _finishHandled = true;
    unawaited(_handleFinished());
  }

  Future<void> _handleFinished() async {
    if (Get.isRegistered<StudentLiveSessionsController>()) {
      try {
        final controller = Get.find<StudentLiveSessionsController>();
        // Mark completion in liveSessionAccess (backend may store this flag).
        await controller.leaveSession(widget.session, lectureCompleted: true);
      } catch (_) {
        await _leaveSession();
      }
    } else {
      await _leaveSession();
    }
    if (!mounted) return;
    await showAppSuccessDialog(
      title: 'Live Session',
      message: 'You have completely watched this session.',
    );
    if (Get.isRegistered<StudentLiveSessionsController>()) {
      final controller = Get.find<StudentLiveSessionsController>();
      unawaited(controller.fetchSessions(silent: true));
    }
    // Refresh My Classes / Courses so the lecture can appear there after completion.
    // (Course content progress merges liveSessionAccess completion via session status.)
    if (Get.isRegistered<StudentCoursesController>()) {
      final courses = Get.find<StudentCoursesController>();
      unawaited(courses.fetchCourses(silent: true));
    }
    if (!mounted) return;
    _goToLiveSessionsRoot();
  }

  void _goToLiveSessionsRoot() {
    if (Get.isRegistered<StudentShellController>()) {
      final shell = Get.find<StudentShellController>();
      shell.navIndex.value = 1; // Live Session tab in StudentShellView
      shell.setActiveLabel('Live Session');
    }
    try {
      Get.until((route) {
        final name = route.settings.name ?? '';
        return name == '/StudentShellView' || route.isFirst;
      });
    } catch (_) {
      Get.back();
    }
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
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Premium Header
              Padding(
                padding: EdgeInsets.fromLTRB(20.w, 14.h, 20.w, 10.h),
                child: Row(
                  children: [
                    IconButton(
                      onPressed: () async {
                        await _leaveSession();
                        if (mounted) Get.back();
                      },
                      icon: Icon(Icons.arrow_back_rounded, color: textColor),
                      style: IconButton.styleFrom(
                        backgroundColor: isDark ? SumAcademyTheme.darkSurface : SumAcademyTheme.white,
                        padding: EdgeInsets.all(12.r),
                      ),
                    ),
                    SizedBox(width: 12.w),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            widget.session.topic.trim().isEmpty ? 'Live Interactive Session' : widget.session.topic.trim(),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                  color: textColor,
                                  fontWeight: FontWeight.w900,
                                  fontSize: 18.sp,
                                ),
                          ),
                          Text(
                            widget.session.batchCode,
                            style: Theme.of(context).textTheme.labelSmall?.copyWith(
                                  color: textColor.withOpacityFloat(0.5),
                                  fontWeight: FontWeight.w700,
                                ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              Expanded(
                child: ListView(
                  physics: const BouncingScrollPhysics(),
                  padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 10.h),
                  children: [
                    // Video Arena
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.black,
                        borderRadius: BorderRadius.circular(24.r),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacityFloat(0.2),
                            blurRadius: 30,
                            offset: const Offset(0, 15),
                          ),
                        ],
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(24.r),
                        child: Stack(
                          children: [
                            AspectRatio(
                              aspectRatio: 16 / 9,
                              child: _playerController == null
                                  ? Container(
                                      color: Colors.black,
                                      alignment: Alignment.center,
                                      child: Column(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          SizedBox(
                                            width: 28.r,
                                            height: 28.r,
                                            child: const CircularProgressIndicator(
                                              strokeWidth: 3,
                                              color: SumAcademyTheme.brandBlue,
                                            ),
                                          ),
                                          SizedBox(height: 12.h),
                                          Text(
                                            'Connecting to Studio...',
                                            style: TextStyle(
                                              color: Colors.white.withOpacityFloat(0.7),
                                              fontSize: 12.sp,
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                        ],
                                      ),
                                    )
                                  : BetterPlayer(controller: _playerController!),
                            ),
                            
                            // Live Badge Overlay
                            Positioned(
                              left: 12.w,
                              top: 12.h,
                              child: _LivePulseBadge(status: _status),
                            ),
                            
                            // Participant Count
                            if (_totalStudents > 0)
                              Positioned(
                                right: 12.w,
                                top: 12.h,
                                child: Container(
                                  padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 6.h),
                                  decoration: BoxDecoration(
                                    color: Colors.black.withOpacityFloat(0.5),
                                    borderRadius: BorderRadius.circular(10.r),
                                    border: Border.all(color: Colors.white.withOpacityFloat(0.1)),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(Icons.visibility_rounded, color: Colors.white, size: 14.sp),
                                      SizedBox(width: 6.w),
                                      Text(
                                        '$_joinedCount',
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 12.sp,
                                          fontWeight: FontWeight.w800,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ),
                    ),
                    
                    SizedBox(height: 24.h),
                    
                    // Rules Container (Modern Informational Banner)
                    Container(
                      padding: EdgeInsets.all(20.r),
                      decoration: BoxDecoration(
                        color: SumAcademyTheme.brandBlue.withOpacityFloat(0.05),
                        borderRadius: BorderRadius.circular(24.r),
                        border: Border.all(
                          color: SumAcademyTheme.brandBlue.withOpacityFloat(0.1),
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Container(
                                padding: EdgeInsets.all(8.r),
                                decoration: BoxDecoration(
                                  color: SumAcademyTheme.brandBlue.withOpacityFloat(0.1),
                                  shape: BoxShape.circle,
                                ),
                                child: Icon(Icons.info_outline_rounded, size: 18.sp, color: SumAcademyTheme.brandBlue),
                              ),
                              SizedBox(width: 12.w),
                              Text(
                                'SESSION PROTOCOL',
                                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                                      color: SumAcademyTheme.brandBlue,
                                      fontWeight: FontWeight.w900,
                                      letterSpacing: 1.5,
                                    ),
                              ),
                            ],
                          ),
                          SizedBox(height: 16.h),
                          _ProtocolItem(
                            icon: Icons.lock_clock_rounded,
                            text: 'Controls are locked during the live broadcast.',
                          ),
                          SizedBox(height: 12.h),
                          _ProtocolItem(
                            icon: Icons.exit_to_app_rounded,
                            text: 'Leaving this screen may disrupt your attendance.',
                          ),
                          SizedBox(height: 12.h),
                          _ProtocolItem(
                            icon: Icons.verified_user_rounded,
                            text: 'Keep this page open until the session concludes.',
                          ),
                        ],
                      ),
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
}

class _LivePulseBadge extends StatefulWidget {
  final String status;
  const _LivePulseBadge({required this.status});

  @override
  State<_LivePulseBadge> createState() => _LivePulseBadgeState();
}

class _LivePulseBadgeState extends State<_LivePulseBadge> with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isActive = widget.status.toLowerCase() == 'active';
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 6.h),
      decoration: BoxDecoration(
        color: Colors.black.withOpacityFloat(0.5),
        borderRadius: BorderRadius.circular(10.r),
        border: Border.all(color: Colors.white.withOpacityFloat(0.1)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          AnimatedBuilder(
            animation: _controller,
            builder: (context, child) {
              return Container(
                width: 8.r,
                height: 8.r,
                decoration: BoxDecoration(
                  color: isActive ? SumAcademyTheme.error : SumAcademyTheme.brandBlue,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: (isActive ? SumAcademyTheme.error : SumAcademyTheme.brandBlue).withOpacityFloat(0.5 * _controller.value),
                      blurRadius: 6 * _controller.value,
                      spreadRadius: 2 * _controller.value,
                    ),
                  ],
                ),
              );
            },
          ),
          SizedBox(width: 8.w),
          Text(
            'LIVE LECTURE',
            style: TextStyle(
              color: Colors.white,
              fontSize: 10.sp,
              fontWeight: FontWeight.w900,
              letterSpacing: 1,
            ),
          ),
        ],
      ),
    );
  }
}

class _ProtocolItem extends StatelessWidget {
  final IconData icon;
  final String text;
  const _ProtocolItem({required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 14.sp, color: SumAcademyTheme.brandBlue.withOpacityFloat(0.6)),
        SizedBox(width: 10.w),
        Expanded(
          child: Text(
            text,
            style: TextStyle(
              color: SumAcademyTheme.darkBase.withOpacityFloat(0.7),
              fontSize: 13.sp,
              fontWeight: FontWeight.w600,
              height: 1.4,
            ),
          ),
        ),
      ],
    );
  }
}
