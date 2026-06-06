import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class ApiService {
  static const String baseUrl = 'http://192.168.1.5:5004/api';

  // ── حفظ التوكن
  static Future<void> saveToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('token', token);
  }

  // ── حفظ الـ Role
  static Future<void> saveRole(String role) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('role', role);
  }

  // ── جيب التوكن
  static Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('token');
  }

  // ── Headers مع التوكن
  static Future<Map<String, String>> getHeaders() async {
    final token = await getToken();
    return {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    };
  }

  // ── تسجيل الدخول
  static Future<Map<String, dynamic>> login(
    String email,
    String password,
  ) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/Auth/login'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'email': email, 'password': password}),
      );
      final data = jsonDecode(response.body);
      if (response.statusCode == 200) {
        await saveToken(data['token']);
        await saveRole(data['role']);

        return {'success': true, 'role': data['role'], 'name': data['name']};
      }
      return {
        'success': false,
        'message': data['message'] ?? 'خطأ بتسجيل الدخول',
      };
    } catch (e) {
      return {'success': false, 'message': 'تعذر الاتصال بالسيرفر'};
    }
  }

  // ── تسجيل متبرع
  static Future<Map<String, dynamic>> registerDonor({
    required String fullName,
    required String email,
    required String password,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/Donor/register'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'fullName': fullName,
          'email': email,
          'password': password,
        }),
      );

      // ✅ طباعة للتشخيص
      debugPrint('Status: ${response.statusCode}');
      debugPrint('Body: ${response.body}');

      if (response.statusCode == 200) return {'success': true};

      // ✅ محاولة decode آمنة
      try {
        final data = jsonDecode(response.body);
        return {
          'success': false,
          'message': data['message'] ?? data['title'] ?? 'خطأ بالتسجيل',
        };
      } catch (_) {
        return {'success': false, 'message': response.body};
      }
    } catch (e) {
      return {'success': false, 'message': 'تعذر الاتصال بالسيرفر'};
    }
  }

  // ── تسجيل مستشفى
  static Future<Map<String, dynamic>> registerHospital({
    required String hospitalName,
    required String licenseNumber,
    required String email,
    required String password,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/Hospital/register'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'hospitalName': hospitalName,
          'licenseNumber': licenseNumber,
          'email': email,
          'password': password,
        }),
      );
      final data = jsonDecode(response.body);
      if (response.statusCode == 200) return {'success': true};
      return {'success': false, 'message': data['message'] ?? 'خطأ بالتسجيل'};
    } catch (e) {
      return {'success': false, 'message': 'تعذر الاتصال بالسيرفر'};
    }
  }

  // ── تسجيل بيانات التبرع + الأعضاء
  static Future<Map<String, dynamic>> applyDonor({
    required String fullName,
    required String email,
    required String nationalId,
    required String bloodType,
    required String dateOfBirth,
    required String address,
    required String phoneNumber,
    required List<String> organs,
    String? medicalConditions,
  }) async {
    try {
      final headers = await getHeaders();
      final body = {
        'fullName': fullName,
        'email': email,
        'nationalId': nationalId,
        'bloodType': bloodType,
        'dateOfBirth': dateOfBirth,
        'address': address,
        'phoneNumber': phoneNumber,
        'organsToDonat': organs,
        'medicalConditions': medicalConditions,
      };

      final response = await http.post(
        Uri.parse('$baseUrl/Donor/apply'),
        headers: headers,
        body: jsonEncode(body),
      );

      final data = jsonDecode(response.body);
      if (response.statusCode == 200) return {'success': true};
      if (response.statusCode == 400 &&
          (data['message'] as String?)?.contains('already submitted') == true) {
        return {'success': false, 'alreadyRegistered': true};
      }

      return {'success': false, 'message': data['message'] ?? 'خطأ بالتسجيل'};
    } catch (e) {
      return {'success': false, 'message': 'تعذر الاتصال بالسيرفر'};
    }
  }

  // ── رفع السجل الطبي
  static Future<Map<String, dynamic>> uploadMedicalReport(
    File? file, {
    Uint8List? webBytes,
    String? fileName,
  }) async {
    try {
      final token = await getToken();
      final request = http.MultipartRequest(
        'POST',
        Uri.parse('$baseUrl/Donor/upload-medical-report'),
      );
      request.headers['Authorization'] = 'Bearer $token';

      if (kIsWeb) {
        if (webBytes == null) {
          return {'success': false, 'message': 'لا يوجد ملف'};
        }
        request.files.add(
          http.MultipartFile.fromBytes(
            'file',
            webBytes,
            filename: fileName ?? 'medical_report',
          ),
        );
      } else {
        if (file == null) {
          return {'success': false, 'message': 'لا يوجد ملف'};
        }
        request.files.add(await http.MultipartFile.fromPath('file', file.path));
      }

      final response = await request.send();
      if (response.statusCode == 200) return {'success': true};
      return {'success': false, 'message': 'فشل رفع الملف'};
    } catch (e) {
      return {'success': false, 'message': 'تعذر الاتصال بالسيرفر'};
    }
  }

  // ── تسجيل مريض محتاج (من المستشفى)
  static Future<Map<String, dynamic>> addPatientNeed({
    required String patientName,
    required String bloodType,
    required String neededOrgan,
    required String nationalId,
  }) async {
    try {
      final headers = await getHeaders();
      final response = await http.post(
        Uri.parse('$baseUrl/PatientNeeds'),
        headers: headers,
        body: jsonEncode({
          'patientName': patientName,
          'bloodType': bloodType,
          'neededOrgan': neededOrgan,
          'nationalId': nationalId,
        }),
      );
      final data = jsonDecode(response.body);
      if (response.statusCode == 200) return {'success': true};
      return {'success': false, 'message': data['message'] ?? 'خطأ'};
    } catch (e) {
      return {'success': false, 'message': 'تعذر الاتصال بالسيرفر'};
    }
  }

  // ── داشبورد المستشفى
  static Future<Map<String, dynamic>> getHospitalDashboard() async {
    try {
      final headers = await getHeaders();
      final response = await http.get(
        Uri.parse('$baseUrl/Hospital/dashboard'),
        headers: headers,
      );
      if (response.statusCode == 200) {
        return {'success': true, 'data': jsonDecode(response.body)};
      }
      return {'success': false, 'message': 'فشل جلب البيانات'};
    } catch (e) {
      return {'success': false, 'message': 'تعذر الاتصال بالسيرفر'};
    }
  }

  // ── البحث عن متبرع بالرقم الوطني
  static Future<Map<String, dynamic>> searchDonorByNationalId(
    String nationalId,
  ) async {
    try {
      final headers = await getHeaders();
      final response = await http.get(
        Uri.parse('$baseUrl/Donor/search?nationalId=$nationalId'),
        headers: headers,
      );
      if (response.statusCode == 200) {
        return {'success': true, 'data': jsonDecode(response.body)};
      } else if (response.statusCode == 401) {
        return {
          'success': false,
          'message': 'غير مصرح — تحقق من التوكن أو الصلاحية',
        };
      } else if (response.statusCode == 403) {
        return {'success': false, 'message': 'ليس لديك صلاحية للبحث'};
      } else if (response.statusCode == 404) {
        return {
          'success': false,
          'message': 'لا يوجد متبرع مسجل بهذا الرقم الوطني',
        };
      }
      return {'success': false, 'message': 'خطأ: ${response.statusCode}'};
    } catch (e) {
      return {'success': false, 'message': 'تعذر الاتصال بالسيرفر'};
    }
  }

  // ── تعليم المتبرع كمتوفى + رفع شهادة الوفاة
  static Future<Map<String, dynamic>> markDonorAsDeceased({
    required String nationalId,
    File? deathCertFile,
    Uint8List? webBytes,
    String? fileName,
  }) async {
    try {
      final token = await getToken();
      final request = http.MultipartRequest(
        'POST',
        Uri.parse('$baseUrl/Donor/mark-deceased'),
      );
      request.headers['Authorization'] = 'Bearer $token';
      request.fields['nationalId'] = nationalId;

      if (kIsWeb) {
        if (webBytes == null)
          return {'success': false, 'message': 'لا يوجد ملف'};
        request.files.add(
          http.MultipartFile.fromBytes(
            'deathCertificate',
            webBytes,
            filename: fileName ?? 'death_certificate',
          ),
        );
      } else {
        if (deathCertFile == null)
          return {'success': false, 'message': 'لا يوجد ملف'};
        request.files.add(
          await http.MultipartFile.fromPath(
            'deathCertificate',
            deathCertFile.path,
          ),
        );
      }

      final response = await request.send();
      final body = await response.stream.bytesToString();
      if (response.statusCode == 200) return {'success': true};
      try {
        final data = jsonDecode(body);
        return {
          'success': false,
          'message': data['message'] ?? 'فشل تسجيل الوفاة',
        };
      } catch (_) {
        return {'success': false, 'message': 'فشل تسجيل الوفاة - $body'};
      }
    } catch (e) {
      return {'success': false, 'message': 'تعذر الاتصال بالسيرفر: $e'};
    }
  }

  // ════════════════════════════════════════
  // ── وزارة — Ministry endpoints
  // ════════════════════════════════════════

  // ── إحصائيات الداشبورد
  static Future<Map<String, dynamic>> getMinistryStats() async {
    try {
      final headers = await getHeaders();
      final response = await http.get(
        Uri.parse('$baseUrl/Ministry/dashboard/stats'),
        headers: headers,
      );
      if (response.statusCode == 200) {
        return {'success': true, 'data': jsonDecode(response.body)};
      }
      return {'success': false, 'message': 'فشل جلب الإحصائيات'};
    } catch (e) {
      return {'success': false, 'message': 'تعذر الاتصال بالسيرفر'};
    }
  }

  // ── طلبات المستشفيات المعلقة
  static Future<Map<String, dynamic>> getMinistryHospitalRequests() async {
    try {
      final headers = await getHeaders();
      final response = await http.get(
        Uri.parse('$baseUrl/Ministry/hospitals'),
        headers: headers,
      );
      if (response.statusCode == 200) {
        return {'success': true, 'data': jsonDecode(response.body)};
      }
      return {'success': false, 'message': 'فشل جلب الطلبات'};
    } catch (e) {
      return {'success': false, 'message': 'تعذر الاتصال بالسيرفر'};
    }
  }

  // ── طلبات المتبرعين المعلقة
  static Future<Map<String, dynamic>> getMinistryDonorRequests() async {
    try {
      final headers = await getHeaders();
      final response = await http.get(
        Uri.parse('$baseUrl/Ministry/donors'),
        headers: headers,
      );
      if (response.statusCode == 200) {
        return {'success': true, 'data': jsonDecode(response.body)};
      }
      return {'success': false, 'message': 'فشل جلب الطلبات'};
    } catch (e) {
      return {'success': false, 'message': 'تعذر الاتصال بالسيرفر'};
    }
  }

  static Future<Map<String, dynamic>> ministryApproveHospital(int id) async {
    try {
      final headers = await getHeaders();
      final response = await http.put(
        Uri.parse('$baseUrl/Ministry/hospitals/approve/$id'),
        headers: headers,
      );
      if (response.statusCode == 200) return {'success': true};
      return {'success': false, 'message': 'فشل القبول'};
    } catch (e) {
      return {'success': false, 'message': 'تعذر الاتصال بالسيرفر'};
    }
  }

  static Future<Map<String, dynamic>> ministryRejectHospital(
    int id,
    String reason,
  ) async {
    try {
      final headers = await getHeaders();
      final response = await http.put(
        Uri.parse('$baseUrl/Ministry/hospitals/reject/$id'),
        headers: headers,
        body: jsonEncode({'reason': reason}),
      );
      if (response.statusCode == 200) return {'success': true};
      return {'success': false, 'message': 'فشل الرفض'};
    } catch (e) {
      return {'success': false, 'message': 'تعذر الاتصال بالسيرفر'};
    }
  }

  static Future<Map<String, dynamic>> ministryApproveDonor(int id) async {
    try {
      final headers = await getHeaders();
      final response = await http.put(
        Uri.parse('$baseUrl/Ministry/donors/approve/$id'),
        headers: headers,
      );
      if (response.statusCode == 200) return {'success': true};
      return {'success': false, 'message': 'فشل القبول'};
    } catch (e) {
      return {'success': false, 'message': 'تعذر الاتصال بالسيرفر'};
    }
  }

  static Future<Map<String, dynamic>> ministryRejectDonor(
    int id,
    String reason,
  ) async {
    try {
      final headers = await getHeaders();
      final response = await http.put(
        Uri.parse('$baseUrl/Ministry/donors/reject/$id'),
        headers: headers,
        body: jsonEncode({'reason': reason}),
      );
      if (response.statusCode == 200) return {'success': true};
      return {'success': false, 'message': 'فشل الرفض'};
    } catch (e) {
      return {'success': false, 'message': 'تعذر الاتصال بالسيرفر'};
    }
  }

  /// يتحقق إذا المستخدم الحالي عنده طلب تبرع مسجل.
  /// يرجع:
  ///   { 'exists': true,  'donor': { id, fullName, bloodType, address, status, registeredAt, organs: [...] } }
  ///   { 'exists': false }
  ///   { 'exists': false, 'error': '...' }   ← عند فشل الـ call
  // استبدل الـ getDonorStatus الموجود بهاد:

  static Future<Map<String, dynamic>> getDonorStatus() async {
    try {
      final headers =
          await getHeaders(); // نفس الدالة اللي بتستخدمها بقية الـ methods

      final response = await http.get(
        Uri.parse(
          '$baseUrl/Donor/my-status',
        ), // baseUrl = '.../api' مش لازم تضيف /api مرة ثانية
        headers: headers,
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return {
          'exists': true,
          'donor': {
            'id': data['id']?.toString() ?? '',
            'fullName': data['fullName'] ?? '',
            'bloodType': data['bloodType'] ?? '',
            'address': data['address'] ?? '',
            'status': data['status'] ?? 'Pending',
            'registeredAt': data['registeredAt'] ?? '',
            'organs': List<String>.from(data['organs'] ?? []),
          },
        };
      }

      if (response.statusCode == 404) {
        return {'exists': false};
      }

      return {'exists': false, 'error': 'status ${response.statusCode}'};
    } catch (e) {
      return {'exists': false, 'error': e.toString()};
    }
  }
}
