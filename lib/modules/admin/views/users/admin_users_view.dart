import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:sum_academy/app/theme.dart';
import 'package:sum_academy/modules/admin/controllers/admin_controller.dart';
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
      widget.controller.loadMoreUsers();
    }
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      controller: _scrollController,
      padding: EdgeInsets.fromLTRB(20.w, 16.h, 20.w, 28.h),
      children: [
        AdminHeaderRow(
          textColor: widget.textColor,
          userName: widget.userName,
          isSearchExpanded: false,
          onSearchTap: widget.controller.toggleSearch,
          onSearchClose: widget.controller.closeSearch,
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
                'User Management',
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
                onPressed: () => showAddUserDialog(context),
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
          final selectedIndex = widget.controller.userFilterIndex.value;
          return Wrap(
            spacing: 10.w,
            runSpacing: 10.h,
            children: [
              for (var i = 0; i < widget.controller.userFilters.length; i++)
                UserFilterChip(
                  label: widget.controller.userFilters[i].label,
                  count: widget.controller.userFilters[i].count,
                  isSelected: selectedIndex == i,
                  onTap: () => widget.controller.setUserFilterIndex(i),
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
          return const SizedBox.shrink();
        }),
      ],
    );
  }
}
