import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:sum_academy/app/theme.dart';
import 'package:sum_academy/core/services/api_exception.dart';
import 'package:sum_academy/core/utils/network_error.dart';
import 'package:sum_academy/core/widgets/status_dialogs.dart';
import 'package:sum_academy/modules/admin/models/admin_course.dart';
import 'package:sum_academy/modules/admin/models/admin_user.dart';
import 'package:sum_academy/modules/admin/models/course_subject.dart';
import 'package:sum_academy/modules/admin/services/admin_course_service.dart';
import 'package:sum_academy/modules/admin/services/admin_teacher_service.dart';
import 'package:sum_academy/modules/admin/widgets/common/admin_ui.dart';
import 'package:sum_academy/modules/admin/widgets/users/role_pill.dart';
import 'package:sum_academy/modules/admin/widgets/users/user_dialog_fields.dart';

class AdminCourseContentView extends StatefulWidget {
  final AdminCourse course;

  const AdminCourseContentView({super.key, required this.course});

  @override
  State<AdminCourseContentView> createState() =>
      _AdminCourseContentViewState();
}

class _AdminCourseContentViewState extends State<AdminCourseContentView> {
  final List<_ContentSubject> _subjects = [];
  int _selectedIndex = 0;
  bool _teachersLoading = false;
  bool _subjectsLoading = true;
  final List<String> _teacherOptions = [];
  final Map<String, String> _teacherIdByLabel = {};
  final Map<String, String> _teacherLabelById = {};

  final _newSubjectName = TextEditingController();
  final _newSubjectOrder = TextEditingController(text: '1');
  String? _newSubjectTeacher;

  @override
  void initState() {
    super.initState();
    _bootstrap();
  }

  @override
  void dispose() {
    for (final subject in _subjects) {
      subject.dispose();
    }
    _newSubjectName.dispose();
    _newSubjectOrder.dispose();
    super.dispose();
  }

  Future<void> _bootstrap() async {
    await _loadTeachers();
    await _loadSubjects();
  }

  Future<void> _loadTeachers() async {
    setState(() => _teachersLoading = true);
    try {
      final teachers = await Get.find<AdminTeacherService>()
          .fetchTeachers(page: 1, limit: 100);
      _teacherOptions.clear();
      _teacherIdByLabel.clear();
      for (final teacher in teachers) {
        final label = _teacherLabel(teacher);
        _teacherOptions.add(label);
        _teacherIdByLabel[label] = teacher.uid;
        _teacherLabelById[teacher.uid] = label;
      }
    } catch (_) {
      // Ignore teacher load failures for now.
    } finally {
      if (mounted) {
        setState(() => _teachersLoading = false);
      }
    }
  }

  Future<void> _loadSubjects() async {
    setState(() => _subjectsLoading = true);
    try {
      final service = Get.find<AdminCourseService>();
      final subjects = await service.fetchCourseSubjects(widget.course.id);
      _subjects
        ..clear()
        ..addAll(subjects.map(_mapSubjectWithTeacherLabel));
      if (_subjects.isNotEmpty && _selectedIndex >= _subjects.length) {
        _selectedIndex = 0;
      }
    } on ApiException catch (e) {
      await handleNetworkError(e);
    } catch (_) {
      // Errors handled by centralized dialogs in ApiClient.
    } finally {
      if (mounted) {
        setState(() => _subjectsLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final statusColor = _statusColor(widget.course.status);
    final statusTone = statusColor.withOpacityFloat(0.12);
    return Scaffold(
      backgroundColor: SumAcademyTheme.surfaceSecondary,
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final isWide = constraints.maxWidth >= 900;
            final leftPanel = _buildLeftPanel(context);
            final rightPanel = _buildRightPanel(context, statusColor, statusTone);
            return SingleChildScrollView(
              padding: AdminUi.pagePadding(),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildHeader(context, statusColor, statusTone),
                  SizedBox(height: 16.h),
                  if (isWide)
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(width: 260.w, child: leftPanel),
                        SizedBox(width: 18.w),
                        Expanded(child: rightPanel),
                      ],
                    )
                  else ...[
                    leftPanel,
                    SizedBox(height: 16.h),
                    rightPanel,
                  ],
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildHeader(
    BuildContext context,
    Color statusColor,
    Color statusTone,
  ) {
    return Row(
      children: [
        OutlinedButton.icon(
          onPressed: () => Get.back(),
          icon: const Icon(Icons.arrow_back_rounded),
          label: const Text('Back'),
          style: OutlinedButton.styleFrom(
            foregroundColor: SumAcademyTheme.darkBase,
            side: const BorderSide(color: SumAcademyTheme.brandBluePale),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14.r),
            ),
            padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 10.h),
          ),
        ),
        SizedBox(width: 12.w),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'MANAGE CONTENT',
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                      color: SumAcademyTheme.darkBase.withOpacityFloat(0.55),
                      letterSpacing: 2.6,
                      fontWeight: FontWeight.w600,
                    ),
              ),
              SizedBox(height: 4.h),
              Text(
                widget.course.title.isNotEmpty
                    ? widget.course.title
                    : 'Course',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      color: SumAcademyTheme.darkBase,
                      fontWeight: FontWeight.w700,
                    ),
              ),
            ],
          ),
        ),
        RolePill(
          label: widget.course.status.isNotEmpty
              ? _capitalize(widget.course.status)
              : 'Draft',
          color: statusColor,
          background: statusTone,
        ),
      ],
    );
  }

  Widget _buildLeftPanel(BuildContext context) {
    final borderColor = AdminUi.borderColor(context);
    return Container(
      padding: EdgeInsets.all(16.r),
      decoration: AdminUi.cardDecoration(
        surface: SumAcademyTheme.white,
        border: borderColor,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Subjects',
            style: Theme.of(context).textTheme.labelLarge?.copyWith(
                  color: SumAcademyTheme.darkBase.withOpacityFloat(0.7),
                  letterSpacing: 2,
                  fontWeight: FontWeight.w600,
                ),
          ),
          SizedBox(height: 12.h),
          if (_subjectsLoading)
            Padding(
              padding: EdgeInsets.symmetric(vertical: 12.h),
              child: Row(
                children: [
                  SizedBox(
                    width: 18.r,
                    height: 18.r,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: SumAcademyTheme.brandBlue,
                    ),
                  ),
                  SizedBox(width: 10.w),
                  Text(
                    'Loading subjects...',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color:
                              SumAcademyTheme.darkBase.withOpacityFloat(0.6),
                        ),
                  ),
                ],
              ),
            )
          else if (_subjects.isEmpty)
            Padding(
              padding: EdgeInsets.only(bottom: 12.h),
              child: Text(
                'No subjects yet.',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: SumAcademyTheme.darkBase.withOpacityFloat(0.55),
                    ),
              ),
            )
          else
            Column(
              children: [
                for (var i = 0; i < _subjects.length; i++)
                  _SubjectTile(
                    subject: _subjects[i],
                    isSelected: _selectedIndex == i,
                    onTap: () => setState(() => _selectedIndex = i),
                  ),
              ],
            ),
          SizedBox(height: 12.h),
          Divider(color: SumAcademyTheme.brandBluePale),
          SizedBox(height: 12.h),
          Text(
            'Add Subject',
            style: Theme.of(context).textTheme.labelLarge?.copyWith(
                  color: SumAcademyTheme.darkBase,
                  fontWeight: FontWeight.w600,
                ),
          ),
          SizedBox(height: 10.h),
          DialogTextField(
            controller: _newSubjectName,
            hintText: 'Subject name',
            textInputAction: TextInputAction.next,
          ),
          SizedBox(height: 10.h),
          DialogDropdown(
            value: _newSubjectTeacher,
            hintText: _teachersLoading ? 'Loading...' : 'Select teacher',
            items: _teacherOptions,
            enabled: !_teachersLoading,
            onChanged: (value) => setState(() => _newSubjectTeacher = value),
          ),
          SizedBox(height: 10.h),
          DialogTextField(
            controller: _newSubjectOrder,
            hintText: 'Order',
            keyboardType: TextInputType.number,
            textInputAction: TextInputAction.done,
          ),
          SizedBox(height: 12.h),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _handleAddSubject,
              style: ElevatedButton.styleFrom(
                backgroundColor: SumAcademyTheme.brandBlue,
                foregroundColor: SumAcademyTheme.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14.r),
                ),
                padding: EdgeInsets.symmetric(vertical: 12.h),
              ),
              child: const Text('Add Subject'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRightPanel(
    BuildContext context,
    Color statusColor,
    Color statusTone,
  ) {
    final borderColor = AdminUi.borderColor(context);
    final selected = _subjects.isEmpty
        ? null
        : _subjects[_selectedIndex.clamp(0, _subjects.length - 1)];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: EdgeInsets.all(16.r),
          decoration: AdminUi.cardDecoration(
            surface: SumAcademyTheme.white,
            border: borderColor,
          ),
          child: _subjectsLoading
              ? Center(
                  child: SizedBox(
                    width: 20.r,
                    height: 20.r,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: SumAcademyTheme.brandBlue,
                    ),
                  ),
                )
              : selected == null
              ? Text(
                  'Select or add a subject to manage content.',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: SumAcademyTheme.darkBase.withOpacityFloat(0.6),
                      ),
                )
              : Column(
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: DialogTextField(
                            controller: selected.nameController,
                            hintText: 'Subject name',
                            textInputAction: TextInputAction.next,
                          ),
                        ),
                        SizedBox(width: 12.w),
                        Expanded(
                          child: DialogDropdown(
                            value: selected.teacherLabel,
                            hintText: _teachersLoading
                                ? 'Loading...'
                                : 'Select teacher',
                            items: _teacherOptions,
                            enabled: !_teachersLoading,
                            onChanged: (value) {
                              setState(() => selected.teacherLabel = value);
                            },
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 12.h),
                    Row(
                      children: [
                        Expanded(
                          child: ElevatedButton(
                            onPressed: () => _handleSaveSubject(selected),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: SumAcademyTheme.brandBlue,
                              foregroundColor: SumAcademyTheme.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(14.r),
                              ),
                              padding: EdgeInsets.symmetric(vertical: 12.h),
                            ),
                            child: const Text('Save Subject'),
                          ),
                        ),
                        SizedBox(width: 12.w),
                        Expanded(
                          child: OutlinedButton(
                            onPressed: () => _handleRemoveSubject(selected),
                            style: OutlinedButton.styleFrom(
                              foregroundColor: SumAcademyTheme.error,
                              side: BorderSide(
                                color: SumAcademyTheme.error
                                    .withOpacityFloat(0.4),
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(14.r),
                              ),
                              padding: EdgeInsets.symmetric(vertical: 12.h),
                            ),
                            child: const Text('Remove'),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
        ),
        SizedBox(height: 14.h),
        _ContentSectionCard(
          title: 'Videos',
          actionLabel: 'Add Video',
          emptyText: 'No videos yet.',
          onTap: () {},
        ),
        SizedBox(height: 12.h),
        _ContentSectionCard(
          title: 'PDF Notes',
          actionLabel: 'Add PDF Notes',
          emptyText: 'No PDF notes yet.',
          onTap: () {},
        ),
        SizedBox(height: 12.h),
        _ContentSectionCard(
          title: 'Books',
          actionLabel: 'Add Book',
          emptyText: 'No books yet.',
          onTap: () {},
        ),
      ],
    );
  }

  void _handleAddSubject() async {
    final name = _newSubjectName.text.trim();
    if (name.isEmpty) {
      await showErrorDialog(
        context,
        title: 'Required',
        message: 'Enter a subject name.',
      );
      return;
    }
    final teacherLabel = _newSubjectTeacher;
    if (teacherLabel == null || teacherLabel.isEmpty) {
      await showErrorDialog(
        context,
        title: 'Required',
        message: 'Select a teacher.',
      );
      return;
    }
    final teacherId = _teacherIdByLabel[teacherLabel] ?? '';
    if (teacherId.isEmpty) {
      await showErrorDialog(
        context,
        title: 'Required',
        message: 'Select a valid teacher.',
      );
      return;
    }
    final order = int.tryParse(_newSubjectOrder.text.trim()) ?? 1;
    var success = false;
    showLoadingDialog(context, message: 'Adding subject...');
    try {
      final service = Get.find<AdminCourseService>();
      await service.addSubject(
        courseId: widget.course.id,
        name: name,
        teacherId: teacherId,
        order: order,
      );
      await _loadSubjects();
      if (_subjects.isNotEmpty) {
        _selectedIndex = _subjects.length - 1;
      }
      _newSubjectName.clear();
      _newSubjectOrder.text = (_subjects.length + 1).toString();
      _newSubjectTeacher = null;
      success = true;
    } on ApiException catch (e) {
      final handled = await handleNetworkError(e);
      if (!handled) {
        await showErrorDialog(
          context,
          title: 'Add Failed',
          message: e.message,
        );
      }
    } catch (_) {
      await showErrorDialog(
        context,
        title: 'Add Failed',
        message: 'Unable to add subject. Please try again.',
      );
    } finally {
      if (Navigator.of(context, rootNavigator: true).canPop()) {
        Navigator.of(context, rootNavigator: true).pop();
      }
    }
    if (success) {
      await showSuccessDialog(
        context,
        title: 'Added',
        message: 'Subject added successfully.',
      );
    }
  }

  void _handleSaveSubject(_ContentSubject subject) async {
    if (subject.nameController.text.trim().isEmpty) {
      await showErrorDialog(
        context,
        title: 'Required',
        message: 'Subject name is required.',
      );
      return;
    }
    if (subject.teacherLabel == null || subject.teacherLabel!.isEmpty) {
      await showErrorDialog(
        context,
        title: 'Required',
        message: 'Select a teacher.',
      );
      return;
    }
    await showSuccessDialog(
      context,
      title: 'Saved',
      message: 'Subject updated locally. API integration pending.',
    );
  }

  void _handleRemoveSubject(_ContentSubject subject) async {
    if (subject.id.isEmpty) {
      setState(() {
        _subjects.remove(subject);
        if (_selectedIndex >= _subjects.length) {
          _selectedIndex = _subjects.isEmpty ? 0 : _subjects.length - 1;
        }
      });
      return;
    }
    var success = false;
    showLoadingDialog(context, message: 'Removing subject...');
    try {
      final service = Get.find<AdminCourseService>();
      await service.deleteSubject(
        courseId: widget.course.id,
        subjectId: subject.id,
      );
      await _loadSubjects();
      success = true;
    } on ApiException catch (e) {
      final handled = await handleNetworkError(e);
      if (!handled) {
        await showErrorDialog(
          context,
          title: 'Remove Failed',
          message: e.message,
        );
      }
    } catch (_) {
      await showErrorDialog(
        context,
        title: 'Remove Failed',
        message: 'Unable to remove subject. Please try again.',
      );
    } finally {
      if (Navigator.of(context, rootNavigator: true).canPop()) {
        Navigator.of(context, rootNavigator: true).pop();
      }
    }
    if (success) {
      await showSuccessDialog(
        context,
        title: 'Removed',
        message: 'Subject removed successfully.',
      );
    }
  }

  _ContentSubject _mapSubjectWithTeacherLabel(CourseSubject subject) {
    final resolvedLabel = subject.teacherName.isNotEmpty
        ? subject.teacherName
        : _teacherLabelById[subject.teacherId];
    return _ContentSubject(
      id: subject.id,
      name: subject.name,
      teacherLabel: resolvedLabel,
      teacherId: subject.teacherId,
      order: subject.order,
    );
  }
}

class _SubjectTile extends StatelessWidget {
  final _ContentSubject subject;
  final bool isSelected;
  final VoidCallback onTap;

  const _SubjectTile({
    required this.subject,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final borderColor = isSelected
        ? SumAcademyTheme.brandBlue
        : SumAcademyTheme.brandBluePale;
    final background = isSelected
        ? SumAcademyTheme.brandBluePale
        : SumAcademyTheme.white;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        margin: EdgeInsets.only(bottom: 10.h),
        padding: EdgeInsets.all(12.r),
        decoration: BoxDecoration(
          color: background,
          borderRadius: BorderRadius.circular(16.r),
          border: Border.all(color: borderColor),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              subject.nameController.text.trim().isNotEmpty
                  ? subject.nameController.text.trim()
                  : subject.name,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: SumAcademyTheme.darkBase,
                    fontWeight: FontWeight.w600,
                  ),
            ),
            SizedBox(height: 4.h),
            Text(
              subject.teacherLabel ?? 'Teacher',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: SumAcademyTheme.darkBase.withOpacityFloat(0.65),
                  ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ContentSectionCard extends StatelessWidget {
  final String title;
  final String actionLabel;
  final String emptyText;
  final VoidCallback onTap;

  const _ContentSectionCard({
    required this.title,
    required this.actionLabel,
    required this.emptyText,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final borderColor = AdminUi.borderColor(context);
    return Container(
      padding: EdgeInsets.all(16.r),
      decoration: AdminUi.cardDecoration(
        surface: SumAcademyTheme.white,
        border: borderColor,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  title,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: SumAcademyTheme.darkBase,
                        fontWeight: FontWeight.w700,
                      ),
                ),
              ),
              OutlinedButton(
                onPressed: onTap,
                style: OutlinedButton.styleFrom(
                  foregroundColor: SumAcademyTheme.darkBase,
                  side: const BorderSide(color: SumAcademyTheme.brandBluePale),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14.r),
                  ),
                  padding:
                      EdgeInsets.symmetric(horizontal: 14.w, vertical: 8.h),
                ),
                child: Text(actionLabel),
              ),
            ],
          ),
          SizedBox(height: 8.h),
          Text(
            emptyText,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: SumAcademyTheme.darkBase.withOpacityFloat(0.55),
                ),
          ),
        ],
      ),
    );
  }
}

class _ContentSubject {
  final String id;
  final TextEditingController nameController;
  final TextEditingController orderController;
  String? teacherLabel;
  String teacherId;
  final String name;
  int order;

  _ContentSubject({
    required this.id,
    required this.name,
    required this.teacherLabel,
    required this.teacherId,
    required this.order,
  })  : nameController = TextEditingController(text: name),
        orderController = TextEditingController(text: order.toString());

  void dispose() {
    nameController.dispose();
    orderController.dispose();
  }
}

String _teacherLabel(AdminUser teacher) {
  final name = teacher.name.isNotEmpty ? teacher.name : teacher.email;
  if (teacher.email.isNotEmpty && !name.contains(teacher.email)) {
    return '$name (${teacher.email})';
  }
  return name;
}

Color _statusColor(String status) {
  final normalized = status.toLowerCase();
  if (normalized.contains('publish') || normalized.contains('active')) {
    return SumAcademyTheme.success;
  }
  if (normalized.contains('arch') || normalized.contains('inactive')) {
    return SumAcademyTheme.error;
  }
  return SumAcademyTheme.warning;
}

String _capitalize(String text) {
  if (text.isEmpty) return text;
  return '${text[0].toUpperCase()}${text.substring(1).toLowerCase()}';
}
