import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:sum_academy/app/theme.dart';
import 'package:sum_academy/core/services/secure_screen_service.dart';
import 'package:sum_academy/modules/student/controllers/student_course_progress_controller.dart';
import 'package:sum_academy/modules/student/models/student_course_progress.dart';
import 'package:sum_academy/modules/student/services/student_course_progress_service.dart';

class StudentCourseDetailView extends StatefulWidget {
  final String courseId;
  final String title;
  final String teacher;
  final double progress;
  final String nextLecture;

  const StudentCourseDetailView({
    super.key,
    required this.courseId,
    required this.title,
    required this.teacher,
    required this.progress,
    required this.nextLecture,
  });

  @override
  State<StudentCourseDetailView> createState() =>
      _StudentCourseDetailViewState();
}

class _StudentCourseDetailViewState extends State<StudentCourseDetailView>
    with WidgetsBindingObserver {
  late final String _tag;

  @override
  void initState() {
    super.initState();
    _tag = widget.courseId.isNotEmpty
        ? 'course_${widget.courseId}'
        : 'course_${widget.title}';
    Get.put(
      StudentCourseProgressController(
        StudentCourseProgressService(),
        courseId: widget.courseId,
      ),
      tag: _tag,
    );
    WidgetsBinding.instance.addObserver(this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      SecureScreenService.enable();
    });
  }

  @override
  void dispose() {
    if (Get.isRegistered<StudentCourseProgressController>(tag: _tag)) {
      Get.delete<StudentCourseProgressController>(tag: _tag);
    }
    SecureScreenService.disable();
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      SecureScreenService.enable();
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor =
        isDark ? SumAcademyTheme.white : SumAcademyTheme.darkBase;

    return Scaffold(
      body: SafeArea(
        child: GetX<StudentCourseProgressController>(
          tag: _tag,
          builder: (controller) {
            final progress = controller.progress.value;
            final progressValue =
                progress.progress > 0 ? progress.progress : widget.progress;
            return RefreshIndicator(
              color: SumAcademyTheme.brandBlue,
              onRefresh: controller.refresh,
              child: ListView(
                padding: EdgeInsets.fromLTRB(20.w, 12.h, 20.w, 24.h),
                physics: const AlwaysScrollableScrollPhysics(
                  parent: BouncingScrollPhysics(),
                ),
                children: [
                  _HeaderRow(textColor: textColor, title: widget.title),
                  SizedBox(height: 16.h),
                  _CourseOverviewCard(
                    title: widget.title,
                    teacher: widget.teacher,
                    progress: progressValue,
                    nextLecture: widget.nextLecture,
                    completedLectures: progress.completedLectures,
                    totalLectures: progress.totalLectures,
                  ),
                  SizedBox(height: 18.h),
                  Text(
                    'Course Content',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          color: textColor,
                          fontWeight: FontWeight.w700,
                        ),
                  ),
                  SizedBox(height: 12.h),
                  if (controller.isLoading.value)
                    const _ContentSkeleton()
                  else if (controller.errorMessage.value.isNotEmpty)
                    _ErrorState(
                      message: controller.errorMessage.value,
                      onRetry: controller.load,
                    )
                  else if (progress.isEmpty)
                    const _EmptyContentState()
                  else
                    _ChaptersList(chapters: progress.chapters),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}

class _HeaderRow extends StatelessWidget {
  final Color textColor;
  final String title;

  const _HeaderRow({
    required this.textColor,
    required this.title,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        IconButton(
          onPressed: () => Get.back(),
          icon: Icon(
            Icons.arrow_back_rounded,
            color: textColor,
          ),
        ),
        Expanded(
          child: Text(
            title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  color: textColor,
                  fontWeight: FontWeight.w700,
                ),
          ),
        ),
      ],
    );
  }
}

class _CourseOverviewCard extends StatelessWidget {
  final String title;
  final String teacher;
  final double progress;
  final String nextLecture;
  final int completedLectures;
  final int totalLectures;

  const _CourseOverviewCard({
    required this.title,
    required this.teacher,
    required this.progress,
    required this.nextLecture,
    required this.completedLectures,
    required this.totalLectures,
  });

  @override
  Widget build(BuildContext context) {
    final progressPercent = (progress * 100).clamp(0, 100).round();
    final hasLectures = totalLectures > 0;

    return Container(
      padding: EdgeInsets.all(16.r),
      decoration: BoxDecoration(
        color: SumAcademyTheme.white,
        borderRadius: BorderRadius.circular(SumAcademyTheme.radiusCard.r),
        border: Border.all(color: SumAcademyTheme.brandBluePale),
        boxShadow: [
          BoxShadow(
            color: SumAcademyTheme.darkBase.withOpacityFloat(0.08),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: SumAcademyTheme.darkBase,
                  fontWeight: FontWeight.w700,
                ),
          ),
          SizedBox(height: 6.h),
          Text(
            teacher.isEmpty ? 'Instructor' : teacher,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: SumAcademyTheme.darkBase.withOpacityFloat(0.6),
                ),
          ),
          SizedBox(height: 12.h),
          Row(
            children: [
              Expanded(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(10.r),
                  child: LinearProgressIndicator(
                    value: progress,
                    minHeight: 6.h,
                    backgroundColor: SumAcademyTheme.brandBluePale,
                    valueColor: const AlwaysStoppedAnimation(
                      SumAcademyTheme.brandBlue,
                    ),
                  ),
                ),
              ),
              SizedBox(width: 10.w),
              Text(
                '$progressPercent%',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: SumAcademyTheme.darkBase.withOpacityFloat(0.7),
                    ),
              ),
            ],
          ),
          SizedBox(height: 12.h),
          Row(
            children: [
              if (hasLectures)
                _InfoPill(
                  label: '$completedLectures / $totalLectures completed',
                  color: SumAcademyTheme.success,
                  background: SumAcademyTheme.successLight,
                ),
              if (!hasLectures)
                _InfoPill(
                  label: 'Lectures syncing',
                  color: SumAcademyTheme.brandBlue,
                  background: SumAcademyTheme.brandBluePale,
                ),
              SizedBox(width: 10.w),
              Expanded(
                child: Text(
                  'Next lecture: ${nextLecture.isEmpty ? 'Resume learning' : nextLecture}',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: SumAcademyTheme.darkBase.withOpacityFloat(0.7),
                      ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _InfoPill extends StatelessWidget {
  final String label;
  final Color color;
  final Color background;

  const _InfoPill({
    required this.label,
    required this.color,
    required this.background,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 6.h),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(20.r),
      ),
      child: Text(
        label,
        style: Theme.of(context).textTheme.labelSmall?.copyWith(
              color: color,
              fontWeight: FontWeight.w600,
            ),
      ),
    );
  }
}

class _ChaptersList extends StatelessWidget {
  final List<StudentCourseChapter> chapters;

  const _ChaptersList({required this.chapters});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: chapters
          .asMap()
          .entries
          .map(
            (entry) => Padding(
              padding: EdgeInsets.only(bottom: 12.h),
              child: _ChapterCard(
                index: entry.key + 1,
                chapter: entry.value,
              ),
            ),
          )
          .toList(),
    );
  }
}

class _ChapterCard extends StatelessWidget {
  final int index;
  final StudentCourseChapter chapter;

  const _ChapterCard({
    required this.index,
    required this.chapter,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: SumAcademyTheme.white,
        borderRadius: BorderRadius.circular(SumAcademyTheme.radiusCard.r),
        border: Border.all(color: SumAcademyTheme.brandBluePale),
      ),
      child: Theme(
        data: Theme.of(context).copyWith(
          dividerColor: Colors.transparent,
        ),
        child: ExpansionTile(
          tilePadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 4.h),
          childrenPadding: EdgeInsets.only(
            left: 16.w,
            right: 16.w,
            bottom: 12.h,
          ),
          title: Text(
            chapter.title.isEmpty ? 'Chapter $index' : chapter.title,
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  color: SumAcademyTheme.darkBase,
                  fontWeight: FontWeight.w600,
                ),
          ),
          subtitle: Text(
            '${chapter.lectures.length} lectures',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: SumAcademyTheme.darkBase.withOpacityFloat(0.6),
                ),
          ),
          children: chapter.lectures
              .map(
                (lecture) => Padding(
                  padding: EdgeInsets.only(bottom: 10.h),
                  child: _LectureCard(lecture: lecture),
                ),
              )
              .toList(),
        ),
      ),
    );
  }
}

class _LectureCard extends StatelessWidget {
  final StudentCourseLecture lecture;

  const _LectureCard({required this.lecture});

  @override
  Widget build(BuildContext context) {
    final iconColor = lecture.isCompleted
        ? SumAcademyTheme.success
        : SumAcademyTheme.brandBlue;
    final progressValue = lecture.progress > 0
        ? lecture.progress
        : (lecture.isCompleted ? 1.0 : 0.0);
    final progressPercent = (progressValue * 100).clamp(0, 100).round();
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Container(
            padding: EdgeInsets.all(14.r),
            decoration: BoxDecoration(
              color: SumAcademyTheme.white,
              borderRadius: BorderRadius.circular(16.r),
              border: Border.all(color: SumAcademyTheme.brandBluePale),
              boxShadow: [
                BoxShadow(
                  color: SumAcademyTheme.darkBase.withOpacityFloat(0.05),
                  blurRadius: 12,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 44.r,
                  height: 44.r,
                  decoration: BoxDecoration(
                    color: iconColor.withOpacityFloat(0.15),
                    borderRadius: BorderRadius.circular(14.r),
                  ),
                  alignment: Alignment.center,
                  child: Icon(
                    lecture.isCompleted
                        ? Icons.check_circle_rounded
                        : Icons.play_arrow_rounded,
                    color: iconColor,
                    size: 22.sp,
                  ),
                ),
                SizedBox(width: 12.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        lecture.title,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: SumAcademyTheme.darkBase,
                              fontWeight: FontWeight.w600,
                            ),
                      ),
                      SizedBox(height: 6.h),
                      Row(
                        children: [
                          Expanded(
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(10.r),
                              child: LinearProgressIndicator(
                                value: progressValue,
                                minHeight: 6.h,
                                backgroundColor:
                                    SumAcademyTheme.brandBluePale,
                                valueColor: AlwaysStoppedAnimation(iconColor),
                              ),
                            ),
                          ),
                          SizedBox(width: 10.w),
                          Text(
                            '$progressPercent%',
                            style:
                                Theme.of(context).textTheme.bodySmall?.copyWith(
                                      color: SumAcademyTheme.darkBase
                                          .withOpacityFloat(0.7),
                                    ),
                          ),
                        ],
                      ),
                      if (lecture.duration.isNotEmpty) ...[
                        SizedBox(height: 6.h),
                        Text(
                          lecture.duration,
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                color: SumAcademyTheme.darkBase
                                    .withOpacityFloat(0.6),
                              ),
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _EmptyContentState extends StatelessWidget {
  const _EmptyContentState();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(16.r),
      decoration: BoxDecoration(
        color: SumAcademyTheme.white,
        borderRadius: BorderRadius.circular(SumAcademyTheme.radiusCard.r),
        border: Border.all(color: SumAcademyTheme.brandBluePale),
      ),
      child: Row(
        children: [
          Icon(Icons.menu_book_rounded, color: SumAcademyTheme.brandBlue),
          SizedBox(width: 12.w),
          Expanded(
            child: Text(
              'No lectures available yet. Please check back later.',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: SumAcademyTheme.darkBase.withOpacityFloat(0.7),
                  ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ErrorState extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;

  const _ErrorState({
    required this.message,
    required this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(16.r),
      decoration: BoxDecoration(
        color: SumAcademyTheme.errorLight,
        borderRadius: BorderRadius.circular(SumAcademyTheme.radiusCard.r),
        border: Border.all(color: SumAcademyTheme.error.withOpacityFloat(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Unable to load course',
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  color: SumAcademyTheme.error,
                  fontWeight: FontWeight.w600,
                ),
          ),
          SizedBox(height: 6.h),
          Text(
            message,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: SumAcademyTheme.error.withOpacityFloat(0.8),
                ),
          ),
          SizedBox(height: 12.h),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton(
              onPressed: onRetry,
              style: OutlinedButton.styleFrom(
                foregroundColor: SumAcademyTheme.error,
                side: BorderSide(color: SumAcademyTheme.error),
              ),
              child: const Text('Retry'),
            ),
          ),
        ],
      ),
    );
  }
}

class _ContentSkeleton extends StatelessWidget {
  const _ContentSkeleton();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: List.generate(
        2,
        (index) => Padding(
          padding: EdgeInsets.only(bottom: 12.h),
          child: Container(
            height: 90.h,
            decoration: BoxDecoration(
              color: SumAcademyTheme.white,
              borderRadius: BorderRadius.circular(SumAcademyTheme.radiusCard.r),
              border: Border.all(color: SumAcademyTheme.brandBluePale),
            ),
          ),
        ),
      ),
    );
  }
}
