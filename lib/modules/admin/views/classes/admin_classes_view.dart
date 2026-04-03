import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:sum_academy/app/theme.dart';
import 'package:sum_academy/modules/admin/controllers/admin_class_controller.dart';
import 'package:sum_academy/modules/admin/widgets/common/admin_filter_panel.dart';
import 'package:sum_academy/modules/admin/widgets/common/admin_ui.dart';
import 'package:sum_academy/modules/admin/widgets/classes/class_form_dialog.dart';
import 'package:sum_academy/modules/admin/widgets/classes/class_list.dart';
import 'package:sum_academy/modules/admin/widgets/classes/class_stats_grid.dart';
import 'package:sum_academy/modules/admin/widgets/classes/classes_empty_state.dart';
import 'package:sum_academy/modules/admin/widgets/header/admin_header_row.dart';
import 'package:sum_academy/modules/admin/widgets/users/user_dialog_fields.dart';
import 'package:sum_academy/modules/admin/widgets/users/users_skeleton_list.dart';
import 'package:sum_academy/modules/auth/widgets/auth_text_field.dart';

class AdminClassesView extends StatefulWidget {
  final AdminClassController controller;
  final Color textColor;
  final Color surface;
  final bool isDark;
  final String userName;

  const AdminClassesView({
    super.key,
    required this.controller,
    required this.textColor,
    required this.surface,
    required this.isDark,
    required this.userName,
  });

  @override
  State<AdminClassesView> createState() => _AdminClassesViewState();
}

class _AdminClassesViewState extends State<AdminClassesView> {
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
      widget.controller.loadMoreClasses();
    }
  }

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: () => widget.controller.fetchClasses(),
      color: widget.textColor,
      child: ListView(
        controller: _scrollController,
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
            title: 'Classes Management',
            textColor: widget.textColor,
            isPageHeader: true,
            subtitle:
                'Create classes, assign courses and shifts, and manage enrollment.',
            trailing: AdminAddIconButton(
              onPressed: () => showAddClassDialog(context),
            ),
          ),
          SizedBox(height: 16.h),
          Obx(() {
            return ClassStatsGrid(
              totalClasses: widget.controller.totalClasses,
              activeClasses: widget.controller.activeClasses,
              totalStudents: widget.controller.totalStudentsEnrolled,
              upcomingClasses: widget.controller.upcomingClasses,
              surface: widget.surface,
              textColor: widget.textColor,
            );
          }),
          SizedBox(height: 16.h),
          AdminFilterPanel(
            surface: widget.surface,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Obx(() {
                  return SizedBox(
                    width: double.infinity,
                    child: DialogDropdown(
                      value: widget.controller.statusFilter.value,
                      hintText: 'All Status',
                      items: AdminClassController.statusOptions,
                      onChanged: (value) {
                        if (value == null) return;
                        widget.controller.setStatusFilter(value);
                      },
                    ),
                  );
                }),
                SizedBox(height: 12.h),
                SizedBox(
                  width: double.infinity,
                  child: AuthTextField(
                    controller: widget.controller.searchController,
                    label: 'Search',
                    hint: 'Search by class name',
                    icon: Icons.search_rounded,
                    textInputAction: TextInputAction.search,
                    onFieldSubmitted: (_) {},
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 16.h),
          Obx(() {
            if (widget.controller.isLoading.value) {
              return const UsersSkeletonList(count: 4);
            }

            final classes = widget.controller.filteredClasses;
            if (classes.isEmpty) {
              if (widget.controller.searchQuery.value.isNotEmpty) {
                return Padding(
                  padding: EdgeInsets.symmetric(vertical: 24.h),
                  child: Text(
                    'No classes match your search.',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: widget.textColor.withOpacityFloat(0.6),
                        ),
                  ),
                );
              }
              return ClassesEmptyState(
                onAddClass: () => showAddClassDialog(context),
              );
            }

            return ClassList(
              classes: classes,
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
