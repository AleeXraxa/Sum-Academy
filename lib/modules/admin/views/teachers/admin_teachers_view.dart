import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:sum_academy/app/theme.dart';
import 'package:sum_academy/modules/admin/controllers/admin_teacher_controller.dart';
import 'package:sum_academy/modules/admin/widgets/header/admin_header_row.dart';
import 'package:sum_academy/modules/admin/widgets/teachers/add_teacher_dialog.dart';
import 'package:sum_academy/modules/admin/widgets/teachers/teacher_list.dart';
import 'package:sum_academy/modules/admin/widgets/teachers/teachers_empty_state.dart';
import 'package:sum_academy/modules/admin/widgets/users/user_filter_chip.dart';
import 'package:sum_academy/modules/admin/widgets/users/users_skeleton_list.dart';
import 'package:sum_academy/modules/auth/widgets/auth_text_field.dart';

class AdminTeachersView extends StatefulWidget {
  final AdminTeacherController controller;
  final Color textColor;
  final Color surface;
  final bool isDark;
  final String userName;

  const AdminTeachersView({
    super.key,
    required this.controller,
    required this.textColor,
    required this.surface,
    required this.isDark,
    required this.userName,
  });

  @override
  State<AdminTeachersView> createState() => _AdminTeachersViewState();
}

class _AdminTeachersViewState extends State<AdminTeachersView> {
  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: () => widget.controller.fetchTeachers(),
      color: widget.textColor,
      child: ListView(
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
                  'Teacher Management',
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
                  onPressed: () => showAddTeacherDialog(context),
                  icon: Icon(
                    Icons.add_rounded,
                    color: SumAcademyTheme.white,
                    size: 20.sp,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 12.h),
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
          SizedBox(height: 16.h),
          Obx(() {
            final hasQuery =
                widget.controller.searchQuery.value.trim().isNotEmpty;
            if (!hasQuery || !widget.controller.hasMore.value) {
              return const SizedBox.shrink();
            }
            return Padding(
              padding: EdgeInsets.only(bottom: 12.h),
              child: Text(
                'Load more to search everything.',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: widget.textColor.withOpacityFloat(0.6),
                    ),
              ),
            );
          }),
          Obx(() {
            if (widget.controller.isLoading.value) {
              return const UsersSkeletonList(count: 5);
            }

            final filtered = widget.controller.filteredTeachers;
            if (filtered.isEmpty) {
              if (widget.controller.searchQuery.value.isNotEmpty) {
                return Padding(
                  padding: EdgeInsets.symmetric(vertical: 24.h),
                  child: Text(
                    'No teachers match your search.',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: widget.textColor.withOpacityFloat(0.6),
                        ),
                  ),
                );
              }
              return TeachersEmptyState(
                onAddTeacher: () => showAddTeacherDialog(context),
              );
            }

            return TeacherList(
              teachers: filtered,
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
                  onPressed: widget.controller.loadMoreTeachers,
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
