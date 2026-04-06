import 'package:sum_academy/core/services/api_client.dart';
import 'package:sum_academy/modules/student/models/student_course_progress.dart';

class StudentCourseProgressService {
  StudentCourseProgressService({ApiClient? client})
      : _client = client ?? ApiClient();

  final ApiClient _client;

  Future<StudentCourseProgress> fetchProgress(String courseId) async {
    if (courseId.trim().isEmpty) {
      return StudentCourseProgress.empty();
    }
    final contentResponse = await _client.get(
      '/student/courses/$courseId/content',
      auth: true,
    );
    final contentPayload = contentResponse['data'] ?? contentResponse;
    final contentProgress = StudentCourseProgress.fromAny(contentPayload);

    StudentCourseProgress? progressData;
    try {
      final progressResponse = await _client.get(
        '/student/courses/$courseId/progress',
        auth: true,
      );
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
  }) async {
    if (courseId.trim().isEmpty || lectureId.trim().isEmpty) {
      return;
    }
    await _client.post(
      '/student/courses/$courseId/lectures/$lectureId/complete',
      auth: true,
    );
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
