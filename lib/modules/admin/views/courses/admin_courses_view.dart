import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:sum_academy/app/theme.dart';
import 'package:sum_academy/modules/admin/controllers/admin_course_controller.dart';
import 'package:sum_academy/modules/admin/widgets/courses/course_form_dialog.dart';
import 'package:sum_academy/modules/admin/widgets/courses/course_list.dart';
import 'package:sum_academy/modules/admin/widgets/courses/courses_empty_state.dart';
import 'package:sum_academy/modules/admin/widgets/header/admin_header_row.dart';
import 'package:sum_academy/modules/admin/widgets/users/users_skeleton_list.dart';
import 'package:sum_academy/modules/auth/widgets/auth_text_field.dart';

class AdminCoursesView extends StatefulWidget {
  final AdminCourseController controller;
  final Color textColor;
  final Color surface;
  final bool isDark;
  final String userName;

  const AdminCoursesView({
    super.key,
    required this.controller,
    required this.textColor,
    required this.surface,
    required this.isDark,
    required this.userName,
  });

  @override
  State<AdminCoursesView> createState() => _AdminCoursesViewState();
}

class _AdminCoursesViewState extends State<AdminCoursesView> {
  late final ScrollController _scrollController;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController()..addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (!_scrollController.hasClients) return;
    final threshold = 240.0;
    if (_scrollController.position.extentAfter < threshold) {
      widget.controller.loadMoreCourses();
    }
  }

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: () => widget.controller.fetchCourses(),
      color: widget.textColor,
      child: ListView(
        controller: _scrollController,
        padding: EdgeInsets.fromLTRB(20.w, 16.h, 20.w, 28.h),
        physics: const AlwaysScrollableScrollPhysics(
          parent: BouncingScrollPhysics(),
        ),
        children: [
          AdminHeaderRow(
            textColor: widget.textColor,
            userName: widget.userName,
            isSearchExpanded: false,
            onSearchTap: () {},
            onSearchClose: () {},
            searchController: widget.controller.searchController,
            showSearch: false,
            showProfile: false,
            showNotifications: false,
          ),
          SizedBox(height: 18.h),
          Row(
            children: [
              Expanded(
                child: Text(
                  'Course Management',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        color: widget.textColor,
                        fontWeight: FontWeight.w700,
                      ),
                ),
              ),
              SizedBox(width: 12.w),
              Container(
                width: 40.r,
                height: 40.r,
                decoration: BoxDecoration(
                  color: SumAcademyTheme.brandBlue,
                  borderRadius: BorderRadius.circular(12.r),
                ),
                child: IconButton(
                  onPressed: () => showAddCourseDialog(context),
                  icon: Icon(
                    Icons.add_rounded,
                    color: SumAcademyTheme.white,
                    size: 20.sp,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 14.h),
          AuthTextField(
            controller: widget.controller.searchController,
            label: 'Search',
            hint: 'Search by title',
            icon: Icons.search_rounded,
            textInputAction: TextInputAction.search,
            onFieldSubmitted: (_) {},
          ),
          SizedBox(height: 16.h),
          Obx(() {
            if (widget.controller.isLoading.value) {
              return const UsersSkeletonList(count: 4);
            }

            final courses = widget.controller.courses;
            if (courses.isEmpty) {
              if (widget.controller.searchQuery.value.isNotEmpty) {
                return Padding(
                  padding: EdgeInsets.symmetric(vertical: 24.h),
                  child: Text(
                    'No courses match your search.',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: widget.textColor.withOpacityFloat(0.6),
                        ),
                  ),
                );
              }
              return CoursesEmptyState(
                onAddCourse: () => showAddCourseDialog(context),
              );
            }

            return CourseList(
              courses: courses,
              surface: widget.surface,
              textColor: widget.textColor,
              isDark: widget.isDark,
            );
          }),
          Obx(() {
            if (widget.controller.isLoadingMore.value) {
              return Padding(
                padding: EdgeInsets.only(top: 16.h),
                child: Center(
                  child: SizedBox(
                    width: 24.r,
                    height: 24.r,
                    child: CircularProgressIndicator(
                      strokeWidth: 2.2,
                      color: SumAcademyTheme.brandBlue,
                    ),
                  ),
                ),
              );
            }
            return const SizedBox.shrink();
          }),
        ],
      ),
    );
  }
}
