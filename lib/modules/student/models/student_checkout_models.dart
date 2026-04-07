class StudentCheckoutClass {
  final String id;
  final String name;
  final String code;
  final int capacity;
  final int enrolledCount;
  final List<StudentCheckoutShift> shifts;

  const StudentCheckoutClass({
    required this.id,
    required this.name,
    required this.code,
    required this.capacity,
    required this.enrolledCount,
    required this.shifts,
  });

  int get spotsLeft {
    if (capacity <= 0) return 0;
    final left = capacity - enrolledCount;
    return left < 0 ? 0 : left;
  }

  String get displayLabel {
    final codeLabel = code.isNotEmpty ? ' ($code)' : '';
    final spotsLabel = capacity > 0 ? ' - $spotsLeft spots left' : '';
    return '$name$codeLabel$spotsLabel';
  }

  factory StudentCheckoutClass.fromJson(Map<String, dynamic> json) {
    final shifts = _readList(json, const [
      'shifts',
      'shiftList',
      'classShifts',
    ]);
    final capacity = _readInt(json, const ['capacity', 'seats', 'studentLimit']);
    final enrolledCount = _readInt(
      json,
      const ['enrolledCount', 'studentsCount', 'studentCount'],
    );
    final spotsLeft = _readInt(json, const ['spotsLeft', 'availableSpots']);
    final resolvedCapacity =
        capacity > 0 ? capacity : (spotsLeft > 0 ? enrolledCount + spotsLeft : 0);
    return StudentCheckoutClass(
      id: _readString(json, const ['id', '_id', 'classId']),
      name: _readString(json, const ['name', 'title', 'className']),
      code: _readString(json, const ['batchCode', 'code', 'classCode']),
      capacity: resolvedCapacity,
      enrolledCount: enrolledCount,
      shifts: shifts
          .whereType<Map<String, dynamic>>()
          .map(StudentCheckoutShift.fromJson)
          .toList(),
    );
  }
}

class StudentCheckoutShift {
  final String id;
  final String name;
  final List<String> days;
  final String startTime;
  final String endTime;
  final String courseId;
  final String teacherName;

  const StudentCheckoutShift({
    required this.id,
    required this.name,
    required this.days,
    required this.startTime,
    required this.endTime,
    required this.courseId,
    required this.teacherName,
  });

  String get displayLabel {
    final daysLabel = days.isEmpty ? '' : '${days.join(', ')} - ';
    final timeLabel =
        startTime.isNotEmpty || endTime.isNotEmpty ? '$startTime-$endTime' : '';
    final base = name.isNotEmpty ? name : 'Shift';
    final separator = daysLabel.isNotEmpty || timeLabel.isNotEmpty ? ' - ' : '';
    return '$base$separator$daysLabel$timeLabel'.trim();
  }

  factory StudentCheckoutShift.fromJson(Map<String, dynamic> json) {
    return StudentCheckoutShift(
      id: _readString(json, const ['id', '_id', 'shiftId']),
      name: _readString(json, const ['name', 'shiftName', 'label']),
      days: _readStringList(json, const ['days', 'weekDays']),
      startTime: _readString(json, const ['startTime', 'start', 'from']),
      endTime: _readString(json, const ['endTime', 'end', 'to']),
      courseId: _readString(
        json,
        const ['courseId', 'subjectId', 'course', 'subject'],
      ),
      teacherName:
          _readString(json, const ['teacherName', 'teacher', 'instructor']),
    );
  }
}

class StudentPaymentConfig {
  final List<String> methods;
  final List<int> installmentOptions;
  final Map<String, dynamic> bankDetails;
  final Map<String, dynamic> jazzcashDetails;
  final Map<String, dynamic> easypaisaDetails;
  final Map<String, dynamic> bankTransferDetails;

  const StudentPaymentConfig({
    required this.methods,
    required this.installmentOptions,
    required this.bankDetails,
    required this.jazzcashDetails,
    required this.easypaisaDetails,
    required this.bankTransferDetails,
  });

  factory StudentPaymentConfig.fromJson(Map<String, dynamic> json) {
    final root = _readMap(json, const ['data', 'payment'])..addAll(json);

    final rawMethods = _readStringList(root, const ['methods', 'paymentMethods']);
    final methods = rawMethods.map(_normalizeMethodLabel).toList();
    final installments = _readIntList(
      root,
      const ['installmentOptions', 'installments', 'plans'],
    );
    final jazzcash = _readMap(root, const ['jazzcash', 'jazzCash']);
    final easypaisa = _readMap(root, const ['easypaisa', 'easyPaisa']);
    final bankTransfer = _readMap(root, const ['bankTransfer', 'bank_transfer']);
    final bank = bankTransfer.isNotEmpty
        ? bankTransfer
        : _resolveBankDetails(root);
    final hasFlags = _hasMethodFlags(root);
    final derived = _deriveMethodsFromFlags(root);
    final resolvedMethods =
        methods.isNotEmpty ? methods : (hasFlags ? derived : const <String>[]);
    final combinedMethods = <String>[
      ...resolvedMethods,
      ...derived.where((item) => !resolvedMethods.contains(item)),
    ];
    final finalMethods = combinedMethods.isNotEmpty
        ? combinedMethods
        : (hasFlags ? const <String>[] : const ['JazzCash', 'EasyPaisa', 'Bank Transfer']);

    return StudentPaymentConfig(
      methods: finalMethods,
      installmentOptions:
          installments.isNotEmpty ? installments : const [2, 3, 4],
      bankDetails: bank,
      jazzcashDetails: jazzcash,
      easypaisaDetails: easypaisa,
      bankTransferDetails: bankTransfer,
    );
  }
}

Map<String, dynamic> _resolveBankDetails(Map<String, dynamic> json) {
  final direct = _readMap(json, const ['bankTransfer', 'bank', 'bankDetails']);
  if (direct.isNotEmpty) {
    return direct;
  }

  for (final entry in json.entries) {
    final value = entry.value;
    if (value is Map<String, dynamic>) {
      final nested = _resolveBankDetails(value);
      if (nested.isNotEmpty) {
        return nested;
      }
    }
  }

  return <String, dynamic>{};
}

List<String> _deriveMethodsFromFlags(Map<String, dynamic> json) {
  final methods = <String>[];
  if (_isEnabled(json, const ['jazzcash', 'jazzCash'])) {
    methods.add('JazzCash');
  }
  if (_isEnabled(json, const ['easypaisa', 'easyPaisa'])) {
    methods.add('EasyPaisa');
  }
  if (_isEnabled(json, const ['bankTransfer', 'bank_transfer'])) {
    methods.add('Bank Transfer');
  }
  return methods;
}

String _normalizeMethodLabel(String value) {
  final lower = value.trim().toLowerCase();
  if (lower.isEmpty) return value;
  if (lower.contains('bank')) return 'Bank Transfer';
  if (lower.contains('jazz')) return 'JazzCash';
  if (lower.contains('easy')) return 'EasyPaisa';
  if (lower.contains('transfer')) return 'Bank Transfer';
  return value.trim();
}

bool _hasMethodFlags(Map<String, dynamic> json) {
  const keys = ['jazzcash', 'jazzCash', 'easypaisa', 'easyPaisa', 'bankTransfer', 'bank_transfer'];
  for (final key in keys) {
    if (json.containsKey(key)) {
      return true;
    }
  }
  for (final entry in json.entries) {
    final value = entry.value;
    if (value is Map<String, dynamic>) {
      if (_hasMethodFlags(value)) {
        return true;
      }
    }
  }
  return false;
}

bool _isEnabled(Map<String, dynamic> json, List<String> keys) {
  for (final key in keys) {
    final value = json[key];
    if (value is bool) {
      return value;
    }
    if (value is num) {
      return value != 0;
    }
    if (value is String) {
      final normalized = value.trim().toLowerCase();
      if (normalized == 'true' || normalized == 'yes' || normalized == '1') {
        return true;
      }
      if (normalized == 'false' || normalized == 'no' || normalized == '0') {
        return false;
      }
    }
    if (value is Map<String, dynamic>) {
      final enabled = value['enabled'];
      if (enabled is bool) return enabled;
      if (enabled is num) return enabled != 0;
      if (enabled is String) {
        final normalized = enabled.trim().toLowerCase();
        if (normalized == 'true' || normalized == 'yes' || normalized == '1') {
          return true;
        }
        if (normalized == 'false' ||
            normalized == 'no' ||
            normalized == '0') {
          return false;
        }
      }
      if (value.isNotEmpty) {
        return true;
      }
    }
  }
  return false;
}

String _readString(Map<String, dynamic> json, List<String> keys) {
  for (final key in keys) {
    final value = json[key];
    if (value == null) continue;
    final text = value.toString().trim();
    if (text.isNotEmpty) return text;
  }
  return '';
}

int _readInt(Map<String, dynamic> json, List<String> keys) {
  for (final key in keys) {
    final value = json[key];
    if (value == null) continue;
    if (value is int) return value;
    if (value is num) return value.toInt();
    final parsed = int.tryParse(value.toString());
    if (parsed != null) return parsed;
  }
  return 0;
}

List<String> _readStringList(Map<String, dynamic> json, List<String> keys) {
  for (final key in keys) {
    final value = json[key];
    if (value is List) {
      return value
          .where((item) => item != null)
          .map((item) => item.toString().trim())
          .where((item) => item.isNotEmpty)
          .toList();
    }
  }
  return const [];
}

List<int> _readIntList(Map<String, dynamic> json, List<String> keys) {
  for (final key in keys) {
    final value = json[key];
    if (value is List) {
      return value
          .map((item) => int.tryParse(item.toString()))
          .whereType<int>()
          .toList();
    }
  }
  return const [];
}

Map<String, dynamic> _readMap(Map<String, dynamic> json, List<String> keys) {
  for (final key in keys) {
    final value = json[key];
    if (value is Map<String, dynamic>) return Map<String, dynamic>.from(value);
    if (value is Map) {
      return Map<String, dynamic>.from(value);
    }
  }
  return <String, dynamic>{};
}

List<dynamic> _readList(Map<String, dynamic> json, List<String> keys) {
  for (final key in keys) {
    final value = json[key];
    if (value is List) return value;
  }
  return const [];
}
