import 'package:sum_academy/core/services/api_client.dart';
import 'package:sum_academy/core/services/api_exception.dart';
import 'package:sum_academy/modules/student/models/student_session.dart';
import 'package:flutter/foundation.dart';

class StudentSessionsService {
  StudentSessionsService({ApiClient? client}) : _client = client ?? ApiClient();

  final ApiClient _client;

  Future<List<StudentSession>> fetchLiveSessions() async {
    final response = await _client.get('/student/live-sessions', auth: true);
    dynamic payload = response['data'] ?? response;

    List<StudentSession> parseList(dynamic value) {
      if (value is List) return value.map(StudentSession.fromAny).toList();
      if (value is Map) {
        // Sometimes backend returns a map keyed by sessionId.
        return value.values.map(StudentSession.fromAny).toList();
      }
      return const [];
    }

    List<StudentSession> scanForLists(dynamic value, {int depth = 0}) {
      if (value is List) {
        return value.map(StudentSession.fromAny).toList();
      }
      if (value is Map && depth < 4) {
        final map = Map<String, dynamic>.from(value);
        for (final entry in map.entries) {
          final found = scanForLists(entry.value, depth: depth + 1);
          if (found.isNotEmpty) return found;
        }
      }
      return const [];
    }

    if (payload is List || payload is Map) {
      if (payload is List) return parseList(payload);

      final map = Map<String, dynamic>.from(payload as Map);
      // Some backends group by status: { upcoming: [], active: [], ended: [] }
      final groupedKeys = [
        'upcoming',
        'active',
        'ended',
        'recording',
        'recordings',
        'live',
      ];
      final grouped = <StudentSession>[];
      for (final key in groupedKeys) {
        final chunk = parseList(map[key]);
        if (chunk.isNotEmpty) grouped.addAll(chunk);
      }
      if (grouped.isNotEmpty) return grouped;

      final candidates = [
        map['sessions'],
        map['liveSessions'],
        map['live_sessions'],
        map['items'],
        map['results'],
        map['data'],
      ];
      for (final c in candidates) {
        final list = parseList(c);
        if (list.isNotEmpty) return list;
      }

      final scanned = scanForLists(map);
      if (scanned.isNotEmpty) return scanned;
    }

    // Fallback: sometimes the list is nested deeper under data.sessions.
    final deep = response['data'];
    if (deep is Map) {
      final deepMap = Map<String, dynamic>.from(deep);
      final deepCandidates = [
        deepMap['sessions'],
        deepMap['liveSessions'],
        deepMap['data'],
        deepMap['upcoming'],
        deepMap['active'],
        deepMap['ended'],
      ];
      for (final c in deepCandidates) {
        final list = parseList(c);
        if (list.isNotEmpty) return list;
      }

      final scanned = scanForLists(deepMap);
      if (scanned.isNotEmpty) return scanned;
    }

    if (kDebugMode) {
      debugPrint(
        'Live sessions API returned no items. '
        'dataType=${(response['data'] ?? response).runtimeType} '
        'keys=${payload is Map ? (payload as Map).keys.toList() : 'n/a'} '
        'response=$response',
      );
    }
    return const [];
  }

  Future<StudentSession> fetchSession(String sessionId) async {
    if (sessionId.trim().isEmpty) {
      return StudentSession.empty();
    }
    // Prefer status endpoint; keep fallbacks because some deployments mount
    // status/sync under /student/live-sessions instead of /student/sessions.
    try {
      final response =
          await _client.get('/student/sessions/$sessionId/status', auth: true);
      return StudentSession.fromJson(response);
    } on ApiException catch (e) {
      if ((e.statusCode ?? 0) != 404) rethrow;
      try {
        final response = await _client.get(
          '/student/live-sessions/$sessionId/status',
          auth: true,
        );
        return StudentSession.fromJson(response);
      } on ApiException catch (e2) {
        if ((e2.statusCode ?? 0) != 404) rethrow;
        // Oldest shape: session details directly.
        final response =
            await _client.get('/student/sessions/$sessionId', auth: true);
        return StudentSession.fromJson(response);
      }
    }
  }

  Future<Map<String, dynamic>> joinSession(String sessionId) async {
    // Some deployments expose join under /student/live-sessions/:id/join.
    // Keep a fallback to /student/sessions/:id/join for older backends.
    try {
      final response =
          await _client.post('/student/live-sessions/$sessionId/join', auth: true);
      return response['data'] is Map
          ? Map<String, dynamic>.from(response['data'])
          : response;
    } catch (_) {
      final response =
          await _client.post('/student/sessions/$sessionId/join', auth: true);
      return response['data'] is Map
          ? Map<String, dynamic>.from(response['data'])
          : response;
    }
  }

  Future<Map<String, dynamic>> syncSession(String sessionId) async {
    try {
      final response =
          await _client.get('/student/sessions/$sessionId/sync', auth: true);
      return response['data'] is Map
          ? Map<String, dynamic>.from(response['data'])
          : response;
    } on ApiException catch (e) {
      if ((e.statusCode ?? 0) != 404) rethrow;
      final response =
          await _client.get('/student/live-sessions/$sessionId/sync', auth: true);
      return response['data'] is Map
          ? Map<String, dynamic>.from(response['data'])
          : response;
    }
  }

  Future<void> leaveSession(
    String sessionId, {
    bool lectureCompleted = false,
  }) async {
    // Spec: leave is exposed under /student/sessions/:id/leave
    // Some backends accept additional flags (e.g. lectureCompleted) on leave.
    final body = lectureCompleted ? {'lectureCompleted': true} : null;
    try {
      await _client.post(
        '/student/sessions/$sessionId/leave',
        auth: true,
        body: body,
      );
    } on ApiException catch (e) {
      if ((e.statusCode ?? 0) != 404) rethrow;
      await _client.post(
        '/student/live-sessions/$sessionId/leave',
        auth: true,
        body: body,
      );
    }
  }

  Future<void> reportViolation({
    required String sessionId,
    required String reason,
    required int count,
    required DateTime timestamp,
  }) async {
    final body = {
      'reason': reason,
      'count': count,
      'timestamp': timestamp.toUtc().toIso8601String(),
    };
    try {
      await _client.post(
        '/student/sessions/$sessionId/violation',
        auth: true,
        body: body,
      );
    } on ApiException catch (e) {
      if ((e.statusCode ?? 0) != 404) rethrow;
      await _client.post(
        '/student/live-sessions/$sessionId/violation',
        auth: true,
        body: body,
      );
    }
  }
}
