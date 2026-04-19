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
    const background = Color(0xFF080A14);
    final textColor = SumAcademyTheme.white.withOpacityFloat(0.92);
    final muted = SumAcademyTheme.white.withOpacityFloat(0.45);

    return Drawer(
      backgroundColor: background,
      child: SafeArea(
        child: Column(
          children: [
            // ── Logo & Brand Header ─────────────────────────────────────────
            Padding(
              padding: EdgeInsets.fromLTRB(20.w, 16.h, 16.w, 16.h),
              child: Row(
                children: [
                  Container(
                    width: 38.r,
                    height: 38.r,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: SumAcademyTheme.white.withOpacityFloat(0.12),
                        width: 1.5,
                      ),
                      image: const DecorationImage(
                        image: AssetImage('assets/logo.jpeg'),
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                  SizedBox(width: 10.w),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Sum Academy',
                          style:
                              Theme.of(context).textTheme.titleSmall?.copyWith(
                                    color: textColor,
                                    fontWeight: FontWeight.w700,
                                  ),
                        ),
                        Text(
                          'Student Portal',
                          style: Theme.of(context)
                              .textTheme
                              .labelSmall
                              ?.copyWith(
                                color: SumAcademyTheme.brandBlueLight
                                    .withOpacityFloat(0.8),
                                letterSpacing: 0.3,
                              ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.of(context).maybePop(),
                    icon: Icon(
                      Icons.close_rounded,
                      color: SumAcademyTheme.white.withOpacityFloat(0.5),
                      size: 20.sp,
                    ),
                  ),
                ],
              ),
            ),
            Container(
              height: 1,
              color: SumAcademyTheme.white.withOpacityFloat(0.06),
            ),
            // ── Navigation Items ────────────────────────────────────────────
            Expanded(
              child: ListView(
                padding: EdgeInsets.fromLTRB(12.w, 12.h, 12.w, 16.h),
                children: [
                  for (final section in sections) ...[
                    _SectionHeader(title: section.title, color: muted),
                    SizedBox(height: 4.h),
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
                    SizedBox(height: 16.h),
                  ],
                ],
              ),
            ),
            // ── User Card ───────────────────────────────────────────────────
            Container(
              height: 1,
              color: SumAcademyTheme.white.withOpacityFloat(0.06),
            ),
            Padding(
              padding: EdgeInsets.fromLTRB(12.w, 12.h, 12.w, 16.h),
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
      _SidebarItem(
          label: 'Help and Support', icon: Icons.support_agent_rounded),
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

// ── Section Header ────────────────────────────────────────────────────────────

class _SectionHeader extends StatelessWidget {
  final String title;
  final Color color;

  const _SectionHeader({required this.title, required this.color});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(8.w, 0, 0, 0),
      child: Text(
        title.toUpperCase(),
        style: Theme.of(context).textTheme.labelSmall?.copyWith(
              color: color,
              letterSpacing: 1.6,
              fontWeight: FontWeight.w600,
            ),
      ),
    );
  }
}

// ── Sidebar Item Tile ─────────────────────────────────────────────────────────

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
    // Active: blue filled pill
    final activeBg =
        SumAcademyTheme.brandBlue.withOpacityFloat(isHighlighted ? 0 : 1);
    // Highlighted (Live Session): blue tinted
    final highlightBg =
        SumAcademyTheme.brandBlue.withOpacityFloat(isActive ? 0.28 : 0.15);
    const highlightBorder = SumAcademyTheme.brandBlueLight;

    Widget tile;
    if (isHighlighted) {
      tile = Container(
        padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 10.h),
        decoration: BoxDecoration(
          color: highlightBg,
          borderRadius: BorderRadius.circular(12.r),
          border: Border.all(
            color: highlightBorder.withOpacityFloat(isActive ? 0.7 : 0.35),
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 8.r,
              height: 8.r,
              decoration: const BoxDecoration(
                color: Color(0xFF22CC77),
                shape: BoxShape.circle,
              ),
            ),
            SizedBox(width: 8.w),
            Icon(
              item.icon,
              color: isActive
                  ? SumAcademyTheme.white
                  : SumAcademyTheme.brandBlueLight,
              size: 18.sp,
            ),
            SizedBox(width: 10.w),
            Expanded(
              child: Text(
                item.label,
                style: Theme.of(context).textTheme.labelLarge?.copyWith(
                      color: SumAcademyTheme.white,
                      fontWeight: FontWeight.w600,
                    ),
              ),
            ),
            Container(
              padding:
                  EdgeInsets.symmetric(horizontal: 8.w, vertical: 3.h),
              decoration: BoxDecoration(
                color: const Color(0xFF22CC77).withOpacityFloat(0.15),
                borderRadius: BorderRadius.circular(6.r),
              ),
              child: Text(
                'LIVE',
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                      color: const Color(0xFF22CC77),
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.5,
                    ),
              ),
            ),
          ],
        ),
      );
    } else if (isActive) {
      tile = Container(
        padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 10.h),
        decoration: BoxDecoration(
          color: SumAcademyTheme.brandBlue,
          borderRadius: BorderRadius.circular(12.r),
        ),
        child: Row(
          children: [
            Icon(
              item.icon,
              color: SumAcademyTheme.white,
              size: 18.sp,
            ),
            SizedBox(width: 10.w),
            Expanded(
              child: Text(
                item.label,
                style: Theme.of(context).textTheme.labelLarge?.copyWith(
                      color: SumAcademyTheme.white,
                      fontWeight: FontWeight.w600,
                    ),
              ),
            ),
          ],
        ),
      );
    } else {
      tile = Container(
        padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 10.h),
        child: Row(
          children: [
            Icon(
              item.icon,
              color: color.withOpacityFloat(0.6),
              size: 18.sp,
            ),
            SizedBox(width: 10.w),
            Expanded(
              child: Text(
                item.label,
                style: Theme.of(context).textTheme.labelLarge?.copyWith(
                      color: color.withOpacityFloat(0.8),
                      fontWeight: FontWeight.w500,
                    ),
              ),
            ),
          ],
        ),
      );
    }

    return Padding(
      padding: EdgeInsets.only(bottom: 2.h),
      child: InkWell(
        borderRadius: BorderRadius.circular(12.r),
        onTap: onTap,
        splashColor: SumAcademyTheme.brandBlue.withOpacityFloat(0.1),
        highlightColor: SumAcademyTheme.brandBlue.withOpacityFloat(0.05),
        child: tile,
      ),
    );
  }
}

// ── User Card ─────────────────────────────────────────────────────────────────

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
    final displayName =
        name.length > 18 ? '${name.substring(0, 16)}…' : name;

    return Container(
      padding: EdgeInsets.all(12.r),
      decoration: BoxDecoration(
        color: SumAcademyTheme.white.withOpacityFloat(0.05),
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(
          color: SumAcademyTheme.white.withOpacityFloat(0.08),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 42.r,
            height: 42.r,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [
                  SumAcademyTheme.brandBlue,
                  SumAcademyTheme.brandBlueDark,
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(13.r),
            ),
            alignment: Alignment.center,
            child: Text(
              initials,
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    color: SumAcademyTheme.white,
                    fontWeight: FontWeight.w700,
                  ),
            ),
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  displayName,
                  style: Theme.of(context).textTheme.labelLarge?.copyWith(
                        color: SumAcademyTheme.white,
                        fontWeight: FontWeight.w600,
                      ),
                ),
                Text(
                  'Student',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color:
                            SumAcademyTheme.white.withOpacityFloat(0.45),
                      ),
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: onLogout,
            icon: Icon(
              Icons.logout_rounded,
              size: 18.sp,
              color: SumAcademyTheme.white.withOpacityFloat(0.45),
            ),
            tooltip: 'Logout',
          ),
        ],
      ),
    );
  }
}
