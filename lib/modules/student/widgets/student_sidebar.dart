import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:sum_academy/app/theme.dart';

class StudentSidebar extends StatelessWidget {
  final String userName;
  final String? activeItem;
  final ValueChanged<String>? onItemSelected;

  const StudentSidebar({
    super.key,
    this.userName = 'Student',
    this.activeItem,
    this.onItemSelected,
  });

  @override
  Widget build(BuildContext context) {
    final sections = _buildSections();
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
                      final isHighlighted = item.label == 'Live Session';
                      return _SidebarItemTile(
                        item: item,
                        color: textColor,
                        isActive: isActive,
                        isHighlighted: isHighlighted,
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

List<_SidebarSection> _buildSections() {
  const overview = _SidebarSection(
    title: 'Overview',
    items: [
      _SidebarItem(label: 'Dashboard', icon: Icons.dashboard_rounded),
    ],
  );

  const learning = _SidebarSection(
    title: 'Learning',
    items: [
      _SidebarItem(label: 'Live Session', icon: Icons.videocam_rounded),
      _SidebarItem(label: 'My Classes', icon: Icons.menu_book_rounded),
      _SidebarItem(label: 'Explore Classes', icon: Icons.explore_rounded),
      _SidebarItem(label: 'My Certificates', icon: Icons.verified_rounded),
      _SidebarItem(label: 'Quizzes', icon: Icons.quiz_rounded),
      _SidebarItem(label: 'Tests', icon: Icons.fact_check_rounded),
    ],
  );

  const payments = _SidebarSection(
    title: 'Payments',
    items: [
      _SidebarItem(label: 'Payments', icon: Icons.payments_rounded),
    ],
  );

  const engagement = _SidebarSection(
    title: 'Engagement',
    items: [
      _SidebarItem(label: 'Announcements', icon: Icons.campaign_rounded),
      _SidebarItem(label: 'Help and Support', icon: Icons.support_agent_rounded),
    ],
  );

  const settings = _SidebarSection(
    title: 'Settings',
    items: [
      _SidebarItem(label: 'Settings', icon: Icons.settings_rounded),
    ],
  );

  return [overview, learning, payments, engagement, settings];
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
  final bool isHighlighted;

  const _SidebarItemTile({
    required this.item,
    required this.color,
    this.isActive = false,
    this.isHighlighted = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final activeBg = SumAcademyTheme.white.withOpacityFloat(0.08);
    final activeBorder = SumAcademyTheme.brandBlueLight.withOpacityFloat(0.35);
    final activeText = SumAcademyTheme.white;
    final activeIcon = SumAcademyTheme.brandBlueLight;
    final highlightBg =
        SumAcademyTheme.brandBlue.withOpacityFloat(isActive ? 0.26 : 0.18);
    final highlightBorder =
        SumAcademyTheme.brandBlueLight.withOpacityFloat(0.6);
    final highlightIcon =
        isActive ? SumAcademyTheme.white : SumAcademyTheme.brandBlueLight;
    final highlightText =
        isActive ? SumAcademyTheme.white : SumAcademyTheme.white;

    return InkWell(
      borderRadius: BorderRadius.circular(14.r),
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 10.h),
        decoration: BoxDecoration(
          color: isHighlighted
              ? highlightBg
              : (isActive ? activeBg : Colors.transparent),
          borderRadius: BorderRadius.circular(14.r),
          border: isHighlighted
              ? Border.all(color: highlightBorder)
              : (isActive ? Border.all(color: activeBorder) : null),
        ),
        child: Row(
          children: [
            Icon(
              item.icon,
              color: isHighlighted
                  ? highlightIcon
                  : (isActive ? activeIcon : color),
              size: 20.sp,
            ),
            SizedBox(width: 12.w),
            Text(
              item.label,
              style: Theme.of(context).textTheme.labelLarge?.copyWith(
                    color: isHighlighted
                        ? highlightText
                        : (isActive ? activeText : color),
                    fontWeight: (isActive || isHighlighted)
                        ? FontWeight.w600
                        : FontWeight.w500,
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
    final initials = name.isNotEmpty ? name.trim()[0].toUpperCase() : 'S';

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
