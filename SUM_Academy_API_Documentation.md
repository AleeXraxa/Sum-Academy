# SUM Academy API Documentation
## For Android App Developer
### Base URL: https://sumacademy.net/api
### Last Updated: March 2026
### Version: 1.0
### Total Endpoints: 168

## Table of Contents
- [Authentication Guide for Android Developer](#authentication-guide-for-android-developer)
- [Device and IP Rules for Android](#device-and-ip-rules-for-android)
- [Response Format](#response-format)
- [Firebase Collections Reference](#firebase-collections-reference)
- [Flutter Recommended Packages](#flutter-recommended-packages)
- [Environment Configuration](#environment-configuration)
- [AUTH APIs](#auth-apis)
- [STUDENT APIs](#student-apis)
- [PAYMENT APIs](#payment-apis)
- [TEACHER APIs](#teacher-apis)
- [ADMIN APIs](#admin-apis)
- [PUBLIC APIs](#public-apis)

## Authentication Guide for Android Developer
1. **Firebase Auth setup in Flutter**: Add dependencies in `pubspec.yaml` (see package list below) and initialize Firebase in `main.dart`.
2. **Register with email/password**: Use `POST /auth/register/send-otp` ? `POST /auth/register/verify-otp` ? `POST /auth/register`.
3. **Get Firebase ID token**:
```dart
String? token = await FirebaseAuth.instance.currentUser?.getIdToken(true);
```
4. **Send token in headers**:
```dart
dio.options.headers['Authorization'] = 'Bearer $token';
```
5. **Handle token refresh**: Call `getIdToken(true)` before critical requests or use an interceptor to refresh when needed.
6. **Handle 401 errors**: On 401, clear local auth state and send user back to login.
7. **Google Sign-In setup**: Use `google_sign_in` + `firebase_auth` to authenticate, then call backend APIs with the Firebase ID token.

## Device and IP Rules for Android
- **Students**: Device and IP are locked to the registration device.
- **First login** saves the device and IP.
- **Different IP** = blocked with `DEVICE_IP_MISMATCH` error.
- **Admin and teacher**: no device restriction.
- **Mobile IP** saved as: `lastKnownMobileIp`.
- **Device name** saved as: `assignedMobileDevice` (on first login).

## Response Format
**Success:**
```json
{
  "success": true,
  "message": "Description",
  "data": { }
}
```
**Error:**
```json
{
  "success": false,
  "message": "Error description",
  "errors": { }
}
```

## Firebase Collections Reference
**Note:** Full schemas were not provided. Replace placeholders with backend-approved schemas.

- `users`: `{ uid, email, role, isActive, setupDone, createdAt, assignedMobileDevice, lastKnownMobileIp, lastKnownWebIp, lastLoginAt }`
- `students`: `{ uid, fullName, address, caste, district, domicile, fatherName, fatherOccupation, fatherPhone, phoneNumber }`
- `teachers`: **TBD**
- `admins`: **TBD**
- `courses`: **TBD**
- `chapters`: **TBD**
- `lectures`: **TBD**
- `classes`: **TBD**
- `sessions`: **TBD**
- `enrollments`: **TBD**
- `payments`: **TBD**
- `installments`: **TBD**
- `promoCodes`: **TBD**
- `certificates`: **TBD**
- `announcements`: **TBD**
- `quizzes`: **TBD**
- `quizResults`: **TBD**
- `attendance`: **TBD**
- `progress`: **TBD**
- `videoAccess`: **TBD**
- `settings`: **TBD**
- `auditLogs`: **TBD**

## Flutter Recommended Packages
- `dio`: ^5.x (HTTP client)
- `firebase_auth`: ^5.3.1
- `firebase_core`: ^3.0.0
- `google_sign_in`: ^6.2.1
- `flutter_secure_storage`: ^9.x
- `cached_network_image`: ^3.x
- `video_player`: ^2.x + `chewie`: ^1.x
- `file_picker`: ^8.x
- `path_provider`: ^2.x
- `encrypt`: ^5.x
- `hive`: ^2.x

## Environment Configuration
```dart
const String baseUrl = "https://sumacademy.net/api";
```
For development:
```dart
const String baseUrl = "http://192.168.x.x:5000/api";
```
(Use local IP, not localhost, for Android emulator/device.)

## AUTH APIs

#### Register Send OTP

<span style="color:#1565C0"><strong>POST</strong></span> https://sumacademy.net/api/auth/register/send-otp

**Description:** Send an OTP for verification.

**Authentication:** Not required

**Role required:** none

**Request Headers:**
- Content-Type: application/json

**Path Parameters:**
- None

**Query Parameters:**
- None specified

**Request Body:**
```json
{
  "email": "string (required)"
}
```

**Response Success (example):**
```json
{
  "success": true,
  "message": "OK",
  "data": {}
}
```

**Response Error (common):**
- 401: Token missing or invalid
- 403: Access denied wrong role
- 404: Resource not found
- 500: Server error

**Flutter/Dart Code Example:**
```dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:firebase_auth/firebase_auth.dart';

final baseUrl = 'https://sumacademy.net/api';
final uri = Uri.parse('$baseUrl/auth/register/send-otp');
final headers = {'Content-Type': 'application/json'};
final payload = {/* TODO: request body */};
final res = await http.post(uri, headers: headers, body: jsonEncode(payload));
final data = jsonDecode(res.body) as Map<String, dynamic>;
if (res.statusCode >= 400) { /* handle error */ }
```

#### Register Verify OTP

<span style="color:#1565C0"><strong>POST</strong></span> https://sumacademy.net/api/auth/register/verify-otp

**Description:** Verify the OTP provided by the user.

**Authentication:** Not required

**Role required:** none

**Request Headers:**
- Content-Type: application/json

**Path Parameters:**
- None

**Query Parameters:**
- None specified

**Request Body:**
```json
{
  "email": "string (required)",
  "otp": "string (required)"
}
```

**Response Success (example):**
```json
{
  "success": true,
  "message": "OK",
  "data": {}
}
```

**Response Error (common):**
- 401: Token missing or invalid
- 403: Access denied wrong role
- 404: Resource not found
- 500: Server error

**Flutter/Dart Code Example:**
```dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:firebase_auth/firebase_auth.dart';

final baseUrl = 'https://sumacademy.net/api';
final uri = Uri.parse('$baseUrl/auth/register/verify-otp');
final headers = {'Content-Type': 'application/json'};
final payload = {/* TODO: request body */};
final res = await http.post(uri, headers: headers, body: jsonEncode(payload));
final data = jsonDecode(res.body) as Map<String, dynamic>;
if (res.statusCode >= 400) { /* handle error */ }
```

#### Register

<span style="color:#1565C0"><strong>POST</strong></span> https://sumacademy.net/api/auth/register

**Description:** Register a new user account.

**Authentication:** Not required

**Role required:** none

**Request Headers:**
- Content-Type: application/json

**Path Parameters:**
- None

**Query Parameters:**
- None specified

**Request Body:**
```json
{
  "fullName": "string (required)",
  "email": "string (required)",
  "password": "string (required)"
}
```

**Response Success (example):**
```json
{
  "success": true,
  "message": "OK",
  "data": {}
}
```

**Response Error (common):**
- 401: Token missing or invalid
- 403: Access denied wrong role
- 404: Resource not found
- 500: Server error

**Flutter/Dart Code Example:**
```dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:firebase_auth/firebase_auth.dart';

final baseUrl = 'https://sumacademy.net/api';
final uri = Uri.parse('$baseUrl/auth/register');
final headers = {'Content-Type': 'application/json'};
final payload = {/* TODO: request body */};
final res = await http.post(uri, headers: headers, body: jsonEncode(payload));
final data = jsonDecode(res.body) as Map<String, dynamic>;
if (res.statusCode >= 400) { /* handle error */ }
```

#### Login

<span style="color:#1565C0"><strong>POST</strong></span> https://sumacademy.net/api/auth/login

**Description:** Authenticate a user and start a session.

**Authentication:** Not required

**Role required:** none

**Request Headers:**
- Content-Type: application/json

**Path Parameters:**
- None

**Query Parameters:**
- None specified

**Request Body:**
```json
{
  "email": "string (required)",
  "password": "string (required)"
}
```

**Response Success (example):**
```json
{
  "success": true,
  "message": "OK",
  "data": {}
}
```

**Response Error (common):**
- 401: Token missing or invalid
- 403: Access denied wrong role
- 404: Resource not found
- 500: Server error

**Flutter/Dart Code Example:**
```dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:firebase_auth/firebase_auth.dart';

final baseUrl = 'https://sumacademy.net/api';
final uri = Uri.parse('$baseUrl/auth/login');
final headers = {'Content-Type': 'application/json'};
final payload = {/* TODO: request body */};
final res = await http.post(uri, headers: headers, body: jsonEncode(payload));
final data = jsonDecode(res.body) as Map<String, dynamic>;
if (res.statusCode >= 400) { /* handle error */ }
```

#### Forgot Password Send OTP

<span style="color:#1565C0"><strong>POST</strong></span> https://sumacademy.net/api/auth/forgot-password/send-otp

**Description:** Send an OTP for verification.

**Authentication:** Not required

**Role required:** none

**Request Headers:**
- Content-Type: application/json

**Path Parameters:**
- None

**Query Parameters:**
- None specified

**Request Body:**
```json
{
  "email": "string (required)"
}
```

**Response Success (example):**
```json
{
  "success": true,
  "message": "OK",
  "data": {}
}
```

**Response Error (common):**
- 401: Token missing or invalid
- 403: Access denied wrong role
- 404: Resource not found
- 500: Server error

**Flutter/Dart Code Example:**
```dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:firebase_auth/firebase_auth.dart';

final baseUrl = 'https://sumacademy.net/api';
final uri = Uri.parse('$baseUrl/auth/forgot-password/send-otp');
final headers = {'Content-Type': 'application/json'};
final payload = {/* TODO: request body */};
final res = await http.post(uri, headers: headers, body: jsonEncode(payload));
final data = jsonDecode(res.body) as Map<String, dynamic>;
if (res.statusCode >= 400) { /* handle error */ }
```

#### Forgot Password Verify OTP

<span style="color:#1565C0"><strong>POST</strong></span> https://sumacademy.net/api/auth/forgot-password/verify-otp

**Description:** Verify the OTP provided by the user.

**Authentication:** Not required

**Role required:** none

**Request Headers:**
- Content-Type: application/json

**Path Parameters:**
- None

**Query Parameters:**
- None specified

**Request Body:**
```json
{
  "email": "string (required)",
  "otp": "string (required)"
}
```

**Response Success (example):**
```json
{
  "success": true,
  "message": "OK",
  "data": {}
}
```

**Response Error (common):**
- 401: Token missing or invalid
- 403: Access denied wrong role
- 404: Resource not found
- 500: Server error

**Flutter/Dart Code Example:**
```dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:firebase_auth/firebase_auth.dart';

final baseUrl = 'https://sumacademy.net/api';
final uri = Uri.parse('$baseUrl/auth/forgot-password/verify-otp');
final headers = {'Content-Type': 'application/json'};
final payload = {/* TODO: request body */};
final res = await http.post(uri, headers: headers, body: jsonEncode(payload));
final data = jsonDecode(res.body) as Map<String, dynamic>;
if (res.statusCode >= 400) { /* handle error */ }
```

#### Forgot Password Reset

<span style="color:#1565C0"><strong>POST</strong></span> https://sumacademy.net/api/auth/forgot-password/reset

**Description:** Reset the user password after OTP verification.

**Authentication:** Not required

**Role required:** none

**Request Headers:**
- Content-Type: application/json

**Path Parameters:**
- None

**Query Parameters:**
- None specified

**Request Body:**
```json
{
  "email": "string (required)",
  "otp": "string (required)",
  "newPassword": "string (required)"
}
```

**Response Success (example):**
```json
{
  "success": true,
  "message": "OK",
  "data": {}
}
```

**Response Error (common):**
- 401: Token missing or invalid
- 403: Access denied wrong role
- 404: Resource not found
- 500: Server error

**Flutter/Dart Code Example:**
```dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:firebase_auth/firebase_auth.dart';

final baseUrl = 'https://sumacademy.net/api';
final uri = Uri.parse('$baseUrl/auth/forgot-password/reset');
final headers = {'Content-Type': 'application/json'};
final payload = {/* TODO: request body */};
final res = await http.post(uri, headers: headers, body: jsonEncode(payload));
final data = jsonDecode(res.body) as Map<String, dynamic>;
if (res.statusCode >= 400) { /* handle error */ }
```

#### Logout

<span style="color:#1565C0"><strong>POST</strong></span> https://sumacademy.net/api/auth/logout

**Description:** Invalidate the current session.

**Authentication:** Required

**Role required:** none

**Request Headers:**
- Content-Type: application/json
- Authorization: Bearer <Firebase ID Token>

**Path Parameters:**
- None

**Query Parameters:**
- None specified

**Request Body:**
```json
TBD (confirm request body with backend)
```

**Response Success (example):**
```json
{
  "success": true,
  "message": "OK",
  "data": {}
}
```

**Response Error (common):**
- 401: Token missing or invalid
- 403: Access denied wrong role
- 404: Resource not found
- 500: Server error

**Flutter/Dart Code Example:**
```dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:firebase_auth/firebase_auth.dart';

final baseUrl = 'https://sumacademy.net/api';
final uri = Uri.parse('$baseUrl/auth/logout');
final token = await FirebaseAuth.instance.currentUser?.getIdToken(true);
final headers = {'Content-Type': 'application/json', 'Authorization': 'Bearer $token'};
final payload = {/* TODO: request body */};
final res = await http.post(uri, headers: headers, body: jsonEncode(payload));
final data = jsonDecode(res.body) as Map<String, dynamic>;
if (res.statusCode >= 400) { /* handle error */ }
```

#### Me

<span style="color:#2E7D32"><strong>GET</strong></span> https://sumacademy.net/api/auth/me

**Description:** Fetch the currently authenticated user profile.

**Authentication:** Required

**Role required:** none

**Request Headers:**
- Content-Type: application/json
- Authorization: Bearer <Firebase ID Token>

**Path Parameters:**
- None

**Query Parameters:**
- None specified

**Request Body:**
- None

**Response Success (example):**
```json
{
  "success": true,
  "message": "OK",
  "data": {}
}
```

**Response Error (common):**
- 401: Token missing or invalid
- 403: Access denied wrong role
- 404: Resource not found
- 500: Server error

**Flutter/Dart Code Example:**
```dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:firebase_auth/firebase_auth.dart';

final baseUrl = 'https://sumacademy.net/api';
final uri = Uri.parse('$baseUrl/auth/me');
final token = await FirebaseAuth.instance.currentUser?.getIdToken(true);
final headers = {'Content-Type': 'application/json', 'Authorization': 'Bearer $token'};
final res = await http.get(uri, headers: headers);
final data = jsonDecode(res.body) as Map<String, dynamic>;
if (res.statusCode >= 400) { /* handle error */ }
```

#### Set Role

<span style="color:#EF6C00"><strong>PATCH</strong></span> https://sumacademy.net/api/auth/set-role

**Description:** Update or set the user's role.

**Authentication:** Required

**Role required:** none

**Request Headers:**
- Content-Type: application/json
- Authorization: Bearer <Firebase ID Token>

**Path Parameters:**
- None

**Query Parameters:**
- None specified

**Request Body:**
```json
{
  "role": "string (required)"
}
```

**Response Success (example):**
```json
{
  "success": true,
  "message": "OK",
  "data": {}
}
```

**Response Error (common):**
- 401: Token missing or invalid
- 403: Access denied wrong role
- 404: Resource not found
- 500: Server error

**Flutter/Dart Code Example:**
```dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:firebase_auth/firebase_auth.dart';

final baseUrl = 'https://sumacademy.net/api';
final uri = Uri.parse('$baseUrl/auth/set-role');
final token = await FirebaseAuth.instance.currentUser?.getIdToken(true);
final headers = {'Content-Type': 'application/json', 'Authorization': 'Bearer $token'};
final payload = {/* TODO: request body */};
final res = await http.patch(uri, headers: headers, body: jsonEncode(payload));
final data = jsonDecode(res.body) as Map<String, dynamic>;
if (res.statusCode >= 400) { /* handle error */ }
```


## STUDENT APIs

#### Dashboard

<span style="color:#2E7D32"><strong>GET</strong></span> https://sumacademy.net/api/student/dashboard

**Description:** Retrieve data for this resource.

**Authentication:** Required

**Role required:** student

**Request Headers:**
- Content-Type: application/json
- Authorization: Bearer <Firebase ID Token>

**Path Parameters:**
- None

**Query Parameters:**
- None specified

**Request Body:**
- None

**Response Success (example):**
```json
{
  "success": true,
  "message": "OK",
  "data": {}
}
```

**Response Error (common):**
- 401: Token missing or invalid
- 403: Access denied wrong role
- 404: Resource not found
- 500: Server error

**Flutter/Dart Code Example:**
```dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:firebase_auth/firebase_auth.dart';

final baseUrl = 'https://sumacademy.net/api';
final uri = Uri.parse('$baseUrl/student/dashboard');
final token = await FirebaseAuth.instance.currentUser?.getIdToken(true);
final headers = {'Content-Type': 'application/json', 'Authorization': 'Bearer $token'};
final res = await http.get(uri, headers: headers);
final data = jsonDecode(res.body) as Map<String, dynamic>;
if (res.statusCode >= 400) { /* handle error */ }
```

#### Courses

<span style="color:#2E7D32"><strong>GET</strong></span> https://sumacademy.net/api/student/courses

**Description:** Retrieve data for this resource.

**Authentication:** Required

**Role required:** student

**Request Headers:**
- Content-Type: application/json
- Authorization: Bearer <Firebase ID Token>

**Path Parameters:**
- None

**Query Parameters:**
- None specified

**Request Body:**
- None

**Response Success (example):**
```json
{
  "success": true,
  "message": "OK",
  "data": {}
}
```

**Response Error (common):**
- 401: Token missing or invalid
- 403: Access denied wrong role
- 404: Resource not found
- 500: Server error

**Flutter/Dart Code Example:**
```dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:firebase_auth/firebase_auth.dart';

final baseUrl = 'https://sumacademy.net/api';
final uri = Uri.parse('$baseUrl/student/courses');
final token = await FirebaseAuth.instance.currentUser?.getIdToken(true);
final headers = {'Content-Type': 'application/json', 'Authorization': 'Bearer $token'};
final res = await http.get(uri, headers: headers);
final data = jsonDecode(res.body) as Map<String, dynamic>;
if (res.statusCode >= 400) { /* handle error */ }
```

#### Courses By Courseid Progress

<span style="color:#2E7D32"><strong>GET</strong></span> https://sumacademy.net/api/student/courses/:courseId/progress

**Description:** Retrieve data for this resource.

**Authentication:** Required

**Role required:** student

**Request Headers:**
- Content-Type: application/json
- Authorization: Bearer <Firebase ID Token>

**Path Parameters:**
- `courseId` (string, required)

**Query Parameters:**
- None specified

**Request Body:**
- None

**Response Success (example):**
```json
{
  "success": true,
  "message": "OK",
  "data": {}
}
```

**Response Error (common):**
- 401: Token missing or invalid
- 403: Access denied wrong role
- 404: Resource not found
- 500: Server error

**Flutter/Dart Code Example:**
```dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:firebase_auth/firebase_auth.dart';

final baseUrl = 'https://sumacademy.net/api';
final uri = Uri.parse('$baseUrl/student/courses/:courseId/progress');
final token = await FirebaseAuth.instance.currentUser?.getIdToken(true);
final headers = {'Content-Type': 'application/json', 'Authorization': 'Bearer $token'};
final res = await http.get(uri, headers: headers);
final data = jsonDecode(res.body) as Map<String, dynamic>;
if (res.statusCode >= 400) { /* handle error */ }
```

#### Courses By Courseid Lectures By Lectureid Complete

<span style="color:#1565C0"><strong>POST</strong></span> https://sumacademy.net/api/student/courses/:courseId/lectures/:lectureId/complete

**Description:** Create or submit data for this resource.

**Authentication:** Required

**Role required:** student

**Request Headers:**
- Content-Type: application/json
- Authorization: Bearer <Firebase ID Token>

**Path Parameters:**
- `courseId` (string, required)
- `lectureId` (string, required)

**Query Parameters:**
- None specified

**Request Body:**
```json
TBD (confirm request body with backend)
```

**Response Success (example):**
```json
{
  "success": true,
  "message": "OK",
  "data": {}
}
```

**Response Error (common):**
- 401: Token missing or invalid
- 403: Access denied wrong role
- 404: Resource not found
- 500: Server error

**Flutter/Dart Code Example:**
```dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:firebase_auth/firebase_auth.dart';

final baseUrl = 'https://sumacademy.net/api';
final uri = Uri.parse('$baseUrl/student/courses/:courseId/lectures/:lectureId/complete');
final token = await FirebaseAuth.instance.currentUser?.getIdToken(true);
final headers = {'Content-Type': 'application/json', 'Authorization': 'Bearer $token'};
final payload = {/* TODO: request body */};
final res = await http.post(uri, headers: headers, body: jsonEncode(payload));
final data = jsonDecode(res.body) as Map<String, dynamic>;
if (res.statusCode >= 400) { /* handle error */ }
```

#### Certificates

<span style="color:#2E7D32"><strong>GET</strong></span> https://sumacademy.net/api/student/certificates

**Description:** Retrieve data for this resource.

**Authentication:** Required

**Role required:** student

**Request Headers:**
- Content-Type: application/json
- Authorization: Bearer <Firebase ID Token>

**Path Parameters:**
- None

**Query Parameters:**
- None specified

**Request Body:**
- None

**Response Success (example):**
```json
{
  "success": true,
  "message": "OK",
  "data": {}
}
```

**Response Error (common):**
- 401: Token missing or invalid
- 403: Access denied wrong role
- 404: Resource not found
- 500: Server error

**Flutter/Dart Code Example:**
```dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:firebase_auth/firebase_auth.dart';

final baseUrl = 'https://sumacademy.net/api';
final uri = Uri.parse('$baseUrl/student/certificates');
final token = await FirebaseAuth.instance.currentUser?.getIdToken(true);
final headers = {'Content-Type': 'application/json', 'Authorization': 'Bearer $token'};
final res = await http.get(uri, headers: headers);
final data = jsonDecode(res.body) as Map<String, dynamic>;
if (res.statusCode >= 400) { /* handle error */ }
```

#### Quizzes

<span style="color:#2E7D32"><strong>GET</strong></span> https://sumacademy.net/api/student/quizzes

**Description:** Retrieve data for this resource.

**Authentication:** Required

**Role required:** student

**Request Headers:**
- Content-Type: application/json
- Authorization: Bearer <Firebase ID Token>

**Path Parameters:**
- None

**Query Parameters:**
- None specified

**Request Body:**
- None

**Response Success (example):**
```json
{
  "success": true,
  "message": "OK",
  "data": {}
}
```

**Response Error (common):**
- 401: Token missing or invalid
- 403: Access denied wrong role
- 404: Resource not found
- 500: Server error

**Flutter/Dart Code Example:**
```dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:firebase_auth/firebase_auth.dart';

final baseUrl = 'https://sumacademy.net/api';
final uri = Uri.parse('$baseUrl/student/quizzes');
final token = await FirebaseAuth.instance.currentUser?.getIdToken(true);
final headers = {'Content-Type': 'application/json', 'Authorization': 'Bearer $token'};
final res = await http.get(uri, headers: headers);
final data = jsonDecode(res.body) as Map<String, dynamic>;
if (res.statusCode >= 400) { /* handle error */ }
```

#### Quizzes By Quizid

<span style="color:#2E7D32"><strong>GET</strong></span> https://sumacademy.net/api/student/quizzes/:quizId

**Description:** Retrieve data for this resource.

**Authentication:** Required

**Role required:** student

**Request Headers:**
- Content-Type: application/json
- Authorization: Bearer <Firebase ID Token>

**Path Parameters:**
- `quizId` (string, required)

**Query Parameters:**
- None specified

**Request Body:**
- None

**Response Success (example):**
```json
{
  "success": true,
  "message": "OK",
  "data": {}
}
```

**Response Error (common):**
- 401: Token missing or invalid
- 403: Access denied wrong role
- 404: Resource not found
- 500: Server error

**Flutter/Dart Code Example:**
```dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:firebase_auth/firebase_auth.dart';

final baseUrl = 'https://sumacademy.net/api';
final uri = Uri.parse('$baseUrl/student/quizzes/:quizId');
final token = await FirebaseAuth.instance.currentUser?.getIdToken(true);
final headers = {'Content-Type': 'application/json', 'Authorization': 'Bearer $token'};
final res = await http.get(uri, headers: headers);
final data = jsonDecode(res.body) as Map<String, dynamic>;
if (res.statusCode >= 400) { /* handle error */ }
```

#### Quizzes By Quizid Submit

<span style="color:#1565C0"><strong>POST</strong></span> https://sumacademy.net/api/student/quizzes/:quizId/submit

**Description:** Create or submit data for this resource.

**Authentication:** Required

**Role required:** student

**Request Headers:**
- Content-Type: application/json
- Authorization: Bearer <Firebase ID Token>

**Path Parameters:**
- `quizId` (string, required)

**Query Parameters:**
- None specified

**Request Body:**
```json
TBD (confirm request body with backend)
```

**Response Success (example):**
```json
{
  "success": true,
  "message": "OK",
  "data": {}
}
```

**Response Error (common):**
- 401: Token missing or invalid
- 403: Access denied wrong role
- 404: Resource not found
- 500: Server error

**Flutter/Dart Code Example:**
```dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:firebase_auth/firebase_auth.dart';

final baseUrl = 'https://sumacademy.net/api';
final uri = Uri.parse('$baseUrl/student/quizzes/:quizId/submit');
final token = await FirebaseAuth.instance.currentUser?.getIdToken(true);
final headers = {'Content-Type': 'application/json', 'Authorization': 'Bearer $token'};
final payload = {/* TODO: request body */};
final res = await http.post(uri, headers: headers, body: jsonEncode(payload));
final data = jsonDecode(res.body) as Map<String, dynamic>;
if (res.statusCode >= 400) { /* handle error */ }
```

#### Announcements

<span style="color:#2E7D32"><strong>GET</strong></span> https://sumacademy.net/api/student/announcements

**Description:** Retrieve data for this resource.

**Authentication:** Required

**Role required:** student

**Request Headers:**
- Content-Type: application/json
- Authorization: Bearer <Firebase ID Token>

**Path Parameters:**
- None

**Query Parameters:**
- None specified

**Request Body:**
- None

**Response Success (example):**
```json
{
  "success": true,
  "message": "OK",
  "data": {}
}
```

**Response Error (common):**
- 401: Token missing or invalid
- 403: Access denied wrong role
- 404: Resource not found
- 500: Server error

**Flutter/Dart Code Example:**
```dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:firebase_auth/firebase_auth.dart';

final baseUrl = 'https://sumacademy.net/api';
final uri = Uri.parse('$baseUrl/student/announcements');
final token = await FirebaseAuth.instance.currentUser?.getIdToken(true);
final headers = {'Content-Type': 'application/json', 'Authorization': 'Bearer $token'};
final res = await http.get(uri, headers: headers);
final data = jsonDecode(res.body) as Map<String, dynamic>;
if (res.statusCode >= 400) { /* handle error */ }
```

#### Announcements By Id Read

<span style="color:#EF6C00"><strong>PATCH</strong></span> https://sumacademy.net/api/student/announcements/:id/read

**Description:** Update data for this resource.

**Authentication:** Required

**Role required:** student

**Request Headers:**
- Content-Type: application/json
- Authorization: Bearer <Firebase ID Token>

**Path Parameters:**
- `id` (string, required)

**Query Parameters:**
- None specified

**Request Body:**
```json
TBD (confirm request body with backend)
```

**Response Success (example):**
```json
{
  "success": true,
  "message": "OK",
  "data": {}
}
```

**Response Error (common):**
- 401: Token missing or invalid
- 403: Access denied wrong role
- 404: Resource not found
- 500: Server error

**Flutter/Dart Code Example:**
```dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:firebase_auth/firebase_auth.dart';

final baseUrl = 'https://sumacademy.net/api';
final uri = Uri.parse('$baseUrl/student/announcements/:id/read');
final token = await FirebaseAuth.instance.currentUser?.getIdToken(true);
final headers = {'Content-Type': 'application/json', 'Authorization': 'Bearer $token'};
final payload = {/* TODO: request body */};
final res = await http.patch(uri, headers: headers, body: jsonEncode(payload));
final data = jsonDecode(res.body) as Map<String, dynamic>;
if (res.statusCode >= 400) { /* handle error */ }
```

#### Attendance

<span style="color:#2E7D32"><strong>GET</strong></span> https://sumacademy.net/api/student/attendance

**Description:** Retrieve data for this resource.

**Authentication:** Required

**Role required:** student

**Request Headers:**
- Content-Type: application/json
- Authorization: Bearer <Firebase ID Token>

**Path Parameters:**
- None

**Query Parameters:**
- None specified

**Request Body:**
- None

**Response Success (example):**
```json
{
  "success": true,
  "message": "OK",
  "data": {}
}
```

**Response Error (common):**
- 401: Token missing or invalid
- 403: Access denied wrong role
- 404: Resource not found
- 500: Server error

**Flutter/Dart Code Example:**
```dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:firebase_auth/firebase_auth.dart';

final baseUrl = 'https://sumacademy.net/api';
final uri = Uri.parse('$baseUrl/student/attendance');
final token = await FirebaseAuth.instance.currentUser?.getIdToken(true);
final headers = {'Content-Type': 'application/json', 'Authorization': 'Bearer $token'};
final res = await http.get(uri, headers: headers);
final data = jsonDecode(res.body) as Map<String, dynamic>;
if (res.statusCode >= 400) { /* handle error */ }
```

#### Help Support

<span style="color:#1565C0"><strong>POST</strong></span> https://sumacademy.net/api/student/help-support

**Description:** Create or submit data for this resource.

**Authentication:** Required

**Role required:** student

**Request Headers:**
- Content-Type: application/json
- Authorization: Bearer <Firebase ID Token>

**Path Parameters:**
- None

**Query Parameters:**
- None specified

**Request Body:**
```json
TBD (confirm request body with backend)
```

**Response Success (example):**
```json
{
  "success": true,
  "message": "OK",
  "data": {}
}
```

**Response Error (common):**
- 401: Token missing or invalid
- 403: Access denied wrong role
- 404: Resource not found
- 500: Server error

**Flutter/Dart Code Example:**
```dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:firebase_auth/firebase_auth.dart';

final baseUrl = 'https://sumacademy.net/api';
final uri = Uri.parse('$baseUrl/student/help-support');
final token = await FirebaseAuth.instance.currentUser?.getIdToken(true);
final headers = {'Content-Type': 'application/json', 'Authorization': 'Bearer $token'};
final payload = {/* TODO: request body */};
final res = await http.post(uri, headers: headers, body: jsonEncode(payload));
final data = jsonDecode(res.body) as Map<String, dynamic>;
if (res.statusCode >= 400) { /* handle error */ }
```

#### Settings

<span style="color:#2E7D32"><strong>GET</strong></span> https://sumacademy.net/api/student/settings

**Description:** Retrieve data for this resource.

**Authentication:** Required

**Role required:** student

**Request Headers:**
- Content-Type: application/json
- Authorization: Bearer <Firebase ID Token>

**Path Parameters:**
- None

**Query Parameters:**
- None specified

**Request Body:**
- None

**Response Success (example):**
```json
{
  "success": true,
  "message": "OK",
  "data": {}
}
```

**Response Error (common):**
- 401: Token missing or invalid
- 403: Access denied wrong role
- 404: Resource not found
- 500: Server error

**Flutter/Dart Code Example:**
```dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:firebase_auth/firebase_auth.dart';

final baseUrl = 'https://sumacademy.net/api';
final uri = Uri.parse('$baseUrl/student/settings');
final token = await FirebaseAuth.instance.currentUser?.getIdToken(true);
final headers = {'Content-Type': 'application/json', 'Authorization': 'Bearer $token'};
final res = await http.get(uri, headers: headers);
final data = jsonDecode(res.body) as Map<String, dynamic>;
if (res.statusCode >= 400) { /* handle error */ }
```

#### Settings

<span style="color:#6A1B9A"><strong>PUT</strong></span> https://sumacademy.net/api/student/settings

**Description:** Replace data for this resource.

**Authentication:** Required

**Role required:** student

**Request Headers:**
- Content-Type: application/json
- Authorization: Bearer <Firebase ID Token>

**Path Parameters:**
- None

**Query Parameters:**
- None specified

**Request Body:**
```json
TBD (confirm request body with backend)
```

**Response Success (example):**
```json
{
  "success": true,
  "message": "OK",
  "data": {}
}
```

**Response Error (common):**
- 401: Token missing or invalid
- 403: Access denied wrong role
- 404: Resource not found
- 500: Server error

**Flutter/Dart Code Example:**
```dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:firebase_auth/firebase_auth.dart';

final baseUrl = 'https://sumacademy.net/api';
final uri = Uri.parse('$baseUrl/student/settings');
final token = await FirebaseAuth.instance.currentUser?.getIdToken(true);
final headers = {'Content-Type': 'application/json', 'Authorization': 'Bearer $token'};
final payload = {/* TODO: request body */};
final res = await http.put(uri, headers: headers, body: jsonEncode(payload));
final data = jsonDecode(res.body) as Map<String, dynamic>;
if (res.statusCode >= 400) { /* handle error */ }
```


## PAYMENT APIs

#### Initiate

<span style="color:#1565C0"><strong>POST</strong></span> https://sumacademy.net/api/payments/initiate

**Description:** Create or submit data for this resource.

**Authentication:** Required

**Role required:** none

**Request Headers:**
- Content-Type: application/json
- Authorization: Bearer <Firebase ID Token>

**Path Parameters:**
- None

**Query Parameters:**
- None specified

**Request Body:**
```json
TBD (confirm request body with backend)
```

**Response Success (example):**
```json
{
  "success": true,
  "message": "OK",
  "data": {}
}
```

**Response Error (common):**
- 401: Token missing or invalid
- 403: Access denied wrong role
- 404: Resource not found
- 500: Server error

**Flutter/Dart Code Example:**
```dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:firebase_auth/firebase_auth.dart';

final baseUrl = 'https://sumacademy.net/api';
final uri = Uri.parse('$baseUrl/payments/initiate');
final token = await FirebaseAuth.instance.currentUser?.getIdToken(true);
final headers = {'Content-Type': 'application/json', 'Authorization': 'Bearer $token'};
final payload = {/* TODO: request body */};
final res = await http.post(uri, headers: headers, body: jsonEncode(payload));
final data = jsonDecode(res.body) as Map<String, dynamic>;
if (res.statusCode >= 400) { /* handle error */ }
```

#### Validate Promo

<span style="color:#1565C0"><strong>POST</strong></span> https://sumacademy.net/api/payments/validate-promo

**Description:** Create or submit data for this resource.

**Authentication:** Required

**Role required:** none

**Request Headers:**
- Content-Type: application/json
- Authorization: Bearer <Firebase ID Token>

**Path Parameters:**
- None

**Query Parameters:**
- None specified

**Request Body:**
```json
TBD (confirm request body with backend)
```

**Response Success (example):**
```json
{
  "success": true,
  "message": "OK",
  "data": {}
}
```

**Response Error (common):**
- 401: Token missing or invalid
- 403: Access denied wrong role
- 404: Resource not found
- 500: Server error

**Flutter/Dart Code Example:**
```dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:firebase_auth/firebase_auth.dart';

final baseUrl = 'https://sumacademy.net/api';
final uri = Uri.parse('$baseUrl/payments/validate-promo');
final token = await FirebaseAuth.instance.currentUser?.getIdToken(true);
final headers = {'Content-Type': 'application/json', 'Authorization': 'Bearer $token'};
final payload = {/* TODO: request body */};
final res = await http.post(uri, headers: headers, body: jsonEncode(payload));
final data = jsonDecode(res.body) as Map<String, dynamic>;
if (res.statusCode >= 400) { /* handle error */ }
```

#### Config

<span style="color:#2E7D32"><strong>GET</strong></span> https://sumacademy.net/api/payments/config

**Description:** Retrieve data for this resource.

**Authentication:** Required

**Role required:** none

**Request Headers:**
- Content-Type: application/json
- Authorization: Bearer <Firebase ID Token>

**Path Parameters:**
- None

**Query Parameters:**
- None specified

**Request Body:**
- None

**Response Success (example):**
```json
{
  "success": true,
  "message": "OK",
  "data": {}
}
```

**Response Error (common):**
- 401: Token missing or invalid
- 403: Access denied wrong role
- 404: Resource not found
- 500: Server error

**Flutter/Dart Code Example:**
```dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:firebase_auth/firebase_auth.dart';

final baseUrl = 'https://sumacademy.net/api';
final uri = Uri.parse('$baseUrl/payments/config');
final token = await FirebaseAuth.instance.currentUser?.getIdToken(true);
final headers = {'Content-Type': 'application/json', 'Authorization': 'Bearer $token'};
final res = await http.get(uri, headers: headers);
final data = jsonDecode(res.body) as Map<String, dynamic>;
if (res.statusCode >= 400) { /* handle error */ }
```

#### By Id Receipt

<span style="color:#1565C0"><strong>POST</strong></span> https://sumacademy.net/api/payments/:id/receipt

**Description:** Create or submit data for this resource.

**Authentication:** Required

**Role required:** none

**Request Headers:**
- Content-Type: application/json
- Authorization: Bearer <Firebase ID Token>

**Path Parameters:**
- `id` (string, required)

**Query Parameters:**
- None specified

**Request Body:**
```json
TBD (confirm request body with backend)
```

**Response Success (example):**
```json
{
  "success": true,
  "message": "OK",
  "data": {}
}
```

**Response Error (common):**
- 401: Token missing or invalid
- 403: Access denied wrong role
- 404: Resource not found
- 500: Server error

**Flutter/Dart Code Example:**
```dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:firebase_auth/firebase_auth.dart';

final baseUrl = 'https://sumacademy.net/api';
final uri = Uri.parse('$baseUrl/payments/:id/receipt');
final token = await FirebaseAuth.instance.currentUser?.getIdToken(true);
final headers = {'Content-Type': 'application/json', 'Authorization': 'Bearer $token'};
final payload = {/* TODO: request body */};
final res = await http.post(uri, headers: headers, body: jsonEncode(payload));
final data = jsonDecode(res.body) as Map<String, dynamic>;
if (res.statusCode >= 400) { /* handle error */ }
```

#### By Id Status

<span style="color:#2E7D32"><strong>GET</strong></span> https://sumacademy.net/api/payments/:id/status

**Description:** Retrieve data for this resource.

**Authentication:** Required

**Role required:** none

**Request Headers:**
- Content-Type: application/json
- Authorization: Bearer <Firebase ID Token>

**Path Parameters:**
- `id` (string, required)

**Query Parameters:**
- None specified

**Request Body:**
- None

**Response Success (example):**
```json
{
  "success": true,
  "message": "OK",
  "data": {}
}
```

**Response Error (common):**
- 401: Token missing or invalid
- 403: Access denied wrong role
- 404: Resource not found
- 500: Server error

**Flutter/Dart Code Example:**
```dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:firebase_auth/firebase_auth.dart';

final baseUrl = 'https://sumacademy.net/api';
final uri = Uri.parse('$baseUrl/payments/:id/status');
final token = await FirebaseAuth.instance.currentUser?.getIdToken(true);
final headers = {'Content-Type': 'application/json', 'Authorization': 'Bearer $token'};
final res = await http.get(uri, headers: headers);
final data = jsonDecode(res.body) as Map<String, dynamic>;
if (res.statusCode >= 400) { /* handle error */ }
```

#### My Payments

<span style="color:#2E7D32"><strong>GET</strong></span> https://sumacademy.net/api/payments/my-payments

**Description:** Retrieve data for this resource.

**Authentication:** Required

**Role required:** none

**Request Headers:**
- Content-Type: application/json
- Authorization: Bearer <Firebase ID Token>

**Path Parameters:**
- None

**Query Parameters:**
- None specified

**Request Body:**
- None

**Response Success (example):**
```json
{
  "success": true,
  "message": "OK",
  "data": {}
}
```

**Response Error (common):**
- 401: Token missing or invalid
- 403: Access denied wrong role
- 404: Resource not found
- 500: Server error

**Flutter/Dart Code Example:**
```dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:firebase_auth/firebase_auth.dart';

final baseUrl = 'https://sumacademy.net/api';
final uri = Uri.parse('$baseUrl/payments/my-payments');
final token = await FirebaseAuth.instance.currentUser?.getIdToken(true);
final headers = {'Content-Type': 'application/json', 'Authorization': 'Bearer $token'};
final res = await http.get(uri, headers: headers);
final data = jsonDecode(res.body) as Map<String, dynamic>;
if (res.statusCode >= 400) { /* handle error */ }
```

#### My Installments

<span style="color:#2E7D32"><strong>GET</strong></span> https://sumacademy.net/api/payments/my-installments

**Description:** Retrieve data for this resource.

**Authentication:** Required

**Role required:** none

**Request Headers:**
- Content-Type: application/json
- Authorization: Bearer <Firebase ID Token>

**Path Parameters:**
- None

**Query Parameters:**
- None specified

**Request Body:**
- None

**Response Success (example):**
```json
{
  "success": true,
  "message": "OK",
  "data": {}
}
```

**Response Error (common):**
- 401: Token missing or invalid
- 403: Access denied wrong role
- 404: Resource not found
- 500: Server error

**Flutter/Dart Code Example:**
```dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:firebase_auth/firebase_auth.dart';

final baseUrl = 'https://sumacademy.net/api';
final uri = Uri.parse('$baseUrl/payments/my-installments');
final token = await FirebaseAuth.instance.currentUser?.getIdToken(true);
final headers = {'Content-Type': 'application/json', 'Authorization': 'Bearer $token'};
final res = await http.get(uri, headers: headers);
final data = jsonDecode(res.body) as Map<String, dynamic>;
if (res.statusCode >= 400) { /* handle error */ }
```


## TEACHER APIs

#### Dashboard

<span style="color:#2E7D32"><strong>GET</strong></span> https://sumacademy.net/api/teacher/dashboard

**Description:** Retrieve data for this resource.

**Authentication:** Required

**Role required:** teacher

**Request Headers:**
- Content-Type: application/json
- Authorization: Bearer <Firebase ID Token>

**Path Parameters:**
- None

**Query Parameters:**
- None specified

**Request Body:**
- None

**Response Success (example):**
```json
{
  "success": true,
  "message": "OK",
  "data": {}
}
```

**Response Error (common):**
- 401: Token missing or invalid
- 403: Access denied wrong role
- 404: Resource not found
- 500: Server error

**Flutter/Dart Code Example:**
```dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:firebase_auth/firebase_auth.dart';

final baseUrl = 'https://sumacademy.net/api';
final uri = Uri.parse('$baseUrl/teacher/dashboard');
final token = await FirebaseAuth.instance.currentUser?.getIdToken(true);
final headers = {'Content-Type': 'application/json', 'Authorization': 'Bearer $token'};
final res = await http.get(uri, headers: headers);
final data = jsonDecode(res.body) as Map<String, dynamic>;
if (res.statusCode >= 400) { /* handle error */ }
```

#### Courses

<span style="color:#2E7D32"><strong>GET</strong></span> https://sumacademy.net/api/teacher/courses

**Description:** Retrieve data for this resource.

**Authentication:** Required

**Role required:** teacher

**Request Headers:**
- Content-Type: application/json
- Authorization: Bearer <Firebase ID Token>

**Path Parameters:**
- None

**Query Parameters:**
- None specified

**Request Body:**
- None

**Response Success (example):**
```json
{
  "success": true,
  "message": "OK",
  "data": {}
}
```

**Response Error (common):**
- 401: Token missing or invalid
- 403: Access denied wrong role
- 404: Resource not found
- 500: Server error

**Flutter/Dart Code Example:**
```dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:firebase_auth/firebase_auth.dart';

final baseUrl = 'https://sumacademy.net/api';
final uri = Uri.parse('$baseUrl/teacher/courses');
final token = await FirebaseAuth.instance.currentUser?.getIdToken(true);
final headers = {'Content-Type': 'application/json', 'Authorization': 'Bearer $token'};
final res = await http.get(uri, headers: headers);
final data = jsonDecode(res.body) as Map<String, dynamic>;
if (res.statusCode >= 400) { /* handle error */ }
```

#### Courses By Courseid

<span style="color:#2E7D32"><strong>GET</strong></span> https://sumacademy.net/api/teacher/courses/:courseId

**Description:** Retrieve data for this resource.

**Authentication:** Required

**Role required:** teacher

**Request Headers:**
- Content-Type: application/json
- Authorization: Bearer <Firebase ID Token>

**Path Parameters:**
- `courseId` (string, required)

**Query Parameters:**
- None specified

**Request Body:**
- None

**Response Success (example):**
```json
{
  "success": true,
  "message": "OK",
  "data": {}
}
```

**Response Error (common):**
- 401: Token missing or invalid
- 403: Access denied wrong role
- 404: Resource not found
- 500: Server error

**Flutter/Dart Code Example:**
```dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:firebase_auth/firebase_auth.dart';

final baseUrl = 'https://sumacademy.net/api';
final uri = Uri.parse('$baseUrl/teacher/courses/:courseId');
final token = await FirebaseAuth.instance.currentUser?.getIdToken(true);
final headers = {'Content-Type': 'application/json', 'Authorization': 'Bearer $token'};
final res = await http.get(uri, headers: headers);
final data = jsonDecode(res.body) as Map<String, dynamic>;
if (res.statusCode >= 400) { /* handle error */ }
```

#### Courses By Courseid Subjects By Subjectid Chapters

<span style="color:#2E7D32"><strong>GET</strong></span> https://sumacademy.net/api/teacher/courses/:courseId/subjects/:subjectId/chapters

**Description:** Retrieve data for this resource.

**Authentication:** Required

**Role required:** teacher

**Request Headers:**
- Content-Type: application/json
- Authorization: Bearer <Firebase ID Token>

**Path Parameters:**
- `courseId` (string, required)
- `subjectId` (string, required)

**Query Parameters:**
- None specified

**Request Body:**
- None

**Response Success (example):**
```json
{
  "success": true,
  "message": "OK",
  "data": {}
}
```

**Response Error (common):**
- 401: Token missing or invalid
- 403: Access denied wrong role
- 404: Resource not found
- 500: Server error

**Flutter/Dart Code Example:**
```dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:firebase_auth/firebase_auth.dart';

final baseUrl = 'https://sumacademy.net/api';
final uri = Uri.parse('$baseUrl/teacher/courses/:courseId/subjects/:subjectId/chapters');
final token = await FirebaseAuth.instance.currentUser?.getIdToken(true);
final headers = {'Content-Type': 'application/json', 'Authorization': 'Bearer $token'};
final res = await http.get(uri, headers: headers);
final data = jsonDecode(res.body) as Map<String, dynamic>;
if (res.statusCode >= 400) { /* handle error */ }
```

#### Courses By Courseid Subjects By Subjectid Chapters

<span style="color:#1565C0"><strong>POST</strong></span> https://sumacademy.net/api/teacher/courses/:courseId/subjects/:subjectId/chapters

**Description:** Create or submit data for this resource.

**Authentication:** Required

**Role required:** teacher

**Request Headers:**
- Content-Type: application/json
- Authorization: Bearer <Firebase ID Token>

**Path Parameters:**
- `courseId` (string, required)
- `subjectId` (string, required)

**Query Parameters:**
- None specified

**Request Body:**
```json
TBD (confirm request body with backend)
```

**Response Success (example):**
```json
{
  "success": true,
  "message": "OK",
  "data": {}
}
```

**Response Error (common):**
- 401: Token missing or invalid
- 403: Access denied wrong role
- 404: Resource not found
- 500: Server error

**Flutter/Dart Code Example:**
```dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:firebase_auth/firebase_auth.dart';

final baseUrl = 'https://sumacademy.net/api';
final uri = Uri.parse('$baseUrl/teacher/courses/:courseId/subjects/:subjectId/chapters');
final token = await FirebaseAuth.instance.currentUser?.getIdToken(true);
final headers = {'Content-Type': 'application/json', 'Authorization': 'Bearer $token'};
final payload = {/* TODO: request body */};
final res = await http.post(uri, headers: headers, body: jsonEncode(payload));
final data = jsonDecode(res.body) as Map<String, dynamic>;
if (res.statusCode >= 400) { /* handle error */ }
```

#### Chapters By Chapterid

<span style="color:#6A1B9A"><strong>PUT</strong></span> https://sumacademy.net/api/teacher/chapters/:chapterId

**Description:** Replace data for this resource.

**Authentication:** Required

**Role required:** teacher

**Request Headers:**
- Content-Type: application/json
- Authorization: Bearer <Firebase ID Token>

**Path Parameters:**
- `chapterId` (string, required)

**Query Parameters:**
- None specified

**Request Body:**
```json
TBD (confirm request body with backend)
```

**Response Success (example):**
```json
{
  "success": true,
  "message": "OK",
  "data": {}
}
```

**Response Error (common):**
- 401: Token missing or invalid
- 403: Access denied wrong role
- 404: Resource not found
- 500: Server error

**Flutter/Dart Code Example:**
```dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:firebase_auth/firebase_auth.dart';

final baseUrl = 'https://sumacademy.net/api';
final uri = Uri.parse('$baseUrl/teacher/chapters/:chapterId');
final token = await FirebaseAuth.instance.currentUser?.getIdToken(true);
final headers = {'Content-Type': 'application/json', 'Authorization': 'Bearer $token'};
final payload = {/* TODO: request body */};
final res = await http.put(uri, headers: headers, body: jsonEncode(payload));
final data = jsonDecode(res.body) as Map<String, dynamic>;
if (res.statusCode >= 400) { /* handle error */ }
```

#### Chapters By Chapterid

<span style="color:#C62828"><strong>DELETE</strong></span> https://sumacademy.net/api/teacher/chapters/:chapterId

**Description:** Delete this resource.

**Authentication:** Required

**Role required:** teacher

**Request Headers:**
- Content-Type: application/json
- Authorization: Bearer <Firebase ID Token>

**Path Parameters:**
- `chapterId` (string, required)

**Query Parameters:**
- None specified

**Request Body:**
- None

**Response Success (example):**
```json
{
  "success": true,
  "message": "OK",
  "data": {}
}
```

**Response Error (common):**
- 401: Token missing or invalid
- 403: Access denied wrong role
- 404: Resource not found
- 500: Server error

**Flutter/Dart Code Example:**
```dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:firebase_auth/firebase_auth.dart';

final baseUrl = 'https://sumacademy.net/api';
final uri = Uri.parse('$baseUrl/teacher/chapters/:chapterId');
final token = await FirebaseAuth.instance.currentUser?.getIdToken(true);
final headers = {'Content-Type': 'application/json', 'Authorization': 'Bearer $token'};
final res = await http.delete(uri, headers: headers);
final data = jsonDecode(res.body) as Map<String, dynamic>;
if (res.statusCode >= 400) { /* handle error */ }
```

#### Chapters By Chapterid Lectures

<span style="color:#2E7D32"><strong>GET</strong></span> https://sumacademy.net/api/teacher/chapters/:chapterId/lectures

**Description:** Retrieve data for this resource.

**Authentication:** Required

**Role required:** teacher

**Request Headers:**
- Content-Type: application/json
- Authorization: Bearer <Firebase ID Token>

**Path Parameters:**
- `chapterId` (string, required)

**Query Parameters:**
- None specified

**Request Body:**
- None

**Response Success (example):**
```json
{
  "success": true,
  "message": "OK",
  "data": {}
}
```

**Response Error (common):**
- 401: Token missing or invalid
- 403: Access denied wrong role
- 404: Resource not found
- 500: Server error

**Flutter/Dart Code Example:**
```dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:firebase_auth/firebase_auth.dart';

final baseUrl = 'https://sumacademy.net/api';
final uri = Uri.parse('$baseUrl/teacher/chapters/:chapterId/lectures');
final token = await FirebaseAuth.instance.currentUser?.getIdToken(true);
final headers = {'Content-Type': 'application/json', 'Authorization': 'Bearer $token'};
final res = await http.get(uri, headers: headers);
final data = jsonDecode(res.body) as Map<String, dynamic>;
if (res.statusCode >= 400) { /* handle error */ }
```

#### Chapters By Chapterid Lectures

<span style="color:#1565C0"><strong>POST</strong></span> https://sumacademy.net/api/teacher/chapters/:chapterId/lectures

**Description:** Create or submit data for this resource.

**Authentication:** Required

**Role required:** teacher

**Request Headers:**
- Content-Type: application/json
- Authorization: Bearer <Firebase ID Token>

**Path Parameters:**
- `chapterId` (string, required)

**Query Parameters:**
- None specified

**Request Body:**
```json
TBD (confirm request body with backend)
```

**Response Success (example):**
```json
{
  "success": true,
  "message": "OK",
  "data": {}
}
```

**Response Error (common):**
- 401: Token missing or invalid
- 403: Access denied wrong role
- 404: Resource not found
- 500: Server error

**Flutter/Dart Code Example:**
```dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:firebase_auth/firebase_auth.dart';

final baseUrl = 'https://sumacademy.net/api';
final uri = Uri.parse('$baseUrl/teacher/chapters/:chapterId/lectures');
final token = await FirebaseAuth.instance.currentUser?.getIdToken(true);
final headers = {'Content-Type': 'application/json', 'Authorization': 'Bearer $token'};
final payload = {/* TODO: request body */};
final res = await http.post(uri, headers: headers, body: jsonEncode(payload));
final data = jsonDecode(res.body) as Map<String, dynamic>;
if (res.statusCode >= 400) { /* handle error */ }
```

#### Lectures By Lectureid

<span style="color:#6A1B9A"><strong>PUT</strong></span> https://sumacademy.net/api/teacher/lectures/:lectureId

**Description:** Replace data for this resource.

**Authentication:** Required

**Role required:** teacher

**Request Headers:**
- Content-Type: application/json
- Authorization: Bearer <Firebase ID Token>

**Path Parameters:**
- `lectureId` (string, required)

**Query Parameters:**
- None specified

**Request Body:**
```json
TBD (confirm request body with backend)
```

**Response Success (example):**
```json
{
  "success": true,
  "message": "OK",
  "data": {}
}
```

**Response Error (common):**
- 401: Token missing or invalid
- 403: Access denied wrong role
- 404: Resource not found
- 500: Server error

**Flutter/Dart Code Example:**
```dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:firebase_auth/firebase_auth.dart';

final baseUrl = 'https://sumacademy.net/api';
final uri = Uri.parse('$baseUrl/teacher/lectures/:lectureId');
final token = await FirebaseAuth.instance.currentUser?.getIdToken(true);
final headers = {'Content-Type': 'application/json', 'Authorization': 'Bearer $token'};
final payload = {/* TODO: request body */};
final res = await http.put(uri, headers: headers, body: jsonEncode(payload));
final data = jsonDecode(res.body) as Map<String, dynamic>;
if (res.statusCode >= 400) { /* handle error */ }
```

#### Lectures By Lectureid

<span style="color:#C62828"><strong>DELETE</strong></span> https://sumacademy.net/api/teacher/lectures/:lectureId

**Description:** Delete this resource.

**Authentication:** Required

**Role required:** teacher

**Request Headers:**
- Content-Type: application/json
- Authorization: Bearer <Firebase ID Token>

**Path Parameters:**
- `lectureId` (string, required)

**Query Parameters:**
- None specified

**Request Body:**
- None

**Response Success (example):**
```json
{
  "success": true,
  "message": "OK",
  "data": {}
}
```

**Response Error (common):**
- 401: Token missing or invalid
- 403: Access denied wrong role
- 404: Resource not found
- 500: Server error

**Flutter/Dart Code Example:**
```dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:firebase_auth/firebase_auth.dart';

final baseUrl = 'https://sumacademy.net/api';
final uri = Uri.parse('$baseUrl/teacher/lectures/:lectureId');
final token = await FirebaseAuth.instance.currentUser?.getIdToken(true);
final headers = {'Content-Type': 'application/json', 'Authorization': 'Bearer $token'};
final res = await http.delete(uri, headers: headers);
final data = jsonDecode(res.body) as Map<String, dynamic>;
if (res.statusCode >= 400) { /* handle error */ }
```

#### Lectures By Lectureid Content

<span style="color:#1565C0"><strong>POST</strong></span> https://sumacademy.net/api/teacher/lectures/:lectureId/content

**Description:** Create or submit data for this resource.

**Authentication:** Required

**Role required:** teacher

**Request Headers:**
- Content-Type: application/json
- Authorization: Bearer <Firebase ID Token>

**Path Parameters:**
- `lectureId` (string, required)

**Query Parameters:**
- None specified

**Request Body:**
```json
TBD (confirm request body with backend)
```

**Response Success (example):**
```json
{
  "success": true,
  "message": "OK",
  "data": {}
}
```

**Response Error (common):**
- 401: Token missing or invalid
- 403: Access denied wrong role
- 404: Resource not found
- 500: Server error

**Flutter/Dart Code Example:**
```dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:firebase_auth/firebase_auth.dart';

final baseUrl = 'https://sumacademy.net/api';
final uri = Uri.parse('$baseUrl/teacher/lectures/:lectureId/content');
final token = await FirebaseAuth.instance.currentUser?.getIdToken(true);
final headers = {'Content-Type': 'application/json', 'Authorization': 'Bearer $token'};
final payload = {/* TODO: request body */};
final res = await http.post(uri, headers: headers, body: jsonEncode(payload));
final data = jsonDecode(res.body) as Map<String, dynamic>;
if (res.statusCode >= 400) { /* handle error */ }
```

#### Lectures By Lectureid Content By Contentid

<span style="color:#C62828"><strong>DELETE</strong></span> https://sumacademy.net/api/teacher/lectures/:lectureId/content/:contentId

**Description:** Delete this resource.

**Authentication:** Required

**Role required:** teacher

**Request Headers:**
- Content-Type: application/json
- Authorization: Bearer <Firebase ID Token>

**Path Parameters:**
- `lectureId` (string, required)
- `contentId` (string, required)

**Query Parameters:**
- None specified

**Request Body:**
- None

**Response Success (example):**
```json
{
  "success": true,
  "message": "OK",
  "data": {}
}
```

**Response Error (common):**
- 401: Token missing or invalid
- 403: Access denied wrong role
- 404: Resource not found
- 500: Server error

**Flutter/Dart Code Example:**
```dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:firebase_auth/firebase_auth.dart';

final baseUrl = 'https://sumacademy.net/api';
final uri = Uri.parse('$baseUrl/teacher/lectures/:lectureId/content/:contentId');
final token = await FirebaseAuth.instance.currentUser?.getIdToken(true);
final headers = {'Content-Type': 'application/json', 'Authorization': 'Bearer $token'};
final res = await http.delete(uri, headers: headers);
final data = jsonDecode(res.body) as Map<String, dynamic>;
if (res.statusCode >= 400) { /* handle error */ }
```

#### Courses By Courseid Students

<span style="color:#2E7D32"><strong>GET</strong></span> https://sumacademy.net/api/teacher/courses/:courseId/students

**Description:** Retrieve data for this resource.

**Authentication:** Required

**Role required:** teacher

**Request Headers:**
- Content-Type: application/json
- Authorization: Bearer <Firebase ID Token>

**Path Parameters:**
- `courseId` (string, required)

**Query Parameters:**
- None specified

**Request Body:**
- None

**Response Success (example):**
```json
{
  "success": true,
  "message": "OK",
  "data": {}
}
```

**Response Error (common):**
- 401: Token missing or invalid
- 403: Access denied wrong role
- 404: Resource not found
- 500: Server error

**Flutter/Dart Code Example:**
```dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:firebase_auth/firebase_auth.dart';

final baseUrl = 'https://sumacademy.net/api';
final uri = Uri.parse('$baseUrl/teacher/courses/:courseId/students');
final token = await FirebaseAuth.instance.currentUser?.getIdToken(true);
final headers = {'Content-Type': 'application/json', 'Authorization': 'Bearer $token'};
final res = await http.get(uri, headers: headers);
final data = jsonDecode(res.body) as Map<String, dynamic>;
if (res.statusCode >= 400) { /* handle error */ }
```

#### Courses By Courseid Students By Studentid Video Access

<span style="color:#EF6C00"><strong>PATCH</strong></span> https://sumacademy.net/api/teacher/courses/:courseId/students/:studentId/video-access

**Description:** Update data for this resource.

**Authentication:** Required

**Role required:** teacher

**Request Headers:**
- Content-Type: application/json
- Authorization: Bearer <Firebase ID Token>

**Path Parameters:**
- `courseId` (string, required)
- `studentId` (string, required)

**Query Parameters:**
- None specified

**Request Body:**
```json
TBD (confirm request body with backend)
```

**Response Success (example):**
```json
{
  "success": true,
  "message": "OK",
  "data": {}
}
```

**Response Error (common):**
- 401: Token missing or invalid
- 403: Access denied wrong role
- 404: Resource not found
- 500: Server error

**Flutter/Dart Code Example:**
```dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:firebase_auth/firebase_auth.dart';

final baseUrl = 'https://sumacademy.net/api';
final uri = Uri.parse('$baseUrl/teacher/courses/:courseId/students/:studentId/video-access');
final token = await FirebaseAuth.instance.currentUser?.getIdToken(true);
final headers = {'Content-Type': 'application/json', 'Authorization': 'Bearer $token'};
final payload = {/* TODO: request body */};
final res = await http.patch(uri, headers: headers, body: jsonEncode(payload));
final data = jsonDecode(res.body) as Map<String, dynamic>;
if (res.statusCode >= 400) { /* handle error */ }
```

#### Students

<span style="color:#2E7D32"><strong>GET</strong></span> https://sumacademy.net/api/teacher/students

**Description:** Retrieve data for this resource.

**Authentication:** Required

**Role required:** teacher

**Request Headers:**
- Content-Type: application/json
- Authorization: Bearer <Firebase ID Token>

**Path Parameters:**
- None

**Query Parameters:**
- None specified

**Request Body:**
- None

**Response Success (example):**
```json
{
  "success": true,
  "message": "OK",
  "data": {}
}
```

**Response Error (common):**
- 401: Token missing or invalid
- 403: Access denied wrong role
- 404: Resource not found
- 500: Server error

**Flutter/Dart Code Example:**
```dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:firebase_auth/firebase_auth.dart';

final baseUrl = 'https://sumacademy.net/api';
final uri = Uri.parse('$baseUrl/teacher/students');
final token = await FirebaseAuth.instance.currentUser?.getIdToken(true);
final headers = {'Content-Type': 'application/json', 'Authorization': 'Bearer $token'};
final res = await http.get(uri, headers: headers);
final data = jsonDecode(res.body) as Map<String, dynamic>;
if (res.statusCode >= 400) { /* handle error */ }
```

#### Students By Studentid

<span style="color:#2E7D32"><strong>GET</strong></span> https://sumacademy.net/api/teacher/students/:studentId

**Description:** Retrieve data for this resource.

**Authentication:** Required

**Role required:** teacher

**Request Headers:**
- Content-Type: application/json
- Authorization: Bearer <Firebase ID Token>

**Path Parameters:**
- `studentId` (string, required)

**Query Parameters:**
- None specified

**Request Body:**
- None

**Response Success (example):**
```json
{
  "success": true,
  "message": "OK",
  "data": {}
}
```

**Response Error (common):**
- 401: Token missing or invalid
- 403: Access denied wrong role
- 404: Resource not found
- 500: Server error

**Flutter/Dart Code Example:**
```dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:firebase_auth/firebase_auth.dart';

final baseUrl = 'https://sumacademy.net/api';
final uri = Uri.parse('$baseUrl/teacher/students/:studentId');
final token = await FirebaseAuth.instance.currentUser?.getIdToken(true);
final headers = {'Content-Type': 'application/json', 'Authorization': 'Bearer $token'};
final res = await http.get(uri, headers: headers);
final data = jsonDecode(res.body) as Map<String, dynamic>;
if (res.statusCode >= 400) { /* handle error */ }
```

#### Students By Studentid Progress By Courseid

<span style="color:#2E7D32"><strong>GET</strong></span> https://sumacademy.net/api/teacher/students/:studentId/progress/:courseId

**Description:** Retrieve data for this resource.

**Authentication:** Required

**Role required:** teacher

**Request Headers:**
- Content-Type: application/json
- Authorization: Bearer <Firebase ID Token>

**Path Parameters:**
- `studentId` (string, required)
- `courseId` (string, required)

**Query Parameters:**
- None specified

**Request Body:**
- None

**Response Success (example):**
```json
{
  "success": true,
  "message": "OK",
  "data": {}
}
```

**Response Error (common):**
- 401: Token missing or invalid
- 403: Access denied wrong role
- 404: Resource not found
- 500: Server error

**Flutter/Dart Code Example:**
```dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:firebase_auth/firebase_auth.dart';

final baseUrl = 'https://sumacademy.net/api';
final uri = Uri.parse('$baseUrl/teacher/students/:studentId/progress/:courseId');
final token = await FirebaseAuth.instance.currentUser?.getIdToken(true);
final headers = {'Content-Type': 'application/json', 'Authorization': 'Bearer $token'};
final res = await http.get(uri, headers: headers);
final data = jsonDecode(res.body) as Map<String, dynamic>;
if (res.statusCode >= 400) { /* handle error */ }
```

#### Students By Studentid Video Access

<span style="color:#EF6C00"><strong>PATCH</strong></span> https://sumacademy.net/api/teacher/students/:studentId/video-access

**Description:** Update data for this resource.

**Authentication:** Required

**Role required:** teacher

**Request Headers:**
- Content-Type: application/json
- Authorization: Bearer <Firebase ID Token>

**Path Parameters:**
- `studentId` (string, required)

**Query Parameters:**
- None specified

**Request Body:**
```json
TBD (confirm request body with backend)
```

**Response Success (example):**
```json
{
  "success": true,
  "message": "OK",
  "data": {}
}
```

**Response Error (common):**
- 401: Token missing or invalid
- 403: Access denied wrong role
- 404: Resource not found
- 500: Server error

**Flutter/Dart Code Example:**
```dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:firebase_auth/firebase_auth.dart';

final baseUrl = 'https://sumacademy.net/api';
final uri = Uri.parse('$baseUrl/teacher/students/:studentId/video-access');
final token = await FirebaseAuth.instance.currentUser?.getIdToken(true);
final headers = {'Content-Type': 'application/json', 'Authorization': 'Bearer $token'};
final payload = {/* TODO: request body */};
final res = await http.patch(uri, headers: headers, body: jsonEncode(payload));
final data = jsonDecode(res.body) as Map<String, dynamic>;
if (res.statusCode >= 400) { /* handle error */ }
```

#### Students By Studentid Attendance By Classid

<span style="color:#2E7D32"><strong>GET</strong></span> https://sumacademy.net/api/teacher/students/:studentId/attendance/:classId

**Description:** Retrieve data for this resource.

**Authentication:** Required

**Role required:** teacher

**Request Headers:**
- Content-Type: application/json
- Authorization: Bearer <Firebase ID Token>

**Path Parameters:**
- `studentId` (string, required)
- `classId` (string, required)

**Query Parameters:**
- None specified

**Request Body:**
- None

**Response Success (example):**
```json
{
  "success": true,
  "message": "OK",
  "data": {}
}
```

**Response Error (common):**
- 401: Token missing or invalid
- 403: Access denied wrong role
- 404: Resource not found
- 500: Server error

**Flutter/Dart Code Example:**
```dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:firebase_auth/firebase_auth.dart';

final baseUrl = 'https://sumacademy.net/api';
final uri = Uri.parse('$baseUrl/teacher/students/:studentId/attendance/:classId');
final token = await FirebaseAuth.instance.currentUser?.getIdToken(true);
final headers = {'Content-Type': 'application/json', 'Authorization': 'Bearer $token'};
final res = await http.get(uri, headers: headers);
final data = jsonDecode(res.body) as Map<String, dynamic>;
if (res.statusCode >= 400) { /* handle error */ }
```

#### Sessions

<span style="color:#2E7D32"><strong>GET</strong></span> https://sumacademy.net/api/teacher/sessions

**Description:** Retrieve data for this resource.

**Authentication:** Required

**Role required:** teacher

**Request Headers:**
- Content-Type: application/json
- Authorization: Bearer <Firebase ID Token>

**Path Parameters:**
- None

**Query Parameters:**
- None specified

**Request Body:**
- None

**Response Success (example):**
```json
{
  "success": true,
  "message": "OK",
  "data": {}
}
```

**Response Error (common):**
- 401: Token missing or invalid
- 403: Access denied wrong role
- 404: Resource not found
- 500: Server error

**Flutter/Dart Code Example:**
```dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:firebase_auth/firebase_auth.dart';

final baseUrl = 'https://sumacademy.net/api';
final uri = Uri.parse('$baseUrl/teacher/sessions');
final token = await FirebaseAuth.instance.currentUser?.getIdToken(true);
final headers = {'Content-Type': 'application/json', 'Authorization': 'Bearer $token'};
final res = await http.get(uri, headers: headers);
final data = jsonDecode(res.body) as Map<String, dynamic>;
if (res.statusCode >= 400) { /* handle error */ }
```

#### Sessions By Sessionid

<span style="color:#2E7D32"><strong>GET</strong></span> https://sumacademy.net/api/teacher/sessions/:sessionId

**Description:** Retrieve data for this resource.

**Authentication:** Required

**Role required:** teacher

**Request Headers:**
- Content-Type: application/json
- Authorization: Bearer <Firebase ID Token>

**Path Parameters:**
- `sessionId` (string, required)

**Query Parameters:**
- None specified

**Request Body:**
- None

**Response Success (example):**
```json
{
  "success": true,
  "message": "OK",
  "data": {}
}
```

**Response Error (common):**
- 401: Token missing or invalid
- 403: Access denied wrong role
- 404: Resource not found
- 500: Server error

**Flutter/Dart Code Example:**
```dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:firebase_auth/firebase_auth.dart';

final baseUrl = 'https://sumacademy.net/api';
final uri = Uri.parse('$baseUrl/teacher/sessions/:sessionId');
final token = await FirebaseAuth.instance.currentUser?.getIdToken(true);
final headers = {'Content-Type': 'application/json', 'Authorization': 'Bearer $token'};
final res = await http.get(uri, headers: headers);
final data = jsonDecode(res.body) as Map<String, dynamic>;
if (res.statusCode >= 400) { /* handle error */ }
```

#### Sessions

<span style="color:#1565C0"><strong>POST</strong></span> https://sumacademy.net/api/teacher/sessions

**Description:** Create or submit data for this resource.

**Authentication:** Required

**Role required:** teacher

**Request Headers:**
- Content-Type: application/json
- Authorization: Bearer <Firebase ID Token>

**Path Parameters:**
- None

**Query Parameters:**
- None specified

**Request Body:**
```json
TBD (confirm request body with backend)
```

**Response Success (example):**
```json
{
  "success": true,
  "message": "OK",
  "data": {}
}
```

**Response Error (common):**
- 401: Token missing or invalid
- 403: Access denied wrong role
- 404: Resource not found
- 500: Server error

**Flutter/Dart Code Example:**
```dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:firebase_auth/firebase_auth.dart';

final baseUrl = 'https://sumacademy.net/api';
final uri = Uri.parse('$baseUrl/teacher/sessions');
final token = await FirebaseAuth.instance.currentUser?.getIdToken(true);
final headers = {'Content-Type': 'application/json', 'Authorization': 'Bearer $token'};
final payload = {/* TODO: request body */};
final res = await http.post(uri, headers: headers, body: jsonEncode(payload));
final data = jsonDecode(res.body) as Map<String, dynamic>;
if (res.statusCode >= 400) { /* handle error */ }
```

#### Sessions By Sessionid

<span style="color:#6A1B9A"><strong>PUT</strong></span> https://sumacademy.net/api/teacher/sessions/:sessionId

**Description:** Replace data for this resource.

**Authentication:** Required

**Role required:** teacher

**Request Headers:**
- Content-Type: application/json
- Authorization: Bearer <Firebase ID Token>

**Path Parameters:**
- `sessionId` (string, required)

**Query Parameters:**
- None specified

**Request Body:**
```json
TBD (confirm request body with backend)
```

**Response Success (example):**
```json
{
  "success": true,
  "message": "OK",
  "data": {}
}
```

**Response Error (common):**
- 401: Token missing or invalid
- 403: Access denied wrong role
- 404: Resource not found
- 500: Server error

**Flutter/Dart Code Example:**
```dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:firebase_auth/firebase_auth.dart';

final baseUrl = 'https://sumacademy.net/api';
final uri = Uri.parse('$baseUrl/teacher/sessions/:sessionId');
final token = await FirebaseAuth.instance.currentUser?.getIdToken(true);
final headers = {'Content-Type': 'application/json', 'Authorization': 'Bearer $token'};
final payload = {/* TODO: request body */};
final res = await http.put(uri, headers: headers, body: jsonEncode(payload));
final data = jsonDecode(res.body) as Map<String, dynamic>;
if (res.statusCode >= 400) { /* handle error */ }
```

#### Sessions By Sessionid Cancel

<span style="color:#EF6C00"><strong>PATCH</strong></span> https://sumacademy.net/api/teacher/sessions/:sessionId/cancel

**Description:** Update data for this resource.

**Authentication:** Required

**Role required:** teacher

**Request Headers:**
- Content-Type: application/json
- Authorization: Bearer <Firebase ID Token>

**Path Parameters:**
- `sessionId` (string, required)

**Query Parameters:**
- None specified

**Request Body:**
```json
TBD (confirm request body with backend)
```

**Response Success (example):**
```json
{
  "success": true,
  "message": "OK",
  "data": {}
}
```

**Response Error (common):**
- 401: Token missing or invalid
- 403: Access denied wrong role
- 404: Resource not found
- 500: Server error

**Flutter/Dart Code Example:**
```dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:firebase_auth/firebase_auth.dart';

final baseUrl = 'https://sumacademy.net/api';
final uri = Uri.parse('$baseUrl/teacher/sessions/:sessionId/cancel');
final token = await FirebaseAuth.instance.currentUser?.getIdToken(true);
final headers = {'Content-Type': 'application/json', 'Authorization': 'Bearer $token'};
final payload = {/* TODO: request body */};
final res = await http.patch(uri, headers: headers, body: jsonEncode(payload));
final data = jsonDecode(res.body) as Map<String, dynamic>;
if (res.statusCode >= 400) { /* handle error */ }
```

#### Sessions By Sessionid Complete

<span style="color:#EF6C00"><strong>PATCH</strong></span> https://sumacademy.net/api/teacher/sessions/:sessionId/complete

**Description:** Update data for this resource.

**Authentication:** Required

**Role required:** teacher

**Request Headers:**
- Content-Type: application/json
- Authorization: Bearer <Firebase ID Token>

**Path Parameters:**
- `sessionId` (string, required)

**Query Parameters:**
- None specified

**Request Body:**
```json
TBD (confirm request body with backend)
```

**Response Success (example):**
```json
{
  "success": true,
  "message": "OK",
  "data": {}
}
```

**Response Error (common):**
- 401: Token missing or invalid
- 403: Access denied wrong role
- 404: Resource not found
- 500: Server error

**Flutter/Dart Code Example:**
```dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:firebase_auth/firebase_auth.dart';

final baseUrl = 'https://sumacademy.net/api';
final uri = Uri.parse('$baseUrl/teacher/sessions/:sessionId/complete');
final token = await FirebaseAuth.instance.currentUser?.getIdToken(true);
final headers = {'Content-Type': 'application/json', 'Authorization': 'Bearer $token'};
final payload = {/* TODO: request body */};
final res = await http.patch(uri, headers: headers, body: jsonEncode(payload));
final data = jsonDecode(res.body) as Map<String, dynamic>;
if (res.statusCode >= 400) { /* handle error */ }
```

#### Sessions By Sessionid Attendance

<span style="color:#2E7D32"><strong>GET</strong></span> https://sumacademy.net/api/teacher/sessions/:sessionId/attendance

**Description:** Retrieve data for this resource.

**Authentication:** Required

**Role required:** teacher

**Request Headers:**
- Content-Type: application/json
- Authorization: Bearer <Firebase ID Token>

**Path Parameters:**
- `sessionId` (string, required)

**Query Parameters:**
- None specified

**Request Body:**
- None

**Response Success (example):**
```json
{
  "success": true,
  "message": "OK",
  "data": {}
}
```

**Response Error (common):**
- 401: Token missing or invalid
- 403: Access denied wrong role
- 404: Resource not found
- 500: Server error

**Flutter/Dart Code Example:**
```dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:firebase_auth/firebase_auth.dart';

final baseUrl = 'https://sumacademy.net/api';
final uri = Uri.parse('$baseUrl/teacher/sessions/:sessionId/attendance');
final token = await FirebaseAuth.instance.currentUser?.getIdToken(true);
final headers = {'Content-Type': 'application/json', 'Authorization': 'Bearer $token'};
final res = await http.get(uri, headers: headers);
final data = jsonDecode(res.body) as Map<String, dynamic>;
if (res.statusCode >= 400) { /* handle error */ }
```

#### Sessions By Sessionid Attendance

<span style="color:#1565C0"><strong>POST</strong></span> https://sumacademy.net/api/teacher/sessions/:sessionId/attendance

**Description:** Create or submit data for this resource.

**Authentication:** Required

**Role required:** teacher

**Request Headers:**
- Content-Type: application/json
- Authorization: Bearer <Firebase ID Token>

**Path Parameters:**
- `sessionId` (string, required)

**Query Parameters:**
- None specified

**Request Body:**
```json
TBD (confirm request body with backend)
```

**Response Success (example):**
```json
{
  "success": true,
  "message": "OK",
  "data": {}
}
```

**Response Error (common):**
- 401: Token missing or invalid
- 403: Access denied wrong role
- 404: Resource not found
- 500: Server error

**Flutter/Dart Code Example:**
```dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:firebase_auth/firebase_auth.dart';

final baseUrl = 'https://sumacademy.net/api';
final uri = Uri.parse('$baseUrl/teacher/sessions/:sessionId/attendance');
final token = await FirebaseAuth.instance.currentUser?.getIdToken(true);
final headers = {'Content-Type': 'application/json', 'Authorization': 'Bearer $token'};
final payload = {/* TODO: request body */};
final res = await http.post(uri, headers: headers, body: jsonEncode(payload));
final data = jsonDecode(res.body) as Map<String, dynamic>;
if (res.statusCode >= 400) { /* handle error */ }
```

#### Classes

<span style="color:#2E7D32"><strong>GET</strong></span> https://sumacademy.net/api/teacher/classes

**Description:** Retrieve data for this resource.

**Authentication:** Required

**Role required:** teacher

**Request Headers:**
- Content-Type: application/json
- Authorization: Bearer <Firebase ID Token>

**Path Parameters:**
- None

**Query Parameters:**
- None specified

**Request Body:**
- None

**Response Success (example):**
```json
{
  "success": true,
  "message": "OK",
  "data": {}
}
```

**Response Error (common):**
- 401: Token missing or invalid
- 403: Access denied wrong role
- 404: Resource not found
- 500: Server error

**Flutter/Dart Code Example:**
```dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:firebase_auth/firebase_auth.dart';

final baseUrl = 'https://sumacademy.net/api';
final uri = Uri.parse('$baseUrl/teacher/classes');
final token = await FirebaseAuth.instance.currentUser?.getIdToken(true);
final headers = {'Content-Type': 'application/json', 'Authorization': 'Bearer $token'};
final res = await http.get(uri, headers: headers);
final data = jsonDecode(res.body) as Map<String, dynamic>;
if (res.statusCode >= 400) { /* handle error */ }
```

#### Announcements

<span style="color:#2E7D32"><strong>GET</strong></span> https://sumacademy.net/api/teacher/announcements

**Description:** Retrieve data for this resource.

**Authentication:** Required

**Role required:** teacher

**Request Headers:**
- Content-Type: application/json
- Authorization: Bearer <Firebase ID Token>

**Path Parameters:**
- None

**Query Parameters:**
- None specified

**Request Body:**
- None

**Response Success (example):**
```json
{
  "success": true,
  "message": "OK",
  "data": {}
}
```

**Response Error (common):**
- 401: Token missing or invalid
- 403: Access denied wrong role
- 404: Resource not found
- 500: Server error

**Flutter/Dart Code Example:**
```dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:firebase_auth/firebase_auth.dart';

final baseUrl = 'https://sumacademy.net/api';
final uri = Uri.parse('$baseUrl/teacher/announcements');
final token = await FirebaseAuth.instance.currentUser?.getIdToken(true);
final headers = {'Content-Type': 'application/json', 'Authorization': 'Bearer $token'};
final res = await http.get(uri, headers: headers);
final data = jsonDecode(res.body) as Map<String, dynamic>;
if (res.statusCode >= 400) { /* handle error */ }
```

#### Announcements

<span style="color:#1565C0"><strong>POST</strong></span> https://sumacademy.net/api/teacher/announcements

**Description:** Create or submit data for this resource.

**Authentication:** Required

**Role required:** teacher

**Request Headers:**
- Content-Type: application/json
- Authorization: Bearer <Firebase ID Token>

**Path Parameters:**
- None

**Query Parameters:**
- None specified

**Request Body:**
```json
TBD (confirm request body with backend)
```

**Response Success (example):**
```json
{
  "success": true,
  "message": "OK",
  "data": {}
}
```

**Response Error (common):**
- 401: Token missing or invalid
- 403: Access denied wrong role
- 404: Resource not found
- 500: Server error

**Flutter/Dart Code Example:**
```dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:firebase_auth/firebase_auth.dart';

final baseUrl = 'https://sumacademy.net/api';
final uri = Uri.parse('$baseUrl/teacher/announcements');
final token = await FirebaseAuth.instance.currentUser?.getIdToken(true);
final headers = {'Content-Type': 'application/json', 'Authorization': 'Bearer $token'};
final payload = {/* TODO: request body */};
final res = await http.post(uri, headers: headers, body: jsonEncode(payload));
final data = jsonDecode(res.body) as Map<String, dynamic>;
if (res.statusCode >= 400) { /* handle error */ }
```

#### Quizzes Template

<span style="color:#2E7D32"><strong>GET</strong></span> https://sumacademy.net/api/teacher/quizzes/template

**Description:** Retrieve data for this resource.

**Authentication:** Required

**Role required:** teacher

**Request Headers:**
- Content-Type: application/json
- Authorization: Bearer <Firebase ID Token>

**Path Parameters:**
- None

**Query Parameters:**
- None specified

**Request Body:**
- None

**Response Success (example):**
```json
{
  "success": true,
  "message": "OK",
  "data": {}
}
```

**Response Error (common):**
- 401: Token missing or invalid
- 403: Access denied wrong role
- 404: Resource not found
- 500: Server error

**Flutter/Dart Code Example:**
```dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:firebase_auth/firebase_auth.dart';

final baseUrl = 'https://sumacademy.net/api';
final uri = Uri.parse('$baseUrl/teacher/quizzes/template');
final token = await FirebaseAuth.instance.currentUser?.getIdToken(true);
final headers = {'Content-Type': 'application/json', 'Authorization': 'Bearer $token'};
final res = await http.get(uri, headers: headers);
final data = jsonDecode(res.body) as Map<String, dynamic>;
if (res.statusCode >= 400) { /* handle error */ }
```

#### Quizzes

<span style="color:#2E7D32"><strong>GET</strong></span> https://sumacademy.net/api/teacher/quizzes

**Description:** Retrieve data for this resource.

**Authentication:** Required

**Role required:** teacher

**Request Headers:**
- Content-Type: application/json
- Authorization: Bearer <Firebase ID Token>

**Path Parameters:**
- None

**Query Parameters:**
- None specified

**Request Body:**
- None

**Response Success (example):**
```json
{
  "success": true,
  "message": "OK",
  "data": {}
}
```

**Response Error (common):**
- 401: Token missing or invalid
- 403: Access denied wrong role
- 404: Resource not found
- 500: Server error

**Flutter/Dart Code Example:**
```dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:firebase_auth/firebase_auth.dart';

final baseUrl = 'https://sumacademy.net/api';
final uri = Uri.parse('$baseUrl/teacher/quizzes');
final token = await FirebaseAuth.instance.currentUser?.getIdToken(true);
final headers = {'Content-Type': 'application/json', 'Authorization': 'Bearer $token'};
final res = await http.get(uri, headers: headers);
final data = jsonDecode(res.body) as Map<String, dynamic>;
if (res.statusCode >= 400) { /* handle error */ }
```

#### Quizzes By Quizid

<span style="color:#2E7D32"><strong>GET</strong></span> https://sumacademy.net/api/teacher/quizzes/:quizId

**Description:** Retrieve data for this resource.

**Authentication:** Required

**Role required:** teacher

**Request Headers:**
- Content-Type: application/json
- Authorization: Bearer <Firebase ID Token>

**Path Parameters:**
- `quizId` (string, required)

**Query Parameters:**
- None specified

**Request Body:**
- None

**Response Success (example):**
```json
{
  "success": true,
  "message": "OK",
  "data": {}
}
```

**Response Error (common):**
- 401: Token missing or invalid
- 403: Access denied wrong role
- 404: Resource not found
- 500: Server error

**Flutter/Dart Code Example:**
```dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:firebase_auth/firebase_auth.dart';

final baseUrl = 'https://sumacademy.net/api';
final uri = Uri.parse('$baseUrl/teacher/quizzes/:quizId');
final token = await FirebaseAuth.instance.currentUser?.getIdToken(true);
final headers = {'Content-Type': 'application/json', 'Authorization': 'Bearer $token'};
final res = await http.get(uri, headers: headers);
final data = jsonDecode(res.body) as Map<String, dynamic>;
if (res.statusCode >= 400) { /* handle error */ }
```

#### Quizzes By Quizid Analytics

<span style="color:#2E7D32"><strong>GET</strong></span> https://sumacademy.net/api/teacher/quizzes/:quizId/analytics

**Description:** Retrieve data for this resource.

**Authentication:** Required

**Role required:** teacher

**Request Headers:**
- Content-Type: application/json
- Authorization: Bearer <Firebase ID Token>

**Path Parameters:**
- `quizId` (string, required)

**Query Parameters:**
- None specified

**Request Body:**
- None

**Response Success (example):**
```json
{
  "success": true,
  "message": "OK",
  "data": {}
}
```

**Response Error (common):**
- 401: Token missing or invalid
- 403: Access denied wrong role
- 404: Resource not found
- 500: Server error

**Flutter/Dart Code Example:**
```dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:firebase_auth/firebase_auth.dart';

final baseUrl = 'https://sumacademy.net/api';
final uri = Uri.parse('$baseUrl/teacher/quizzes/:quizId/analytics');
final token = await FirebaseAuth.instance.currentUser?.getIdToken(true);
final headers = {'Content-Type': 'application/json', 'Authorization': 'Bearer $token'};
final res = await http.get(uri, headers: headers);
final data = jsonDecode(res.body) as Map<String, dynamic>;
if (res.statusCode >= 400) { /* handle error */ }
```

#### Quizzes

<span style="color:#1565C0"><strong>POST</strong></span> https://sumacademy.net/api/teacher/quizzes

**Description:** Create or submit data for this resource.

**Authentication:** Required

**Role required:** teacher

**Request Headers:**
- Content-Type: application/json
- Authorization: Bearer <Firebase ID Token>

**Path Parameters:**
- None

**Query Parameters:**
- None specified

**Request Body:**
```json
TBD (confirm request body with backend)
```

**Response Success (example):**
```json
{
  "success": true,
  "message": "OK",
  "data": {}
}
```

**Response Error (common):**
- 401: Token missing or invalid
- 403: Access denied wrong role
- 404: Resource not found
- 500: Server error

**Flutter/Dart Code Example:**
```dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:firebase_auth/firebase_auth.dart';

final baseUrl = 'https://sumacademy.net/api';
final uri = Uri.parse('$baseUrl/teacher/quizzes');
final token = await FirebaseAuth.instance.currentUser?.getIdToken(true);
final headers = {'Content-Type': 'application/json', 'Authorization': 'Bearer $token'};
final payload = {/* TODO: request body */};
final res = await http.post(uri, headers: headers, body: jsonEncode(payload));
final data = jsonDecode(res.body) as Map<String, dynamic>;
if (res.statusCode >= 400) { /* handle error */ }
```

#### Quizzes Bulk Upload

<span style="color:#1565C0"><strong>POST</strong></span> https://sumacademy.net/api/teacher/quizzes/bulk-upload

**Description:** Create or submit data for this resource.

**Authentication:** Required

**Role required:** teacher

**Request Headers:**
- Content-Type: application/json
- Authorization: Bearer <Firebase ID Token>

**Path Parameters:**
- None

**Query Parameters:**
- None specified

**Request Body:**
```json
TBD (confirm request body with backend)
```

**Response Success (example):**
```json
{
  "success": true,
  "message": "OK",
  "data": {}
}
```

**Response Error (common):**
- 401: Token missing or invalid
- 403: Access denied wrong role
- 404: Resource not found
- 500: Server error

**Flutter/Dart Code Example:**
```dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:firebase_auth/firebase_auth.dart';

final baseUrl = 'https://sumacademy.net/api';
final uri = Uri.parse('$baseUrl/teacher/quizzes/bulk-upload');
final token = await FirebaseAuth.instance.currentUser?.getIdToken(true);
final headers = {'Content-Type': 'application/json', 'Authorization': 'Bearer $token'};
final payload = {/* TODO: request body */};
final res = await http.post(uri, headers: headers, body: jsonEncode(payload));
final data = jsonDecode(res.body) as Map<String, dynamic>;
if (res.statusCode >= 400) { /* handle error */ }
```

#### Quizzes By Quizid Assign

<span style="color:#EF6C00"><strong>PATCH</strong></span> https://sumacademy.net/api/teacher/quizzes/:quizId/assign

**Description:** Update data for this resource.

**Authentication:** Required

**Role required:** teacher

**Request Headers:**
- Content-Type: application/json
- Authorization: Bearer <Firebase ID Token>

**Path Parameters:**
- `quizId` (string, required)

**Query Parameters:**
- None specified

**Request Body:**
```json
TBD (confirm request body with backend)
```

**Response Success (example):**
```json
{
  "success": true,
  "message": "OK",
  "data": {}
}
```

**Response Error (common):**
- 401: Token missing or invalid
- 403: Access denied wrong role
- 404: Resource not found
- 500: Server error

**Flutter/Dart Code Example:**
```dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:firebase_auth/firebase_auth.dart';

final baseUrl = 'https://sumacademy.net/api';
final uri = Uri.parse('$baseUrl/teacher/quizzes/:quizId/assign');
final token = await FirebaseAuth.instance.currentUser?.getIdToken(true);
final headers = {'Content-Type': 'application/json', 'Authorization': 'Bearer $token'};
final payload = {/* TODO: request body */};
final res = await http.patch(uri, headers: headers, body: jsonEncode(payload));
final data = jsonDecode(res.body) as Map<String, dynamic>;
if (res.statusCode >= 400) { /* handle error */ }
```

#### Quizzes By Quizid Evaluate

<span style="color:#1565C0"><strong>POST</strong></span> https://sumacademy.net/api/teacher/quizzes/:quizId/evaluate

**Description:** Create or submit data for this resource.

**Authentication:** Required

**Role required:** teacher

**Request Headers:**
- Content-Type: application/json
- Authorization: Bearer <Firebase ID Token>

**Path Parameters:**
- `quizId` (string, required)

**Query Parameters:**
- None specified

**Request Body:**
```json
TBD (confirm request body with backend)
```

**Response Success (example):**
```json
{
  "success": true,
  "message": "OK",
  "data": {}
}
```

**Response Error (common):**
- 401: Token missing or invalid
- 403: Access denied wrong role
- 404: Resource not found
- 500: Server error

**Flutter/Dart Code Example:**
```dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:firebase_auth/firebase_auth.dart';

final baseUrl = 'https://sumacademy.net/api';
final uri = Uri.parse('$baseUrl/teacher/quizzes/:quizId/evaluate');
final token = await FirebaseAuth.instance.currentUser?.getIdToken(true);
final headers = {'Content-Type': 'application/json', 'Authorization': 'Bearer $token'};
final payload = {/* TODO: request body */};
final res = await http.post(uri, headers: headers, body: jsonEncode(payload));
final data = jsonDecode(res.body) as Map<String, dynamic>;
if (res.statusCode >= 400) { /* handle error */ }
```

#### Quizzes By Quizid Submissions

<span style="color:#1565C0"><strong>POST</strong></span> https://sumacademy.net/api/teacher/quizzes/:quizId/submissions

**Description:** Create or submit data for this resource.

**Authentication:** Required

**Role required:** teacher

**Request Headers:**
- Content-Type: application/json
- Authorization: Bearer <Firebase ID Token>

**Path Parameters:**
- `quizId` (string, required)

**Query Parameters:**
- None specified

**Request Body:**
```json
TBD (confirm request body with backend)
```

**Response Success (example):**
```json
{
  "success": true,
  "message": "OK",
  "data": {}
}
```

**Response Error (common):**
- 401: Token missing or invalid
- 403: Access denied wrong role
- 404: Resource not found
- 500: Server error

**Flutter/Dart Code Example:**
```dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:firebase_auth/firebase_auth.dart';

final baseUrl = 'https://sumacademy.net/api';
final uri = Uri.parse('$baseUrl/teacher/quizzes/:quizId/submissions');
final token = await FirebaseAuth.instance.currentUser?.getIdToken(true);
final headers = {'Content-Type': 'application/json', 'Authorization': 'Bearer $token'};
final payload = {/* TODO: request body */};
final res = await http.post(uri, headers: headers, body: jsonEncode(payload));
final data = jsonDecode(res.body) as Map<String, dynamic>;
if (res.statusCode >= 400) { /* handle error */ }
```

#### Quizzes By Quizid Submissions

<span style="color:#2E7D32"><strong>GET</strong></span> https://sumacademy.net/api/teacher/quizzes/:quizId/submissions

**Description:** Retrieve data for this resource.

**Authentication:** Required

**Role required:** teacher

**Request Headers:**
- Content-Type: application/json
- Authorization: Bearer <Firebase ID Token>

**Path Parameters:**
- `quizId` (string, required)

**Query Parameters:**
- None specified

**Request Body:**
- None

**Response Success (example):**
```json
{
  "success": true,
  "message": "OK",
  "data": {}
}
```

**Response Error (common):**
- 401: Token missing or invalid
- 403: Access denied wrong role
- 404: Resource not found
- 500: Server error

**Flutter/Dart Code Example:**
```dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:firebase_auth/firebase_auth.dart';

final baseUrl = 'https://sumacademy.net/api';
final uri = Uri.parse('$baseUrl/teacher/quizzes/:quizId/submissions');
final token = await FirebaseAuth.instance.currentUser?.getIdToken(true);
final headers = {'Content-Type': 'application/json', 'Authorization': 'Bearer $token'};
final res = await http.get(uri, headers: headers);
final data = jsonDecode(res.body) as Map<String, dynamic>;
if (res.statusCode >= 400) { /* handle error */ }
```

#### Quizzes By Quizid Submissions By Resultid Grade Short

<span style="color:#EF6C00"><strong>PATCH</strong></span> https://sumacademy.net/api/teacher/quizzes/:quizId/submissions/:resultId/grade-short

**Description:** Update data for this resource.

**Authentication:** Required

**Role required:** teacher

**Request Headers:**
- Content-Type: application/json
- Authorization: Bearer <Firebase ID Token>

**Path Parameters:**
- `quizId` (string, required)
- `resultId` (string, required)

**Query Parameters:**
- None specified

**Request Body:**
```json
TBD (confirm request body with backend)
```

**Response Success (example):**
```json
{
  "success": true,
  "message": "OK",
  "data": {}
}
```

**Response Error (common):**
- 401: Token missing or invalid
- 403: Access denied wrong role
- 404: Resource not found
- 500: Server error

**Flutter/Dart Code Example:**
```dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:firebase_auth/firebase_auth.dart';

final baseUrl = 'https://sumacademy.net/api';
final uri = Uri.parse('$baseUrl/teacher/quizzes/:quizId/submissions/:resultId/grade-short');
final token = await FirebaseAuth.instance.currentUser?.getIdToken(true);
final headers = {'Content-Type': 'application/json', 'Authorization': 'Bearer $token'};
final payload = {/* TODO: request body */};
final res = await http.patch(uri, headers: headers, body: jsonEncode(payload));
final data = jsonDecode(res.body) as Map<String, dynamic>;
if (res.statusCode >= 400) { /* handle error */ }
```

#### Settings Profile

<span style="color:#2E7D32"><strong>GET</strong></span> https://sumacademy.net/api/teacher/settings/profile

**Description:** Retrieve data for this resource.

**Authentication:** Required

**Role required:** teacher

**Request Headers:**
- Content-Type: application/json
- Authorization: Bearer <Firebase ID Token>

**Path Parameters:**
- None

**Query Parameters:**
- None specified

**Request Body:**
- None

**Response Success (example):**
```json
{
  "success": true,
  "message": "OK",
  "data": {}
}
```

**Response Error (common):**
- 401: Token missing or invalid
- 403: Access denied wrong role
- 404: Resource not found
- 500: Server error

**Flutter/Dart Code Example:**
```dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:firebase_auth/firebase_auth.dart';

final baseUrl = 'https://sumacademy.net/api';
final uri = Uri.parse('$baseUrl/teacher/settings/profile');
final token = await FirebaseAuth.instance.currentUser?.getIdToken(true);
final headers = {'Content-Type': 'application/json', 'Authorization': 'Bearer $token'};
final res = await http.get(uri, headers: headers);
final data = jsonDecode(res.body) as Map<String, dynamic>;
if (res.statusCode >= 400) { /* handle error */ }
```

#### Settings Profile

<span style="color:#6A1B9A"><strong>PUT</strong></span> https://sumacademy.net/api/teacher/settings/profile

**Description:** Replace data for this resource.

**Authentication:** Required

**Role required:** teacher

**Request Headers:**
- Content-Type: application/json
- Authorization: Bearer <Firebase ID Token>

**Path Parameters:**
- None

**Query Parameters:**
- None specified

**Request Body:**
```json
TBD (confirm request body with backend)
```

**Response Success (example):**
```json
{
  "success": true,
  "message": "OK",
  "data": {}
}
```

**Response Error (common):**
- 401: Token missing or invalid
- 403: Access denied wrong role
- 404: Resource not found
- 500: Server error

**Flutter/Dart Code Example:**
```dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:firebase_auth/firebase_auth.dart';

final baseUrl = 'https://sumacademy.net/api';
final uri = Uri.parse('$baseUrl/teacher/settings/profile');
final token = await FirebaseAuth.instance.currentUser?.getIdToken(true);
final headers = {'Content-Type': 'application/json', 'Authorization': 'Bearer $token'};
final payload = {/* TODO: request body */};
final res = await http.put(uri, headers: headers, body: jsonEncode(payload));
final data = jsonDecode(res.body) as Map<String, dynamic>;
if (res.statusCode >= 400) { /* handle error */ }
```

#### Settings Security

<span style="color:#2E7D32"><strong>GET</strong></span> https://sumacademy.net/api/teacher/settings/security

**Description:** Retrieve data for this resource.

**Authentication:** Required

**Role required:** teacher

**Request Headers:**
- Content-Type: application/json
- Authorization: Bearer <Firebase ID Token>

**Path Parameters:**
- None

**Query Parameters:**
- None specified

**Request Body:**
- None

**Response Success (example):**
```json
{
  "success": true,
  "message": "OK",
  "data": {}
}
```

**Response Error (common):**
- 401: Token missing or invalid
- 403: Access denied wrong role
- 404: Resource not found
- 500: Server error

**Flutter/Dart Code Example:**
```dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:firebase_auth/firebase_auth.dart';

final baseUrl = 'https://sumacademy.net/api';
final uri = Uri.parse('$baseUrl/teacher/settings/security');
final token = await FirebaseAuth.instance.currentUser?.getIdToken(true);
final headers = {'Content-Type': 'application/json', 'Authorization': 'Bearer $token'};
final res = await http.get(uri, headers: headers);
final data = jsonDecode(res.body) as Map<String, dynamic>;
if (res.statusCode >= 400) { /* handle error */ }
```

#### Settings Security Sessions By Sessiondocid Revoke

<span style="color:#EF6C00"><strong>PATCH</strong></span> https://sumacademy.net/api/teacher/settings/security/sessions/:sessionDocId/revoke

**Description:** Update data for this resource.

**Authentication:** Required

**Role required:** teacher

**Request Headers:**
- Content-Type: application/json
- Authorization: Bearer <Firebase ID Token>

**Path Parameters:**
- `sessionDocId` (string, required)

**Query Parameters:**
- None specified

**Request Body:**
```json
TBD (confirm request body with backend)
```

**Response Success (example):**
```json
{
  "success": true,
  "message": "OK",
  "data": {}
}
```

**Response Error (common):**
- 401: Token missing or invalid
- 403: Access denied wrong role
- 404: Resource not found
- 500: Server error

**Flutter/Dart Code Example:**
```dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:firebase_auth/firebase_auth.dart';

final baseUrl = 'https://sumacademy.net/api';
final uri = Uri.parse('$baseUrl/teacher/settings/security/sessions/:sessionDocId/revoke');
final token = await FirebaseAuth.instance.currentUser?.getIdToken(true);
final headers = {'Content-Type': 'application/json', 'Authorization': 'Bearer $token'};
final payload = {/* TODO: request body */};
final res = await http.patch(uri, headers: headers, body: jsonEncode(payload));
final data = jsonDecode(res.body) as Map<String, dynamic>;
if (res.statusCode >= 400) { /* handle error */ }
```

#### Settings Security Sessions Revoke All

<span style="color:#EF6C00"><strong>PATCH</strong></span> https://sumacademy.net/api/teacher/settings/security/sessions/revoke-all

**Description:** Update data for this resource.

**Authentication:** Required

**Role required:** teacher

**Request Headers:**
- Content-Type: application/json
- Authorization: Bearer <Firebase ID Token>

**Path Parameters:**
- None

**Query Parameters:**
- None specified

**Request Body:**
```json
TBD (confirm request body with backend)
```

**Response Success (example):**
```json
{
  "success": true,
  "message": "OK",
  "data": {}
}
```

**Response Error (common):**
- 401: Token missing or invalid
- 403: Access denied wrong role
- 404: Resource not found
- 500: Server error

**Flutter/Dart Code Example:**
```dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:firebase_auth/firebase_auth.dart';

final baseUrl = 'https://sumacademy.net/api';
final uri = Uri.parse('$baseUrl/teacher/settings/security/sessions/revoke-all');
final token = await FirebaseAuth.instance.currentUser?.getIdToken(true);
final headers = {'Content-Type': 'application/json', 'Authorization': 'Bearer $token'};
final payload = {/* TODO: request body */};
final res = await http.patch(uri, headers: headers, body: jsonEncode(payload));
final data = jsonDecode(res.body) as Map<String, dynamic>;
if (res.statusCode >= 400) { /* handle error */ }
```


## ADMIN APIs

#### Stats

<span style="color:#2E7D32"><strong>GET</strong></span> https://sumacademy.net/api/admin/stats

**Description:** Retrieve data for this resource.

**Authentication:** Required

**Role required:** admin

**Request Headers:**
- Content-Type: application/json
- Authorization: Bearer <Firebase ID Token>

**Path Parameters:**
- None

**Query Parameters:**
- None specified

**Request Body:**
- None

**Response Success (example):**
```json
{
  "success": true,
  "message": "OK",
  "data": {}
}
```

**Response Error (common):**
- 401: Token missing or invalid
- 403: Access denied wrong role
- 404: Resource not found
- 500: Server error

**Flutter/Dart Code Example:**
```dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:firebase_auth/firebase_auth.dart';

final baseUrl = 'https://sumacademy.net/api';
final uri = Uri.parse('$baseUrl/admin/stats');
final token = await FirebaseAuth.instance.currentUser?.getIdToken(true);
final headers = {'Content-Type': 'application/json', 'Authorization': 'Bearer $token'};
final res = await http.get(uri, headers: headers);
final data = jsonDecode(res.body) as Map<String, dynamic>;
if (res.statusCode >= 400) { /* handle error */ }
```

#### Revenue Chart

<span style="color:#2E7D32"><strong>GET</strong></span> https://sumacademy.net/api/admin/revenue-chart

**Description:** Retrieve data for this resource.

**Authentication:** Required

**Role required:** admin

**Request Headers:**
- Content-Type: application/json
- Authorization: Bearer <Firebase ID Token>

**Path Parameters:**
- None

**Query Parameters:**
- None specified

**Request Body:**
- None

**Response Success (example):**
```json
{
  "success": true,
  "message": "OK",
  "data": {}
}
```

**Response Error (common):**
- 401: Token missing or invalid
- 403: Access denied wrong role
- 404: Resource not found
- 500: Server error

**Flutter/Dart Code Example:**
```dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:firebase_auth/firebase_auth.dart';

final baseUrl = 'https://sumacademy.net/api';
final uri = Uri.parse('$baseUrl/admin/revenue-chart');
final token = await FirebaseAuth.instance.currentUser?.getIdToken(true);
final headers = {'Content-Type': 'application/json', 'Authorization': 'Bearer $token'};
final res = await http.get(uri, headers: headers);
final data = jsonDecode(res.body) as Map<String, dynamic>;
if (res.statusCode >= 400) { /* handle error */ }
```

#### Recent Enrollments

<span style="color:#2E7D32"><strong>GET</strong></span> https://sumacademy.net/api/admin/recent-enrollments

**Description:** Retrieve data for this resource.

**Authentication:** Required

**Role required:** admin

**Request Headers:**
- Content-Type: application/json
- Authorization: Bearer <Firebase ID Token>

**Path Parameters:**
- None

**Query Parameters:**
- None specified

**Request Body:**
- None

**Response Success (example):**
```json
{
  "success": true,
  "message": "OK",
  "data": {}
}
```

**Response Error (common):**
- 401: Token missing or invalid
- 403: Access denied wrong role
- 404: Resource not found
- 500: Server error

**Flutter/Dart Code Example:**
```dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:firebase_auth/firebase_auth.dart';

final baseUrl = 'https://sumacademy.net/api';
final uri = Uri.parse('$baseUrl/admin/recent-enrollments');
final token = await FirebaseAuth.instance.currentUser?.getIdToken(true);
final headers = {'Content-Type': 'application/json', 'Authorization': 'Bearer $token'};
final res = await http.get(uri, headers: headers);
final data = jsonDecode(res.body) as Map<String, dynamic>;
if (res.statusCode >= 400) { /* handle error */ }
```

#### Top Courses

<span style="color:#2E7D32"><strong>GET</strong></span> https://sumacademy.net/api/admin/top-courses

**Description:** Retrieve data for this resource.

**Authentication:** Required

**Role required:** admin

**Request Headers:**
- Content-Type: application/json
- Authorization: Bearer <Firebase ID Token>

**Path Parameters:**
- None

**Query Parameters:**
- None specified

**Request Body:**
- None

**Response Success (example):**
```json
{
  "success": true,
  "message": "OK",
  "data": {}
}
```

**Response Error (common):**
- 401: Token missing or invalid
- 403: Access denied wrong role
- 404: Resource not found
- 500: Server error

**Flutter/Dart Code Example:**
```dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:firebase_auth/firebase_auth.dart';

final baseUrl = 'https://sumacademy.net/api';
final uri = Uri.parse('$baseUrl/admin/top-courses');
final token = await FirebaseAuth.instance.currentUser?.getIdToken(true);
final headers = {'Content-Type': 'application/json', 'Authorization': 'Bearer $token'};
final res = await http.get(uri, headers: headers);
final data = jsonDecode(res.body) as Map<String, dynamic>;
if (res.statusCode >= 400) { /* handle error */ }
```

#### Recent Activity

<span style="color:#2E7D32"><strong>GET</strong></span> https://sumacademy.net/api/admin/recent-activity

**Description:** Retrieve data for this resource.

**Authentication:** Required

**Role required:** admin

**Request Headers:**
- Content-Type: application/json
- Authorization: Bearer <Firebase ID Token>

**Path Parameters:**
- None

**Query Parameters:**
- None specified

**Request Body:**
- None

**Response Success (example):**
```json
{
  "success": true,
  "message": "OK",
  "data": {}
}
```

**Response Error (common):**
- 401: Token missing or invalid
- 403: Access denied wrong role
- 404: Resource not found
- 500: Server error

**Flutter/Dart Code Example:**
```dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:firebase_auth/firebase_auth.dart';

final baseUrl = 'https://sumacademy.net/api';
final uri = Uri.parse('$baseUrl/admin/recent-activity');
final token = await FirebaseAuth.instance.currentUser?.getIdToken(true);
final headers = {'Content-Type': 'application/json', 'Authorization': 'Bearer $token'};
final res = await http.get(uri, headers: headers);
final data = jsonDecode(res.body) as Map<String, dynamic>;
if (res.statusCode >= 400) { /* handle error */ }
```

#### Analytics Report

<span style="color:#2E7D32"><strong>GET</strong></span> https://sumacademy.net/api/admin/analytics-report

**Description:** Retrieve data for this resource.

**Authentication:** Required

**Role required:** admin

**Request Headers:**
- Content-Type: application/json
- Authorization: Bearer <Firebase ID Token>

**Path Parameters:**
- None

**Query Parameters:**
- None specified

**Request Body:**
- None

**Response Success (example):**
```json
{
  "success": true,
  "message": "OK",
  "data": {}
}
```

**Response Error (common):**
- 401: Token missing or invalid
- 403: Access denied wrong role
- 404: Resource not found
- 500: Server error

**Flutter/Dart Code Example:**
```dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:firebase_auth/firebase_auth.dart';

final baseUrl = 'https://sumacademy.net/api';
final uri = Uri.parse('$baseUrl/admin/analytics-report');
final token = await FirebaseAuth.instance.currentUser?.getIdToken(true);
final headers = {'Content-Type': 'application/json', 'Authorization': 'Bearer $token'};
final res = await http.get(uri, headers: headers);
final data = jsonDecode(res.body) as Map<String, dynamic>;
if (res.statusCode >= 400) { /* handle error */ }
```

#### Users

<span style="color:#2E7D32"><strong>GET</strong></span> https://sumacademy.net/api/admin/users

**Description:** Retrieve data for this resource.

**Authentication:** Required

**Role required:** admin

**Request Headers:**
- Content-Type: application/json
- Authorization: Bearer <Firebase ID Token>

**Path Parameters:**
- None

**Query Parameters:**
- None specified

**Request Body:**
- None

**Response Success (example):**
```json
{
  "success": true,
  "message": "OK",
  "data": {}
}
```

**Response Error (common):**
- 401: Token missing or invalid
- 403: Access denied wrong role
- 404: Resource not found
- 500: Server error

**Flutter/Dart Code Example:**
```dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:firebase_auth/firebase_auth.dart';

final baseUrl = 'https://sumacademy.net/api';
final uri = Uri.parse('$baseUrl/admin/users');
final token = await FirebaseAuth.instance.currentUser?.getIdToken(true);
final headers = {'Content-Type': 'application/json', 'Authorization': 'Bearer $token'};
final res = await http.get(uri, headers: headers);
final data = jsonDecode(res.body) as Map<String, dynamic>;
if (res.statusCode >= 400) { /* handle error */ }
```

#### Users

<span style="color:#1565C0"><strong>POST</strong></span> https://sumacademy.net/api/admin/users

**Description:** Create or submit data for this resource.

**Authentication:** Required

**Role required:** admin

**Request Headers:**
- Content-Type: application/json
- Authorization: Bearer <Firebase ID Token>

**Path Parameters:**
- None

**Query Parameters:**
- None specified

**Request Body:**
```json
TBD (confirm request body with backend)
```

**Response Success (example):**
```json
{
  "success": true,
  "message": "OK",
  "data": {}
}
```

**Response Error (common):**
- 401: Token missing or invalid
- 403: Access denied wrong role
- 404: Resource not found
- 500: Server error

**Flutter/Dart Code Example:**
```dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:firebase_auth/firebase_auth.dart';

final baseUrl = 'https://sumacademy.net/api';
final uri = Uri.parse('$baseUrl/admin/users');
final token = await FirebaseAuth.instance.currentUser?.getIdToken(true);
final headers = {'Content-Type': 'application/json', 'Authorization': 'Bearer $token'};
final payload = {/* TODO: request body */};
final res = await http.post(uri, headers: headers, body: jsonEncode(payload));
final data = jsonDecode(res.body) as Map<String, dynamic>;
if (res.statusCode >= 400) { /* handle error */ }
```

#### Users By Uid

<span style="color:#6A1B9A"><strong>PUT</strong></span> https://sumacademy.net/api/admin/users/:uid

**Description:** Replace data for this resource.

**Authentication:** Required

**Role required:** admin

**Request Headers:**
- Content-Type: application/json
- Authorization: Bearer <Firebase ID Token>

**Path Parameters:**
- `uid` (string, required)

**Query Parameters:**
- None specified

**Request Body:**
```json
TBD (confirm request body with backend)
```

**Response Success (example):**
```json
{
  "success": true,
  "message": "OK",
  "data": {}
}
```

**Response Error (common):**
- 401: Token missing or invalid
- 403: Access denied wrong role
- 404: Resource not found
- 500: Server error

**Flutter/Dart Code Example:**
```dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:firebase_auth/firebase_auth.dart';

final baseUrl = 'https://sumacademy.net/api';
final uri = Uri.parse('$baseUrl/admin/users/:uid');
final token = await FirebaseAuth.instance.currentUser?.getIdToken(true);
final headers = {'Content-Type': 'application/json', 'Authorization': 'Bearer $token'};
final payload = {/* TODO: request body */};
final res = await http.put(uri, headers: headers, body: jsonEncode(payload));
final data = jsonDecode(res.body) as Map<String, dynamic>;
if (res.statusCode >= 400) { /* handle error */ }
```

#### Users By Uid

<span style="color:#C62828"><strong>DELETE</strong></span> https://sumacademy.net/api/admin/users/:uid

**Description:** Delete this resource.

**Authentication:** Required

**Role required:** admin

**Request Headers:**
- Content-Type: application/json
- Authorization: Bearer <Firebase ID Token>

**Path Parameters:**
- `uid` (string, required)

**Query Parameters:**
- None specified

**Request Body:**
- None

**Response Success (example):**
```json
{
  "success": true,
  "message": "OK",
  "data": {}
}
```

**Response Error (common):**
- 401: Token missing or invalid
- 403: Access denied wrong role
- 404: Resource not found
- 500: Server error

**Flutter/Dart Code Example:**
```dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:firebase_auth/firebase_auth.dart';

final baseUrl = 'https://sumacademy.net/api';
final uri = Uri.parse('$baseUrl/admin/users/:uid');
final token = await FirebaseAuth.instance.currentUser?.getIdToken(true);
final headers = {'Content-Type': 'application/json', 'Authorization': 'Bearer $token'};
final res = await http.delete(uri, headers: headers);
final data = jsonDecode(res.body) as Map<String, dynamic>;
if (res.statusCode >= 400) { /* handle error */ }
```

#### Users By Uid Role

<span style="color:#EF6C00"><strong>PATCH</strong></span> https://sumacademy.net/api/admin/users/:uid/role

**Description:** Update data for this resource.

**Authentication:** Required

**Role required:** admin

**Request Headers:**
- Content-Type: application/json
- Authorization: Bearer <Firebase ID Token>

**Path Parameters:**
- `uid` (string, required)

**Query Parameters:**
- None specified

**Request Body:**
```json
TBD (confirm request body with backend)
```

**Response Success (example):**
```json
{
  "success": true,
  "message": "OK",
  "data": {}
}
```

**Response Error (common):**
- 401: Token missing or invalid
- 403: Access denied wrong role
- 404: Resource not found
- 500: Server error

**Flutter/Dart Code Example:**
```dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:firebase_auth/firebase_auth.dart';

final baseUrl = 'https://sumacademy.net/api';
final uri = Uri.parse('$baseUrl/admin/users/:uid/role');
final token = await FirebaseAuth.instance.currentUser?.getIdToken(true);
final headers = {'Content-Type': 'application/json', 'Authorization': 'Bearer $token'};
final payload = {/* TODO: request body */};
final res = await http.patch(uri, headers: headers, body: jsonEncode(payload));
final data = jsonDecode(res.body) as Map<String, dynamic>;
if (res.statusCode >= 400) { /* handle error */ }
```

#### Users By Uid Reset Device

<span style="color:#EF6C00"><strong>PATCH</strong></span> https://sumacademy.net/api/admin/users/:uid/reset-device

**Description:** Update data for this resource.

**Authentication:** Required

**Role required:** admin

**Request Headers:**
- Content-Type: application/json
- Authorization: Bearer <Firebase ID Token>

**Path Parameters:**
- `uid` (string, required)

**Query Parameters:**
- None specified

**Request Body:**
```json
TBD (confirm request body with backend)
```

**Response Success (example):**
```json
{
  "success": true,
  "message": "OK",
  "data": {}
}
```

**Response Error (common):**
- 401: Token missing or invalid
- 403: Access denied wrong role
- 404: Resource not found
- 500: Server error

**Flutter/Dart Code Example:**
```dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:firebase_auth/firebase_auth.dart';

final baseUrl = 'https://sumacademy.net/api';
final uri = Uri.parse('$baseUrl/admin/users/:uid/reset-device');
final token = await FirebaseAuth.instance.currentUser?.getIdToken(true);
final headers = {'Content-Type': 'application/json', 'Authorization': 'Bearer $token'};
final payload = {/* TODO: request body */};
final res = await http.patch(uri, headers: headers, body: jsonEncode(payload));
final data = jsonDecode(res.body) as Map<String, dynamic>;
if (res.statusCode >= 400) { /* handle error */ }
```

#### Teachers

<span style="color:#2E7D32"><strong>GET</strong></span> https://sumacademy.net/api/admin/teachers

**Description:** Retrieve data for this resource.

**Authentication:** Required

**Role required:** admin

**Request Headers:**
- Content-Type: application/json
- Authorization: Bearer <Firebase ID Token>

**Path Parameters:**
- None

**Query Parameters:**
- None specified

**Request Body:**
- None

**Response Success (example):**
```json
{
  "success": true,
  "message": "OK",
  "data": {}
}
```

**Response Error (common):**
- 401: Token missing or invalid
- 403: Access denied wrong role
- 404: Resource not found
- 500: Server error

**Flutter/Dart Code Example:**
```dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:firebase_auth/firebase_auth.dart';

final baseUrl = 'https://sumacademy.net/api';
final uri = Uri.parse('$baseUrl/admin/teachers');
final token = await FirebaseAuth.instance.currentUser?.getIdToken(true);
final headers = {'Content-Type': 'application/json', 'Authorization': 'Bearer $token'};
final res = await http.get(uri, headers: headers);
final data = jsonDecode(res.body) as Map<String, dynamic>;
if (res.statusCode >= 400) { /* handle error */ }
```

#### Students

<span style="color:#2E7D32"><strong>GET</strong></span> https://sumacademy.net/api/admin/students

**Description:** Retrieve data for this resource.

**Authentication:** Required

**Role required:** admin

**Request Headers:**
- Content-Type: application/json
- Authorization: Bearer <Firebase ID Token>

**Path Parameters:**
- None

**Query Parameters:**
- None specified

**Request Body:**
- None

**Response Success (example):**
```json
{
  "success": true,
  "message": "OK",
  "data": {}
}
```

**Response Error (common):**
- 401: Token missing or invalid
- 403: Access denied wrong role
- 404: Resource not found
- 500: Server error

**Flutter/Dart Code Example:**
```dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:firebase_auth/firebase_auth.dart';

final baseUrl = 'https://sumacademy.net/api';
final uri = Uri.parse('$baseUrl/admin/students');
final token = await FirebaseAuth.instance.currentUser?.getIdToken(true);
final headers = {'Content-Type': 'application/json', 'Authorization': 'Bearer $token'};
final res = await http.get(uri, headers: headers);
final data = jsonDecode(res.body) as Map<String, dynamic>;
if (res.statusCode >= 400) { /* handle error */ }
```

#### Students Template

<span style="color:#2E7D32"><strong>GET</strong></span> https://sumacademy.net/api/admin/students/template

**Description:** Retrieve data for this resource.

**Authentication:** Required

**Role required:** admin

**Request Headers:**
- Content-Type: application/json
- Authorization: Bearer <Firebase ID Token>

**Path Parameters:**
- None

**Query Parameters:**
- None specified

**Request Body:**
- None

**Response Success (example):**
```json
{
  "success": true,
  "message": "OK",
  "data": {}
}
```

**Response Error (common):**
- 401: Token missing or invalid
- 403: Access denied wrong role
- 404: Resource not found
- 500: Server error

**Flutter/Dart Code Example:**
```dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:firebase_auth/firebase_auth.dart';

final baseUrl = 'https://sumacademy.net/api';
final uri = Uri.parse('$baseUrl/admin/students/template');
final token = await FirebaseAuth.instance.currentUser?.getIdToken(true);
final headers = {'Content-Type': 'application/json', 'Authorization': 'Bearer $token'};
final res = await http.get(uri, headers: headers);
final data = jsonDecode(res.body) as Map<String, dynamic>;
if (res.statusCode >= 400) { /* handle error */ }
```

#### Students Bulk Upload

<span style="color:#1565C0"><strong>POST</strong></span> https://sumacademy.net/api/admin/students/bulk-upload

**Description:** Create or submit data for this resource.

**Authentication:** Required

**Role required:** admin

**Request Headers:**
- Content-Type: application/json
- Authorization: Bearer <Firebase ID Token>

**Path Parameters:**
- None

**Query Parameters:**
- None specified

**Request Body:**
```json
TBD (confirm request body with backend)
```

**Response Success (example):**
```json
{
  "success": true,
  "message": "OK",
  "data": {}
}
```

**Response Error (common):**
- 401: Token missing or invalid
- 403: Access denied wrong role
- 404: Resource not found
- 500: Server error

**Flutter/Dart Code Example:**
```dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:firebase_auth/firebase_auth.dart';

final baseUrl = 'https://sumacademy.net/api';
final uri = Uri.parse('$baseUrl/admin/students/bulk-upload');
final token = await FirebaseAuth.instance.currentUser?.getIdToken(true);
final headers = {'Content-Type': 'application/json', 'Authorization': 'Bearer $token'};
final payload = {/* TODO: request body */};
final res = await http.post(uri, headers: headers, body: jsonEncode(payload));
final data = jsonDecode(res.body) as Map<String, dynamic>;
if (res.statusCode >= 400) { /* handle error */ }
```

#### Courses

<span style="color:#2E7D32"><strong>GET</strong></span> https://sumacademy.net/api/admin/courses

**Description:** Retrieve data for this resource.

**Authentication:** Required

**Role required:** admin

**Request Headers:**
- Content-Type: application/json
- Authorization: Bearer <Firebase ID Token>

**Path Parameters:**
- None

**Query Parameters:**
- None specified

**Request Body:**
- None

**Response Success (example):**
```json
{
  "success": true,
  "message": "OK",
  "data": {}
}
```

**Response Error (common):**
- 401: Token missing or invalid
- 403: Access denied wrong role
- 404: Resource not found
- 500: Server error

**Flutter/Dart Code Example:**
```dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:firebase_auth/firebase_auth.dart';

final baseUrl = 'https://sumacademy.net/api';
final uri = Uri.parse('$baseUrl/admin/courses');
final token = await FirebaseAuth.instance.currentUser?.getIdToken(true);
final headers = {'Content-Type': 'application/json', 'Authorization': 'Bearer $token'};
final res = await http.get(uri, headers: headers);
final data = jsonDecode(res.body) as Map<String, dynamic>;
if (res.statusCode >= 400) { /* handle error */ }
```

#### Courses

<span style="color:#1565C0"><strong>POST</strong></span> https://sumacademy.net/api/admin/courses

**Description:** Create or submit data for this resource.

**Authentication:** Required

**Role required:** admin

**Request Headers:**
- Content-Type: application/json
- Authorization: Bearer <Firebase ID Token>

**Path Parameters:**
- None

**Query Parameters:**
- None specified

**Request Body:**
```json
TBD (confirm request body with backend)
```

**Response Success (example):**
```json
{
  "success": true,
  "message": "OK",
  "data": {}
}
```

**Response Error (common):**
- 401: Token missing or invalid
- 403: Access denied wrong role
- 404: Resource not found
- 500: Server error

**Flutter/Dart Code Example:**
```dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:firebase_auth/firebase_auth.dart';

final baseUrl = 'https://sumacademy.net/api';
final uri = Uri.parse('$baseUrl/admin/courses');
final token = await FirebaseAuth.instance.currentUser?.getIdToken(true);
final headers = {'Content-Type': 'application/json', 'Authorization': 'Bearer $token'};
final payload = {/* TODO: request body */};
final res = await http.post(uri, headers: headers, body: jsonEncode(payload));
final data = jsonDecode(res.body) as Map<String, dynamic>;
if (res.statusCode >= 400) { /* handle error */ }
```

#### Courses By Courseid

<span style="color:#6A1B9A"><strong>PUT</strong></span> https://sumacademy.net/api/admin/courses/:courseId

**Description:** Replace data for this resource.

**Authentication:** Required

**Role required:** admin

**Request Headers:**
- Content-Type: application/json
- Authorization: Bearer <Firebase ID Token>

**Path Parameters:**
- `courseId` (string, required)

**Query Parameters:**
- None specified

**Request Body:**
```json
TBD (confirm request body with backend)
```

**Response Success (example):**
```json
{
  "success": true,
  "message": "OK",
  "data": {}
}
```

**Response Error (common):**
- 401: Token missing or invalid
- 403: Access denied wrong role
- 404: Resource not found
- 500: Server error

**Flutter/Dart Code Example:**
```dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:firebase_auth/firebase_auth.dart';

final baseUrl = 'https://sumacademy.net/api';
final uri = Uri.parse('$baseUrl/admin/courses/:courseId');
final token = await FirebaseAuth.instance.currentUser?.getIdToken(true);
final headers = {'Content-Type': 'application/json', 'Authorization': 'Bearer $token'};
final payload = {/* TODO: request body */};
final res = await http.put(uri, headers: headers, body: jsonEncode(payload));
final data = jsonDecode(res.body) as Map<String, dynamic>;
if (res.statusCode >= 400) { /* handle error */ }
```

#### Courses By Courseid

<span style="color:#EF6C00"><strong>PATCH</strong></span> https://sumacademy.net/api/admin/courses/:courseId

**Description:** Update data for this resource.

**Authentication:** Required

**Role required:** admin

**Request Headers:**
- Content-Type: application/json
- Authorization: Bearer <Firebase ID Token>

**Path Parameters:**
- `courseId` (string, required)

**Query Parameters:**
- None specified

**Request Body:**
```json
TBD (confirm request body with backend)
```

**Response Success (example):**
```json
{
  "success": true,
  "message": "OK",
  "data": {}
}
```

**Response Error (common):**
- 401: Token missing or invalid
- 403: Access denied wrong role
- 404: Resource not found
- 500: Server error

**Flutter/Dart Code Example:**
```dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:firebase_auth/firebase_auth.dart';

final baseUrl = 'https://sumacademy.net/api';
final uri = Uri.parse('$baseUrl/admin/courses/:courseId');
final token = await FirebaseAuth.instance.currentUser?.getIdToken(true);
final headers = {'Content-Type': 'application/json', 'Authorization': 'Bearer $token'};
final payload = {/* TODO: request body */};
final res = await http.patch(uri, headers: headers, body: jsonEncode(payload));
final data = jsonDecode(res.body) as Map<String, dynamic>;
if (res.statusCode >= 400) { /* handle error */ }
```

#### Courses By Courseid

<span style="color:#C62828"><strong>DELETE</strong></span> https://sumacademy.net/api/admin/courses/:courseId

**Description:** Delete this resource.

**Authentication:** Required

**Role required:** admin

**Request Headers:**
- Content-Type: application/json
- Authorization: Bearer <Firebase ID Token>

**Path Parameters:**
- `courseId` (string, required)

**Query Parameters:**
- None specified

**Request Body:**
- None

**Response Success (example):**
```json
{
  "success": true,
  "message": "OK",
  "data": {}
}
```

**Response Error (common):**
- 401: Token missing or invalid
- 403: Access denied wrong role
- 404: Resource not found
- 500: Server error

**Flutter/Dart Code Example:**
```dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:firebase_auth/firebase_auth.dart';

final baseUrl = 'https://sumacademy.net/api';
final uri = Uri.parse('$baseUrl/admin/courses/:courseId');
final token = await FirebaseAuth.instance.currentUser?.getIdToken(true);
final headers = {'Content-Type': 'application/json', 'Authorization': 'Bearer $token'};
final res = await http.delete(uri, headers: headers);
final data = jsonDecode(res.body) as Map<String, dynamic>;
if (res.statusCode >= 400) { /* handle error */ }
```

#### Courses By Courseid Subjects

<span style="color:#1565C0"><strong>POST</strong></span> https://sumacademy.net/api/admin/courses/:courseId/subjects

**Description:** Create or submit data for this resource.

**Authentication:** Required

**Role required:** admin

**Request Headers:**
- Content-Type: application/json
- Authorization: Bearer <Firebase ID Token>

**Path Parameters:**
- `courseId` (string, required)

**Query Parameters:**
- None specified

**Request Body:**
```json
TBD (confirm request body with backend)
```

**Response Success (example):**
```json
{
  "success": true,
  "message": "OK",
  "data": {}
}
```

**Response Error (common):**
- 401: Token missing or invalid
- 403: Access denied wrong role
- 404: Resource not found
- 500: Server error

**Flutter/Dart Code Example:**
```dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:firebase_auth/firebase_auth.dart';

final baseUrl = 'https://sumacademy.net/api';
final uri = Uri.parse('$baseUrl/admin/courses/:courseId/subjects');
final token = await FirebaseAuth.instance.currentUser?.getIdToken(true);
final headers = {'Content-Type': 'application/json', 'Authorization': 'Bearer $token'};
final payload = {/* TODO: request body */};
final res = await http.post(uri, headers: headers, body: jsonEncode(payload));
final data = jsonDecode(res.body) as Map<String, dynamic>;
if (res.statusCode >= 400) { /* handle error */ }
```

#### Courses By Courseid Subjects By Subjectid

<span style="color:#C62828"><strong>DELETE</strong></span> https://sumacademy.net/api/admin/courses/:courseId/subjects/:subjectId

**Description:** Delete this resource.

**Authentication:** Required

**Role required:** admin

**Request Headers:**
- Content-Type: application/json
- Authorization: Bearer <Firebase ID Token>

**Path Parameters:**
- `courseId` (string, required)
- `subjectId` (string, required)

**Query Parameters:**
- None specified

**Request Body:**
- None

**Response Success (example):**
```json
{
  "success": true,
  "message": "OK",
  "data": {}
}
```

**Response Error (common):**
- 401: Token missing or invalid
- 403: Access denied wrong role
- 404: Resource not found
- 500: Server error

**Flutter/Dart Code Example:**
```dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:firebase_auth/firebase_auth.dart';

final baseUrl = 'https://sumacademy.net/api';
final uri = Uri.parse('$baseUrl/admin/courses/:courseId/subjects/:subjectId');
final token = await FirebaseAuth.instance.currentUser?.getIdToken(true);
final headers = {'Content-Type': 'application/json', 'Authorization': 'Bearer $token'};
final res = await http.delete(uri, headers: headers);
final data = jsonDecode(res.body) as Map<String, dynamic>;
if (res.statusCode >= 400) { /* handle error */ }
```

#### Courses By Courseid Subjects By Subjectid Content

<span style="color:#1565C0"><strong>POST</strong></span> https://sumacademy.net/api/admin/courses/:courseId/subjects/:subjectId/content

**Description:** Create or submit data for this resource.

**Authentication:** Required

**Role required:** admin

**Request Headers:**
- Content-Type: application/json
- Authorization: Bearer <Firebase ID Token>

**Path Parameters:**
- `courseId` (string, required)
- `subjectId` (string, required)

**Query Parameters:**
- None specified

**Request Body:**
```json
TBD (confirm request body with backend)
```

**Response Success (example):**
```json
{
  "success": true,
  "message": "OK",
  "data": {}
}
```

**Response Error (common):**
- 401: Token missing or invalid
- 403: Access denied wrong role
- 404: Resource not found
- 500: Server error

**Flutter/Dart Code Example:**
```dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:firebase_auth/firebase_auth.dart';

final baseUrl = 'https://sumacademy.net/api';
final uri = Uri.parse('$baseUrl/admin/courses/:courseId/subjects/:subjectId/content');
final token = await FirebaseAuth.instance.currentUser?.getIdToken(true);
final headers = {'Content-Type': 'application/json', 'Authorization': 'Bearer $token'};
final payload = {/* TODO: request body */};
final res = await http.post(uri, headers: headers, body: jsonEncode(payload));
final data = jsonDecode(res.body) as Map<String, dynamic>;
if (res.statusCode >= 400) { /* handle error */ }
```

#### Courses By Courseid Content

<span style="color:#2E7D32"><strong>GET</strong></span> https://sumacademy.net/api/admin/courses/:courseId/content

**Description:** Retrieve data for this resource.

**Authentication:** Required

**Role required:** admin

**Request Headers:**
- Content-Type: application/json
- Authorization: Bearer <Firebase ID Token>

**Path Parameters:**
- `courseId` (string, required)

**Query Parameters:**
- None specified

**Request Body:**
- None

**Response Success (example):**
```json
{
  "success": true,
  "message": "OK",
  "data": {}
}
```

**Response Error (common):**
- 401: Token missing or invalid
- 403: Access denied wrong role
- 404: Resource not found
- 500: Server error

**Flutter/Dart Code Example:**
```dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:firebase_auth/firebase_auth.dart';

final baseUrl = 'https://sumacademy.net/api';
final uri = Uri.parse('$baseUrl/admin/courses/:courseId/content');
final token = await FirebaseAuth.instance.currentUser?.getIdToken(true);
final headers = {'Content-Type': 'application/json', 'Authorization': 'Bearer $token'};
final res = await http.get(uri, headers: headers);
final data = jsonDecode(res.body) as Map<String, dynamic>;
if (res.statusCode >= 400) { /* handle error */ }
```

#### Courses By Courseid Content By Contentid

<span style="color:#C62828"><strong>DELETE</strong></span> https://sumacademy.net/api/admin/courses/:courseId/content/:contentId

**Description:** Delete this resource.

**Authentication:** Required

**Role required:** admin

**Request Headers:**
- Content-Type: application/json
- Authorization: Bearer <Firebase ID Token>

**Path Parameters:**
- `courseId` (string, required)
- `contentId` (string, required)

**Query Parameters:**
- None specified

**Request Body:**
- None

**Response Success (example):**
```json
{
  "success": true,
  "message": "OK",
  "data": {}
}
```

**Response Error (common):**
- 401: Token missing or invalid
- 403: Access denied wrong role
- 404: Resource not found
- 500: Server error

**Flutter/Dart Code Example:**
```dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:firebase_auth/firebase_auth.dart';

final baseUrl = 'https://sumacademy.net/api';
final uri = Uri.parse('$baseUrl/admin/courses/:courseId/content/:contentId');
final token = await FirebaseAuth.instance.currentUser?.getIdToken(true);
final headers = {'Content-Type': 'application/json', 'Authorization': 'Bearer $token'};
final res = await http.delete(uri, headers: headers);
final data = jsonDecode(res.body) as Map<String, dynamic>;
if (res.statusCode >= 400) { /* handle error */ }
```

#### Classes

<span style="color:#2E7D32"><strong>GET</strong></span> https://sumacademy.net/api/admin/classes

**Description:** Retrieve data for this resource.

**Authentication:** Required

**Role required:** admin

**Request Headers:**
- Content-Type: application/json
- Authorization: Bearer <Firebase ID Token>

**Path Parameters:**
- None

**Query Parameters:**
- None specified

**Request Body:**
- None

**Response Success (example):**
```json
{
  "success": true,
  "message": "OK",
  "data": {}
}
```

**Response Error (common):**
- 401: Token missing or invalid
- 403: Access denied wrong role
- 404: Resource not found
- 500: Server error

**Flutter/Dart Code Example:**
```dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:firebase_auth/firebase_auth.dart';

final baseUrl = 'https://sumacademy.net/api';
final uri = Uri.parse('$baseUrl/admin/classes');
final token = await FirebaseAuth.instance.currentUser?.getIdToken(true);
final headers = {'Content-Type': 'application/json', 'Authorization': 'Bearer $token'};
final res = await http.get(uri, headers: headers);
final data = jsonDecode(res.body) as Map<String, dynamic>;
if (res.statusCode >= 400) { /* handle error */ }
```

#### Classes

<span style="color:#1565C0"><strong>POST</strong></span> https://sumacademy.net/api/admin/classes

**Description:** Create or submit data for this resource.

**Authentication:** Required

**Role required:** admin

**Request Headers:**
- Content-Type: application/json
- Authorization: Bearer <Firebase ID Token>

**Path Parameters:**
- None

**Query Parameters:**
- None specified

**Request Body:**
```json
TBD (confirm request body with backend)
```

**Response Success (example):**
```json
{
  "success": true,
  "message": "OK",
  "data": {}
}
```

**Response Error (common):**
- 401: Token missing or invalid
- 403: Access denied wrong role
- 404: Resource not found
- 500: Server error

**Flutter/Dart Code Example:**
```dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:firebase_auth/firebase_auth.dart';

final baseUrl = 'https://sumacademy.net/api';
final uri = Uri.parse('$baseUrl/admin/classes');
final token = await FirebaseAuth.instance.currentUser?.getIdToken(true);
final headers = {'Content-Type': 'application/json', 'Authorization': 'Bearer $token'};
final payload = {/* TODO: request body */};
final res = await http.post(uri, headers: headers, body: jsonEncode(payload));
final data = jsonDecode(res.body) as Map<String, dynamic>;
if (res.statusCode >= 400) { /* handle error */ }
```

#### Classes By Classid

<span style="color:#6A1B9A"><strong>PUT</strong></span> https://sumacademy.net/api/admin/classes/:classId

**Description:** Replace data for this resource.

**Authentication:** Required

**Role required:** admin

**Request Headers:**
- Content-Type: application/json
- Authorization: Bearer <Firebase ID Token>

**Path Parameters:**
- `classId` (string, required)

**Query Parameters:**
- None specified

**Request Body:**
```json
TBD (confirm request body with backend)
```

**Response Success (example):**
```json
{
  "success": true,
  "message": "OK",
  "data": {}
}
```

**Response Error (common):**
- 401: Token missing or invalid
- 403: Access denied wrong role
- 404: Resource not found
- 500: Server error

**Flutter/Dart Code Example:**
```dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:firebase_auth/firebase_auth.dart';

final baseUrl = 'https://sumacademy.net/api';
final uri = Uri.parse('$baseUrl/admin/classes/:classId');
final token = await FirebaseAuth.instance.currentUser?.getIdToken(true);
final headers = {'Content-Type': 'application/json', 'Authorization': 'Bearer $token'};
final payload = {/* TODO: request body */};
final res = await http.put(uri, headers: headers, body: jsonEncode(payload));
final data = jsonDecode(res.body) as Map<String, dynamic>;
if (res.statusCode >= 400) { /* handle error */ }
```

#### Classes By Classid

<span style="color:#C62828"><strong>DELETE</strong></span> https://sumacademy.net/api/admin/classes/:classId

**Description:** Delete this resource.

**Authentication:** Required

**Role required:** admin

**Request Headers:**
- Content-Type: application/json
- Authorization: Bearer <Firebase ID Token>

**Path Parameters:**
- `classId` (string, required)

**Query Parameters:**
- None specified

**Request Body:**
- None

**Response Success (example):**
```json
{
  "success": true,
  "message": "OK",
  "data": {}
}
```

**Response Error (common):**
- 401: Token missing or invalid
- 403: Access denied wrong role
- 404: Resource not found
- 500: Server error

**Flutter/Dart Code Example:**
```dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:firebase_auth/firebase_auth.dart';

final baseUrl = 'https://sumacademy.net/api';
final uri = Uri.parse('$baseUrl/admin/classes/:classId');
final token = await FirebaseAuth.instance.currentUser?.getIdToken(true);
final headers = {'Content-Type': 'application/json', 'Authorization': 'Bearer $token'};
final res = await http.delete(uri, headers: headers);
final data = jsonDecode(res.body) as Map<String, dynamic>;
if (res.statusCode >= 400) { /* handle error */ }
```

#### Classes By Classid Courses

<span style="color:#1565C0"><strong>POST</strong></span> https://sumacademy.net/api/admin/classes/:classId/courses

**Description:** Create or submit data for this resource.

**Authentication:** Required

**Role required:** admin

**Request Headers:**
- Content-Type: application/json
- Authorization: Bearer <Firebase ID Token>

**Path Parameters:**
- `classId` (string, required)

**Query Parameters:**
- None specified

**Request Body:**
```json
TBD (confirm request body with backend)
```

**Response Success (example):**
```json
{
  "success": true,
  "message": "OK",
  "data": {}
}
```

**Response Error (common):**
- 401: Token missing or invalid
- 403: Access denied wrong role
- 404: Resource not found
- 500: Server error

**Flutter/Dart Code Example:**
```dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:firebase_auth/firebase_auth.dart';

final baseUrl = 'https://sumacademy.net/api';
final uri = Uri.parse('$baseUrl/admin/classes/:classId/courses');
final token = await FirebaseAuth.instance.currentUser?.getIdToken(true);
final headers = {'Content-Type': 'application/json', 'Authorization': 'Bearer $token'};
final payload = {/* TODO: request body */};
final res = await http.post(uri, headers: headers, body: jsonEncode(payload));
final data = jsonDecode(res.body) as Map<String, dynamic>;
if (res.statusCode >= 400) { /* handle error */ }
```

#### Classes By Classid Courses By Courseid

<span style="color:#C62828"><strong>DELETE</strong></span> https://sumacademy.net/api/admin/classes/:classId/courses/:courseId

**Description:** Delete this resource.

**Authentication:** Required

**Role required:** admin

**Request Headers:**
- Content-Type: application/json
- Authorization: Bearer <Firebase ID Token>

**Path Parameters:**
- `classId` (string, required)
- `courseId` (string, required)

**Query Parameters:**
- None specified

**Request Body:**
- None

**Response Success (example):**
```json
{
  "success": true,
  "message": "OK",
  "data": {}
}
```

**Response Error (common):**
- 401: Token missing or invalid
- 403: Access denied wrong role
- 404: Resource not found
- 500: Server error

**Flutter/Dart Code Example:**
```dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:firebase_auth/firebase_auth.dart';

final baseUrl = 'https://sumacademy.net/api';
final uri = Uri.parse('$baseUrl/admin/classes/:classId/courses/:courseId');
final token = await FirebaseAuth.instance.currentUser?.getIdToken(true);
final headers = {'Content-Type': 'application/json', 'Authorization': 'Bearer $token'};
final res = await http.delete(uri, headers: headers);
final data = jsonDecode(res.body) as Map<String, dynamic>;
if (res.statusCode >= 400) { /* handle error */ }
```

#### Classes By Classid Shifts

<span style="color:#1565C0"><strong>POST</strong></span> https://sumacademy.net/api/admin/classes/:classId/shifts

**Description:** Create or submit data for this resource.

**Authentication:** Required

**Role required:** admin

**Request Headers:**
- Content-Type: application/json
- Authorization: Bearer <Firebase ID Token>

**Path Parameters:**
- `classId` (string, required)

**Query Parameters:**
- None specified

**Request Body:**
```json
TBD (confirm request body with backend)
```

**Response Success (example):**
```json
{
  "success": true,
  "message": "OK",
  "data": {}
}
```

**Response Error (common):**
- 401: Token missing or invalid
- 403: Access denied wrong role
- 404: Resource not found
- 500: Server error

**Flutter/Dart Code Example:**
```dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:firebase_auth/firebase_auth.dart';

final baseUrl = 'https://sumacademy.net/api';
final uri = Uri.parse('$baseUrl/admin/classes/:classId/shifts');
final token = await FirebaseAuth.instance.currentUser?.getIdToken(true);
final headers = {'Content-Type': 'application/json', 'Authorization': 'Bearer $token'};
final payload = {/* TODO: request body */};
final res = await http.post(uri, headers: headers, body: jsonEncode(payload));
final data = jsonDecode(res.body) as Map<String, dynamic>;
if (res.statusCode >= 400) { /* handle error */ }
```

#### Classes By Classid Shifts By Shiftid

<span style="color:#6A1B9A"><strong>PUT</strong></span> https://sumacademy.net/api/admin/classes/:classId/shifts/:shiftId

**Description:** Replace data for this resource.

**Authentication:** Required

**Role required:** admin

**Request Headers:**
- Content-Type: application/json
- Authorization: Bearer <Firebase ID Token>

**Path Parameters:**
- `classId` (string, required)
- `shiftId` (string, required)

**Query Parameters:**
- None specified

**Request Body:**
```json
TBD (confirm request body with backend)
```

**Response Success (example):**
```json
{
  "success": true,
  "message": "OK",
  "data": {}
}
```

**Response Error (common):**
- 401: Token missing or invalid
- 403: Access denied wrong role
- 404: Resource not found
- 500: Server error

**Flutter/Dart Code Example:**
```dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:firebase_auth/firebase_auth.dart';

final baseUrl = 'https://sumacademy.net/api';
final uri = Uri.parse('$baseUrl/admin/classes/:classId/shifts/:shiftId');
final token = await FirebaseAuth.instance.currentUser?.getIdToken(true);
final headers = {'Content-Type': 'application/json', 'Authorization': 'Bearer $token'};
final payload = {/* TODO: request body */};
final res = await http.put(uri, headers: headers, body: jsonEncode(payload));
final data = jsonDecode(res.body) as Map<String, dynamic>;
if (res.statusCode >= 400) { /* handle error */ }
```

#### Classes By Classid Shifts By Shiftid

<span style="color:#C62828"><strong>DELETE</strong></span> https://sumacademy.net/api/admin/classes/:classId/shifts/:shiftId

**Description:** Delete this resource.

**Authentication:** Required

**Role required:** admin

**Request Headers:**
- Content-Type: application/json
- Authorization: Bearer <Firebase ID Token>

**Path Parameters:**
- `classId` (string, required)
- `shiftId` (string, required)

**Query Parameters:**
- None specified

**Request Body:**
- None

**Response Success (example):**
```json
{
  "success": true,
  "message": "OK",
  "data": {}
}
```

**Response Error (common):**
- 401: Token missing or invalid
- 403: Access denied wrong role
- 404: Resource not found
- 500: Server error

**Flutter/Dart Code Example:**
```dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:firebase_auth/firebase_auth.dart';

final baseUrl = 'https://sumacademy.net/api';
final uri = Uri.parse('$baseUrl/admin/classes/:classId/shifts/:shiftId');
final token = await FirebaseAuth.instance.currentUser?.getIdToken(true);
final headers = {'Content-Type': 'application/json', 'Authorization': 'Bearer $token'};
final res = await http.delete(uri, headers: headers);
final data = jsonDecode(res.body) as Map<String, dynamic>;
if (res.statusCode >= 400) { /* handle error */ }
```

#### Classes By Classid Students

<span style="color:#1565C0"><strong>POST</strong></span> https://sumacademy.net/api/admin/classes/:classId/students

**Description:** Create or submit data for this resource.

**Authentication:** Required

**Role required:** admin

**Request Headers:**
- Content-Type: application/json
- Authorization: Bearer <Firebase ID Token>

**Path Parameters:**
- `classId` (string, required)

**Query Parameters:**
- None specified

**Request Body:**
```json
TBD (confirm request body with backend)
```

**Response Success (example):**
```json
{
  "success": true,
  "message": "OK",
  "data": {}
}
```

**Response Error (common):**
- 401: Token missing or invalid
- 403: Access denied wrong role
- 404: Resource not found
- 500: Server error

**Flutter/Dart Code Example:**
```dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:firebase_auth/firebase_auth.dart';

final baseUrl = 'https://sumacademy.net/api';
final uri = Uri.parse('$baseUrl/admin/classes/:classId/students');
final token = await FirebaseAuth.instance.currentUser?.getIdToken(true);
final headers = {'Content-Type': 'application/json', 'Authorization': 'Bearer $token'};
final payload = {/* TODO: request body */};
final res = await http.post(uri, headers: headers, body: jsonEncode(payload));
final data = jsonDecode(res.body) as Map<String, dynamic>;
if (res.statusCode >= 400) { /* handle error */ }
```

#### Classes By Classid Students

<span style="color:#2E7D32"><strong>GET</strong></span> https://sumacademy.net/api/admin/classes/:classId/students

**Description:** Retrieve data for this resource.

**Authentication:** Required

**Role required:** admin

**Request Headers:**
- Content-Type: application/json
- Authorization: Bearer <Firebase ID Token>

**Path Parameters:**
- `classId` (string, required)

**Query Parameters:**
- None specified

**Request Body:**
- None

**Response Success (example):**
```json
{
  "success": true,
  "message": "OK",
  "data": {}
}
```

**Response Error (common):**
- 401: Token missing or invalid
- 403: Access denied wrong role
- 404: Resource not found
- 500: Server error

**Flutter/Dart Code Example:**
```dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:firebase_auth/firebase_auth.dart';

final baseUrl = 'https://sumacademy.net/api';
final uri = Uri.parse('$baseUrl/admin/classes/:classId/students');
final token = await FirebaseAuth.instance.currentUser?.getIdToken(true);
final headers = {'Content-Type': 'application/json', 'Authorization': 'Bearer $token'};
final res = await http.get(uri, headers: headers);
final data = jsonDecode(res.body) as Map<String, dynamic>;
if (res.statusCode >= 400) { /* handle error */ }
```

#### Classes By Classid Enroll

<span style="color:#1565C0"><strong>POST</strong></span> https://sumacademy.net/api/admin/classes/:classId/enroll

**Description:** Create or submit data for this resource.

**Authentication:** Required

**Role required:** admin

**Request Headers:**
- Content-Type: application/json
- Authorization: Bearer <Firebase ID Token>

**Path Parameters:**
- `classId` (string, required)

**Query Parameters:**
- None specified

**Request Body:**
```json
TBD (confirm request body with backend)
```

**Response Success (example):**
```json
{
  "success": true,
  "message": "OK",
  "data": {}
}
```

**Response Error (common):**
- 401: Token missing or invalid
- 403: Access denied wrong role
- 404: Resource not found
- 500: Server error

**Flutter/Dart Code Example:**
```dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:firebase_auth/firebase_auth.dart';

final baseUrl = 'https://sumacademy.net/api';
final uri = Uri.parse('$baseUrl/admin/classes/:classId/enroll');
final token = await FirebaseAuth.instance.currentUser?.getIdToken(true);
final headers = {'Content-Type': 'application/json', 'Authorization': 'Bearer $token'};
final payload = {/* TODO: request body */};
final res = await http.post(uri, headers: headers, body: jsonEncode(payload));
final data = jsonDecode(res.body) as Map<String, dynamic>;
if (res.statusCode >= 400) { /* handle error */ }
```

#### Classes By Classid Students By Studentid

<span style="color:#C62828"><strong>DELETE</strong></span> https://sumacademy.net/api/admin/classes/:classId/students/:studentId

**Description:** Delete this resource.

**Authentication:** Required

**Role required:** admin

**Request Headers:**
- Content-Type: application/json
- Authorization: Bearer <Firebase ID Token>

**Path Parameters:**
- `classId` (string, required)
- `studentId` (string, required)

**Query Parameters:**
- None specified

**Request Body:**
- None

**Response Success (example):**
```json
{
  "success": true,
  "message": "OK",
  "data": {}
}
```

**Response Error (common):**
- 401: Token missing or invalid
- 403: Access denied wrong role
- 404: Resource not found
- 500: Server error

**Flutter/Dart Code Example:**
```dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:firebase_auth/firebase_auth.dart';

final baseUrl = 'https://sumacademy.net/api';
final uri = Uri.parse('$baseUrl/admin/classes/:classId/students/:studentId');
final token = await FirebaseAuth.instance.currentUser?.getIdToken(true);
final headers = {'Content-Type': 'application/json', 'Authorization': 'Bearer $token'};
final res = await http.delete(uri, headers: headers);
final data = jsonDecode(res.body) as Map<String, dynamic>;
if (res.statusCode >= 400) { /* handle error */ }
```

#### Payments

<span style="color:#2E7D32"><strong>GET</strong></span> https://sumacademy.net/api/admin/payments

**Description:** Retrieve data for this resource.

**Authentication:** Required

**Role required:** admin

**Request Headers:**
- Content-Type: application/json
- Authorization: Bearer <Firebase ID Token>

**Path Parameters:**
- None

**Query Parameters:**
- None specified

**Request Body:**
- None

**Response Success (example):**
```json
{
  "success": true,
  "message": "OK",
  "data": {}
}
```

**Response Error (common):**
- 401: Token missing or invalid
- 403: Access denied wrong role
- 404: Resource not found
- 500: Server error

**Flutter/Dart Code Example:**
```dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:firebase_auth/firebase_auth.dart';

final baseUrl = 'https://sumacademy.net/api';
final uri = Uri.parse('$baseUrl/admin/payments');
final token = await FirebaseAuth.instance.currentUser?.getIdToken(true);
final headers = {'Content-Type': 'application/json', 'Authorization': 'Bearer $token'};
final res = await http.get(uri, headers: headers);
final data = jsonDecode(res.body) as Map<String, dynamic>;
if (res.statusCode >= 400) { /* handle error */ }
```

#### Payments By Paymentid Verify

<span style="color:#EF6C00"><strong>PATCH</strong></span> https://sumacademy.net/api/admin/payments/:paymentId/verify

**Description:** Update data for this resource.

**Authentication:** Required

**Role required:** admin

**Request Headers:**
- Content-Type: application/json
- Authorization: Bearer <Firebase ID Token>

**Path Parameters:**
- `paymentId` (string, required)

**Query Parameters:**
- None specified

**Request Body:**
```json
TBD (confirm request body with backend)
```

**Response Success (example):**
```json
{
  "success": true,
  "message": "OK",
  "data": {}
}
```

**Response Error (common):**
- 401: Token missing or invalid
- 403: Access denied wrong role
- 404: Resource not found
- 500: Server error

**Flutter/Dart Code Example:**
```dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:firebase_auth/firebase_auth.dart';

final baseUrl = 'https://sumacademy.net/api';
final uri = Uri.parse('$baseUrl/admin/payments/:paymentId/verify');
final token = await FirebaseAuth.instance.currentUser?.getIdToken(true);
final headers = {'Content-Type': 'application/json', 'Authorization': 'Bearer $token'};
final payload = {/* TODO: request body */};
final res = await http.patch(uri, headers: headers, body: jsonEncode(payload));
final data = jsonDecode(res.body) as Map<String, dynamic>;
if (res.statusCode >= 400) { /* handle error */ }
```

#### Transactions

<span style="color:#2E7D32"><strong>GET</strong></span> https://sumacademy.net/api/admin/transactions

**Description:** Retrieve data for this resource.

**Authentication:** Required

**Role required:** admin

**Request Headers:**
- Content-Type: application/json
- Authorization: Bearer <Firebase ID Token>

**Path Parameters:**
- None

**Query Parameters:**
- None specified

**Request Body:**
- None

**Response Success (example):**
```json
{
  "success": true,
  "message": "OK",
  "data": {}
}
```

**Response Error (common):**
- 401: Token missing or invalid
- 403: Access denied wrong role
- 404: Resource not found
- 500: Server error

**Flutter/Dart Code Example:**
```dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:firebase_auth/firebase_auth.dart';

final baseUrl = 'https://sumacademy.net/api';
final uri = Uri.parse('$baseUrl/admin/transactions');
final token = await FirebaseAuth.instance.currentUser?.getIdToken(true);
final headers = {'Content-Type': 'application/json', 'Authorization': 'Bearer $token'};
final res = await http.get(uri, headers: headers);
final data = jsonDecode(res.body) as Map<String, dynamic>;
if (res.statusCode >= 400) { /* handle error */ }
```

#### Transactions Export

<span style="color:#2E7D32"><strong>GET</strong></span> https://sumacademy.net/api/admin/transactions/export

**Description:** Retrieve data for this resource.

**Authentication:** Required

**Role required:** admin

**Request Headers:**
- Content-Type: application/json
- Authorization: Bearer <Firebase ID Token>

**Path Parameters:**
- None

**Query Parameters:**
- None specified

**Request Body:**
- None

**Response Success (example):**
```json
{
  "success": true,
  "message": "OK",
  "data": {}
}
```

**Response Error (common):**
- 401: Token missing or invalid
- 403: Access denied wrong role
- 404: Resource not found
- 500: Server error

**Flutter/Dart Code Example:**
```dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:firebase_auth/firebase_auth.dart';

final baseUrl = 'https://sumacademy.net/api';
final uri = Uri.parse('$baseUrl/admin/transactions/export');
final token = await FirebaseAuth.instance.currentUser?.getIdToken(true);
final headers = {'Content-Type': 'application/json', 'Authorization': 'Bearer $token'};
final res = await http.get(uri, headers: headers);
final data = jsonDecode(res.body) as Map<String, dynamic>;
if (res.statusCode >= 400) { /* handle error */ }
```

#### Transactions By Id

<span style="color:#2E7D32"><strong>GET</strong></span> https://sumacademy.net/api/admin/transactions/:id

**Description:** Retrieve data for this resource.

**Authentication:** Required

**Role required:** admin

**Request Headers:**
- Content-Type: application/json
- Authorization: Bearer <Firebase ID Token>

**Path Parameters:**
- `id` (string, required)

**Query Parameters:**
- None specified

**Request Body:**
- None

**Response Success (example):**
```json
{
  "success": true,
  "message": "OK",
  "data": {}
}
```

**Response Error (common):**
- 401: Token missing or invalid
- 403: Access denied wrong role
- 404: Resource not found
- 500: Server error

**Flutter/Dart Code Example:**
```dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:firebase_auth/firebase_auth.dart';

final baseUrl = 'https://sumacademy.net/api';
final uri = Uri.parse('$baseUrl/admin/transactions/:id');
final token = await FirebaseAuth.instance.currentUser?.getIdToken(true);
final headers = {'Content-Type': 'application/json', 'Authorization': 'Bearer $token'};
final res = await http.get(uri, headers: headers);
final data = jsonDecode(res.body) as Map<String, dynamic>;
if (res.statusCode >= 400) { /* handle error */ }
```

#### Installments

<span style="color:#2E7D32"><strong>GET</strong></span> https://sumacademy.net/api/admin/installments

**Description:** Retrieve data for this resource.

**Authentication:** Required

**Role required:** admin

**Request Headers:**
- Content-Type: application/json
- Authorization: Bearer <Firebase ID Token>

**Path Parameters:**
- None

**Query Parameters:**
- None specified

**Request Body:**
- None

**Response Success (example):**
```json
{
  "success": true,
  "message": "OK",
  "data": {}
}
```

**Response Error (common):**
- 401: Token missing or invalid
- 403: Access denied wrong role
- 404: Resource not found
- 500: Server error

**Flutter/Dart Code Example:**
```dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:firebase_auth/firebase_auth.dart';

final baseUrl = 'https://sumacademy.net/api';
final uri = Uri.parse('$baseUrl/admin/installments');
final token = await FirebaseAuth.instance.currentUser?.getIdToken(true);
final headers = {'Content-Type': 'application/json', 'Authorization': 'Bearer $token'};
final res = await http.get(uri, headers: headers);
final data = jsonDecode(res.body) as Map<String, dynamic>;
if (res.statusCode >= 400) { /* handle error */ }
```

#### Installments By Planid

<span style="color:#2E7D32"><strong>GET</strong></span> https://sumacademy.net/api/admin/installments/:planId

**Description:** Retrieve data for this resource.

**Authentication:** Required

**Role required:** admin

**Request Headers:**
- Content-Type: application/json
- Authorization: Bearer <Firebase ID Token>

**Path Parameters:**
- `planId` (string, required)

**Query Parameters:**
- None specified

**Request Body:**
- None

**Response Success (example):**
```json
{
  "success": true,
  "message": "OK",
  "data": {}
}
```

**Response Error (common):**
- 401: Token missing or invalid
- 403: Access denied wrong role
- 404: Resource not found
- 500: Server error

**Flutter/Dart Code Example:**
```dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:firebase_auth/firebase_auth.dart';

final baseUrl = 'https://sumacademy.net/api';
final uri = Uri.parse('$baseUrl/admin/installments/:planId');
final token = await FirebaseAuth.instance.currentUser?.getIdToken(true);
final headers = {'Content-Type': 'application/json', 'Authorization': 'Bearer $token'};
final res = await http.get(uri, headers: headers);
final data = jsonDecode(res.body) as Map<String, dynamic>;
if (res.statusCode >= 400) { /* handle error */ }
```

#### Installments By Planid By Number Pay

<span style="color:#EF6C00"><strong>PATCH</strong></span> https://sumacademy.net/api/admin/installments/:planId/:number/pay

**Description:** Update data for this resource.

**Authentication:** Required

**Role required:** admin

**Request Headers:**
- Content-Type: application/json
- Authorization: Bearer <Firebase ID Token>

**Path Parameters:**
- `planId` (string, required)
- `number` (string, required)

**Query Parameters:**
- None specified

**Request Body:**
```json
TBD (confirm request body with backend)
```

**Response Success (example):**
```json
{
  "success": true,
  "message": "OK",
  "data": {}
}
```

**Response Error (common):**
- 401: Token missing or invalid
- 403: Access denied wrong role
- 404: Resource not found
- 500: Server error

**Flutter/Dart Code Example:**
```dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:firebase_auth/firebase_auth.dart';

final baseUrl = 'https://sumacademy.net/api';
final uri = Uri.parse('$baseUrl/admin/installments/:planId/:number/pay');
final token = await FirebaseAuth.instance.currentUser?.getIdToken(true);
final headers = {'Content-Type': 'application/json', 'Authorization': 'Bearer $token'};
final payload = {/* TODO: request body */};
final res = await http.patch(uri, headers: headers, body: jsonEncode(payload));
final data = jsonDecode(res.body) as Map<String, dynamic>;
if (res.statusCode >= 400) { /* handle error */ }
```

#### Installments Send Reminders

<span style="color:#1565C0"><strong>POST</strong></span> https://sumacademy.net/api/admin/installments/send-reminders

**Description:** Create or submit data for this resource.

**Authentication:** Required

**Role required:** admin

**Request Headers:**
- Content-Type: application/json
- Authorization: Bearer <Firebase ID Token>

**Path Parameters:**
- None

**Query Parameters:**
- None specified

**Request Body:**
```json
TBD (confirm request body with backend)
```

**Response Success (example):**
```json
{
  "success": true,
  "message": "OK",
  "data": {}
}
```

**Response Error (common):**
- 401: Token missing or invalid
- 403: Access denied wrong role
- 404: Resource not found
- 500: Server error

**Flutter/Dart Code Example:**
```dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:firebase_auth/firebase_auth.dart';

final baseUrl = 'https://sumacademy.net/api';
final uri = Uri.parse('$baseUrl/admin/installments/send-reminders');
final token = await FirebaseAuth.instance.currentUser?.getIdToken(true);
final headers = {'Content-Type': 'application/json', 'Authorization': 'Bearer $token'};
final payload = {/* TODO: request body */};
final res = await http.post(uri, headers: headers, body: jsonEncode(payload));
final data = jsonDecode(res.body) as Map<String, dynamic>;
if (res.statusCode >= 400) { /* handle error */ }
```

#### Installments By Planid Override

<span style="color:#6A1B9A"><strong>PUT</strong></span> https://sumacademy.net/api/admin/installments/:planId/override

**Description:** Replace data for this resource.

**Authentication:** Required

**Role required:** admin

**Request Headers:**
- Content-Type: application/json
- Authorization: Bearer <Firebase ID Token>

**Path Parameters:**
- `planId` (string, required)

**Query Parameters:**
- None specified

**Request Body:**
```json
TBD (confirm request body with backend)
```

**Response Success (example):**
```json
{
  "success": true,
  "message": "OK",
  "data": {}
}
```

**Response Error (common):**
- 401: Token missing or invalid
- 403: Access denied wrong role
- 404: Resource not found
- 500: Server error

**Flutter/Dart Code Example:**
```dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:firebase_auth/firebase_auth.dart';

final baseUrl = 'https://sumacademy.net/api';
final uri = Uri.parse('$baseUrl/admin/installments/:planId/override');
final token = await FirebaseAuth.instance.currentUser?.getIdToken(true);
final headers = {'Content-Type': 'application/json', 'Authorization': 'Bearer $token'};
final payload = {/* TODO: request body */};
final res = await http.put(uri, headers: headers, body: jsonEncode(payload));
final data = jsonDecode(res.body) as Map<String, dynamic>;
if (res.statusCode >= 400) { /* handle error */ }
```

#### Installments

<span style="color:#1565C0"><strong>POST</strong></span> https://sumacademy.net/api/admin/installments

**Description:** Create or submit data for this resource.

**Authentication:** Required

**Role required:** admin

**Request Headers:**
- Content-Type: application/json
- Authorization: Bearer <Firebase ID Token>

**Path Parameters:**
- None

**Query Parameters:**
- None specified

**Request Body:**
```json
TBD (confirm request body with backend)
```

**Response Success (example):**
```json
{
  "success": true,
  "message": "OK",
  "data": {}
}
```

**Response Error (common):**
- 401: Token missing or invalid
- 403: Access denied wrong role
- 404: Resource not found
- 500: Server error

**Flutter/Dart Code Example:**
```dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:firebase_auth/firebase_auth.dart';

final baseUrl = 'https://sumacademy.net/api';
final uri = Uri.parse('$baseUrl/admin/installments');
final token = await FirebaseAuth.instance.currentUser?.getIdToken(true);
final headers = {'Content-Type': 'application/json', 'Authorization': 'Bearer $token'};
final payload = {/* TODO: request body */};
final res = await http.post(uri, headers: headers, body: jsonEncode(payload));
final data = jsonDecode(res.body) as Map<String, dynamic>;
if (res.statusCode >= 400) { /* handle error */ }
```

#### Promo Codes

<span style="color:#2E7D32"><strong>GET</strong></span> https://sumacademy.net/api/admin/promo-codes

**Description:** Retrieve data for this resource.

**Authentication:** Required

**Role required:** admin

**Request Headers:**
- Content-Type: application/json
- Authorization: Bearer <Firebase ID Token>

**Path Parameters:**
- None

**Query Parameters:**
- None specified

**Request Body:**
- None

**Response Success (example):**
```json
{
  "success": true,
  "message": "OK",
  "data": {}
}
```

**Response Error (common):**
- 401: Token missing or invalid
- 403: Access denied wrong role
- 404: Resource not found
- 500: Server error

**Flutter/Dart Code Example:**
```dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:firebase_auth/firebase_auth.dart';

final baseUrl = 'https://sumacademy.net/api';
final uri = Uri.parse('$baseUrl/admin/promo-codes');
final token = await FirebaseAuth.instance.currentUser?.getIdToken(true);
final headers = {'Content-Type': 'application/json', 'Authorization': 'Bearer $token'};
final res = await http.get(uri, headers: headers);
final data = jsonDecode(res.body) as Map<String, dynamic>;
if (res.statusCode >= 400) { /* handle error */ }
```

#### Promo Codes

<span style="color:#1565C0"><strong>POST</strong></span> https://sumacademy.net/api/admin/promo-codes

**Description:** Create or submit data for this resource.

**Authentication:** Required

**Role required:** admin

**Request Headers:**
- Content-Type: application/json
- Authorization: Bearer <Firebase ID Token>

**Path Parameters:**
- None

**Query Parameters:**
- None specified

**Request Body:**
```json
TBD (confirm request body with backend)
```

**Response Success (example):**
```json
{
  "success": true,
  "message": "OK",
  "data": {}
}
```

**Response Error (common):**
- 401: Token missing or invalid
- 403: Access denied wrong role
- 404: Resource not found
- 500: Server error

**Flutter/Dart Code Example:**
```dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:firebase_auth/firebase_auth.dart';

final baseUrl = 'https://sumacademy.net/api';
final uri = Uri.parse('$baseUrl/admin/promo-codes');
final token = await FirebaseAuth.instance.currentUser?.getIdToken(true);
final headers = {'Content-Type': 'application/json', 'Authorization': 'Bearer $token'};
final payload = {/* TODO: request body */};
final res = await http.post(uri, headers: headers, body: jsonEncode(payload));
final data = jsonDecode(res.body) as Map<String, dynamic>;
if (res.statusCode >= 400) { /* handle error */ }
```

#### Promo Codes By Codeid

<span style="color:#6A1B9A"><strong>PUT</strong></span> https://sumacademy.net/api/admin/promo-codes/:codeId

**Description:** Replace data for this resource.

**Authentication:** Required

**Role required:** admin

**Request Headers:**
- Content-Type: application/json
- Authorization: Bearer <Firebase ID Token>

**Path Parameters:**
- `codeId` (string, required)

**Query Parameters:**
- None specified

**Request Body:**
```json
TBD (confirm request body with backend)
```

**Response Success (example):**
```json
{
  "success": true,
  "message": "OK",
  "data": {}
}
```

**Response Error (common):**
- 401: Token missing or invalid
- 403: Access denied wrong role
- 404: Resource not found
- 500: Server error

**Flutter/Dart Code Example:**
```dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:firebase_auth/firebase_auth.dart';

final baseUrl = 'https://sumacademy.net/api';
final uri = Uri.parse('$baseUrl/admin/promo-codes/:codeId');
final token = await FirebaseAuth.instance.currentUser?.getIdToken(true);
final headers = {'Content-Type': 'application/json', 'Authorization': 'Bearer $token'};
final payload = {/* TODO: request body */};
final res = await http.put(uri, headers: headers, body: jsonEncode(payload));
final data = jsonDecode(res.body) as Map<String, dynamic>;
if (res.statusCode >= 400) { /* handle error */ }
```

#### Promo Codes By Codeid

<span style="color:#C62828"><strong>DELETE</strong></span> https://sumacademy.net/api/admin/promo-codes/:codeId

**Description:** Delete this resource.

**Authentication:** Required

**Role required:** admin

**Request Headers:**
- Content-Type: application/json
- Authorization: Bearer <Firebase ID Token>

**Path Parameters:**
- `codeId` (string, required)

**Query Parameters:**
- None specified

**Request Body:**
- None

**Response Success (example):**
```json
{
  "success": true,
  "message": "OK",
  "data": {}
}
```

**Response Error (common):**
- 401: Token missing or invalid
- 403: Access denied wrong role
- 404: Resource not found
- 500: Server error

**Flutter/Dart Code Example:**
```dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:firebase_auth/firebase_auth.dart';

final baseUrl = 'https://sumacademy.net/api';
final uri = Uri.parse('$baseUrl/admin/promo-codes/:codeId');
final token = await FirebaseAuth.instance.currentUser?.getIdToken(true);
final headers = {'Content-Type': 'application/json', 'Authorization': 'Bearer $token'};
final res = await http.delete(uri, headers: headers);
final data = jsonDecode(res.body) as Map<String, dynamic>;
if (res.statusCode >= 400) { /* handle error */ }
```

#### Promo Codes By Codeid Toggle

<span style="color:#EF6C00"><strong>PATCH</strong></span> https://sumacademy.net/api/admin/promo-codes/:codeId/toggle

**Description:** Update data for this resource.

**Authentication:** Required

**Role required:** admin

**Request Headers:**
- Content-Type: application/json
- Authorization: Bearer <Firebase ID Token>

**Path Parameters:**
- `codeId` (string, required)

**Query Parameters:**
- None specified

**Request Body:**
```json
TBD (confirm request body with backend)
```

**Response Success (example):**
```json
{
  "success": true,
  "message": "OK",
  "data": {}
}
```

**Response Error (common):**
- 401: Token missing or invalid
- 403: Access denied wrong role
- 404: Resource not found
- 500: Server error

**Flutter/Dart Code Example:**
```dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:firebase_auth/firebase_auth.dart';

final baseUrl = 'https://sumacademy.net/api';
final uri = Uri.parse('$baseUrl/admin/promo-codes/:codeId/toggle');
final token = await FirebaseAuth.instance.currentUser?.getIdToken(true);
final headers = {'Content-Type': 'application/json', 'Authorization': 'Bearer $token'};
final payload = {/* TODO: request body */};
final res = await http.patch(uri, headers: headers, body: jsonEncode(payload));
final data = jsonDecode(res.body) as Map<String, dynamic>;
if (res.statusCode >= 400) { /* handle error */ }
```

#### Promo Codes Validate

<span style="color:#1565C0"><strong>POST</strong></span> https://sumacademy.net/api/admin/promo-codes/validate

**Description:** Create or submit data for this resource.

**Authentication:** Required

**Role required:** admin

**Request Headers:**
- Content-Type: application/json
- Authorization: Bearer <Firebase ID Token>

**Path Parameters:**
- None

**Query Parameters:**
- None specified

**Request Body:**
```json
{
  "code": "string (required)"
}
```

**Response Success (example):**
```json
{
  "success": true,
  "message": "OK",
  "data": {}
}
```

**Response Error (common):**
- 401: Token missing or invalid
- 403: Access denied wrong role
- 404: Resource not found
- 500: Server error

**Flutter/Dart Code Example:**
```dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:firebase_auth/firebase_auth.dart';

final baseUrl = 'https://sumacademy.net/api';
final uri = Uri.parse('$baseUrl/admin/promo-codes/validate');
final token = await FirebaseAuth.instance.currentUser?.getIdToken(true);
final headers = {'Content-Type': 'application/json', 'Authorization': 'Bearer $token'};
final payload = {/* TODO: request body */};
final res = await http.post(uri, headers: headers, body: jsonEncode(payload));
final data = jsonDecode(res.body) as Map<String, dynamic>;
if (res.statusCode >= 400) { /* handle error */ }
```

#### Certificates

<span style="color:#2E7D32"><strong>GET</strong></span> https://sumacademy.net/api/admin/certificates

**Description:** Retrieve data for this resource.

**Authentication:** Required

**Role required:** admin

**Request Headers:**
- Content-Type: application/json
- Authorization: Bearer <Firebase ID Token>

**Path Parameters:**
- None

**Query Parameters:**
- None specified

**Request Body:**
- None

**Response Success (example):**
```json
{
  "success": true,
  "message": "OK",
  "data": {}
}
```

**Response Error (common):**
- 401: Token missing or invalid
- 403: Access denied wrong role
- 404: Resource not found
- 500: Server error

**Flutter/Dart Code Example:**
```dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:firebase_auth/firebase_auth.dart';

final baseUrl = 'https://sumacademy.net/api';
final uri = Uri.parse('$baseUrl/admin/certificates');
final token = await FirebaseAuth.instance.currentUser?.getIdToken(true);
final headers = {'Content-Type': 'application/json', 'Authorization': 'Bearer $token'};
final res = await http.get(uri, headers: headers);
final data = jsonDecode(res.body) as Map<String, dynamic>;
if (res.statusCode >= 400) { /* handle error */ }
```

#### Certificates

<span style="color:#1565C0"><strong>POST</strong></span> https://sumacademy.net/api/admin/certificates

**Description:** Create or submit data for this resource.

**Authentication:** Required

**Role required:** admin

**Request Headers:**
- Content-Type: application/json
- Authorization: Bearer <Firebase ID Token>

**Path Parameters:**
- None

**Query Parameters:**
- None specified

**Request Body:**
```json
TBD (confirm request body with backend)
```

**Response Success (example):**
```json
{
  "success": true,
  "message": "OK",
  "data": {}
}
```

**Response Error (common):**
- 401: Token missing or invalid
- 403: Access denied wrong role
- 404: Resource not found
- 500: Server error

**Flutter/Dart Code Example:**
```dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:firebase_auth/firebase_auth.dart';

final baseUrl = 'https://sumacademy.net/api';
final uri = Uri.parse('$baseUrl/admin/certificates');
final token = await FirebaseAuth.instance.currentUser?.getIdToken(true);
final headers = {'Content-Type': 'application/json', 'Authorization': 'Bearer $token'};
final payload = {/* TODO: request body */};
final res = await http.post(uri, headers: headers, body: jsonEncode(payload));
final data = jsonDecode(res.body) as Map<String, dynamic>;
if (res.statusCode >= 400) { /* handle error */ }
```

#### Certificates By Certid Revoke

<span style="color:#EF6C00"><strong>PATCH</strong></span> https://sumacademy.net/api/admin/certificates/:certId/revoke

**Description:** Update data for this resource.

**Authentication:** Required

**Role required:** admin

**Request Headers:**
- Content-Type: application/json
- Authorization: Bearer <Firebase ID Token>

**Path Parameters:**
- `certId` (string, required)

**Query Parameters:**
- None specified

**Request Body:**
```json
TBD (confirm request body with backend)
```

**Response Success (example):**
```json
{
  "success": true,
  "message": "OK",
  "data": {}
}
```

**Response Error (common):**
- 401: Token missing or invalid
- 403: Access denied wrong role
- 404: Resource not found
- 500: Server error

**Flutter/Dart Code Example:**
```dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:firebase_auth/firebase_auth.dart';

final baseUrl = 'https://sumacademy.net/api';
final uri = Uri.parse('$baseUrl/admin/certificates/:certId/revoke');
final token = await FirebaseAuth.instance.currentUser?.getIdToken(true);
final headers = {'Content-Type': 'application/json', 'Authorization': 'Bearer $token'};
final payload = {/* TODO: request body */};
final res = await http.patch(uri, headers: headers, body: jsonEncode(payload));
final data = jsonDecode(res.body) as Map<String, dynamic>;
if (res.statusCode >= 400) { /* handle error */ }
```

#### Certificates By Certid Unrevoke

<span style="color:#EF6C00"><strong>PATCH</strong></span> https://sumacademy.net/api/admin/certificates/:certId/unrevoke

**Description:** Update data for this resource.

**Authentication:** Required

**Role required:** admin

**Request Headers:**
- Content-Type: application/json
- Authorization: Bearer <Firebase ID Token>

**Path Parameters:**
- `certId` (string, required)

**Query Parameters:**
- None specified

**Request Body:**
```json
TBD (confirm request body with backend)
```

**Response Success (example):**
```json
{
  "success": true,
  "message": "OK",
  "data": {}
}
```

**Response Error (common):**
- 401: Token missing or invalid
- 403: Access denied wrong role
- 404: Resource not found
- 500: Server error

**Flutter/Dart Code Example:**
```dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:firebase_auth/firebase_auth.dart';

final baseUrl = 'https://sumacademy.net/api';
final uri = Uri.parse('$baseUrl/admin/certificates/:certId/unrevoke');
final token = await FirebaseAuth.instance.currentUser?.getIdToken(true);
final headers = {'Content-Type': 'application/json', 'Authorization': 'Bearer $token'};
final payload = {/* TODO: request body */};
final res = await http.patch(uri, headers: headers, body: jsonEncode(payload));
final data = jsonDecode(res.body) as Map<String, dynamic>;
if (res.statusCode >= 400) { /* handle error */ }
```

#### Announcements

<span style="color:#2E7D32"><strong>GET</strong></span> https://sumacademy.net/api/admin/announcements

**Description:** Retrieve data for this resource.

**Authentication:** Required

**Role required:** admin

**Request Headers:**
- Content-Type: application/json
- Authorization: Bearer <Firebase ID Token>

**Path Parameters:**
- None

**Query Parameters:**
- None specified

**Request Body:**
- None

**Response Success (example):**
```json
{
  "success": true,
  "message": "OK",
  "data": {}
}
```

**Response Error (common):**
- 401: Token missing or invalid
- 403: Access denied wrong role
- 404: Resource not found
- 500: Server error

**Flutter/Dart Code Example:**
```dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:firebase_auth/firebase_auth.dart';

final baseUrl = 'https://sumacademy.net/api';
final uri = Uri.parse('$baseUrl/admin/announcements');
final token = await FirebaseAuth.instance.currentUser?.getIdToken(true);
final headers = {'Content-Type': 'application/json', 'Authorization': 'Bearer $token'};
final res = await http.get(uri, headers: headers);
final data = jsonDecode(res.body) as Map<String, dynamic>;
if (res.statusCode >= 400) { /* handle error */ }
```

#### Announcements

<span style="color:#1565C0"><strong>POST</strong></span> https://sumacademy.net/api/admin/announcements

**Description:** Create or submit data for this resource.

**Authentication:** Required

**Role required:** admin

**Request Headers:**
- Content-Type: application/json
- Authorization: Bearer <Firebase ID Token>

**Path Parameters:**
- None

**Query Parameters:**
- None specified

**Request Body:**
```json
TBD (confirm request body with backend)
```

**Response Success (example):**
```json
{
  "success": true,
  "message": "OK",
  "data": {}
}
```

**Response Error (common):**
- 401: Token missing or invalid
- 403: Access denied wrong role
- 404: Resource not found
- 500: Server error

**Flutter/Dart Code Example:**
```dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:firebase_auth/firebase_auth.dart';

final baseUrl = 'https://sumacademy.net/api';
final uri = Uri.parse('$baseUrl/admin/announcements');
final token = await FirebaseAuth.instance.currentUser?.getIdToken(true);
final headers = {'Content-Type': 'application/json', 'Authorization': 'Bearer $token'};
final payload = {/* TODO: request body */};
final res = await http.post(uri, headers: headers, body: jsonEncode(payload));
final data = jsonDecode(res.body) as Map<String, dynamic>;
if (res.statusCode >= 400) { /* handle error */ }
```

#### Announcements By Id

<span style="color:#6A1B9A"><strong>PUT</strong></span> https://sumacademy.net/api/admin/announcements/:id

**Description:** Replace data for this resource.

**Authentication:** Required

**Role required:** admin

**Request Headers:**
- Content-Type: application/json
- Authorization: Bearer <Firebase ID Token>

**Path Parameters:**
- `id` (string, required)

**Query Parameters:**
- None specified

**Request Body:**
```json
TBD (confirm request body with backend)
```

**Response Success (example):**
```json
{
  "success": true,
  "message": "OK",
  "data": {}
}
```

**Response Error (common):**
- 401: Token missing or invalid
- 403: Access denied wrong role
- 404: Resource not found
- 500: Server error

**Flutter/Dart Code Example:**
```dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:firebase_auth/firebase_auth.dart';

final baseUrl = 'https://sumacademy.net/api';
final uri = Uri.parse('$baseUrl/admin/announcements/:id');
final token = await FirebaseAuth.instance.currentUser?.getIdToken(true);
final headers = {'Content-Type': 'application/json', 'Authorization': 'Bearer $token'};
final payload = {/* TODO: request body */};
final res = await http.put(uri, headers: headers, body: jsonEncode(payload));
final data = jsonDecode(res.body) as Map<String, dynamic>;
if (res.statusCode >= 400) { /* handle error */ }
```

#### Announcements By Id

<span style="color:#C62828"><strong>DELETE</strong></span> https://sumacademy.net/api/admin/announcements/:id

**Description:** Delete this resource.

**Authentication:** Required

**Role required:** admin

**Request Headers:**
- Content-Type: application/json
- Authorization: Bearer <Firebase ID Token>

**Path Parameters:**
- `id` (string, required)

**Query Parameters:**
- None specified

**Request Body:**
- None

**Response Success (example):**
```json
{
  "success": true,
  "message": "OK",
  "data": {}
}
```

**Response Error (common):**
- 401: Token missing or invalid
- 403: Access denied wrong role
- 404: Resource not found
- 500: Server error

**Flutter/Dart Code Example:**
```dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:firebase_auth/firebase_auth.dart';

final baseUrl = 'https://sumacademy.net/api';
final uri = Uri.parse('$baseUrl/admin/announcements/:id');
final token = await FirebaseAuth.instance.currentUser?.getIdToken(true);
final headers = {'Content-Type': 'application/json', 'Authorization': 'Bearer $token'};
final res = await http.delete(uri, headers: headers);
final data = jsonDecode(res.body) as Map<String, dynamic>;
if (res.statusCode >= 400) { /* handle error */ }
```

#### Announcements By Id Pin

<span style="color:#EF6C00"><strong>PATCH</strong></span> https://sumacademy.net/api/admin/announcements/:id/pin

**Description:** Update data for this resource.

**Authentication:** Required

**Role required:** admin

**Request Headers:**
- Content-Type: application/json
- Authorization: Bearer <Firebase ID Token>

**Path Parameters:**
- `id` (string, required)

**Query Parameters:**
- None specified

**Request Body:**
```json
TBD (confirm request body with backend)
```

**Response Success (example):**
```json
{
  "success": true,
  "message": "OK",
  "data": {}
}
```

**Response Error (common):**
- 401: Token missing or invalid
- 403: Access denied wrong role
- 404: Resource not found
- 500: Server error

**Flutter/Dart Code Example:**
```dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:firebase_auth/firebase_auth.dart';

final baseUrl = 'https://sumacademy.net/api';
final uri = Uri.parse('$baseUrl/admin/announcements/:id/pin');
final token = await FirebaseAuth.instance.currentUser?.getIdToken(true);
final headers = {'Content-Type': 'application/json', 'Authorization': 'Bearer $token'};
final payload = {/* TODO: request body */};
final res = await http.patch(uri, headers: headers, body: jsonEncode(payload));
final data = jsonDecode(res.body) as Map<String, dynamic>;
if (res.statusCode >= 400) { /* handle error */ }
```

#### Settings

<span style="color:#2E7D32"><strong>GET</strong></span> https://sumacademy.net/api/admin/settings

**Description:** Retrieve data for this resource.

**Authentication:** Required

**Role required:** admin

**Request Headers:**
- Content-Type: application/json
- Authorization: Bearer <Firebase ID Token>

**Path Parameters:**
- None

**Query Parameters:**
- None specified

**Request Body:**
- None

**Response Success (example):**
```json
{
  "success": true,
  "message": "OK",
  "data": {}
}
```

**Response Error (common):**
- 401: Token missing or invalid
- 403: Access denied wrong role
- 404: Resource not found
- 500: Server error

**Flutter/Dart Code Example:**
```dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:firebase_auth/firebase_auth.dart';

final baseUrl = 'https://sumacademy.net/api';
final uri = Uri.parse('$baseUrl/admin/settings');
final token = await FirebaseAuth.instance.currentUser?.getIdToken(true);
final headers = {'Content-Type': 'application/json', 'Authorization': 'Bearer $token'};
final res = await http.get(uri, headers: headers);
final data = jsonDecode(res.body) as Map<String, dynamic>;
if (res.statusCode >= 400) { /* handle error */ }
```

#### Settings General

<span style="color:#6A1B9A"><strong>PUT</strong></span> https://sumacademy.net/api/admin/settings/general

**Description:** Replace data for this resource.

**Authentication:** Required

**Role required:** admin

**Request Headers:**
- Content-Type: application/json
- Authorization: Bearer <Firebase ID Token>

**Path Parameters:**
- None

**Query Parameters:**
- None specified

**Request Body:**
```json
TBD (confirm request body with backend)
```

**Response Success (example):**
```json
{
  "success": true,
  "message": "OK",
  "data": {}
}
```

**Response Error (common):**
- 401: Token missing or invalid
- 403: Access denied wrong role
- 404: Resource not found
- 500: Server error

**Flutter/Dart Code Example:**
```dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:firebase_auth/firebase_auth.dart';

final baseUrl = 'https://sumacademy.net/api';
final uri = Uri.parse('$baseUrl/admin/settings/general');
final token = await FirebaseAuth.instance.currentUser?.getIdToken(true);
final headers = {'Content-Type': 'application/json', 'Authorization': 'Bearer $token'};
final payload = {/* TODO: request body */};
final res = await http.put(uri, headers: headers, body: jsonEncode(payload));
final data = jsonDecode(res.body) as Map<String, dynamic>;
if (res.statusCode >= 400) { /* handle error */ }
```

#### Settings Hero

<span style="color:#6A1B9A"><strong>PUT</strong></span> https://sumacademy.net/api/admin/settings/hero

**Description:** Replace data for this resource.

**Authentication:** Required

**Role required:** admin

**Request Headers:**
- Content-Type: application/json
- Authorization: Bearer <Firebase ID Token>

**Path Parameters:**
- None

**Query Parameters:**
- None specified

**Request Body:**
```json
TBD (confirm request body with backend)
```

**Response Success (example):**
```json
{
  "success": true,
  "message": "OK",
  "data": {}
}
```

**Response Error (common):**
- 401: Token missing or invalid
- 403: Access denied wrong role
- 404: Resource not found
- 500: Server error

**Flutter/Dart Code Example:**
```dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:firebase_auth/firebase_auth.dart';

final baseUrl = 'https://sumacademy.net/api';
final uri = Uri.parse('$baseUrl/admin/settings/hero');
final token = await FirebaseAuth.instance.currentUser?.getIdToken(true);
final headers = {'Content-Type': 'application/json', 'Authorization': 'Bearer $token'};
final payload = {/* TODO: request body */};
final res = await http.put(uri, headers: headers, body: jsonEncode(payload));
final data = jsonDecode(res.body) as Map<String, dynamic>;
if (res.statusCode >= 400) { /* handle error */ }
```

#### Settings How It Works

<span style="color:#6A1B9A"><strong>PUT</strong></span> https://sumacademy.net/api/admin/settings/how-it-works

**Description:** Replace data for this resource.

**Authentication:** Required

**Role required:** admin

**Request Headers:**
- Content-Type: application/json
- Authorization: Bearer <Firebase ID Token>

**Path Parameters:**
- None

**Query Parameters:**
- None specified

**Request Body:**
```json
TBD (confirm request body with backend)
```

**Response Success (example):**
```json
{
  "success": true,
  "message": "OK",
  "data": {}
}
```

**Response Error (common):**
- 401: Token missing or invalid
- 403: Access denied wrong role
- 404: Resource not found
- 500: Server error

**Flutter/Dart Code Example:**
```dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:firebase_auth/firebase_auth.dart';

final baseUrl = 'https://sumacademy.net/api';
final uri = Uri.parse('$baseUrl/admin/settings/how-it-works');
final token = await FirebaseAuth.instance.currentUser?.getIdToken(true);
final headers = {'Content-Type': 'application/json', 'Authorization': 'Bearer $token'};
final payload = {/* TODO: request body */};
final res = await http.put(uri, headers: headers, body: jsonEncode(payload));
final data = jsonDecode(res.body) as Map<String, dynamic>;
if (res.statusCode >= 400) { /* handle error */ }
```

#### Settings Features

<span style="color:#6A1B9A"><strong>PUT</strong></span> https://sumacademy.net/api/admin/settings/features

**Description:** Replace data for this resource.

**Authentication:** Required

**Role required:** admin

**Request Headers:**
- Content-Type: application/json
- Authorization: Bearer <Firebase ID Token>

**Path Parameters:**
- None

**Query Parameters:**
- None specified

**Request Body:**
```json
TBD (confirm request body with backend)
```

**Response Success (example):**
```json
{
  "success": true,
  "message": "OK",
  "data": {}
}
```

**Response Error (common):**
- 401: Token missing or invalid
- 403: Access denied wrong role
- 404: Resource not found
- 500: Server error

**Flutter/Dart Code Example:**
```dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:firebase_auth/firebase_auth.dart';

final baseUrl = 'https://sumacademy.net/api';
final uri = Uri.parse('$baseUrl/admin/settings/features');
final token = await FirebaseAuth.instance.currentUser?.getIdToken(true);
final headers = {'Content-Type': 'application/json', 'Authorization': 'Bearer $token'};
final payload = {/* TODO: request body */};
final res = await http.put(uri, headers: headers, body: jsonEncode(payload));
final data = jsonDecode(res.body) as Map<String, dynamic>;
if (res.statusCode >= 400) { /* handle error */ }
```

#### Settings Testimonials

<span style="color:#6A1B9A"><strong>PUT</strong></span> https://sumacademy.net/api/admin/settings/testimonials

**Description:** Replace data for this resource.

**Authentication:** Required

**Role required:** admin

**Request Headers:**
- Content-Type: application/json
- Authorization: Bearer <Firebase ID Token>

**Path Parameters:**
- None

**Query Parameters:**
- None specified

**Request Body:**
```json
TBD (confirm request body with backend)
```

**Response Success (example):**
```json
{
  "success": true,
  "message": "OK",
  "data": {}
}
```

**Response Error (common):**
- 401: Token missing or invalid
- 403: Access denied wrong role
- 404: Resource not found
- 500: Server error

**Flutter/Dart Code Example:**
```dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:firebase_auth/firebase_auth.dart';

final baseUrl = 'https://sumacademy.net/api';
final uri = Uri.parse('$baseUrl/admin/settings/testimonials');
final token = await FirebaseAuth.instance.currentUser?.getIdToken(true);
final headers = {'Content-Type': 'application/json', 'Authorization': 'Bearer $token'};
final payload = {/* TODO: request body */};
final res = await http.put(uri, headers: headers, body: jsonEncode(payload));
final data = jsonDecode(res.body) as Map<String, dynamic>;
if (res.statusCode >= 400) { /* handle error */ }
```

#### Settings About

<span style="color:#6A1B9A"><strong>PUT</strong></span> https://sumacademy.net/api/admin/settings/about

**Description:** Replace data for this resource.

**Authentication:** Required

**Role required:** admin

**Request Headers:**
- Content-Type: application/json
- Authorization: Bearer <Firebase ID Token>

**Path Parameters:**
- None

**Query Parameters:**
- None specified

**Request Body:**
```json
TBD (confirm request body with backend)
```

**Response Success (example):**
```json
{
  "success": true,
  "message": "OK",
  "data": {}
}
```

**Response Error (common):**
- 401: Token missing or invalid
- 403: Access denied wrong role
- 404: Resource not found
- 500: Server error

**Flutter/Dart Code Example:**
```dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:firebase_auth/firebase_auth.dart';

final baseUrl = 'https://sumacademy.net/api';
final uri = Uri.parse('$baseUrl/admin/settings/about');
final token = await FirebaseAuth.instance.currentUser?.getIdToken(true);
final headers = {'Content-Type': 'application/json', 'Authorization': 'Bearer $token'};
final payload = {/* TODO: request body */};
final res = await http.put(uri, headers: headers, body: jsonEncode(payload));
final data = jsonDecode(res.body) as Map<String, dynamic>;
if (res.statusCode >= 400) { /* handle error */ }
```

#### Settings Contact

<span style="color:#6A1B9A"><strong>PUT</strong></span> https://sumacademy.net/api/admin/settings/contact

**Description:** Replace data for this resource.

**Authentication:** Required

**Role required:** admin

**Request Headers:**
- Content-Type: application/json
- Authorization: Bearer <Firebase ID Token>

**Path Parameters:**
- None

**Query Parameters:**
- None specified

**Request Body:**
```json
TBD (confirm request body with backend)
```

**Response Success (example):**
```json
{
  "success": true,
  "message": "OK",
  "data": {}
}
```

**Response Error (common):**
- 401: Token missing or invalid
- 403: Access denied wrong role
- 404: Resource not found
- 500: Server error

**Flutter/Dart Code Example:**
```dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:firebase_auth/firebase_auth.dart';

final baseUrl = 'https://sumacademy.net/api';
final uri = Uri.parse('$baseUrl/admin/settings/contact');
final token = await FirebaseAuth.instance.currentUser?.getIdToken(true);
final headers = {'Content-Type': 'application/json', 'Authorization': 'Bearer $token'};
final payload = {/* TODO: request body */};
final res = await http.put(uri, headers: headers, body: jsonEncode(payload));
final data = jsonDecode(res.body) as Map<String, dynamic>;
if (res.statusCode >= 400) { /* handle error */ }
```

#### Settings Footer

<span style="color:#6A1B9A"><strong>PUT</strong></span> https://sumacademy.net/api/admin/settings/footer

**Description:** Replace data for this resource.

**Authentication:** Required

**Role required:** admin

**Request Headers:**
- Content-Type: application/json
- Authorization: Bearer <Firebase ID Token>

**Path Parameters:**
- None

**Query Parameters:**
- None specified

**Request Body:**
```json
TBD (confirm request body with backend)
```

**Response Success (example):**
```json
{
  "success": true,
  "message": "OK",
  "data": {}
}
```

**Response Error (common):**
- 401: Token missing or invalid
- 403: Access denied wrong role
- 404: Resource not found
- 500: Server error

**Flutter/Dart Code Example:**
```dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:firebase_auth/firebase_auth.dart';

final baseUrl = 'https://sumacademy.net/api';
final uri = Uri.parse('$baseUrl/admin/settings/footer');
final token = await FirebaseAuth.instance.currentUser?.getIdToken(true);
final headers = {'Content-Type': 'application/json', 'Authorization': 'Bearer $token'};
final payload = {/* TODO: request body */};
final res = await http.put(uri, headers: headers, body: jsonEncode(payload));
final data = jsonDecode(res.body) as Map<String, dynamic>;
if (res.statusCode >= 400) { /* handle error */ }
```

#### Settings Appearance

<span style="color:#6A1B9A"><strong>PUT</strong></span> https://sumacademy.net/api/admin/settings/appearance

**Description:** Replace data for this resource.

**Authentication:** Required

**Role required:** admin

**Request Headers:**
- Content-Type: application/json
- Authorization: Bearer <Firebase ID Token>

**Path Parameters:**
- None

**Query Parameters:**
- None specified

**Request Body:**
```json
TBD (confirm request body with backend)
```

**Response Success (example):**
```json
{
  "success": true,
  "message": "OK",
  "data": {}
}
```

**Response Error (common):**
- 401: Token missing or invalid
- 403: Access denied wrong role
- 404: Resource not found
- 500: Server error

**Flutter/Dart Code Example:**
```dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:firebase_auth/firebase_auth.dart';

final baseUrl = 'https://sumacademy.net/api';
final uri = Uri.parse('$baseUrl/admin/settings/appearance');
final token = await FirebaseAuth.instance.currentUser?.getIdToken(true);
final headers = {'Content-Type': 'application/json', 'Authorization': 'Bearer $token'};
final payload = {/* TODO: request body */};
final res = await http.put(uri, headers: headers, body: jsonEncode(payload));
final data = jsonDecode(res.body) as Map<String, dynamic>;
if (res.statusCode >= 400) { /* handle error */ }
```

#### Settings Certificate

<span style="color:#6A1B9A"><strong>PUT</strong></span> https://sumacademy.net/api/admin/settings/certificate

**Description:** Replace data for this resource.

**Authentication:** Required

**Role required:** admin

**Request Headers:**
- Content-Type: application/json
- Authorization: Bearer <Firebase ID Token>

**Path Parameters:**
- None

**Query Parameters:**
- None specified

**Request Body:**
```json
TBD (confirm request body with backend)
```

**Response Success (example):**
```json
{
  "success": true,
  "message": "OK",
  "data": {}
}
```

**Response Error (common):**
- 401: Token missing or invalid
- 403: Access denied wrong role
- 404: Resource not found
- 500: Server error

**Flutter/Dart Code Example:**
```dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:firebase_auth/firebase_auth.dart';

final baseUrl = 'https://sumacademy.net/api';
final uri = Uri.parse('$baseUrl/admin/settings/certificate');
final token = await FirebaseAuth.instance.currentUser?.getIdToken(true);
final headers = {'Content-Type': 'application/json', 'Authorization': 'Bearer $token'};
final payload = {/* TODO: request body */};
final res = await http.put(uri, headers: headers, body: jsonEncode(payload));
final data = jsonDecode(res.body) as Map<String, dynamic>;
if (res.statusCode >= 400) { /* handle error */ }
```

#### Settings Maintenance

<span style="color:#6A1B9A"><strong>PUT</strong></span> https://sumacademy.net/api/admin/settings/maintenance

**Description:** Replace data for this resource.

**Authentication:** Required

**Role required:** admin

**Request Headers:**
- Content-Type: application/json
- Authorization: Bearer <Firebase ID Token>

**Path Parameters:**
- None

**Query Parameters:**
- None specified

**Request Body:**
```json
TBD (confirm request body with backend)
```

**Response Success (example):**
```json
{
  "success": true,
  "message": "OK",
  "data": {}
}
```

**Response Error (common):**
- 401: Token missing or invalid
- 403: Access denied wrong role
- 404: Resource not found
- 500: Server error

**Flutter/Dart Code Example:**
```dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:firebase_auth/firebase_auth.dart';

final baseUrl = 'https://sumacademy.net/api';
final uri = Uri.parse('$baseUrl/admin/settings/maintenance');
final token = await FirebaseAuth.instance.currentUser?.getIdToken(true);
final headers = {'Content-Type': 'application/json', 'Authorization': 'Bearer $token'};
final payload = {/* TODO: request body */};
final res = await http.put(uri, headers: headers, body: jsonEncode(payload));
final data = jsonDecode(res.body) as Map<String, dynamic>;
if (res.statusCode >= 400) { /* handle error */ }
```

#### Settings Email

<span style="color:#6A1B9A"><strong>PUT</strong></span> https://sumacademy.net/api/admin/settings/email

**Description:** Replace data for this resource.

**Authentication:** Required

**Role required:** admin

**Request Headers:**
- Content-Type: application/json
- Authorization: Bearer <Firebase ID Token>

**Path Parameters:**
- None

**Query Parameters:**
- None specified

**Request Body:**
```json
TBD (confirm request body with backend)
```

**Response Success (example):**
```json
{
  "success": true,
  "message": "OK",
  "data": {}
}
```

**Response Error (common):**
- 401: Token missing or invalid
- 403: Access denied wrong role
- 404: Resource not found
- 500: Server error

**Flutter/Dart Code Example:**
```dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:firebase_auth/firebase_auth.dart';

final baseUrl = 'https://sumacademy.net/api';
final uri = Uri.parse('$baseUrl/admin/settings/email');
final token = await FirebaseAuth.instance.currentUser?.getIdToken(true);
final headers = {'Content-Type': 'application/json', 'Authorization': 'Bearer $token'};
final payload = {/* TODO: request body */};
final res = await http.put(uri, headers: headers, body: jsonEncode(payload));
final data = jsonDecode(res.body) as Map<String, dynamic>;
if (res.statusCode >= 400) { /* handle error */ }
```

#### Settings Email Test

<span style="color:#1565C0"><strong>POST</strong></span> https://sumacademy.net/api/admin/settings/email/test

**Description:** Create or submit data for this resource.

**Authentication:** Required

**Role required:** admin

**Request Headers:**
- Content-Type: application/json
- Authorization: Bearer <Firebase ID Token>

**Path Parameters:**
- None

**Query Parameters:**
- None specified

**Request Body:**
```json
TBD (confirm request body with backend)
```

**Response Success (example):**
```json
{
  "success": true,
  "message": "OK",
  "data": {}
}
```

**Response Error (common):**
- 401: Token missing or invalid
- 403: Access denied wrong role
- 404: Resource not found
- 500: Server error

**Flutter/Dart Code Example:**
```dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:firebase_auth/firebase_auth.dart';

final baseUrl = 'https://sumacademy.net/api';
final uri = Uri.parse('$baseUrl/admin/settings/email/test');
final token = await FirebaseAuth.instance.currentUser?.getIdToken(true);
final headers = {'Content-Type': 'application/json', 'Authorization': 'Bearer $token'};
final payload = {/* TODO: request body */};
final res = await http.post(uri, headers: headers, body: jsonEncode(payload));
final data = jsonDecode(res.body) as Map<String, dynamic>;
if (res.statusCode >= 400) { /* handle error */ }
```

#### Settings Payment

<span style="color:#6A1B9A"><strong>PUT</strong></span> https://sumacademy.net/api/admin/settings/payment

**Description:** Replace data for this resource.

**Authentication:** Required

**Role required:** admin

**Request Headers:**
- Content-Type: application/json
- Authorization: Bearer <Firebase ID Token>

**Path Parameters:**
- None

**Query Parameters:**
- None specified

**Request Body:**
```json
TBD (confirm request body with backend)
```

**Response Success (example):**
```json
{
  "success": true,
  "message": "OK",
  "data": {}
}
```

**Response Error (common):**
- 401: Token missing or invalid
- 403: Access denied wrong role
- 404: Resource not found
- 500: Server error

**Flutter/Dart Code Example:**
```dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:firebase_auth/firebase_auth.dart';

final baseUrl = 'https://sumacademy.net/api';
final uri = Uri.parse('$baseUrl/admin/settings/payment');
final token = await FirebaseAuth.instance.currentUser?.getIdToken(true);
final headers = {'Content-Type': 'application/json', 'Authorization': 'Bearer $token'};
final payload = {/* TODO: request body */};
final res = await http.put(uri, headers: headers, body: jsonEncode(payload));
final data = jsonDecode(res.body) as Map<String, dynamic>;
if (res.statusCode >= 400) { /* handle error */ }
```

#### Settings Security

<span style="color:#6A1B9A"><strong>PUT</strong></span> https://sumacademy.net/api/admin/settings/security

**Description:** Replace data for this resource.

**Authentication:** Required

**Role required:** admin

**Request Headers:**
- Content-Type: application/json
- Authorization: Bearer <Firebase ID Token>

**Path Parameters:**
- None

**Query Parameters:**
- None specified

**Request Body:**
```json
TBD (confirm request body with backend)
```

**Response Success (example):**
```json
{
  "success": true,
  "message": "OK",
  "data": {}
}
```

**Response Error (common):**
- 401: Token missing or invalid
- 403: Access denied wrong role
- 404: Resource not found
- 500: Server error

**Flutter/Dart Code Example:**
```dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:firebase_auth/firebase_auth.dart';

final baseUrl = 'https://sumacademy.net/api';
final uri = Uri.parse('$baseUrl/admin/settings/security');
final token = await FirebaseAuth.instance.currentUser?.getIdToken(true);
final headers = {'Content-Type': 'application/json', 'Authorization': 'Bearer $token'};
final payload = {/* TODO: request body */};
final res = await http.put(uri, headers: headers, body: jsonEncode(payload));
final data = jsonDecode(res.body) as Map<String, dynamic>;
if (res.statusCode >= 400) { /* handle error */ }
```

#### Settings Templates

<span style="color:#2E7D32"><strong>GET</strong></span> https://sumacademy.net/api/admin/settings/templates

**Description:** Retrieve data for this resource.

**Authentication:** Required

**Role required:** admin

**Request Headers:**
- Content-Type: application/json
- Authorization: Bearer <Firebase ID Token>

**Path Parameters:**
- None

**Query Parameters:**
- None specified

**Request Body:**
- None

**Response Success (example):**
```json
{
  "success": true,
  "message": "OK",
  "data": {}
}
```

**Response Error (common):**
- 401: Token missing or invalid
- 403: Access denied wrong role
- 404: Resource not found
- 500: Server error

**Flutter/Dart Code Example:**
```dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:firebase_auth/firebase_auth.dart';

final baseUrl = 'https://sumacademy.net/api';
final uri = Uri.parse('$baseUrl/admin/settings/templates');
final token = await FirebaseAuth.instance.currentUser?.getIdToken(true);
final headers = {'Content-Type': 'application/json', 'Authorization': 'Bearer $token'};
final res = await http.get(uri, headers: headers);
final data = jsonDecode(res.body) as Map<String, dynamic>;
if (res.statusCode >= 400) { /* handle error */ }
```

#### Settings Templates

<span style="color:#6A1B9A"><strong>PUT</strong></span> https://sumacademy.net/api/admin/settings/templates

**Description:** Replace data for this resource.

**Authentication:** Required

**Role required:** admin

**Request Headers:**
- Content-Type: application/json
- Authorization: Bearer <Firebase ID Token>

**Path Parameters:**
- None

**Query Parameters:**
- None specified

**Request Body:**
```json
TBD (confirm request body with backend)
```

**Response Success (example):**
```json
{
  "success": true,
  "message": "OK",
  "data": {}
}
```

**Response Error (common):**
- 401: Token missing or invalid
- 403: Access denied wrong role
- 404: Resource not found
- 500: Server error

**Flutter/Dart Code Example:**
```dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:firebase_auth/firebase_auth.dart';

final baseUrl = 'https://sumacademy.net/api';
final uri = Uri.parse('$baseUrl/admin/settings/templates');
final token = await FirebaseAuth.instance.currentUser?.getIdToken(true);
final headers = {'Content-Type': 'application/json', 'Authorization': 'Bearer $token'};
final payload = {/* TODO: request body */};
final res = await http.put(uri, headers: headers, body: jsonEncode(payload));
final data = jsonDecode(res.body) as Map<String, dynamic>;
if (res.statusCode >= 400) { /* handle error */ }
```


## PUBLIC APIs

#### Settings

<span style="color:#2E7D32"><strong>GET</strong></span> https://sumacademy.net/api/settings

**Description:** Retrieve data for this resource.

**Authentication:** Not required

**Role required:** none

**Request Headers:**
- Content-Type: application/json

**Path Parameters:**
- None

**Query Parameters:**
- None specified

**Request Body:**
- None

**Response Success (example):**
```json
{
  "success": true,
  "message": "OK",
  "data": {}
}
```

**Response Error (common):**
- 401: Token missing or invalid
- 403: Access denied wrong role
- 404: Resource not found
- 500: Server error

**Flutter/Dart Code Example:**
```dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:firebase_auth/firebase_auth.dart';

final baseUrl = 'https://sumacademy.net/api';
final uri = Uri.parse('$baseUrl/settings');
final headers = {'Content-Type': 'application/json'};
final res = await http.get(uri, headers: headers);
final data = jsonDecode(res.body) as Map<String, dynamic>;
if (res.statusCode >= 400) { /* handle error */ }
```

#### Verify By Certid

<span style="color:#2E7D32"><strong>GET</strong></span> https://sumacademy.net/api/verify/:certId

**Description:** Retrieve data for this resource.

**Authentication:** Not required

**Role required:** none

**Request Headers:**
- Content-Type: application/json

**Path Parameters:**
- `certId` (string, required)

**Query Parameters:**
- None specified

**Request Body:**
- None

**Response Success (example):**
```json
{
  "success": true,
  "message": "OK",
  "data": {}
}
```

**Response Error (common):**
- 401: Token missing or invalid
- 403: Access denied wrong role
- 404: Resource not found
- 500: Server error

**Flutter/Dart Code Example:**
```dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:firebase_auth/firebase_auth.dart';

final baseUrl = 'https://sumacademy.net/api';
final uri = Uri.parse('$baseUrl/verify/:certId');
final headers = {'Content-Type': 'application/json'};
final res = await http.get(uri, headers: headers);
final data = jsonDecode(res.body) as Map<String, dynamic>;
if (res.statusCode >= 400) { /* handle error */ }
```

#### Courses Explore

<span style="color:#2E7D32"><strong>GET</strong></span> https://sumacademy.net/api/courses/explore

**Description:** Retrieve data for this resource.

**Authentication:** Not required

**Role required:** none

**Request Headers:**
- Content-Type: application/json

**Path Parameters:**
- None

**Query Parameters:**
- None specified

**Request Body:**
- None

**Response Success (example):**
```json
{
  "success": true,
  "message": "OK",
  "data": {}
}
```

**Response Error (common):**
- 401: Token missing or invalid
- 403: Access denied wrong role
- 404: Resource not found
- 500: Server error

**Flutter/Dart Code Example:**
```dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:firebase_auth/firebase_auth.dart';

final baseUrl = 'https://sumacademy.net/api';
final uri = Uri.parse('$baseUrl/courses/explore');
final headers = {'Content-Type': 'application/json'};
final res = await http.get(uri, headers: headers);
final data = jsonDecode(res.body) as Map<String, dynamic>;
if (res.statusCode >= 400) { /* handle error */ }
```

#### Classes Catalog

<span style="color:#2E7D32"><strong>GET</strong></span> https://sumacademy.net/api/classes/catalog

**Description:** Retrieve data for this resource.

**Authentication:** Not required

**Role required:** none

**Request Headers:**
- Content-Type: application/json

**Path Parameters:**
- None

**Query Parameters:**
- None specified

**Request Body:**
- None

**Response Success (example):**
```json
{
  "success": true,
  "message": "OK",
  "data": {}
}
```

**Response Error (common):**
- 401: Token missing or invalid
- 403: Access denied wrong role
- 404: Resource not found
- 500: Server error

**Flutter/Dart Code Example:**
```dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:firebase_auth/firebase_auth.dart';

final baseUrl = 'https://sumacademy.net/api';
final uri = Uri.parse('$baseUrl/classes/catalog');
final headers = {'Content-Type': 'application/json'};
final res = await http.get(uri, headers: headers);
final data = jsonDecode(res.body) as Map<String, dynamic>;
if (res.statusCode >= 400) { /* handle error */ }
```

#### Classes Available

<span style="color:#2E7D32"><strong>GET</strong></span> https://sumacademy.net/api/classes/available

**Description:** Retrieve data for this resource.

**Authentication:** Not required

**Role required:** none

**Request Headers:**
- Content-Type: application/json

**Path Parameters:**
- None

**Query Parameters:**
- None specified

**Request Body:**
- None

**Response Success (example):**
```json
{
  "success": true,
  "message": "OK",
  "data": {}
}
```

**Response Error (common):**
- 401: Token missing or invalid
- 403: Access denied wrong role
- 404: Resource not found
- 500: Server error

**Flutter/Dart Code Example:**
```dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:firebase_auth/firebase_auth.dart';

final baseUrl = 'https://sumacademy.net/api';
final uri = Uri.parse('$baseUrl/classes/available');
final headers = {'Content-Type': 'application/json'};
final res = await http.get(uri, headers: headers);
final data = jsonDecode(res.body) as Map<String, dynamic>;
if (res.statusCode >= 400) { /* handle error */ }
```

#### Promo Codes Validate

<span style="color:#1565C0"><strong>POST</strong></span> https://sumacademy.net/api/promo-codes/validate

**Description:** Create or submit data for this resource.

**Authentication:** Not required

**Role required:** none

**Request Headers:**
- Content-Type: application/json

**Path Parameters:**
- None

**Query Parameters:**
- None specified

**Request Body:**
```json
{
  "code": "string (required)"
}
```

**Response Success (example):**
```json
{
  "success": true,
  "message": "OK",
  "data": {}
}
```

**Response Error (common):**
- 401: Token missing or invalid
- 403: Access denied wrong role
- 404: Resource not found
- 500: Server error

**Flutter/Dart Code Example:**
```dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:firebase_auth/firebase_auth.dart';

final baseUrl = 'https://sumacademy.net/api';
final uri = Uri.parse('$baseUrl/promo-codes/validate');
final headers = {'Content-Type': 'application/json'};
final payload = {/* TODO: request body */};
final res = await http.post(uri, headers: headers, body: jsonEncode(payload));
final data = jsonDecode(res.body) as Map<String, dynamic>;
if (res.statusCode >= 400) { /* handle error */ }
```

#### Health

<span style="color:#2E7D32"><strong>GET</strong></span> https://sumacademy.net/api/health

**Description:** Retrieve data for this resource.

**Authentication:** Not required

**Role required:** none

**Request Headers:**
- Content-Type: application/json

**Path Parameters:**
- None

**Query Parameters:**
- None specified

**Request Body:**
- None

**Response Success (example):**
```json
{
  "success": true,
  "message": "OK",
  "data": {}
}
```

**Response Error (common):**
- 401: Token missing or invalid
- 403: Access denied wrong role
- 404: Resource not found
- 500: Server error

**Flutter/Dart Code Example:**
```dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:firebase_auth/firebase_auth.dart';

final baseUrl = 'https://sumacademy.net/api';
final uri = Uri.parse('$baseUrl/health');
final headers = {'Content-Type': 'application/json'};
final res = await http.get(uri, headers: headers);
final data = jsonDecode(res.body) as Map<String, dynamic>;
if (res.statusCode >= 400) { /* handle error */ }
```
