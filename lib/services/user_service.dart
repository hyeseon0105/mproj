import 'dart:convert';
import 'package:http/http.dart' as http;

class UserService {
  static const String baseUrl = 'http://10.0.2.2:8000/api';

  // 사용자 생일 정보 업데이트
  static Future<bool> updateUserBirthday(String userId, DateTime birthday) async {
    try {
      final response = await http.put(
        Uri.parse('$baseUrl/auth/users/$userId'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'birthday': '${birthday.year}-${birthday.month.toString().padLeft(2, '0')}-${birthday.day.toString().padLeft(2, '0')}',
        }),
      );

      if (response.statusCode == 200) {
        print('생일 정보 업데이트 성공');
        return true;
      } else {
        print('생일 정보 업데이트 실패: ${response.statusCode}');
        return false;
      }
    } catch (e) {
      print('생일 정보 업데이트 중 오류: $e');
      return false;
    }
  }

  // 사용자 정보 조회
  static Future<Map<String, dynamic>?> getUserInfo(String userId) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/auth/users/$userId'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data;
      } else {
        print('사용자 정보 조회 실패: ${response.statusCode}');
        return null;
      }
    } catch (e) {
      print('사용자 정보 조회 중 오류: $e');
      return null;
    }
  }
} 