import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:sum_academy/app/theme.dart';
import 'package:sum_academy/modules/admin/controllers/admin_payments_controller.dart';
import 'package:sum_academy/modules/admin/widgets/common/admin_filter_panel.dart';
import 'package:sum_academy/modules/admin/widgets/common/admin_ui.dart';
import 'package:sum_academy/modules/admin/widgets/header/admin_header_row.dart';
import 'package:sum_academy/modules/admin/widgets/payments/installments_empty_state.dart';
import 'package:sum_academy/modules/admin/widgets/payments/installments_list.dart';
import 'package:sum_academy/modules/admin/widgets/payments/installments_skeleton_list.dart';
import 'package:sum_academy/modules/admin/widgets/users/user_filter_chip.dart';
import 'package:sum_academy/modules/auth/widgets/auth_text_field.dart';

class AdminInstallmentsView extends StatefulWidget {
  final AdminPaymentsController controller;
  final Color textColor;
  final Color surface;
  final bool isDark;
  final String userName;

  const AdminInstallmentsView({
    super.key,
    required this.controller,
    required this.textColor,
    required this.surface,
    required this.isDark,
    required this.userName,
  });

  @override
  State<AdminInstallmentsView> createState() => _AdminInstallmentsViewState();
}

class _AdminInstallmentsViewState extends State<AdminInstallmentsView> {
  @override
  void initState() {
    super.initState();
    widget.controller.ensureInstallmentsLoaded();
  }

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: () => widget.controller.fetchInstallments(),
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
            searchController: widget.controller.installmentSearchController,
            showSearch: false,
            showProfile: false,
            showNotifications: false,
          ),
          SizedBox(height: 18.h),
          AdminSectionHeader(
            title: 'Installments',
            textColor: widget.textColor,
            isPageHeader: true,
          ),
          SizedBox(height: 12.h),
          AdminFilterPanel(
            surface: widget.surface,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Obx(() {
                  final selected =
                      widget.controller.installmentFilterIndex.value;
                  return Wrap(
                    spacing: 10.w,
                    runSpacing: 10.h,
                    children: [
                      for (var i = 0;
                          i < widget.controller.installmentFilters.length;
                          i++)
                        UserFilterChip(
                          label:
                              widget.controller.installmentFilters[i].label,
                          count:
                              widget.controller.installmentFilters[i].count,
                          isSelected: selected == i,
                          onTap: () =>
                              widget.controller.setInstallmentFilterIndex(i),
                        ),
                    ],
                  );
                }),
                SizedBox(height: 14.h),
                AuthTextField(
                  controller: widget.controller.installmentSearchController,
                  label: 'Search',
                  hint: 'Search by student or plan',
                  icon: Icons.search_rounded,
                  textInputAction: TextInputAction.search,
                  onFieldSubmitted: (_) {},
                ),
                Obx(() {
                  final hasQuery = widget
                      .controller.installmentSearchQuery.value
                      .trim()
                      .isNotEmpty;
                  if (!hasQuery ||
                      !widget.controller.hasMoreInstallments.value) {
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
            if (widget.controller.isInstallmentsLoading.value) {
              return const InstallmentsSkeletonList(count: 5);
            }

            final filtered = widget.controller.filteredInstallments;
            if (filtered.isEmpty) {
              if (widget.controller.installmentSearchQuery.value.isNotEmpty) {
                return Padding(
                  padding: EdgeInsets.symmetric(vertical: 24.h),
                  child: Text(
                    'No installment plans match your search.',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: widget.textColor.withOpacityFloat(0.6),
                        ),
                  ),
                );
              }
              return const InstallmentsEmptyState();
            }

            return InstallmentsList(
              plans: filtered,
              surface: widget.surface,
              textColor: widget.textColor,
              isDark: widget.isDark,
            );
          }),
          Obx(() {
            if (widget.controller.isInstallmentsLoadingMore.value) {
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
            if (!widget.controller.hasMoreInstallments.value) {
              return const SizedBox.shrink();
            }
            return Padding(
              padding: EdgeInsets.only(top: 8.h),
              child: SizedBox(
                width: double.infinity,
                child: OutlinedButton(
                  onPressed: widget.controller.loadMoreInstallments,
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
