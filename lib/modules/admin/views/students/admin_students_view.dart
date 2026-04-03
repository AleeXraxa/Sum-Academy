import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:sum_academy/app/theme.dart';
import 'package:sum_academy/modules/admin/controllers/admin_student_controller.dart';
import 'package:sum_academy/modules/admin/widgets/common/admin_filter_panel.dart';
import 'package:sum_academy/modules/admin/widgets/common/admin_ui.dart';
import 'package:sum_academy/modules/admin/widgets/header/admin_header_row.dart';
import 'package:sum_academy/modules/admin/widgets/students/add_student_dialog.dart';
import 'package:sum_academy/modules/admin/widgets/students/student_list.dart';
import 'package:sum_academy/modules/admin/widgets/students/students_empty_state.dart';
import 'package:sum_academy/modules/admin/widgets/users/user_filter_chip.dart';
import 'package:sum_academy/modules/admin/widgets/users/users_skeleton_list.dart';
import 'package:sum_academy/modules/auth/widgets/auth_text_field.dart';

class AdminStudentsView extends StatefulWidget {
  final AdminStudentController controller;
  final Color textColor;
  final Color surface;
  final bool isDark;
  final String userName;

  const AdminStudentsView({
    super.key,
    required this.controller,
    required this.textColor,
    required this.surface,
    required this.isDark,
    required this.userName,
  });

  @override
  State<AdminStudentsView> createState() => _AdminStudentsViewState();
}

class _AdminStudentsViewState extends State<AdminStudentsView> {
  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: () => widget.controller.fetchStudents(),
      color: widget.textColor,
      child: ListView(
        padding: AdminUi.pagePadding(),
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
          AdminSectionHeader(
            title: 'Student Management',
            textColor: widget.textColor,
            isPageHeader: true,
            trailing: AdminAddIconButton(
              onPressed: () => showAddStudentDialog(context),
            ),
          ),
          SizedBox(height: 12.h),
          AdminFilterPanel(
            surface: widget.surface,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Obx(() {
                  final selected = widget.controller.filterIndex.value;
                  return Wrap(
                    spacing: 10.w,
                    runSpacing: 10.h,
                    children: [
                      for (var i = 0; i < widget.controller.filters.length; i++)
                        UserFilterChip(
                          label: widget.controller.filters[i].label,
                          count: widget.controller.filters[i].count,
                          isSelected: selected == i,
                          onTap: () => widget.controller.setFilterIndex(i),
                        ),
                    ],
                  );
                }),
                SizedBox(height: 14.h),
                AuthTextField(
                  controller: widget.controller.searchController,
                  label: 'Search',
                  hint: 'Search by email',
                  icon: Icons.search_rounded,
                  textInputAction: TextInputAction.search,
                  onFieldSubmitted: (_) {},
                ),
                Obx(() {
                  final hasQuery =
                      widget.controller.searchQuery.value.trim().isNotEmpty;
                  if (!hasQuery || !widget.controller.hasMore.value) {
                    return const SizedBox.shrink();
                  }
                  return Padding(
                    padding: EdgeInsets.only(top: 10.h),
                    child: Text(
                      'Load more to search everything.',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: widget.textColor.withOpacityFloat(0.6),
                          ),
                    ),
                  );
                }),
              ],
            ),
          ),
          SizedBox(height: 16.h),
          Obx(() {
            if (widget.controller.isLoading.value) {
              return const UsersSkeletonList(count: 5);
            }

            final filtered = widget.controller.filteredStudents;
            if (filtered.isEmpty) {
              if (widget.controller.searchQuery.value.isNotEmpty) {
                return Padding(
                  padding: EdgeInsets.symmetric(vertical: 24.h),
                  child: Text(
                    'No students match your search.',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: widget.textColor.withOpacityFloat(0.6),
                        ),
                  ),
                );
              }
              return StudentsEmptyState(
                onAddStudent: () => showAddStudentDialog(context),
              );
            }

            return StudentList(
              students: filtered,
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
            if (!widget.controller.hasMore.value) {
              return const SizedBox.shrink();
            }
            return Padding(
              padding: EdgeInsets.only(top: 8.h),
              child: SizedBox(
                width: double.infinity,
                child: OutlinedButton(
                  onPressed: widget.controller.loadMoreStudents,
                  style: OutlinedButton.styleFrom(
                    foregroundColor: SumAcademyTheme.brandBlue,
                    side: const BorderSide(
                      color: SumAcademyTheme.brandBluePale,
                    ),
                    padding:
                        EdgeInsets.symmetric(horizontal: 18.w, vertical: 12.h),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(
                        SumAcademyTheme.radiusButton.r,
                      ),
                    ),
                  ),
                  child: const Text('Load More'),
                ),
              ),
            );
          }),
        ],
      ),
    );
  }
}
