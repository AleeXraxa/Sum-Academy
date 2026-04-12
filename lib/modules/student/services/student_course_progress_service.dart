import 'package:flutter/foundation.dart';
import 'package:sum_academy/core/services/api_client.dart';
import 'package:sum_academy/core/services/api_exception.dart';
import 'package:sum_academy/modules/student/models/student_course_progress.dart';
import 'package:sum_academy/modules/student/models/student_session.dart';
import 'package:sum_academy/modules/student/services/student_sessions_service.dart';

class StudentCourseProgressService {
  StudentCourseProgressService({ApiClient? client})
      : _client = client ?? ApiClient();

  final ApiClient _client;
  final StudentSessionsService _sessionsService = StudentSessionsService();

  Future<StudentCourseProgress> fetchProgress(String courseId) async {
    if (courseId.trim().isEmpty) {
      return StudentCourseProgress.empty();
    }
    final contentResponse = await _fetchContent(courseId);
    final contentPayload = contentResponse['data'] ?? contentResponse;
    final contentProgress = StudentCourseProgress.fromAny(contentPayload);

    StudentCourseProgress? progressData;
    try {
      final progressResponse = await _fetchProgress(courseId);
      final progressPayload = progressResponse['data'] ?? progressResponse;
      progressData = StudentCourseProgress.fromAny(progressPayload);
    } catch (_) {
      progressData = null;
    }

    if (progressData == null || progressData.isEmpty) {
      return _applySessionTiming(contentProgress);
    }
    final merged = _mergeProgress(contentProgress, progressData);
    return _applySessionTiming(merged);
  }

  Future<void> markLectureComplete({
    required String courseId,
    required String lectureId,
    required double watchedPercent,
    required double currentTimeSec,
    required double durationSec,
  }) async {
    if (courseId.trim().isEmpty || lectureId.trim().isEmpty) {
      return;
    }
    final body = {
      'watchedPercent': watchedPercent,
      'currentTimeSec': currentTimeSec,
      'duration': durationSec,
      'durationSec': durationSec,
    };
    if (kDebugMode) {
      debugPrint(
        'Lecture complete payload -> courseId=$courseId lectureId=$lectureId '
        'body=$body',
      );
    }
    await _postWithFallback(
      subjectPath:
          '/student/subjects/$courseId/lectures/$lectureId/complete',
      coursePath:
          '/student/courses/$courseId/lectures/$lectureId/complete',
      body: body,
    );
  }

  Future<void> reportLectureProgress({
    required String courseId,
    required String lectureId,
    required double watchedPercent,
    required double currentTimeSec,
    required double durationSec,
  }) async {
    if (courseId.trim().isEmpty || lectureId.trim().isEmpty) {
      return;
    }
    final body = {
      'watchedPercent': watchedPercent,
      'currentTimeSec': currentTimeSec,
      'duration': durationSec,
      'durationSec': durationSec,
    };
    if (kDebugMode) {
      debugPrint(
        'Lecture progress payload -> courseId=$courseId lectureId=$lectureId '
        'body=$body',
      );
    }
    await _patchWithFallback(
      subjectPath:
          '/student/subjects/$courseId/lectures/$lectureId/progress',
      coursePath:
          '/student/courses/$courseId/lectures/$lectureId/progress',
      body: body,
    );
  }

  Future<StudentCourseProgress> _applySessionTiming(
    StudentCourseProgress progress,
  ) async {
    if (progress.chapters.isEmpty) return progress;

    final sessionIds = <String>{};
    for (final chapter in progress.chapters) {
      for (final lecture in chapter.lectures) {
        if (!lecture.isLiveSession) continue;
        if (lecture.sessionId.trim().isEmpty) continue;
        sessionIds.add(lecture.sessionId.trim());
      }
    }
    if (sessionIds.isEmpty) return progress;

    final sessionMap = <String, StudentSession>{};
    await Future.wait(
      sessionIds.map((id) async {
        try {
          final session = await _sessionsService.fetchSession(id);
          if (session.id.isNotEmpty) {
            sessionMap[id] = session;
          }
        } catch (_) {}
      }),
    );
    if (sessionMap.isEmpty) return progress;

    final updatedChapters = progress.chapters
        .map((chapter) {
          final updatedLectures = chapter.lectures.map((lecture) {
            final session = sessionMap[lecture.sessionId];
            if (session == null) return lecture;
            final recordingUrl = session.recordingUrl.trim();
            final completedFromSession = session.lectureCompleted == true;
            final fallbackEnded = lecture.endsAt != null
                ? DateTime.now().isAfter(lecture.endsAt!)
                : false;
            final effectiveEnded = session.hasEnded || fallbackEnded;
            final shouldUseRecording =
                recordingUrl.isNotEmpty && effectiveEnded;
            final mergedCompleted = lecture.isCompleted || completedFromSession;
            final mergedProgress = mergedCompleted ? 1.0 : lecture.progress;
            final mergedIsLocked = effectiveEnded
                ? session.isLocked
                : (session.isLocked
                    ? true
                    : (completedFromSession ? false : lecture.isLocked));
            final mergedCanRewatch = effectiveEnded
                ? !mergedIsLocked
                : (lecture.canRewatch || (shouldUseRecording && mergedCompleted));
            return StudentCourseLecture(
              id: lecture.id,
              title: lecture.title,
              duration: lecture.duration,
              isCompleted: mergedCompleted,
              progress: mergedProgress,
              // After session ends, we prefer the recording URL for playback.
              videoUrl: shouldUseRecording ? recordingUrl : lecture.videoUrl,
              videoMode: lecture.videoMode,
              // Once the live session ends, treat it as a normal lecture in course content.
              isLiveSession: lecture.isLiveSession && !effectiveEnded,
              sessionId: lecture.sessionId,
              joinOpensAt: session.joinOpensAt ?? lecture.joinOpensAt,
              startsAt: session.startAt ?? lecture.startsAt,
              endsAt: session.endAt ?? lecture.endsAt,
              isLocked: mergedIsLocked,
              canRewatch: mergedCanRewatch,
              lockAfterCompletion: lecture.lockAfterCompletion,
              lockReason: lecture.lockReason,
            );
          }).toList();
          return StudentCourseChapter(
            title: chapter.title,
            lectures: updatedLectures,
          );
        })
        .toList();

    return StudentCourseProgress(
      courseId: progress.courseId,
      progress: progress.progress,
      completedLectures: progress.completedLectures,
      totalLectures: progress.totalLectures,
      chapters: updatedChapters,
    );
  }
}

extension on StudentCourseProgressService {
  Future<Map<String, dynamic>> _fetchContent(String courseId) async {
    return _getWithFallback(
      subjectPath: '/student/subjects/$courseId/content',
      coursePath: '/student/courses/$courseId/content',
    );
  }

  Future<Map<String, dynamic>> _fetchProgress(String courseId) async {
    // Backend docs expose only /student/courses/:courseId/progress.
    // Some parts of the app pass a subjectId as "courseId" (class-based access),
    // in which case the backend may return 403. We treat that as "no progress"
    // and rely on the content payload progress instead.
    try {
      return await _client.get('/student/courses/$courseId/progress', auth: true);
    } on ApiException catch (e) {
      if ((e.statusCode ?? 0) == 403 &&
          e.message.toLowerCase().contains('not enrolled')) {
        return const {};
      }
      rethrow;
    }
  }

  Future<Map<String, dynamic>> _getWithFallback({
    required String subjectPath,
    required String coursePath,
  }) async {
    try {
      return await _client.get(subjectPath, auth: true);
    } on ApiException catch (e) {
      if (_shouldFallback(e)) {
        try {
          return await _client.get(coursePath, auth: true);
        } on ApiException catch (e2) {
          // Common case in this app: UI treats "subjectId" as "courseId" and hits
          // the /student/courses/... fallback with a subject id, which the backend
          // correctly rejects with 403. This is read-only and shouldn't block UI.
          if ((e2.statusCode ?? 0) == 403 &&
              e2.message.toLowerCase().contains('not enrolled')) {
            return const {};
          }
          rethrow;
        }
      }
      rethrow;
    }
  }

  Future<void> _postWithFallback({
    required String subjectPath,
    required String coursePath,
    required Map<String, dynamic> body,
  }) async {
    try {
      await _client.post(subjectPath, auth: true, body: body);
    } on ApiException catch (e) {
      if (_shouldFallback(e)) {
        await _client.post(coursePath, auth: true, body: body);
        return;
      }
      rethrow;
    }
  }

  Future<void> _patchWithFallback({
    required String subjectPath,
    required String coursePath,
    required Map<String, dynamic> body,
  }) async {
    try {
      await _client.patch(subjectPath, auth: true, body: body);
    } on ApiException catch (e) {
      if (_shouldFallback(e)) {
        await _client.patch(coursePath, auth: true, body: body);
        return;
      }
      rethrow;
    }
  }

  bool _shouldFallback(ApiException error) {
    final status = error.statusCode ?? 0;
    if (status == 404) return true;
    final message = error.message.toLowerCase();
    // Some deployments respond with HTML (200) on unknown/blocked routes.
    // In that case, try the alternate (course vs subject) route.
    if (status == 200 && message.contains('unexpected server response')) {
      return true;
    }
    return message.contains('not found') ||
        message.contains('route') ||
        message.contains('endpoint');
  }
}

StudentCourseProgress _mergeProgress(
  StudentCourseProgress content,
  StudentCourseProgress progress,
) {
  if (content.chapters.isEmpty) return progress;

  final progressLectureMap = <String, StudentCourseLecture>{};
  for (final chapter in progress.chapters) {
    for (final lecture in chapter.lectures) {
      final key = lecture.id.isNotEmpty
          ? lecture.id
          : lecture.title.toLowerCase();
      progressLectureMap[key] = lecture;
    }
  }

  final mergedChapters = content.chapters
      .map((chapter) {
        final mergedLectures = chapter.lectures.map((lecture) {
          final key = lecture.id.isNotEmpty
              ? lecture.id
              : lecture.title.toLowerCase();
          final override = progressLectureMap[key];
          if (override == null) {
            return lecture;
          }
        return StudentCourseLecture(
          id: lecture.id.isNotEmpty ? lecture.id : override.id,
          title: lecture.title,
          duration:
              lecture.duration.isNotEmpty ? lecture.duration : override.duration,
          isCompleted: override.isCompleted || lecture.isCompleted,
          progress: override.progress > 0 ? override.progress : lecture.progress,
          videoUrl:
              lecture.videoUrl.isNotEmpty ? lecture.videoUrl : override.videoUrl,
          videoMode:
              lecture.videoMode.isNotEmpty ? lecture.videoMode : override.videoMode,
          isLiveSession: lecture.isLiveSession || override.isLiveSession,
          sessionId:
              lecture.sessionId.isNotEmpty ? lecture.sessionId : override.sessionId,
          joinOpensAt: lecture.joinOpensAt ?? override.joinOpensAt,
          startsAt: lecture.startsAt ?? override.startsAt,
          endsAt: lecture.endsAt ?? override.endsAt,
          isLocked: (override.canRewatch || lecture.canRewatch)
              ? false
              : (override.isLocked || lecture.isLocked),
          canRewatch: override.canRewatch || lecture.canRewatch,
          lockAfterCompletion:
              override.lockAfterCompletion && lecture.lockAfterCompletion,
          lockReason:
              lecture.lockReason.isNotEmpty ? lecture.lockReason : override.lockReason,
        );
        }).toList();
        return StudentCourseChapter(
          title: chapter.title,
          lectures: mergedLectures,
        );
      })
      .toList();

  final totalLectures = progress.totalLectures > 0
      ? progress.totalLectures
      : content.totalLectures;
  final completedLectures = progress.completedLectures > 0
      ? progress.completedLectures
      : content.completedLectures;
  final progressValue =
      progress.progress > 0 ? progress.progress : content.progress;

  return StudentCourseProgress(
    courseId: content.courseId.isNotEmpty ? content.courseId : progress.courseId,
    progress: progressValue,
    completedLectures: completedLectures,
    totalLectures: totalLectures,
    chapters: mergedChapters,
  );
}
