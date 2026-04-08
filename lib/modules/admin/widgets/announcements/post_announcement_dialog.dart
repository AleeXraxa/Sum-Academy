import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:sum_academy/app/theme.dart';
import 'package:sum_academy/core/widgets/status_dialogs.dart';
import 'package:sum_academy/modules/admin/controllers/admin_announcement_controller.dart';
import 'package:sum_academy/modules/admin/controllers/admin_class_controller.dart';
import 'package:sum_academy/modules/admin/controllers/admin_course_controller.dart';
import 'package:sum_academy/modules/admin/models/admin_announcement.dart';
import 'package:sum_academy/modules/admin/models/admin_class.dart';
import 'package:sum_academy/modules/admin/models/admin_course.dart';

Future<void> showPostAnnouncementDialog(
  BuildContext context, {
  required AdminAnnouncementController controller,
  AdminAnnouncement? announcement,
}) {
  return showDialog(
    context: context,
    barrierDismissible: false,
    builder: (context) => _PostAnnouncementDialog(
      controller: controller,
      announcement: announcement,
    ),
  );
}

class _PostAnnouncementDialog extends StatefulWidget {
  final AdminAnnouncementController controller;
  final AdminAnnouncement? announcement;

  const _PostAnnouncementDialog({
    required this.controller,
    this.announcement,
  });

  @override
  State<_PostAnnouncementDialog> createState() =>
      _PostAnnouncementDialogState();
}

class _PostAnnouncementDialogState extends State<_PostAnnouncementDialog> {
  final _titleController = TextEditingController();
  final _messageController = TextEditingController();
  final _targetIdController = TextEditingController();

  String _targetType = 'system';
  String _audienceRole = 'student';
  bool _sendEmail = false;
  bool _isPinned = false;
  AdminClass? _selectedClass;
  AdminCourse? _selectedCourse;

  @override
  void initState() {
    super.initState();
    final announcement = widget.announcement;
    if (announcement != null) {
      _titleController.text = announcement.title;
      _messageController.text = announcement.message;
      _targetType = announcement.normalizedType.isEmpty
          ? 'system'
          : announcement.normalizedType;
      _audienceRole =
          announcement.audienceRole.isEmpty ? 'student' : announcement.audienceRole;
      _sendEmail = announcement.sendEmail;
      _isPinned = announcement.isPinned;
      _targetIdController.text = announcement.targetId;
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _messageController.dispose();
    _targetIdController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final classes = Get.find<AdminClassController>().classes;
    final courses = Get.find<AdminCourseController>().courses;
    return Dialog(
      backgroundColor: SumAcademyTheme.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(24.r),
      ),
      child: SingleChildScrollView(
        padding: EdgeInsets.all(20.r),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.announcement == null
                            ? 'Post Announcement'
                            : 'Edit Announcement',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                              color: SumAcademyTheme.darkBase,
                              fontWeight: FontWeight.w700,
                            ),
                      ),
                      SizedBox(height: 4.h),
                      Text(
                        'Create or update announcement settings.',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: SumAcademyTheme.darkBase
                                  .withOpacityFloat(0.6),
                            ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  onPressed: () => Navigator.of(context).pop(),
                  icon: const Icon(Icons.close_rounded),
                ),
              ],
            ),
            SizedBox(height: 16.h),
            _InputLabel(text: 'Title'),
            TextField(
              controller: _titleController,
              maxLength: 100,
              decoration: const InputDecoration(
                hintText: 'Enter announcement title',
                counterText: '',
              ),
            ),
            SizedBox(height: 14.h),
            _InputLabel(text: 'Target Type'),
            Wrap(
              spacing: 8.w,
              runSpacing: 8.h,
              children: [
                _TargetChip(
                  label: 'System-wide',
                  isSelected: _targetType == 'system',
                  onTap: () => _setTargetType('system'),
                ),
                _TargetChip(
                  label: 'Class',
                  isSelected: _targetType == 'class',
                  onTap: () => _setTargetType('class'),
                ),
                _TargetChip(
                  label: 'Course',
                  isSelected: _targetType == 'course',
                  onTap: () => _setTargetType('course'),
                ),
                _TargetChip(
                  label: 'Single User',
                  isSelected: _targetType == 'single_user',
                  onTap: () => _setTargetType('single_user'),
                ),
              ],
            ),
            SizedBox(height: 14.h),
            _InputLabel(text: 'Audience'),
            DropdownButtonFormField<String>(
              value: _audienceRole,
              items: const [
                DropdownMenuItem(value: 'student', child: Text('Students')),
                DropdownMenuItem(value: 'teacher', child: Text('Teachers')),
                DropdownMenuItem(value: 'admin', child: Text('Admins')),
                DropdownMenuItem(value: 'all', child: Text('All Users')),
              ],
              onChanged: (value) {
                if (value == null) return;
                setState(() => _audienceRole = value);
              },
            ),
            if (_targetType == 'class') ...[
              SizedBox(height: 14.h),
              _InputLabel(text: 'Select Class'),
              DropdownButtonFormField<AdminClass>(
                value: _selectedClass ??
                    _findClassById(
                      classes,
                      _targetIdController.text,
                    ),
                items: classes
                    .map(
                      (item) => DropdownMenuItem(
                        value: item,
                        child: Text(item.name.isEmpty ? item.code : item.name),
                      ),
                    )
                    .toList(),
                onChanged: (value) {
                  if (value == null) return;
                  setState(() {
                    _selectedClass = value;
                    _targetIdController.text = value.id;
                  });
                },
              ),
            ],
            if (_targetType == 'course') ...[
              SizedBox(height: 14.h),
              _InputLabel(text: 'Select Course'),
              DropdownButtonFormField<AdminCourse>(
                value: _selectedCourse ??
                    _findCourseById(
                      courses,
                      _targetIdController.text,
                    ),
                items: courses
                    .map(
                      (item) => DropdownMenuItem(
                        value: item,
                        child: Text(item.title),
                      ),
                    )
                    .toList(),
                onChanged: (value) {
                  if (value == null) return;
                  setState(() {
                    _selectedCourse = value;
                    _targetIdController.text = value.id;
                  });
                },
              ),
            ],
            if (_targetType == 'single_user') ...[
              SizedBox(height: 14.h),
              _InputLabel(text: 'User ID'),
              TextField(
                controller: _targetIdController,
                decoration: const InputDecoration(
                  hintText: 'Enter user id',
                ),
              ),
            ],
            SizedBox(height: 14.h),
            _InputLabel(text: 'Message'),
            TextField(
              controller: _messageController,
              maxLines: 5,
              decoration: const InputDecoration(
                hintText: 'Write announcement message...',
              ),
            ),
            SizedBox(height: 14.h),
            Row(
              children: [
                Expanded(
                  child: _ToggleRow(
                    label: 'Send Email',
                    value: _sendEmail,
                    onChanged: (value) {
                      setState(() => _sendEmail = value);
                    },
                  ),
                ),
                SizedBox(width: 12.w),
                Expanded(
                  child: _ToggleRow(
                    label: 'Pin to Top',
                    value: _isPinned,
                    onChanged: (value) {
                      setState(() => _isPinned = value);
                    },
                  ),
                ),
              ],
            ),
            SizedBox(height: 18.h),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _handleSubmit,
                style: ElevatedButton.styleFrom(
                  backgroundColor: SumAcademyTheme.brandBlue,
                  foregroundColor: SumAcademyTheme.white,
                  padding: EdgeInsets.symmetric(vertical: 14.h),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(
                      SumAcademyTheme.radiusButton.r,
                    ),
                  ),
                ),
                child: Text(
                  widget.announcement == null
                      ? 'Post Announcement'
                      : 'Update Announcement',
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _setTargetType(String type) {
    setState(() {
      _targetType = type;
      if (type == 'system') {
        _targetIdController.clear();
        _selectedClass = null;
        _selectedCourse = null;
      }
    });
  }

  Future<void> _handleSubmit() async {
    final title = _titleController.text.trim();
    final message = _messageController.text.trim();
    final targetId = _targetType == 'system'
        ? null
        : _targetIdController.text.trim();

    if (title.length < 5) {
      await showErrorDialog(
        context,
        title: 'Invalid Title',
        message: 'Title must be at least 5 characters.',
      );
      return;
    }
    if (message.length < 10) {
      await showErrorDialog(
        context,
        title: 'Invalid Message',
        message: 'Message must be at least 10 characters.',
      );
      return;
    }
    if (_targetType != 'system' && (targetId == null || targetId.isEmpty)) {
      await showErrorDialog(
        context,
        title: 'Target Required',
        message: 'Please select a target for this announcement.',
      );
      return;
    }

    await showLoadingDialog(context, message: 'Posting announcement...');
    var success = false;
    try {
      if (widget.announcement == null) {
        await widget.controller.createAnnouncement(
          title: title,
          message: message,
          targetType: _targetType,
          audienceRole: _audienceRole,
          targetId: targetId,
          sendEmail: _sendEmail,
          isPinned: _isPinned,
        );
      } else {
        await widget.controller.updateAnnouncement(
          announcement: widget.announcement!,
          title: title,
          message: message,
          isPinned: _isPinned,
        );
      }
      success = true;
    } finally {
      if (Get.isDialogOpen ?? false) {
        Navigator.of(context).pop();
      }
    }
    if (success) {
      Navigator.of(context).pop();
    }
  }
}

class _InputLabel extends StatelessWidget {
  final String text;

  const _InputLabel({required this.text});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: 6.h),
      child: Text(
        text.toUpperCase(),
        style: Theme.of(context).textTheme.labelSmall?.copyWith(
              color: SumAcademyTheme.darkBase.withOpacityFloat(0.6),
              letterSpacing: 1.8,
              fontWeight: FontWeight.w700,
            ),
      ),
    );
  }
}

class _TargetChip extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _TargetChip({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final background = isSelected
        ? SumAcademyTheme.brandBlue
        : SumAcademyTheme.surfaceTertiary;
    final textColor = isSelected
        ? SumAcademyTheme.white
        : SumAcademyTheme.darkBase;
    return InkWell(
      borderRadius: BorderRadius.circular(999),
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 8.h),
        decoration: BoxDecoration(
          color: background,
          borderRadius: BorderRadius.circular(999),
          border: Border.all(
            color: isSelected
                ? SumAcademyTheme.brandBlue
                : SumAcademyTheme.brandBluePale,
          ),
        ),
        child: Text(
          label,
          style: Theme.of(context).textTheme.labelLarge?.copyWith(
                color: textColor,
                fontWeight: FontWeight.w600,
              ),
        ),
      ),
    );
  }
}

class _ToggleRow extends StatelessWidget {
  final String label;
  final bool value;
  final ValueChanged<bool> onChanged;

  const _ToggleRow({
    required this.label,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
      decoration: BoxDecoration(
        color: SumAcademyTheme.surfaceTertiary,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: SumAcademyTheme.brandBluePale),
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              label,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: SumAcademyTheme.darkBase,
                    fontWeight: FontWeight.w600,
                  ),
            ),
          ),
          Switch(
            value: value,
            onChanged: onChanged,
            activeColor: SumAcademyTheme.brandBlue,
          ),
        ],
      ),
    );
  }
}

AdminClass? _findClassById(Iterable<AdminClass> list, String id) {
  for (final item in list) {
    if (item.id == id) return item;
  }
  return null;
}

AdminCourse? _findCourseById(Iterable<AdminCourse> list, String id) {
  for (final item in list) {
    if (item.id == id) return item;
  }
  return null;
}
