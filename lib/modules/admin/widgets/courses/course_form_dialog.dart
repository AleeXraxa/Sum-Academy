import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:sum_academy/app/theme.dart';
import 'package:sum_academy/core/widgets/status_dialogs.dart';
import 'package:sum_academy/modules/admin/controllers/admin_course_controller.dart';
import 'package:sum_academy/modules/admin/models/admin_course.dart';
import 'package:sum_academy/modules/admin/models/admin_user.dart';
import 'package:sum_academy/modules/admin/services/admin_teacher_service.dart';
import 'package:sum_academy/modules/admin/widgets/users/user_dialog_fields.dart';

Future<void> showAddCourseDialog(BuildContext context) {
  return showDialog(
    context: context,
    barrierColor: Colors.black.withOpacity(0.45),
    builder: (context) => const CourseFormDialog(),
  );
}

Future<void> showEditCourseDialog(
  BuildContext context, {
  required AdminCourse course,
}) {
  return showDialog(
    context: context,
    barrierColor: Colors.black.withOpacity(0.45),
    builder: (context) => CourseFormDialog(course: course),
  );
}

class CourseFormDialog extends StatefulWidget {
  final AdminCourse? course;

  const CourseFormDialog({super.key, this.course});

  bool get isEdit => course != null;

  @override
  State<CourseFormDialog> createState() => _CourseFormDialogState();
}

class _CourseFormDialogState extends State<CourseFormDialog> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _shortDescController = TextEditingController();
  final _descController = TextEditingController();
  final _priceController = TextEditingController();
  final _discountController = TextEditingController();

  String? _category;
  String? _level;
  String? _status;
  bool _certificateEnabled = true;
  int _stepIndex = 0;
  bool _isSubmitting = false;
  int _shortDescLength = 0;
  double _discountedPrice = 0;

  String? _thumbnailName;

  final List<_SubjectDraft> _subjects = [];
  final List<_TeacherOption> _teacherOptions = [];
  final Map<String, String> _teacherIdByLabel = {};
  bool _teachersLoading = false;

  final List<String> _categories = const [
    'Math',
    'Science',
    'English',
    'Biology',
    'Computer',
  ];

  final List<String> _levels = const [
    'Beginner',
    'Intermediate',
    'Advanced',
  ];

  final List<String> _statuses = const [
    'Draft',
    'Published',
  ];

  @override
  void initState() {
    super.initState();
    final course = widget.course;
    if (course != null) {
      _titleController.text = course.title;
      _shortDescController.text = course.shortDescription;
      _descController.text = course.description;
      _priceController.text =
          course.price == 0 ? '' : course.price.toStringAsFixed(0);
      _discountController.text =
          course.discount == 0 ? '' : course.discount.toStringAsFixed(0);
      _category = course.category.isNotEmpty ? course.category : null;
      _level = course.level.isNotEmpty ? course.level : null;
      _status = course.status.isNotEmpty ? course.status : null;
      _certificateEnabled = course.certificateEnabled;
      _shortDescLength = _shortDescController.text.trim().length;
      _thumbnailName = course.thumbnailUrl.isNotEmpty ? course.thumbnailUrl : null;
    } else {
      _status = _statuses.first;
      _certificateEnabled = true;
    }
    _updateDiscountedPrice();
    _subjects.add(_SubjectDraft(order: 1));
    _loadTeachers();
  }

  @override
  void dispose() {
    _titleController.dispose();
    _shortDescController.dispose();
    _descController.dispose();
    _priceController.dispose();
    _discountController.dispose();
    for (final subject in _subjects) {
      subject.dispose();
    }
    super.dispose();
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
        _teacherOptions.add(_TeacherOption(label: label, id: teacher.uid));
        _teacherIdByLabel[label] = teacher.uid;
      }
    } catch (_) {
      // Ignore teacher load failures for now.
    } finally {
      if (mounted) {
        setState(() => _teachersLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: SumAcademyTheme.white,
      insetPadding: EdgeInsets.symmetric(horizontal: 18.w, vertical: 20.h),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24.r)),
      child: SingleChildScrollView(
        padding: EdgeInsets.all(20.r),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    widget.isEdit ? 'Edit Course' : 'Add Course',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          color: SumAcademyTheme.darkBase,
                          fontWeight: FontWeight.w700,
                        ),
                  ),
                ),
                DialogIconButton(
                  icon: Icons.close_rounded,
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ],
            ),
            SizedBox(height: 12.h),
            _StepIndicator(currentStep: _stepIndex),
            SizedBox(height: 18.h),
            if (_stepIndex == 0) _buildStepOne(context),
            if (_stepIndex == 1) _buildStepTwo(context),
            if (_stepIndex == 2) _buildStepThree(context),
          ],
        ),
      ),
    );
  }

  Widget _buildStepOne(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const DialogLabel(text: 'Title'),
          SizedBox(height: 8.h),
          DialogTextField(
            controller: _titleController,
            hintText: 'Course title',
            textInputAction: TextInputAction.next,
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return 'Title is required';
              }
              return null;
            },
          ),
          SizedBox(height: 14.h),
          const DialogLabel(text: 'Short Description'),
          SizedBox(height: 8.h),
          DialogTextField(
            controller: _shortDescController,
            hintText: 'Short course summary',
            textInputAction: TextInputAction.next,
            maxLines: 3,
            minLines: 3,
            maxLength: 150,
            showCounter: false,
            onChanged: (value) => setState(() {
              _shortDescLength = value.trim().length;
            }),
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return 'Short description is required';
              }
              return null;
            },
          ),
          SizedBox(height: 6.h),
          Align(
            alignment: Alignment.centerLeft,
            child: Text(
              '$_shortDescLength/150',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: SumAcademyTheme.darkBase.withOpacityFloat(0.6),
                  ),
            ),
          ),
          SizedBox(height: 12.h),
          const DialogLabel(text: 'Full Description'),
          SizedBox(height: 8.h),
          DialogTextField(
            controller: _descController,
            hintText: 'Detailed course description',
            textInputAction: TextInputAction.newline,
            maxLines: 5,
            minLines: 5,
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return 'Description is required';
              }
              return null;
            },
          ),
          SizedBox(height: 14.h),
          _fieldPair(
            _buildDropdownField(
              label: 'Category',
              value: _category,
              items: _categories,
              onChanged: (value) => setState(() => _category = value),
            ),
            _buildDropdownField(
              label: 'Level',
              value: _level,
              items: _levels,
              onChanged: (value) => setState(() => _level = value),
            ),
          ),
          SizedBox(height: 14.h),
          _fieldPair(
            _buildField(
              label: 'Price PKR',
              child: DialogTextField(
                controller: _priceController,
                hintText: '0',
                keyboardType: TextInputType.number,
                textInputAction: TextInputAction.next,
                onChanged: (_) => _updateDiscountedPrice(),
              ),
            ),
            _buildField(
              label: 'Discount %',
              child: DialogTextField(
                controller: _discountController,
                hintText: '0',
                keyboardType: TextInputType.number,
                textInputAction: TextInputAction.next,
                onChanged: (_) => _updateDiscountedPrice(),
              ),
            ),
          ),
          SizedBox(height: 8.h),
          Text(
            'Discounted Price: ${_formatPrice(_discountedPrice)}',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: SumAcademyTheme.darkBase.withOpacityFloat(0.7),
                ),
          ),
          SizedBox(height: 14.h),
          _fieldPair(
            _buildDropdownField(
              label: 'Status',
              value: _status,
              items: _statuses,
              onChanged: (value) => setState(() => _status = value),
            ),
            _buildCheckboxField(
              label: 'Certificate on completion',
              value: _certificateEnabled,
              onChanged: (value) =>
                  setState(() => _certificateEnabled = value ?? false),
            ),
          ),
          SizedBox(height: 20.h),
          _StepActions(
            onCancel: () => Navigator.of(context).pop(),
            onNext: _handleStepOneNext,
            nextLabel: 'Next',
          ),
        ],
      ),
    );
  }

  Widget _buildStepTwo(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _UploadBox(
          fileName: _thumbnailName,
          onChoose: () {
            setState(() {
              _thumbnailName = 'thumbnail.png';
            });
          },
        ),
        SizedBox(height: 20.h),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            OutlinedButton(
              onPressed: () => setState(() => _stepIndex = 0),
              child: const Text('Back'),
            ),
            Row(
              children: [
                TextButton(
                  onPressed: () => setState(() => _stepIndex = 2),
                  child: const Text('Skip'),
                ),
                SizedBox(width: 8.w),
                ElevatedButton(
                  onPressed: () => setState(() => _stepIndex = 2),
                  child: const Text('Next'),
                ),
              ],
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildStepThree(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                'Subjects',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: SumAcademyTheme.darkBase,
                      fontWeight: FontWeight.w600,
                    ),
              ),
            ),
            TextButton.icon(
              onPressed: _addSubject,
              icon: const Icon(Icons.add_rounded),
              label: const Text('Add Subject'),
            ),
          ],
        ),
        SizedBox(height: 12.h),
        Column(
          children: [
            for (var i = 0; i < _subjects.length; i++)
              Padding(
                padding: EdgeInsets.only(bottom: 12.h),
                child: _SubjectRow(
                  subject: _subjects[i],
                  teacherOptions:
                      _teacherOptions.map((item) => item.label).toList(),
                  teacherIdByLabel: _teacherIdByLabel,
                  loadingTeachers: _teachersLoading,
                  onDelete: _subjects.length > 1
                      ? () => _removeSubject(i)
                      : null,
                ),
              ),
          ],
        ),
        SizedBox(height: 16.h),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            OutlinedButton(
              onPressed: () => setState(() => _stepIndex = 1),
              child: const Text('Back'),
            ),
            ElevatedButton(
              onPressed: _isSubmitting ? null : _handleSaveCourse,
              child: Text(widget.isEdit ? 'Save Course' : 'Save Course'),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildDropdownField({
    required String label,
    required String? value,
    required List<String> items,
    required ValueChanged<String?> onChanged,
  }) {
    return _buildField(
      label: label,
      child: DialogDropdown(
        value: value,
        hintText: label,
        items: items,
        onChanged: onChanged,
      ),
    );
  }

  Widget _buildCheckboxField({
    required String label,
    required bool value,
    required ValueChanged<bool?> onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const DialogLabel(text: ' '),
        SizedBox(height: 8.h),
        Row(
          children: [
            Checkbox(
              value: value,
              onChanged: onChanged,
              activeColor: SumAcademyTheme.brandBlue,
            ),
            Expanded(
              child: Text(
                label,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: SumAcademyTheme.darkBase,
                      fontWeight: FontWeight.w600,
                    ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildField({required String label, required Widget child}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        DialogLabel(text: label),
        SizedBox(height: 8.h),
        child,
      ],
    );
  }

  Widget _fieldPair(Widget left, Widget right) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isWide = constraints.maxWidth >= 520;
        if (!isWide) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              left,
              SizedBox(height: 14.h),
              right,
            ],
          );
        }
        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(child: left),
            SizedBox(width: 16.w),
            Expanded(child: right),
          ],
        );
      },
    );
  }

  void _handleStepOneNext() {
    final isValid = _formKey.currentState?.validate() ?? false;
    if (!isValid) {
      return;
    }
    if (_category == null || _category!.trim().isEmpty) {
      showErrorDialog(context, title: 'Required', message: 'Select a category.');
      return;
    }
    if (_level == null || _level!.trim().isEmpty) {
      showErrorDialog(context, title: 'Required', message: 'Select a level.');
      return;
    }
    if (_status == null || _status!.trim().isEmpty) {
      showErrorDialog(context, title: 'Required', message: 'Select a status.');
      return;
    }
    setState(() => _stepIndex = 1);
  }

  void _addSubject() {
    setState(() {
      _subjects.add(_SubjectDraft(order: _subjects.length + 1));
    });
  }

  void _removeSubject(int index) {
    final subject = _subjects.removeAt(index);
    subject.dispose();
    setState(() {});
  }

  Future<void> _handleSaveCourse() async {
    final controller = Get.find<AdminCourseController>();
    final title = _titleController.text.trim();
    final shortDesc = _shortDescController.text.trim();
    final description = _descController.text.trim();
    final category = _category ?? '';
    final level = _level ?? '';
    final status = _status ?? _statuses.first;
    final price = double.tryParse(_priceController.text.trim()) ?? 0;
    final discount = double.tryParse(_discountController.text.trim()) ?? 0;

    final subjects = <CourseSubjectInput>[];
    for (final subject in _subjects) {
      final name = subject.nameController.text.trim();
      if (name.isEmpty) continue;
      final teacherLabel = subject.teacherLabel;
      if (teacherLabel == null || teacherLabel.isEmpty) {
        await showErrorDialog(
          context,
          title: 'Required',
          message: 'Select teacher for "$name".',
        );
        return;
      }
      final teacherId = _teacherIdByLabel[teacherLabel] ?? '';
      if (teacherId.isEmpty) {
        await showErrorDialog(
          context,
          title: 'Required',
          message: 'Select a valid teacher for "$name".',
        );
        return;
      }
      final order = int.tryParse(subject.orderController.text.trim()) ?? 1;
      subjects.add(
        CourseSubjectInput(name: name, teacherId: teacherId, order: order),
      );
    }
    if (subjects.isEmpty) {
      await showErrorDialog(
        context,
        title: 'Required',
        message: 'At least one subject is required.',
      );
      return;
    }

    setState(() => _isSubmitting = true);
    final overlayContext = Get.context ?? context;
    showLoadingDialog(overlayContext, message: 'Saving course...');
    late final result;
    try {
      if (widget.isEdit) {
        result = await controller.updateCourse(
          courseId: widget.course!.id,
          title: title,
          shortDescription: shortDesc,
          description: description,
          category: category,
          level: level,
          price: price,
          discount: discount,
          status: status,
          certificateEnabled: _certificateEnabled,
          thumbnailUrl: _thumbnailName,
        );
      } else {
        result = await controller.createCourse(
          title: title,
          shortDescription: shortDesc,
          description: description,
          category: category,
          level: level,
          price: price,
          discount: discount,
          status: status,
          certificateEnabled: _certificateEnabled,
          thumbnailUrl: _thumbnailName,
          subjects: subjects,
        );
      }
    } finally {
      if (Navigator.of(overlayContext, rootNavigator: true).canPop()) {
        Navigator.of(overlayContext, rootNavigator: true).pop();
      }
    }
    if (mounted) {
      setState(() => _isSubmitting = false);
    }
    if (!mounted) return;

    if (result.isSuccess) {
      Navigator.of(context).pop();
      await showSuccessDialog(
        overlayContext,
        title: widget.isEdit ? 'Course Updated' : 'Course Created',
        message: result.message,
      );
    } else {
      if (result.isNetworkError) {
        await showNoInternetDialog(
          overlayContext,
          message: result.message,
        );
        return;
      }
      await showErrorDialog(
        overlayContext,
        title: 'Save Failed',
        message: result.message,
      );
    }
  }

  void _updateDiscountedPrice() {
    final price = double.tryParse(_priceController.text.trim()) ?? 0;
    final discount = double.tryParse(_discountController.text.trim()) ?? 0;
    setState(() {
      _discountedPrice = price - (price * (discount / 100));
      if (_discountedPrice.isNaN || _discountedPrice < 0) {
        _discountedPrice = 0;
      }
    });
  }
}

class _StepIndicator extends StatelessWidget {
  final int currentStep;

  const _StepIndicator({required this.currentStep});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: List.generate(3, (index) {
        final isActive = index == currentStep;
        return Container(
          margin: EdgeInsets.only(right: 8.w),
          width: 28.r,
          height: 28.r,
          decoration: BoxDecoration(
            color: isActive ? SumAcademyTheme.brandBlue : SumAcademyTheme.white,
            borderRadius: BorderRadius.circular(14.r),
            border: Border.all(
              color: isActive
                  ? SumAcademyTheme.brandBlue
                  : SumAcademyTheme.brandBluePale,
            ),
          ),
          alignment: Alignment.center,
          child: Text(
            '${index + 1}',
            style: Theme.of(context).textTheme.labelMedium?.copyWith(
                  color: isActive
                      ? SumAcademyTheme.white
                      : SumAcademyTheme.darkBase.withOpacityFloat(0.6),
                  fontWeight: FontWeight.w600,
                ),
          ),
        );
      }),
    );
  }
}

class _StepActions extends StatelessWidget {
  final VoidCallback onCancel;
  final VoidCallback onNext;
  final String nextLabel;

  const _StepActions({
    required this.onCancel,
    required this.onNext,
    required this.nextLabel,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        OutlinedButton(
          onPressed: onCancel,
          child: const Text('Cancel'),
        ),
        SizedBox(width: 12.w),
        ElevatedButton(
          onPressed: onNext,
          child: Text(nextLabel),
        ),
      ],
    );
  }
}

class _UploadBox extends StatelessWidget {
  final String? fileName;
  final VoidCallback onChoose;

  const _UploadBox({
    required this.fileName,
    required this.onChoose,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 20.h),
      decoration: BoxDecoration(
        color: SumAcademyTheme.surfaceSecondary,
        borderRadius: BorderRadius.circular(18.r),
        border: Border.all(color: SumAcademyTheme.brandBluePale),
      ),
      child: Column(
        children: [
          Icon(
            Icons.cloud_upload_outlined,
            color: SumAcademyTheme.brandBlue,
            size: 36.sp,
          ),
          SizedBox(height: 8.h),
          Text(
            'Upload thumbnail',
            style: Theme.of(context).textTheme.labelLarge?.copyWith(
                  color: SumAcademyTheme.darkBase,
                  fontWeight: FontWeight.w600,
                ),
          ),
          SizedBox(height: 4.h),
          Text(
            'JPG, PNG, WEBP - max 5MB',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: SumAcademyTheme.darkBase.withOpacityFloat(0.6),
                ),
          ),
          SizedBox(height: 12.h),
          OutlinedButton(
            onPressed: onChoose,
            child: const Text('Choose File'),
          ),
          if (fileName != null && fileName!.isNotEmpty) ...[
            SizedBox(height: 8.h),
            Text(
              fileName!,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: SumAcademyTheme.darkBase.withOpacityFloat(0.6),
                  ),
            ),
          ],
        ],
      ),
    );
  }
}

class _SubjectDraft {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController orderController;
  String? teacherLabel;

  _SubjectDraft({int order = 1})
      : orderController = TextEditingController(text: order.toString());

  void dispose() {
    nameController.dispose();
    orderController.dispose();
  }
}

class _SubjectRow extends StatelessWidget {
  final _SubjectDraft subject;
  final List<String> teacherOptions;
  final Map<String, String> teacherIdByLabel;
  final bool loadingTeachers;
  final VoidCallback? onDelete;

  const _SubjectRow({
    required this.subject,
    required this.teacherOptions,
    required this.teacherIdByLabel,
    required this.loadingTeachers,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(12.r),
      decoration: BoxDecoration(
        color: SumAcademyTheme.white,
        borderRadius: BorderRadius.circular(18.r),
        border: Border.all(color: SumAcademyTheme.brandBluePale),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: _SubjectField(
                  label: 'Subject Name',
                  child: DialogTextField(
                    controller: subject.nameController,
                    hintText: 'Subject name',
                    textInputAction: TextInputAction.next,
                  ),
                ),
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: _SubjectField(
                  label: 'Teacher',
                  child: DialogDropdown(
                    value: subject.teacherLabel,
                    hintText: loadingTeachers ? 'Loading...' : 'Select teacher',
                    items: teacherOptions,
                    enabled: !loadingTeachers,
                    onChanged: (value) {
                      subject.teacherLabel = value;
                    },
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 12.h),
          Row(
            children: [
              SizedBox(
                width: 90.w,
                child: _SubjectField(
                  label: 'Order',
                  child: DialogTextField(
                    controller: subject.orderController,
                    hintText: '1',
                    keyboardType: TextInputType.number,
                  ),
                ),
              ),
              const Spacer(),
              if (onDelete != null)
                IconButton(
                  onPressed: onDelete,
                  icon: const Icon(Icons.close_rounded),
                  color: SumAcademyTheme.error,
                ),
            ],
          ),
        ],
      ),
    );
  }
}

class _SubjectField extends StatelessWidget {
  final String label;
  final Widget child;

  const _SubjectField({required this.label, required this.child});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        DialogLabel(text: label),
        SizedBox(height: 8.h),
        child,
      ],
    );
  }
}

class _TeacherOption {
  final String label;
  final String id;

  const _TeacherOption({required this.label, required this.id});
}

String _teacherLabel(AdminUser teacher) {
  final name = teacher.name.isNotEmpty ? teacher.name : teacher.email;
  if (teacher.email.isNotEmpty && !name.contains(teacher.email)) {
    return '$name (${teacher.email})';
  }
  return name;
}

String _formatPrice(double value) {
  return 'PKR ${value.toStringAsFixed(0)}';
}
