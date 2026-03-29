import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:sum_academy/app/theme.dart';

class AdminSidebar extends StatelessWidget {
  final String role;
  final String userName;
  final String? activeItem;
  final ValueChanged<String>? onItemSelected;

  const AdminSidebar({
    super.key,
    this.role = 'admin',
    this.userName = 'User',
    this.activeItem,
    this.onItemSelected,
  });

  @override
  Widget build(BuildContext context) {
    final sections = _buildSections(role);
    const background = Colors.black;
    final textColor = SumAcademyTheme.white.withOpacityFloat(0.92);
    final muted = SumAcademyTheme.white.withOpacityFloat(0.6);

    return Drawer(
      backgroundColor: background,
      child: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: EdgeInsets.fromLTRB(20.w, 12.h, 16.w, 12.h),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      'Sum Academy',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            color: textColor,
                            fontWeight: FontWeight.w600,
                          ),
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.of(context).maybePop(),
                    icon: Icon(
                      Icons.tune_rounded,
                      color: textColor,
                    ),
                  ),
                ],
              ),
            ),
            Divider(color: SumAcademyTheme.white.withOpacityFloat(0.08)),
            Expanded(
              child: ListView(
                padding: EdgeInsets.fromLTRB(16.w, 8.h, 16.w, 16.h),
                children: [
                  for (final section in sections) ...[
                    _SectionHeader(title: section.title, color: muted),
                    SizedBox(height: 6.h),
                    ...section.items.map((item) {
                      final isActive = item.label == activeItem;
                      return _SidebarItemTile(
                        item: item,
                        color: textColor,
                        isActive: isActive,
                        onTap: () => onItemSelected?.call(item.label),
                      );
                    }),
                    SizedBox(height: 12.h),
                  ],
                ],
              ),
            ),
            Padding(
              padding: EdgeInsets.fromLTRB(16.w, 8.h, 16.w, 20.h),
              child: _SidebarUserCard(
                name: userName,
                onLogout: () => onItemSelected?.call('Logout'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SidebarItem {
  final String label;
  final IconData icon;

  const _SidebarItem({required this.label, required this.icon});
}

class _SidebarSection {
  final String title;
  final List<_SidebarItem> items;

  const _SidebarSection({required this.title, required this.items});
}

List<_SidebarSection> _buildSections(String role) {
  const overview = _SidebarSection(
    title: 'Overview',
    items: [
      _SidebarItem(label: 'Dashboard', icon: Icons.dashboard_rounded),
      _SidebarItem(label: 'Analytics', icon: Icons.query_stats_rounded),
    ],
  );

  const management = _SidebarSection(
    title: 'Management',
    items: [
      _SidebarItem(label: 'Users', icon: Icons.group_outlined),
      _SidebarItem(label: 'Teachers', icon: Icons.auto_stories_outlined),
      _SidebarItem(label: 'Students', icon: Icons.school_outlined),
      _SidebarItem(label: 'Courses', icon: Icons.menu_book_outlined),
      _SidebarItem(label: 'Classes', icon: Icons.class_outlined),
    ],
  );

  const payments = _SidebarSection(
    title: 'Payments',
    items: [
      _SidebarItem(label: 'Payments', icon: Icons.payments_outlined),
      _SidebarItem(label: 'Transactions', icon: Icons.receipt_long_outlined),
      _SidebarItem(label: 'Installments', icon: Icons.stacked_line_chart_outlined),
      _SidebarItem(label: 'Promo Codes', icon: Icons.confirmation_number_outlined),
    ],
  );

  const content = _SidebarSection(
    title: 'Content',
    items: [
      _SidebarItem(label: 'Certificates', icon: Icons.verified_outlined),
      _SidebarItem(label: 'Announcements', icon: Icons.campaign_outlined),
      _SidebarItem(label: 'Site Settings', icon: Icons.settings_outlined),
    ],
  );

  if (role == 'admin') {
    return [overview, management, payments, content];
  }

  if (role == 'teacher') {
    return [overview, management, content];
  }

  return [overview, content];
}

class _SectionHeader extends StatelessWidget {
  final String title;
  final Color color;

  const _SectionHeader({required this.title, required this.color});

  @override
  Widget build(BuildContext context) {
    return Text(
      title.toUpperCase(),
      style: Theme.of(context).textTheme.labelSmall?.copyWith(
            color: color,
            letterSpacing: 1.8,
            fontWeight: FontWeight.w600,
          ),
    );
  }
}

class _SidebarItemTile extends StatelessWidget {
  final _SidebarItem item;
  final Color color;
  final bool isActive;
  final VoidCallback? onTap;

  const _SidebarItemTile({
    required this.item,
    required this.color,
    this.isActive = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final activeBg = SumAcademyTheme.white.withOpacityFloat(0.08);
    final activeBorder = SumAcademyTheme.brandBlueLight.withOpacityFloat(0.35);
    final activeText = SumAcademyTheme.white;
    final activeIcon = SumAcademyTheme.brandBlueLight;

    return InkWell(
      borderRadius: BorderRadius.circular(14.r),
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 10.h),
        decoration: BoxDecoration(
          color: isActive ? activeBg : Colors.transparent,
          borderRadius: BorderRadius.circular(14.r),
          border: isActive ? Border.all(color: activeBorder) : null,
        ),
        child: Row(
          children: [
            Icon(
              item.icon,
              color: isActive ? activeIcon : color,
              size: 20.sp,
            ),
            SizedBox(width: 12.w),
            Text(
              item.label,
              style: Theme.of(context).textTheme.labelLarge?.copyWith(
                    color: isActive ? activeText : color,
                    fontWeight: isActive ? FontWeight.w600 : FontWeight.w500,
                  ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SidebarUserCard extends StatelessWidget {
  final String name;
  final VoidCallback? onLogout;

  const _SidebarUserCard({
    required this.name,
    this.onLogout,
  });

  @override
  Widget build(BuildContext context) {
    final initials = name.isNotEmpty ? name.trim()[0].toUpperCase() : 'U';

    return Container(
      padding: EdgeInsets.all(12.r),
      decoration: BoxDecoration(
        color: SumAcademyTheme.white.withOpacityFloat(0.06),
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(
          color: SumAcademyTheme.white.withOpacityFloat(0.08),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 40.r,
            height: 40.r,
            decoration: BoxDecoration(
              color: SumAcademyTheme.white.withOpacityFloat(0.1),
              borderRadius: BorderRadius.circular(20.r),
            ),
            alignment: Alignment.center,
            child: Text(
              initials,
              style: Theme.of(context).textTheme.labelLarge?.copyWith(
                    color: SumAcademyTheme.white,
                    fontWeight: FontWeight.w700,
                  ),
            ),
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: Theme.of(context).textTheme.labelLarge?.copyWith(
                        color: SumAcademyTheme.white,
                        fontWeight: FontWeight.w600,
                      ),
                ),
                SizedBox(height: 4.h),
                GestureDetector(
                  onTap: onLogout,
                  child: Text(
                    'Logout',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: SumAcademyTheme.white.withOpacityFloat(0.7),
                        ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
