import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:sum_academy/app/theme.dart';
import 'package:sum_academy/core/services/maintenance_service.dart';
import 'package:sum_academy/core/widgets/status_dialogs.dart';

class AdminSiteSettingsView extends StatefulWidget {
  final Color textColor;
  final Color surface;
  final bool isDark;
  final String userName;

  const AdminSiteSettingsView({
    super.key,
    required this.textColor,
    required this.surface,
    required this.isDark,
    required this.userName,
  });

  @override
  State<AdminSiteSettingsView> createState() => _AdminSiteSettingsViewState();
}

class _AdminSiteSettingsViewState extends State<AdminSiteSettingsView> {
  final _maintenanceService = Get.find<MaintenanceService>();

  bool _loading = false;
  bool _enabled = false;
  String _message = '';

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    try {
      final status = await _maintenanceService.fetchStatus();
      _enabled = status.enabled;
      _message = status.message;
    } catch (_) {
      // Keep last known state.
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _toggleMaintenance() async {
    await showLoadingDialog(context, message: 'Updating maintenance mode...');
    var success = false;
    try {
      await _maintenanceService.toggleMaintenanceAsAdmin();
      success = true;
    } catch (_) {
      success = false;
    } finally {
      if (Get.isDialogOpen ?? false) {
        Navigator.of(context).pop();
      }
    }

    if (!success) {
      await showErrorDialog(
        context,
        title: 'Maintenance Mode',
        message: 'Failed to update maintenance settings.',
      );
      return;
    }

    await _load();
  }

  @override
  Widget build(BuildContext context) {
    final muted = widget.textColor.withOpacityFloat(0.68);
    final cardBorder = widget.isDark
        ? SumAcademyTheme.darkBorder
        : SumAcademyTheme.brandBluePale;

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 18.w, vertical: 16.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Site Settings',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  color: widget.textColor,
                  fontWeight: FontWeight.w800,
                ),
          ),
          SizedBox(height: 6.h),
          Text(
            'Manage app-wide settings like maintenance mode.',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: muted,
                ),
          ),
          SizedBox(height: 14.h),
          Container(
            padding: EdgeInsets.all(16.r),
            decoration: BoxDecoration(
              color: widget.surface,
              borderRadius: BorderRadius.circular(18.r),
              border: Border.all(color: cardBorder),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      width: 44.r,
                      height: 44.r,
                      decoration: BoxDecoration(
                        color:
                            SumAcademyTheme.accentOrange.withOpacityFloat(0.14),
                        borderRadius: BorderRadius.circular(14.r),
                        border: Border.all(
                          color: SumAcademyTheme.accentOrange
                              .withOpacityFloat(0.2),
                        ),
                      ),
                      child: Icon(
                        Icons.construction_rounded,
                        color: SumAcademyTheme.accentOrange,
                        size: 22.sp,
                      ),
                    ),
                    SizedBox(width: 12.w),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Maintenance Mode',
                            style: Theme.of(context)
                                .textTheme
                                .titleMedium
                                ?.copyWith(
                                  color: widget.textColor,
                                  fontWeight: FontWeight.w700,
                                ),
                          ),
                          SizedBox(height: 2.h),
                          Text(
                            'When enabled, students will only see the maintenance screen after login.',
                            style:
                                Theme.of(context).textTheme.bodySmall?.copyWith(
                                      color: muted,
                                      height: 1.3,
                                    ),
                          ),
                        ],
                      ),
                    ),
                    Switch(
                      value: _enabled,
                      onChanged: _loading ? null : (_) => _toggleMaintenance(),
                      activeColor: SumAcademyTheme.brandBlue,
                    ),
                  ],
                ),
                if (_message.trim().isNotEmpty) ...[
                  SizedBox(height: 12.h),
                  Container(
                    width: double.infinity,
                    padding: EdgeInsets.all(12.r),
                    decoration: BoxDecoration(
                      color: widget.isDark
                          ? SumAcademyTheme.darkElevated
                          : SumAcademyTheme.surfaceTertiary,
                      borderRadius: BorderRadius.circular(14.r),
                      border: Border.all(color: cardBorder),
                    ),
                    child: Text(
                      _message.trim(),
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: muted,
                          ),
                    ),
                  ),
                ],
                SizedBox(height: 10.h),
                Row(
                  children: [
                    OutlinedButton(
                      onPressed: _loading ? null : _load,
                      style: OutlinedButton.styleFrom(
                        foregroundColor: widget.isDark
                            ? SumAcademyTheme.white
                            : SumAcademyTheme.brandBlue,
                        side: BorderSide(
                          color: widget.isDark
                              ? SumAcademyTheme.darkBorder
                              : SumAcademyTheme.brandBluePale,
                        ),
                      ),
                      child: Text(_loading ? 'Refreshing...' : 'Refresh'),
                    ),
                  ],
                )
              ],
            ),
          ),
        ],
      ),
    );
  }
}

