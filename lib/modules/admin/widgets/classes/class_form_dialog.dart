
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:sum_academy/app/theme.dart';
import 'package:sum_academy/core/services/api_exception.dart';
import 'package:sum_academy/core/utils/network_error.dart';
import 'package:sum_academy/core/widgets/status_dialogs.dart';
import 'package:sum_academy/modules/admin/controllers/admin_class_controller.dart';
import 'package:sum_academy/modules/admin/models/admin_class.dart';
import 'package:sum_academy/modules/admin/models/admin_course.dart';
import 'package:sum_academy/modules/admin/models/admin_user.dart';
import 'package:sum_academy/modules/admin/services/admin_class_service.dart';
import 'package:sum_academy/modules/admin/services/admin_course_service.dart';
import 'package:sum_academy/modules/admin/services/admin_teacher_service.dart';
import 'package:sum_academy/modules/admin/widgets/users/user_dialog_fields.dart';

Future<void> showAddClassDialog(BuildContext context) {
  return showDialog(
    context: context,
    barrierColor: Colors.black.withOpacity(0.45),
    builder: (context) => const ClassFormDialog(),
  );
}

Future<void> showEditClassDialog(
  BuildContext context, {
  required AdminClass classItem,
}) {
  return showDialog(
    context: context,
    barrierColor: Colors.black.withOpacity(0.45),
    builder: (context) => ClassFormDialog(classItem: classItem),
  );
}

class ClassFormDialog extends StatefulWidget {
  final AdminClass? classItem;

  const ClassFormDialog({super.key, this.classItem});

  @override
  State<ClassFormDialog> createState() => _ClassFormDialogState();
}

class _ClassFormDialogState extends State<ClassFormDialog> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _capacityController = TextEditingController();
  final _startDateController = TextEditingController();
  final _endDateController = TextEditingController();
  final _statuses = const [
    'Active',
    'Upcoming',
    'Inactive',
    'Archived',
    'Completed',
  ];

  int _currentStep = 0;
  String? _status;
  DateTime? _startDate;
  DateTime? _endDate;
  bool _isSubmitting = false;

  bool _coursesLoading = false;
  bool _teachersLoading = false;
  final List<AdminCourse> _availableCourses = [];
  final List<String> _courseOptions = [];
  final Map<String, String> _courseIdByLabel = {};
  String? _selectedCourseLabel;
  final List<_SelectedCourse> _selectedCourses = [];

  final List<String> _teacherOptions = [];
  final Map<String, String> _teacherIdByLabel = {};

  final List<_ShiftInput> _shifts = [];

  bool get _isEditing => widget.classItem != null;

  @override
  void initState() {
    super.initState();
    _bootstrap();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _capacityController.dispose();
    _startDateController.dispose();
    _endDateController.dispose();
    for (final shift in _shifts) {
      shift.dispose();
    }
    super.dispose();
  }

  Future<void> _bootstrap() async {
    final classItem = widget.classItem;
    if (classItem != null) {
      _nameController.text = classItem.name;
      _descriptionController.text = classItem.description;
      _capacityController.text = classItem.capacity.toString();
      _startDate = classItem.startDate;
      _endDate = classItem.endDate;
      _startDateController.text = _formatDateShort(_startDate) ?? '';
      _endDateController.text = _formatDateShort(_endDate) ?? '';
      _status = _resolveStatus(classItem.status) ?? _statuses.first;
    } else {
      _status = _statuses.first;
    }
    await _loadCourses();
    await _loadTeachers();
  }

  Future<void> _loadCourses() async {
    setState(() => _coursesLoading = true);
    try {
      final service = Get.find<AdminCourseService>();
      final courses = await service.fetchCourses(page: 1, limit: 100);
      _availableCourses
        ..clear()
        ..addAll(courses);
      _courseOptions.clear();
      _courseIdByLabel.clear();
      for (final course in courses) {
        final label = _courseLabel(course);
        _courseOptions.add(label);
        _courseIdByLabel[label] = course.id;
      }
    } catch (_) {
      // ignore
    } finally {
      if (mounted) {
        setState(() => _coursesLoading = false);
      }
    }
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
      }
    } catch (_) {
      // ignore
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
      insetPadding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 24.h),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(24.r),
      ),
      child: SingleChildScrollView(
        padding: EdgeInsets.all(20.r),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      _isEditing ? 'Edit Class' : 'Add Class',
                      style:
                          Theme.of(context).textTheme.headlineSmall?.copyWith(
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
              SizedBox(height: 14.h),
              Row(
                children: [
                  _StepPill(
                    label: 'Step 1',
                    isActive: _currentStep == 0,
                    isDone: _currentStep > 0,
                  ),
                  SizedBox(width: 8.w),
                  _StepPill(
                    label: 'Step 2',
                    isActive: _currentStep == 1,
                    isDone: _currentStep > 1,
                  ),
                  SizedBox(width: 8.w),
                  _StepPill(
                    label: 'Step 3',
                    isActive: _currentStep == 2,
                    isDone: false,
                  ),
                ],
              ),
              SizedBox(height: 18.h),
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 250),
                child: _buildStepContent(context),
              ),
              SizedBox(height: 18.h),
              Divider(color: SumAcademyTheme.brandBluePale),
              SizedBox(height: 14.h),
              _buildFooter(context),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStepContent(BuildContext context) {
    switch (_currentStep) {
      case 0:
        return _buildStepOne(context);
      case 1:
        return _buildStepTwo(context);
      case 2:
        return _buildStepThree(context);
      default:
        return const SizedBox.shrink();
    }
  }

  Widget _buildStepOne(BuildContext context) {
    return Column(
      key: const ValueKey('step1'),
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildField(
          label: 'Class Name',
          child: DialogTextField(
            controller: _nameController,
            hintText: 'Class name',
            keyboardType: TextInputType.text,
            textInputAction: TextInputAction.next,
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return 'Class name is required';
              }
              if (value.trim().length < 2) {
                return 'Enter at least 2 characters';
              }
              return null;
            },
          ),
        ),
        SizedBox(height: 14.h),
        _buildField(
          label: 'Description',
          child: DialogTextField(
            controller: _descriptionController,
            hintText: 'Class description',
            textInputAction: TextInputAction.newline,
            keyboardType: TextInputType.multiline,
            maxLines: 3,
            minLines: 3,
          ),
        ),
        SizedBox(height: 14.h),
        _fieldPair(
          _buildDateField(
            label: 'Start Date',
            controller: _startDateController,
            onTap: () => _pickDate(isStart: true),
          ),
          _buildDateField(
            label: 'End Date',
            controller: _endDateController,
            onTap: () => _pickDate(isStart: false),
          ),
        ),
        SizedBox(height: 14.h),
        _fieldPair(
          _buildField(
            label: 'Capacity',
            child: DialogTextField(
              controller: _capacityController,
              hintText: 'Total students',
              keyboardType: TextInputType.number,
              textInputAction: TextInputAction.next,
              validator: (value) {
                final input = value?.trim() ?? '';
                if (input.isEmpty) {
                  return 'Capacity is required';
                }
                final parsed = int.tryParse(input);
                if (parsed == null || parsed <= 0) {
                  return 'Enter a valid number';
                }
                return null;
              },
            ),
          ),
          _buildField(
            label: 'Status',
            child: DialogDropdown(
              value: _status,
              hintText: 'Select status',
              items: _statuses,
              onChanged: (value) => setState(() => _status = value),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildStepTwo(BuildContext context) {
    return Column(
      key: const ValueKey('step2'),
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: EdgeInsets.all(12.r),
          decoration: BoxDecoration(
            color: SumAcademyTheme.surfaceSecondary,
            borderRadius: BorderRadius.circular(16.r),
            border: Border.all(color: SumAcademyTheme.brandBluePale),
          ),
          child: Row(
            children: [
              Expanded(
                child: DialogDropdown(
                  value: _selectedCourseLabel,
                  hintText: _coursesLoading ? 'Loading...' : 'Select course',
                  items: _courseOptions,
                  enabled: !_coursesLoading,
                  onChanged: (value) =>
                      setState(() => _selectedCourseLabel = value),
                ),
              ),
              SizedBox(width: 12.w),
              ElevatedButton(
                onPressed: _handleAddCourse,
                style: ElevatedButton.styleFrom(
                  backgroundColor: SumAcademyTheme.brandBlue,
                  foregroundColor: SumAcademyTheme.white,
                  padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14.r),
                  ),
                ),
                child: const Text('Add Course'),
              ),
            ],
          ),
        ),
        SizedBox(height: 12.h),
        if (_selectedCourses.isEmpty)
          Container(
            width: double.infinity,
            padding: EdgeInsets.symmetric(vertical: 22.h),
            decoration: BoxDecoration(
              color: SumAcademyTheme.surfaceSecondary,
              borderRadius: BorderRadius.circular(16.r),
              border: Border.all(color: SumAcademyTheme.brandBluePale),
            ),
            child: Center(
              child: Text(
                'No courses assigned yet.',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: SumAcademyTheme.darkBase.withOpacityFloat(0.6),
                    ),
              ),
            ),
          )
        else
          Column(
            children: _selectedCourses
                .map(
                  (course) => Padding(
                    padding: EdgeInsets.only(bottom: 10.h),
                    child: _CourseItemTile(
                      course: course,
                      onRemove: () => _removeCourse(course.id),
                    ),
                  ),
                )
                .toList(),
          ),
      ],
    );
  }

  Widget _buildStepThree(BuildContext context) {
    return Column(
      key: const ValueKey('step3'),
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ElevatedButton.icon(
          onPressed: _addShift,
          icon: const Icon(Icons.add_rounded),
          label: const Text('Add Shift'),
          style: ElevatedButton.styleFrom(
            backgroundColor: SumAcademyTheme.brandBlue,
            foregroundColor: SumAcademyTheme.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14.r),
            ),
            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 10.h),
          ),
        ),
        SizedBox(height: 12.h),
        if (_shifts.isEmpty)
          Container(
            width: double.infinity,
            padding: EdgeInsets.symmetric(vertical: 22.h),
            decoration: BoxDecoration(
              color: SumAcademyTheme.surfaceSecondary,
              borderRadius: BorderRadius.circular(16.r),
              border: Border.all(color: SumAcademyTheme.brandBluePale),
            ),
            child: Center(
              child: Text(
                'No shifts added yet.',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: SumAcademyTheme.darkBase.withOpacityFloat(0.6),
                    ),
              ),
            ),
          )
        else
          Column(
            children: _shifts
                .map(
                  (shift) => Padding(
                    padding: EdgeInsets.only(bottom: 12.h),
                    child: _ShiftCard(
                      shift: shift,
                      courses: _selectedCourses.isNotEmpty
                          ? _selectedCourses
                          : _courseOptions
                              .map(
                                (label) => _SelectedCourse(
                                  id: _courseIdByLabel[label] ?? '',
                                  title: label,
                                  subtitle: '',
                                ),
                              )
                              .toList(),
                      teachers: _teacherOptions,
                      teachersLoading: _teachersLoading,
                      onRemove: () => _removeShift(shift),
                      onPickStart: () => _pickTime(shift, isStart: true),
                      onPickEnd: () => _pickTime(shift, isStart: false),
                      onChanged: () => setState(() {}),
                      onCourseChanged: (value) {
                        if (value == null) return;
                        setState(() {
                          shift.courseLabel = value;
                          shift.courseId = _courseIdByLabel[value] ?? '';
                        });
                      },
                      onTeacherChanged: (value) {
                        if (value == null) return;
                        setState(() {
                          shift.teacherLabel = value;
                          shift.teacherId = _teacherIdByLabel[value] ?? '';
                        });
                      },
                    ),
                  ),
                )
                .toList(),
          ),
      ],
    );
  }

  Widget _buildFooter(BuildContext context) {
    return Row(
      children: [
        OutlinedButton(
          onPressed: () => Navigator.of(context).pop(),
          style: OutlinedButton.styleFrom(
            foregroundColor: SumAcademyTheme.darkBase,
            side: const BorderSide(color: SumAcademyTheme.brandBluePale),
            padding: EdgeInsets.symmetric(horizontal: 18.w, vertical: 12.h),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(
                SumAcademyTheme.radiusButton.r,
              ),
            ),
          ),
          child: const Text('Cancel'),
        ),
        const Spacer(),
        if (_currentStep > 0)
          OutlinedButton(
            onPressed: () => setState(() => _currentStep -= 1),
            style: OutlinedButton.styleFrom(
              foregroundColor: SumAcademyTheme.darkBase,
              side: const BorderSide(color: SumAcademyTheme.brandBluePale),
              padding: EdgeInsets.symmetric(horizontal: 18.w, vertical: 12.h),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(
                  SumAcademyTheme.radiusButton.r,
                ),
              ),
            ),
            child: const Text('Back'),
          ),
        SizedBox(width: 12.w),
        if (_currentStep < 2)
          ElevatedButton(
            onPressed: _handleNext,
            style: ElevatedButton.styleFrom(
              backgroundColor: SumAcademyTheme.brandBlue,
              foregroundColor: SumAcademyTheme.white,
              padding: EdgeInsets.symmetric(horizontal: 18.w, vertical: 12.h),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(
                  SumAcademyTheme.radiusButton.r,
                ),
              ),
            ),
            child: const Text('Next'),
          )
        else
          ElevatedButton(
            onPressed: _isSubmitting ? null : _handleSubmit,
            style: ElevatedButton.styleFrom(
              backgroundColor: SumAcademyTheme.brandBlue,
              foregroundColor: SumAcademyTheme.white,
              padding: EdgeInsets.symmetric(horizontal: 18.w, vertical: 12.h),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(
                  SumAcademyTheme.radiusButton.r,
                ),
              ),
            ),
            child: Text(_isEditing ? 'Update Class' : 'Create Class'),
          ),
      ],
    );
  }

  void _handleNext() async {
    if (_currentStep == 0) {
      if (!(_formKey.currentState?.validate() ?? false)) {
        await showErrorDialog(
          Get.context ?? context,
          title: 'Required',
          message: 'Please fix the highlighted fields.',
        );
        return;
      }
      if (_startDate != null && _endDate != null) {
        if (_endDate!.isBefore(_startDate!)) {
          await showErrorDialog(
            Get.context ?? context,
            title: 'Invalid Dates',
            message: 'End date must be after start date.',
          );
          return;
        }
      }
    }
    setState(() => _currentStep += 1);
  }

  Future<void> _handleSubmit() async {
    if (!(_formKey.currentState?.validate() ?? false)) {
      await showErrorDialog(
        Get.context ?? context,
        title: 'Required',
        message: 'Please fix the highlighted fields.',
      );
      setState(() => _currentStep = 0);
      return;
    }

    if (_selectedCourses.isEmpty) {
      await showErrorDialog(
        context,
        title: 'Required',
        message: 'At least 1 course is required.',
      );
      setState(() => _currentStep = 1);
      return;
    }

    final shiftPayloads = _shifts
        .map(_buildShiftPayload)
        .whereType<Map<String, dynamic>>()
        .toList();
    if (shiftPayloads.isEmpty) {
      await showErrorDialog(
        context,
        title: 'Required',
        message: 'At least 1 shift is required.',
      );
      setState(() => _currentStep = 2);
      return;
    }

    final timeError = _validateShiftTimes();
    if (timeError != null) {
      await showErrorDialog(
        context,
        title: 'Invalid Time',
        message: timeError,
      );
      setState(() => _currentStep = 2);
      return;
    }

    final courseError = _validateShiftCourses();
    if (courseError != null) {
      await showErrorDialog(
        context,
        title: 'Required',
        message: courseError,
      );
      setState(() => _currentStep = 2);
      return;
    }

    final name = _nameController.text.trim();
    final description = _descriptionController.text.trim();
    final capacity = int.tryParse(_capacityController.text.trim()) ?? 0;
    final status = (_status ?? _statuses.first).toLowerCase();
    final courseIds = _selectedCourses
        .map((course) => course.id)
        .where((id) => id.isNotEmpty)
        .toList();

    setState(() => _isSubmitting = true);
    final controller = Get.find<AdminClassController>();
    final classService = Get.find<AdminClassService>();
    final overlayContext = Get.context ?? context;
    showLoadingDialog(
      overlayContext,
      message: _isEditing ? 'Updating class...' : 'Creating class...',
    );
    late final ClassActionResult result;
    try {
      if (_isEditing) {
        result = await controller.updateClass(
          classId: widget.classItem!.id,
          name: name,
          description: description,
          capacity: capacity,
          status: status,
          startDate: _startDate,
          endDate: _endDate,
          courseIds: courseIds,
          shifts: shiftPayloads,
        );
      } else {
        result = await controller.createClass(
          name: name,
          description: description,
          capacity: capacity,
          status: status,
          startDate: _startDate,
          endDate: _endDate,
          courseIds: courseIds,
          shifts: shiftPayloads,
        );
      }

    if (result.isSuccess) {
      final classId = _isEditing
          ? widget.classItem!.id
          : result.classItem?.id ?? '';
      if (classId.isNotEmpty) {
        final shiftCount = result.classItem?.shiftCount ?? 0;
        if (shiftPayloads.isNotEmpty && shiftCount == 0) {
          await _submitShifts(classService, classId);
        }
      }
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
        title: _isEditing ? 'Class Updated' : 'Class Created',
        message: result.message,
      );
    } else {
      if (result.isNetworkError) {
        await showNoInternetDialogOnce(message: result.message);
        return;
      }
      await showErrorDialog(
        overlayContext,
        title: _isEditing ? 'Update Failed' : 'Create Failed',
        message: result.message,
      );
    }
  }

  Future<void> _submitCourses(
    AdminClassService service,
    String classId,
  ) async {
    if (_selectedCourses.isEmpty) return;
    try {
      for (final course in _selectedCourses) {
        if (course.id.isEmpty) continue;
        await service.addCourseToClass(
          classId: classId,
          courseId: course.id,
        );
      }
    } on ApiException catch (e) {
      final message = e.message.toLowerCase();
      if (message.contains('already assigned')) {
        return;
      }
      if (e.statusCode == 0) {
        await showNoInternetDialogOnce(message: e.message);
      } else {
        await showErrorDialog(
          context,
          title: 'Courses',
          message: e.message,
        );
      }
    } catch (_) {
      await showErrorDialog(
        context,
        title: 'Courses',
        message: 'Failed to assign courses.',
      );
    }
  }

  Future<void> _submitShifts(
    AdminClassService service,
    String classId,
  ) async {
    if (_shifts.isEmpty) return;
    for (final shift in _shifts) {
      final payload = _buildShiftPayload(shift);
      if (payload == null) continue;
      try {
        await service.addShift(classId: classId, payload: payload);
      } on ApiException catch (e) {
        if (e.statusCode == 0) {
          await showNoInternetDialogOnce(message: e.message);
          return;
        }
        await showErrorDialog(
          context,
          title: 'Shifts',
          message: e.message,
        );
        return;
      } catch (_) {
        await showErrorDialog(
          context,
          title: 'Shifts',
          message: 'Failed to add shifts.',
        );
        return;
      }
    }
  }

  Map<String, dynamic>? _buildShiftPayload(_ShiftInput shift) {
    final name = shift.shiftName ?? '';
    final start = _normalizeTimeText(
      shift.startController.text.trim(),
      shift.startTime,
    );
    final end = _normalizeTimeText(
      shift.endController.text.trim(),
      shift.endTime,
    );
    final resolvedCourseId = (shift.courseId ?? '').isNotEmpty
        ? shift.courseId!
        : _resolveCourseId(shift.courseLabel);
    final resolvedTeacherId = (shift.teacherId ?? '').isNotEmpty
        ? shift.teacherId!
        : _teacherIdByLabel[shift.teacherLabel] ?? '';
    if (name.isEmpty ||
        start == null ||
        start.isEmpty ||
        end == null ||
        end.isEmpty ||
        resolvedCourseId.isEmpty) {
      return null;
    }
    final payload = <String, dynamic>{
      'name': name,
      'startTime': start,
      'endTime': end,
      'courseId': resolvedCourseId,
      'days': shift.days.toList(),
    };
    if (resolvedTeacherId.isNotEmpty) {
      payload['teacherId'] = resolvedTeacherId;
    }
    final room = shift.roomController.text.trim();
    if (room.isNotEmpty) {
      payload['room'] = room;
    }
    return payload;
  }

  String? _validateShiftTimes() {
    for (final shift in _shifts) {
      final start = _parseTimeToMinutes(
        shift.startController.text.trim(),
        shift.startTime,
      );
      final end = _parseTimeToMinutes(
        shift.endController.text.trim(),
        shift.endTime,
      );
      if (start == null || end == null) {
        return 'Please select valid start and end times.';
      }
      if (end <= start) {
        return 'End time must be after start time.';
      }
    }
    return null;
  }

  String? _validateShiftCourses() {
    for (final shift in _shifts) {
      final resolvedCourseId = (shift.courseId ?? '').isNotEmpty
          ? shift.courseId!
          : _resolveCourseId(shift.courseLabel);
      if (resolvedCourseId.isEmpty) {
        return 'Please select a course for each shift.';
      }
    }
    return null;
  }

  String _resolveCourseId(String? label) {
    if (label == null || label.trim().isEmpty) return '';
    final direct = _courseIdByLabel[label];
    if (direct != null && direct.isNotEmpty) return direct;
    for (final course in _selectedCourses) {
      if (course.title == label) {
        return course.id;
      }
    }
    return '';
  }

  void _handleAddCourse() async {
    if (_selectedCourseLabel == null || _selectedCourseLabel!.isEmpty) {
      await showErrorDialog(
        context,
        title: 'Required',
        message: 'Select a course to add.',
      );
      return;
    }
    final label = _selectedCourseLabel!;
    final id = _courseIdByLabel[label] ?? '';
    if (id.isEmpty) {
      await showErrorDialog(
        context,
        title: 'Required',
        message: 'Select a valid course.',
      );
      return;
    }
    if (_selectedCourses.any((course) => course.id == id)) {
      return;
    }
    final course = _availableCourses.firstWhere(
      (item) => item.id == id,
      orElse: () => AdminCourse(
        id: id,
        title: label,
        shortDescription: '',
        description: '',
        category: '',
        level: '',
        price: 0,
        discount: 0,
        status: '',
        certificateEnabled: false,
        thumbnailUrl: '',
        subjectCount: 0,
        teacherCount: 0,
        enrolledCount: 0,
        isArchived: false,
      ),
    );
    setState(() {
      _selectedCourses.add(
        _SelectedCourse(
          id: id,
          title: label,
          subtitle: course.category,
        ),
      );
      _selectedCourseLabel = null;
    });
  }

  void _removeCourse(String id) {
    setState(() {
      _selectedCourses.removeWhere((course) => course.id == id);
    });
  }

  void _addShift() {
    setState(() {
      _shifts.add(_ShiftInput());
    });
  }

  void _removeShift(_ShiftInput shift) {
    setState(() {
      shift.dispose();
      _shifts.remove(shift);
    });
  }

  Future<void> _pickDate({required bool isStart}) async {
    final now = DateTime.now();
    final initial = isStart ? _startDate ?? now : _endDate ?? _startDate ?? now;
    final picked = await showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: DateTime(now.year - 2),
      lastDate: DateTime(now.year + 5),
    );
    if (picked == null) return;
    setState(() {
      if (isStart) {
        _startDate = picked;
        _startDateController.text = _formatDateShort(picked) ?? '';
      } else {
        _endDate = picked;
        _endDateController.text = _formatDateShort(picked) ?? '';
      }
    });
  }

  Future<void> _pickTime(_ShiftInput shift, {required bool isStart}) async {
    final initial = TimeOfDay.now();
    final picked = await showTimePicker(
      context: context,
      initialTime: initial,
    );
    if (picked == null) return;
    setState(() {
      if (isStart) {
        shift.startTime = picked;
        shift.startController.text = _formatTime(picked);
      } else {
        shift.endTime = picked;
        shift.endController.text = _formatTime(picked);
      }
    });
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
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(child: left),
        SizedBox(width: 16.w),
        Expanded(child: right),
      ],
    );
  }

  Widget _buildDateField({
    required String label,
    required TextEditingController controller,
    required VoidCallback onTap,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        DialogLabel(text: label),
        SizedBox(height: 8.h),
        GestureDetector(
          onTap: onTap,
          child: AbsorbPointer(
            child: DialogTextField(
              controller: controller,
              hintText: 'Select date',
              textInputAction: TextInputAction.next,
              suffixIcon: Icon(
                Icons.calendar_month_rounded,
                size: 18.sp,
                color: SumAcademyTheme.darkBase,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _StepPill extends StatelessWidget {
  final String label;
  final bool isActive;
  final bool isDone;

  const _StepPill({
    required this.label,
    required this.isActive,
    required this.isDone,
  });

  @override
  Widget build(BuildContext context) {
    final background = isActive
        ? SumAcademyTheme.brandBlue
        : isDone
            ? SumAcademyTheme.successLight
            : SumAcademyTheme.surfaceSecondary;
    final color = isActive
        ? SumAcademyTheme.white
        : isDone
            ? SumAcademyTheme.success
            : SumAcademyTheme.darkBase.withOpacityFloat(0.65);

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 6.h),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(SumAcademyTheme.radiusPill.r),
      ),
      child: Text(
        label,
        style: Theme.of(context).textTheme.labelMedium?.copyWith(
              color: color,
              fontWeight: FontWeight.w600,
            ),
      ),
    );
  }
}

class _CourseItemTile extends StatelessWidget {
  final _SelectedCourse course;
  final VoidCallback onRemove;

  const _CourseItemTile({
    required this.course,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(14.r),
      decoration: BoxDecoration(
        color: SumAcademyTheme.white,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: SumAcademyTheme.brandBluePale),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  course.title,
                  style: Theme.of(context).textTheme.labelLarge?.copyWith(
                        color: SumAcademyTheme.darkBase,
                        fontWeight: FontWeight.w600,
                      ),
                ),
                if (course.subtitle.isNotEmpty) ...[
                  SizedBox(height: 4.h),
                  Text(
                    course.subtitle,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: SumAcademyTheme.darkBase.withOpacityFloat(0.6),
                        ),
                  ),
                ],
              ],
            ),
          ),
          OutlinedButton(
            onPressed: onRemove,
            style: OutlinedButton.styleFrom(
              foregroundColor: SumAcademyTheme.error,
              side: BorderSide(
                color: SumAcademyTheme.error.withOpacityFloat(0.4),
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14.r),
              ),
              padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 8.h),
            ),
            child: const Text('Remove'),
          ),
        ],
      ),
    );
  }
}

class _ShiftCard extends StatelessWidget {
  final _ShiftInput shift;
  final List<_SelectedCourse> courses;
  final List<String> teachers;
  final bool teachersLoading;
  final VoidCallback onRemove;
  final VoidCallback onPickStart;
  final VoidCallback onPickEnd;
  final VoidCallback onChanged;
  final ValueChanged<String?> onCourseChanged;
  final ValueChanged<String?> onTeacherChanged;

  const _ShiftCard({
    required this.shift,
    required this.courses,
    required this.teachers,
    required this.teachersLoading,
    required this.onRemove,
    required this.onPickStart,
    required this.onPickEnd,
    required this.onChanged,
    required this.onCourseChanged,
    required this.onTeacherChanged,
  });

  @override
  Widget build(BuildContext context) {
    final courseLabels = courses.map((course) => course.title).toList();
    return Container(
      padding: EdgeInsets.all(16.r),
      decoration: BoxDecoration(
        color: SumAcademyTheme.surfaceSecondary,
        borderRadius: BorderRadius.circular(18.r),
        border: Border.all(color: SumAcademyTheme.brandBluePale),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildDropdownField(
            label: 'Shift Name',
            value: shift.shiftName,
            items: _ShiftInput.shiftNames,
            onChanged: (value) {
              shift.shiftName = value;
              onChanged();
            },
          ),
          SizedBox(height: 12.h),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: _buildTimeField(
                  label: 'Start Time',
                  controller: shift.startController,
                  onTap: onPickStart,
                ),
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: _buildTimeField(
                  label: 'End Time',
                  controller: shift.endController,
                  onTap: onPickEnd,
                ),
              ),
            ],
          ),
          SizedBox(height: 12.h),
          _buildDropdownField(
            label: 'Course',
            value: shift.courseLabel,
            items: courseLabels,
            onChanged: onCourseChanged,
          ),
          SizedBox(height: 12.h),
          _buildDropdownField(
            label: 'Teacher',
            value: shift.teacherLabel,
            items: teachers,
            hint: teachersLoading ? 'Loading...' : 'Select teacher',
            onChanged: onTeacherChanged,
          ),
          SizedBox(height: 12.h),
          _buildTextField(
            label: 'Room',
            controller: shift.roomController,
            hintText: 'Room (optional)',
          ),
          SizedBox(height: 12.h),
          Text(
            'Days',
            style: Theme.of(context).textTheme.labelLarge?.copyWith(
                  color: SumAcademyTheme.darkBase,
                  fontWeight: FontWeight.w600,
                ),
          ),
          SizedBox(height: 8.h),
          Wrap(
            spacing: 8.w,
            runSpacing: 8.h,
            children: _ShiftInput.daysOfWeek
                .map(
                  (day) => ChoiceChip(
                    label: Text(day),
                    selected: shift.days.contains(day),
                    onSelected: (selected) {
                      if (selected) {
                        shift.days.add(day);
                      } else {
                        shift.days.remove(day);
                      }
                      onChanged();
                    },
                    selectedColor: SumAcademyTheme.brandBlue,
                    labelStyle: Theme.of(context).textTheme.labelMedium?.copyWith(
                          color: shift.days.contains(day)
                              ? SumAcademyTheme.white
                              : SumAcademyTheme.darkBase,
                        ),
                    backgroundColor: SumAcademyTheme.white,
                    side: const BorderSide(color: SumAcademyTheme.brandBluePale),
                  ),
                )
                .toList(),
          ),
          SizedBox(height: 10.h),
          Align(
            alignment: Alignment.centerRight,
            child: OutlinedButton(
              onPressed: onRemove,
              style: OutlinedButton.styleFrom(
                foregroundColor: SumAcademyTheme.error,
                side: BorderSide(
                  color: SumAcademyTheme.error.withOpacityFloat(0.4),
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14.r),
                ),
                padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 8.h),
              ),
              child: const Text('Remove Shift'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDropdownField({
    required String label,
    required String? value,
    required List<String> items,
    String? hint,
    required ValueChanged<String?> onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        DialogLabel(text: label),
        SizedBox(height: 8.h),
        DialogDropdown(
          value: value,
          hintText: hint ?? 'Select',
          items: items,
          onChanged: onChanged,
        ),
      ],
    );
  }

  Widget _buildTimeField({
    required String label,
    required TextEditingController controller,
    required VoidCallback onTap,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        DialogLabel(text: label),
        SizedBox(height: 8.h),
        GestureDetector(
          onTap: onTap,
          child: AbsorbPointer(
            child: DialogTextField(
              controller: controller,
              hintText: 'Select time',
              textInputAction: TextInputAction.next,
              suffixIcon: Icon(
                Icons.access_time_rounded,
                size: 18.sp,
                color: SumAcademyTheme.darkBase,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTextField({
    required String label,
    required TextEditingController controller,
    required String hintText,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        DialogLabel(text: label),
        SizedBox(height: 8.h),
        DialogTextField(
          controller: controller,
          hintText: hintText,
          textInputAction: TextInputAction.next,
        ),
      ],
    );
  }
}

class _SelectedCourse {
  final String id;
  final String title;
  final String subtitle;

  const _SelectedCourse({
    required this.id,
    required this.title,
    required this.subtitle,
  });
}

class _ShiftInput {
  static const shiftNames = ['Morning', 'Afternoon', 'Evening', 'Weekend'];
  static const daysOfWeek = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];

  String? shiftName;
  String? courseId;
  String? courseLabel;
  String? teacherId;
  String? teacherLabel;
  TimeOfDay? startTime;
  TimeOfDay? endTime;
  final TextEditingController startController = TextEditingController();
  final TextEditingController endController = TextEditingController();
  final TextEditingController roomController = TextEditingController();
  final Set<String> days = {'Mon', 'Wed', 'Fri'};

  void dispose() {
    startController.dispose();
    endController.dispose();
    roomController.dispose();
  }
}

String? _formatDateShort(DateTime? date) {
  if (date == null) return null;
  final month = date.month.toString().padLeft(2, '0');
  final day = date.day.toString().padLeft(2, '0');
  return '$month/$day/${date.year}';
}

String _formatTime(TimeOfDay time) {
  final hour = time.hourOfPeriod == 0 ? 12 : time.hourOfPeriod;
  final minute = time.minute.toString().padLeft(2, '0');
  final suffix = time.period == DayPeriod.am ? 'AM' : 'PM';
  return '$hour:$minute $suffix';
}

String _formatTime24(TimeOfDay time) {
  final hour = time.hour.toString().padLeft(2, '0');
  final minute = time.minute.toString().padLeft(2, '0');
  return '$hour:$minute';
}

String? _normalizeTimeText(String raw, TimeOfDay? time) {
  if (time != null) {
    return _formatTime24(time);
  }
  final trimmed = raw.trim();
  if (trimmed.isEmpty) return null;
  final upper = trimmed.toUpperCase();
  if (upper.contains('AM') || upper.contains('PM')) {
    final parts = upper.replaceAll(RegExp(r'\\s+'), ' ').split(' ');
    if (parts.isEmpty) return null;
    final timePart = parts.first;
    final meridiem = parts.length > 1 ? parts[1] : '';
    final segments = timePart.split(':');
    if (segments.length < 2) return null;
    final hour = int.tryParse(segments[0]) ?? -1;
    final minute = int.tryParse(segments[1]) ?? -1;
    if (hour < 0 || hour > 12 || minute < 0 || minute > 59) return null;
    var normalizedHour = hour % 12;
    if (meridiem == 'PM') {
      normalizedHour += 12;
    }
    return '${normalizedHour.toString().padLeft(2, '0')}:${minute.toString().padLeft(2, '0')}';
  }
  final match = RegExp(r'^(\\d{1,2}):(\\d{2})(?::(\\d{2}))?\$')
      .firstMatch(trimmed);
  if (match != null) {
    final hour = int.tryParse(match.group(1) ?? '') ?? -1;
    final minute = int.tryParse(match.group(2) ?? '') ?? -1;
    if (hour < 0 || hour > 23 || minute < 0 || minute > 59) return null;
    return '${hour.toString().padLeft(2, '0')}:${minute.toString().padLeft(2, '0')}';
  }
  return null;
}

int? _parseTimeToMinutes(String raw, TimeOfDay? time) {
  if (time != null) {
    return time.hour * 60 + time.minute;
  }
  final normalized = _normalizeTimeText(raw, null);
  if (normalized == null) return null;
  final parts = normalized.split(':');
  if (parts.length < 2) return null;
  final hour = int.tryParse(parts[0]) ?? -1;
  final minute = int.tryParse(parts[1]) ?? -1;
  if (hour < 0 || hour > 23 || minute < 0 || minute > 59) return null;
  return hour * 60 + minute;
}

String? _resolveStatus(String status) {
  if (status.isEmpty) return null;
  final normalized = status.toLowerCase();
  if (normalized.contains('active')) return 'Active';
  if (normalized.contains('upcoming')) return 'Upcoming';
  if (normalized.contains('inactive')) return 'Inactive';
  if (normalized.contains('arch')) return 'Archived';
  if (normalized.contains('complete')) return 'Completed';
  return null;
}

String _courseLabel(AdminCourse course) {
  if (course.title.isEmpty) return 'Course';
  if (course.category.isNotEmpty) {
    return '${course.title} (${course.category})';
  }
  return course.title;
}

String _teacherLabel(AdminUser teacher) {
  final name = teacher.name.isNotEmpty ? teacher.name : teacher.email;
  if (teacher.email.isNotEmpty && !name.contains(teacher.email)) {
    return '$name (${teacher.email})';
  }
  return name;
}
