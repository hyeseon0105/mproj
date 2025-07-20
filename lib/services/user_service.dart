import 'dart:convert';
import 'package:http/http.dart' as http;
<<<<<<< HEAD

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
=======
import 'package:shared_preferences/shared_preferences.dart';

class UserService {
  static const String baseUrl = 'http://localhost:8000/api/auth'; // 백엔드 서버 URL
  
  // 사용자 프로필 정보 조회
  static Future<Map<String, dynamic>> getUserProfile() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('access_token');
      
      if (token == null) {
        // 토큰이 없으면 저장된 사용자 정보 반환
        final username = prefs.getString('username') ?? '사용자';
        final birthday = prefs.getString('birthday');
        
        return {
          'username': username,
          'birthday': birthday ?? '',
          'email': prefs.getString('email') ?? '',
          'id': prefs.getString('user_id') ?? '',
        };
      }
      
      final response = await http.get(
        Uri.parse('$baseUrl/user/profile'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );
      
      if (response.statusCode == 200) {
        final userData = json.decode(response.body);
        
        // 성공적으로 가져온 데이터를 SharedPreferences에 저장
        await prefs.setString('username', userData['username'] ?? '사용자');
        await prefs.setString('email', userData['email'] ?? '');
        await prefs.setString('user_id', userData['id']?.toString() ?? '');
        if (userData['birthday'] != null) {
          await prefs.setString('birthday', userData['birthday']);
        }
        
        return userData;
      } else if (response.statusCode == 401) {
        // 인증 실패 시 저장된 토큰 삭제
        await prefs.remove('access_token');
        throw Exception('인증이 만료되었습니다. 다시 로그인해주세요.');
      } else {
        throw Exception('프로필 조회 실패: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('프로필 조회 중 오류 발생: $e');
    }
  }
  
  // 사용자 프로필 정보 수정
  static Future<Map<String, dynamic>> updateUserProfile({
    String? username,
    String? password,
    String? email,
    String? birthday,
  }) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('access_token');
      
      if (token == null) {
        // 토큰이 없으면 로컬에만 저장
        if (username != null) await prefs.setString('username', username);
        if (email != null) await prefs.setString('email', email);
        if (birthday != null) await prefs.setString('birthday', birthday);
        
        return {
          'message': '프로필이 로컬에 저장되었습니다 (서버 동기화 불가)',
          'user': {
            'username': username ?? prefs.getString('username') ?? '사용자',
            'email': email ?? prefs.getString('email') ?? '',
            'birthday': birthday ?? prefs.getString('birthday') ?? '',
          }
        };
      }
      
      final Map<String, dynamic> updateData = {};
      if (username != null) updateData['username'] = username;
      if (password != null) updateData['password'] = password;
      if (email != null) updateData['email'] = email;
      if (birthday != null) updateData['birthday'] = birthday;
      
      final response = await http.put(
        Uri.parse('$baseUrl/user/profile'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: json.encode(updateData),
      );
      
      if (response.statusCode == 200) {
        final result = json.decode(response.body);
        
        // 성공적으로 수정된 데이터를 로컬에도 저장
        if (username != null) await prefs.setString('username', username);
        if (email != null) await prefs.setString('email', email);
        if (birthday != null) await prefs.setString('birthday', birthday);
        
        return result;
      } else if (response.statusCode == 401) {
        // 인증 실패 시 저장된 토큰 삭제
        await prefs.remove('access_token');
        throw Exception('인증이 만료되었습니다. 다시 로그인해주세요.');
      } else {
        throw Exception('프로필 수정 실패: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('프로필 수정 중 오류 발생: $e');
    }
  }
  
  // 생일 문자열을 DateTime으로 변환
  static DateTime? parseBirthday(String? birthdayStr) {
    if (birthdayStr == null || birthdayStr.isEmpty) return null;
    try {
      return DateTime.parse(birthdayStr);
    } catch (e) {
      return null;
    }
  }
  
  // DateTime을 생일 문자열로 변환 (YYYY-MM-DD 형식)
  static String formatBirthday(DateTime? birthday) {
    if (birthday == null) return '';
    return '${birthday.year}-${birthday.month.toString().padLeft(2, '0')}-${birthday.day.toString().padLeft(2, '0')}';
  }
>>>>>>> origin/main
} 