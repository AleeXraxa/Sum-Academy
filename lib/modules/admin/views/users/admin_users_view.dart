import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:sum_academy/app/theme.dart';
import 'package:sum_academy/modules/admin/controllers/admin_controller.dart';
import 'package:sum_academy/modules/admin/widgets/common/admin_filter_panel.dart';
import 'package:sum_academy/modules/admin/widgets/common/admin_ui.dart';
import 'package:sum_academy/modules/admin/widgets/header/admin_header_row.dart';
import 'package:sum_academy/modules/admin/widgets/users/add_user_dialog.dart';
import 'package:sum_academy/modules/admin/widgets/users/user_filter_chip.dart';
import 'package:sum_academy/modules/admin/widgets/users/users_list.dart';
import 'package:sum_academy/modules/admin/widgets/users/users_empty_state.dart';
import 'package:sum_academy/modules/admin/widgets/users/users_skeleton_list.dart';
import 'package:sum_academy/modules/auth/widgets/auth_text_field.dart';

class AdminUsersView extends StatefulWidget {
  final AdminController controller;
  final Color textColor;
  final Color surface;
  final bool isDark;
  final String userName;

  const AdminUsersView({
    super.key,
    required this.controller,
    required this.textColor,
    required this.surface,
    required this.isDark,
    required this.userName,
  });

  @override
  State<AdminUsersView> createState() => _AdminUsersViewState();
}

class _AdminUsersViewState extends State<AdminUsersView> {
  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: () => widget.controller.fetchUsers(),
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
            title: 'User Management',
            textColor: widget.textColor,
            isPageHeader: true,
            trailing: AdminAddIconButton(
              onPressed: () => showAddUserDialog(context),
            ),
          ),
          SizedBox(height: 12.h),
          AdminFilterPanel(
            surface: widget.surface,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Obx(() {
                  final selectedIndex =
                      widget.controller.userFilterIndex.value;
                  return Wrap(
                    spacing: 10.w,
                    runSpacing: 10.h,
                    children: [
                      for (var i = 0;
                          i < widget.controller.userFilters.length;
                          i++)
                        UserFilterChip(
                          label: widget.controller.userFilters[i].label,
                          count: widget.controller.userFilters[i].count,
                          isSelected: selectedIndex == i,
                          onTap: () =>
                              widget.controller.setUserFilterIndex(i),
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
                  if (!hasQuery || !widget.controller.hasMoreUsers.value) {
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
            if (widget.controller.isUsersLoading.value) {
              return const UsersSkeletonList(count: 5);
            }

            final filtered = widget.controller.filteredUsers;
            if (filtered.isEmpty) {
              if (widget.controller.searchQuery.value.isNotEmpty) {
                return Padding(
                  padding: EdgeInsets.symmetric(vertical: 24.h),
                  child: Text(
                    'No users match your search.',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: widget.textColor.withOpacityFloat(0.6),
                    ),
                  ),
                );
              }
              return UsersEmptyState(
                onAddUser: () => showAddUserDialog(context),
              );
            }

            return UsersList(
              users: filtered,
              surface: widget.surface,
              textColor: widget.textColor,
              isDark: widget.isDark,
            );
          }),
          Obx(() {
            if (widget.controller.isUsersLoadingMore.value) {
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
            if (!widget.controller.hasMoreUsers.value) {
              return const SizedBox.shrink();
            }
            return Padding(
              padding: EdgeInsets.only(top: 8.h),
              child: SizedBox(
                width: double.infinity,
                child: OutlinedButton(
                  onPressed: widget.controller.loadMoreUsers,
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
