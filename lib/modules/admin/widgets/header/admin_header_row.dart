import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:sum_academy/app/theme.dart';
import 'package:sum_academy/modules/admin/widgets/header/admin_header_icon_button.dart';
import 'package:sum_academy/modules/auth/widgets/auth_text_field.dart';

class AdminHeaderRow extends StatelessWidget {
  final Color textColor;
  final String userName;
  final bool isSearchExpanded;
  final VoidCallback onSearchTap;
  final VoidCallback onSearchClose;
  final TextEditingController searchController;
  final bool showSearch;
  final bool showProfile;
  final bool showNotifications;

  const AdminHeaderRow({
    super.key,
    required this.textColor,
    required this.userName,
    required this.isSearchExpanded,
    required this.onSearchTap,
    required this.onSearchClose,
    required this.searchController,
    this.showSearch = true,
    this.showProfile = true,
    this.showNotifications = true,
  });

  @override
  Widget build(BuildContext context) {
    final initials = userName.isNotEmpty
        ? userName.trim()[0].toUpperCase()
        : 'A';

    if (!showSearch) {
      return _buildHeaderContent(
        context: context,
        textColor: textColor,
        userName: userName,
        initials: initials,
        showSearchIcon: false,
        showProfile: showProfile,
        showNotifications: showNotifications,
        onSearchTap: onSearchTap,
      );
    }

    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 280),
      switchInCurve: Curves.easeOutCubic,
      switchOutCurve: Curves.easeInCubic,
      transitionBuilder: (child, animation) {
        return FadeTransition(
          opacity: animation,
          child: SlideTransition(
            position: Tween<Offset>(
              begin: const Offset(0, 0.05),
              end: Offset.zero,
            ).animate(animation),
            child: child,
          ),
        );
      },
      child: isSearchExpanded
          ? LayoutBuilder(
              key: const ValueKey('search'),
              builder: (context, constraints) {
                return TweenAnimationBuilder<double>(
                  tween: Tween<double>(begin: 0.6, end: 1.0),
                  duration: const Duration(milliseconds: 280),
                  curve: Curves.easeOutCubic,
                  builder: (context, value, child) {
                    return Align(
                      alignment: Alignment.centerLeft,
                      child: SizedBox(
                        width: constraints.maxWidth * value,
                        child: child,
                      ),
                    );
                  },
                  child: AuthTextField(
                    controller: searchController,
                    label: 'Search',
                    hint: 'Search dashboard',
                    icon: Icons.search_rounded,
                    textInputAction: TextInputAction.search,
                    onFieldSubmitted: (_) => onSearchClose(),
                    suffix: IconButton(
                      onPressed: onSearchClose,
                      icon: Icon(Icons.close_rounded, size: 18.sp),
                    ),
                  ),
                );
              },
            )
          : _buildHeaderContent(
              context: context,
              key: const ValueKey('header'),
              textColor: textColor,
              userName: userName,
              initials: initials,
              showSearchIcon: true,
              showProfile: showProfile,
              showNotifications: showNotifications,
              onSearchTap: onSearchTap,
            ),
    );
  }
}

Widget _buildHeaderContent({
  Key? key,
  required BuildContext context,
  required Color textColor,
  required String userName,
  required String initials,
  required bool showSearchIcon,
  required bool showProfile,
  required bool showNotifications,
  required VoidCallback onSearchTap,
}) {
  return Row(
    key: key,
    crossAxisAlignment: CrossAxisAlignment.end,
    children: [
      Expanded(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Builder(
                  builder: (context) {
                    return IconButton(
                      onPressed: () => Scaffold.of(context).openDrawer(),
                      icon: Icon(
                        Icons.menu_rounded,
                        color: textColor.withOpacityFloat(0.7),
                        size: 20.sp,
                      ),
                    );
                  },
                ),
                SizedBox(width: 6.w),
                Text(
                  'SUM ACADEMY',
                  style: Theme.of(context).textTheme.labelLarge?.copyWith(
                    color: textColor.withOpacityFloat(0.55),
                    letterSpacing: 3.6,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            if (showProfile) ...[
              SizedBox(height: 10.h),
              Row(
                children: [
                  Container(
                    width: 44.r,
                    height: 44.r,
                    decoration: BoxDecoration(
                      color: SumAcademyTheme.brandBlue,
                      borderRadius: BorderRadius.circular(
                        SumAcademyTheme.radiusAvatar.r,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: SumAcademyTheme.brandBlue.withOpacityFloat(0.2),
                          blurRadius: 16.r,
                          offset: Offset(0, 8.h),
                        ),
                      ],
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      initials,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: SumAcademyTheme.white,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  SizedBox(width: 12.w),
                  Text(
                    userName,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: textColor,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
      Row(
        children: [
          if (showSearchIcon) ...[
            AdminHeaderIconButton(
              icon: Icons.search_rounded,
              tooltip: 'Search',
              onPressed: onSearchTap,
            ),
            SizedBox(width: 10.w),
          ],
          if (showNotifications)
            const AdminHeaderIconButton(
              icon: Icons.notifications_none_rounded,
              tooltip: 'Notifications',
            ),
        ],
      ),
    ],
  );
}
