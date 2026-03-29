import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:http/http.dart' as http;

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final DeviceInfoPlugin _deviceInfo = DeviceInfoPlugin();
  final GoogleSignIn _googleSignIn = GoogleSignIn();

  Future<void> signIn({required String email, required String password}) async {
    final credential = await _auth.signInWithEmailAndPassword(
      email: email,
      password: password,
    );

    final user = credential.user;
    if (user != null) {
      await _upsertUserDocuments(user: user, isNewUser: false);
      await _updateLastSeen(user.uid);
    }
  }

  Future<bool> signInWithGoogle() async {
    final account = await _googleSignIn.signIn();
    if (account == null) {
      return false;
    }

    final auth = await account.authentication;
    final credential = GoogleAuthProvider.credential(
      accessToken: auth.accessToken,
      idToken: auth.idToken,
    );

    final userCredential = await _auth.signInWithCredential(credential);
    final user = userCredential.user;
    if (user == null) {
      return false;
    }

    final isNewUser = userCredential.additionalUserInfo?.isNewUser ?? false;
    await _upsertUserDocuments(user: user, isNewUser: isNewUser);
    await _updateLastSeen(user.uid);
    return true;
  }

  Future<void> register({
    required String name,
    required String email,
    required String password,
  }) async {
    final credential = await _auth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );

    final uid = credential.user?.uid;
    if (uid == null) {
      throw FirebaseAuthException(
        code: 'missing-uid',
        message: 'User account was created without a UID.',
      );
    }

    final lastSeen = await _buildLastSeenPayload();

    final batch = _firestore.batch();
    final usersRef = _firestore.collection('users').doc(uid);
    final studentsRef = _firestore.collection('students').doc(uid);

    batch.set(usersRef, {
      'email': email,
      'createdAt': FieldValue.serverTimestamp(),
      'isActive': true,
      'setupDone': false,
      'role': 'student',
      'uid': uid,
      ...lastSeen,
    });

    batch.set(studentsRef, {
      'fullName': name.trim(),
      'uid': uid,
      'email': email.trim(),
      'createdAt': FieldValue.serverTimestamp(),
      'address': '',
      'caste': '',
      'district': '',
      'domicile': '',
      'fatherName': '',
      'fatherOccupation': '',
      'fatherPhone': '',
      'phoneNumber': '',
    });

    await batch.commit();

    await credential.user?.updateDisplayName(name);
  }

  Future<void> requestPasswordReset({required String email}) async {
    await _auth.sendPasswordResetEmail(email: email);
  }

  Future<void> verifyOtp({required String code}) async {
    await Future<void>.delayed(const Duration(milliseconds: 700));
  }

  Future<void> logout() async {
    await _googleSignIn.signOut();
    await _auth.signOut();
  }

  Future<String> getCurrentUserRole() async {
    final uid = _auth.currentUser?.uid;
    if (uid == null) {
      return 'student';
    }

    final snapshot = await _firestore.collection('users').doc(uid).get();
    final role = snapshot.data()?['role'];
    if (role is String && role.trim().isNotEmpty) {
      return role.trim().toLowerCase();
    }
    return 'student';
  }

  User? get currentUser => _auth.currentUser;

  Future<void> _upsertUserDocuments({
    required User user,
    required bool isNewUser,
  }) async {
    final usersRef = _firestore.collection('users').doc(user.uid);
    final studentsRef = _firestore.collection('students').doc(user.uid);

    final usersSnap = await usersRef.get();
    final studentsSnap = await studentsRef.get();

    final shouldCreateUsers = isNewUser || !usersSnap.exists;
    final shouldCreateStudents = isNewUser || !studentsSnap.exists;

    final batch = _firestore.batch();
    var hasWrites = false;

    if (shouldCreateUsers) {
      batch.set(usersRef, {
        'email': user.email ?? '',
        'createdAt': FieldValue.serverTimestamp(),
        'isActive': true,
        'setupDone': false,
        'role': 'student',
        'uid': user.uid,
      });
      hasWrites = true;
    } else {
      final existingEmail = usersSnap.data()?['email'];
      final email = user.email ?? '';
      if ((existingEmail == null || existingEmail.toString().trim().isEmpty) &&
          email.trim().isNotEmpty) {
        batch.set(usersRef, {
          'email': email,
          'uid': user.uid,
        }, SetOptions(merge: true));
        hasWrites = true;
      }
    }

    if (shouldCreateStudents) {
      final displayName = (user.displayName ?? '').trim();
      batch.set(studentsRef, {
        'fullName': displayName,
        'uid': user.uid,
        'email': (user.email ?? '').trim(),
        'createdAt': FieldValue.serverTimestamp(),
        'address': '',
        'caste': '',
        'district': '',
        'domicile': '',
        'fatherName': '',
        'fatherOccupation': '',
        'fatherPhone': '',
        'phoneNumber': '',
      });
      hasWrites = true;
    } else {
      final existingName = studentsSnap.data()?['fullName'];
      final displayName = (user.displayName ?? '').trim();
      if ((existingName == null || existingName.toString().trim().isEmpty) &&
          displayName.isNotEmpty) {
        batch.set(studentsRef, {
          'fullName': displayName,
          'uid': user.uid,
        }, SetOptions(merge: true));
        hasWrites = true;
      }
    }

    if (hasWrites) {
      await batch.commit();
    }
  }

  Future<void> _updateLastSeen(String uid) async {
    final payload = await _buildLastSeenPayload();
    await _firestore
        .collection('users')
        .doc(uid)
        .set(payload, SetOptions(merge: true));
  }

  Future<Map<String, dynamic>> _buildLastSeenPayload() async {
    final deviceLabel = await _resolveDeviceLabel();
    final ipAddress = await _fetchPublicIp();
    final lastKnownMobileIp = kIsWeb ? '' : ipAddress;
    final lastKnownWebIp = kIsWeb ? ipAddress : '';

    return {
      'assignedMobileDevice': deviceLabel,
      'lastKnownMobileIp': lastKnownMobileIp,
      'lastKnownWebIp': lastKnownWebIp,
      'lastLoginAt': FieldValue.serverTimestamp(),
    };
  }

  Future<String> _resolveDeviceLabel() async {
    if (kIsWeb) {
      try {
        final web = await _deviceInfo.webBrowserInfo;
        final browser = web.browserName.name;
        final platform = web.platform ?? 'web';
        return '$browser on $platform';
      } catch (e) {
        if (kDebugMode) {
          debugPrint('Device info (web) failed: $e');
        }
        return 'Web';
      }
    }

    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        try {
          final android = await _deviceInfo.androidInfo;
          final primary = _joinNonEmpty([android.manufacturer, android.model]);
          final secondary = _joinNonEmpty([android.brand, android.device]);
          final fallback = _joinNonEmpty([android.product, android.hardware]);
          final label = primary.isNotEmpty
              ? primary
              : (secondary.isNotEmpty ? secondary : fallback);
          return label.isNotEmpty ? label : 'Android device';
        } catch (e) {
          if (kDebugMode) {
            debugPrint('Device info (android) failed: $e');
          }
          return 'Android device';
        }
      case TargetPlatform.iOS:
        try {
          final ios = await _deviceInfo.iosInfo;
          final machine = ios.utsname.machine;
          return machine.isNotEmpty ? machine : 'iOS device';
        } catch (e) {
          if (kDebugMode) {
            debugPrint('Device info (ios) failed: $e');
          }
          return 'iOS device';
        }
      case TargetPlatform.macOS:
        try {
          final mac = await _deviceInfo.macOsInfo;
          return mac.model.isNotEmpty ? mac.model : 'macOS';
        } catch (e) {
          if (kDebugMode) {
            debugPrint('Device info (mac) failed: $e');
          }
          return 'macOS';
        }
      case TargetPlatform.windows:
        try {
          final windows = await _deviceInfo.windowsInfo;
          return windows.computerName.isNotEmpty
              ? windows.computerName
              : 'Windows';
        } catch (e) {
          if (kDebugMode) {
            debugPrint('Device info (windows) failed: $e');
          }
          return 'Windows';
        }
      case TargetPlatform.linux:
        try {
          final linux = await _deviceInfo.linuxInfo;
          return linux.prettyName.isNotEmpty ? linux.prettyName : 'Linux';
        } catch (e) {
          if (kDebugMode) {
            debugPrint('Device info (linux) failed: $e');
          }
          return 'Linux';
        }
      default:
        return 'Device';
    }
  }

  String _joinNonEmpty(List<String?> parts) {
    return parts
        .where((value) => value != null && value.trim().isNotEmpty)
        .map((value) => value!.trim())
        .join(' ')
        .trim();
  }

  Future<String> _fetchPublicIp() async {
    try {
      final response = await http
          .get(Uri.parse('https://api.ipify.org?format=json'))
          .timeout(const Duration(seconds: 6));
      if (response.statusCode != 200) {
        return '';
      }
      final data = jsonDecode(response.body) as Map<String, dynamic>;
      return data['ip']?.toString() ?? '';
    } catch (_) {
      return '';
    }
  }
}
