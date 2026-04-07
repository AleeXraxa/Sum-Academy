import 'package:sum_academy/core/services/api_client.dart';
import 'package:sum_academy/core/services/api_exception.dart';
import 'package:sum_academy/modules/student/models/student_course_progress.dart';

class StudentCourseProgressService {
  StudentCourseProgressService({ApiClient? client})
      : _client = client ?? ApiClient();

  final ApiClient _client;

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
      return contentProgress;
    }
    return _mergeProgress(contentProgress, progressData);
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
    await _patchWithFallback(
      subjectPath:
          '/student/subjects/$courseId/lectures/$lectureId/progress',
      coursePath:
          '/student/courses/$courseId/lectures/$lectureId/progress',
      body: body,
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
    return _getWithFallback(
      subjectPath: '/student/subjects/$courseId/progress',
      coursePath: '/student/courses/$courseId/progress',
    );
  }

  Future<Map<String, dynamic>> _getWithFallback({
    required String subjectPath,
    required String coursePath,
  }) async {
    try {
      return await _client.get(subjectPath, auth: true);
    } on ApiException catch (e) {
      if (_shouldFallback(e)) {
        return _client.get(coursePath, auth: true);
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
          isLocked: override.isLocked || lecture.isLocked,
          canRewatch: override.canRewatch || lecture.canRewatch,
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
