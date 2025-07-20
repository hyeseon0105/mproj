import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
<<<<<<< HEAD
import '../models/app_state.dart';

class DiaryService {
<<<<<<< HEAD
  static const String baseUrl = 'http://10.0.2.2:8000'; // FastAPI 서버 주소 (Android 에뮬레이터용)
=======
import 'package:shared_preferences/shared_preferences.dart';
import '../models/app_state.dart';

class DiaryService {
  static const String baseUrl = 'http://localhost:8000'; // FastAPI 서버 주소

  // 인증 토큰 가져오기
  static Future<String?> _getAuthToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('access_token');
  }
>>>>>>> origin/main
=======
  static const String baseUrl = 'http://192.168.43.129:8000'; // FastAPI 서버 주소 (실제 안드로이드 폰용)
>>>>>>> ec3101fac74b54c58bff6fbb00dcf6d5e01fc55e

  Future<String> createDiary({
    required String content,
    required Emotion emotion,
    List<String>? images,
  }) async {
    try {
      print('일기 저장 API 호출 시작');
<<<<<<< HEAD
=======
      
      // 인증 토큰 가져오기
      final token = await _getAuthToken();
      if (token == null) {
        throw Exception('로그인이 필요합니다');
      }
      
>>>>>>> origin/main
      final response = await http.post(
        Uri.parse('$baseUrl/api/posts/'),
        headers: {
          'Content-Type': 'application/json',
<<<<<<< HEAD
=======
          'Authorization': 'Bearer $token',
>>>>>>> origin/main
        },
        body: jsonEncode({
          'content': content,
          'status': 'published',
          'images': images ?? [],
        }),
      );

      print('API 응답 상태 코드: ${response.statusCode}');
      print('API 응답 내용: ${response.body}');

      if (response.statusCode == 201) {
        final data = jsonDecode(response.body);
        return data['post_id'];
<<<<<<< HEAD
=======
      } else if (response.statusCode == 401) {
        throw Exception('인증이 만료되었습니다. 다시 로그인해주세요.');
>>>>>>> origin/main
      } else {
        throw Exception('일기 저장에 실패했습니다: ${response.body}');
      }
    } catch (e) {
      print('API 호출 중 에러 발생: $e');
      throw Exception('일기 저장 중 오류가 발생했습니다: $e');
    }
  }

  Future<Map<String, dynamic>?> getDiaryByDate(String date) async {
    try {
      print('일기 조회 API 호출 시작: $date');
<<<<<<< HEAD
=======
      
      // 인증 토큰 가져오기
      final token = await _getAuthToken();
      if (token == null) {
        throw Exception('로그인이 필요합니다');
      }
      
>>>>>>> origin/main
      final response = await http.get(
        Uri.parse('$baseUrl/api/posts/date/$date'),
        headers: {
          'Content-Type': 'application/json',
<<<<<<< HEAD
=======
          'Authorization': 'Bearer $token',
>>>>>>> origin/main
        },
      );

      print('API 응답 상태 코드: ${response.statusCode}');
      print('API 응답 내용: ${response.body}');

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        if (data.isNotEmpty) {
          // 해당 날짜의 첫 번째 일기 반환
          return {
            'content': data[0]['content'],
            'images': List<String>.from(data[0]['images'].map((img) => img['file_path'])),
            'created_at': data[0]['created_at'],
          };
        }
        return null; // 해당 날짜의 일기가 없음
<<<<<<< HEAD
=======
      } else if (response.statusCode == 401) {
        throw Exception('인증이 만료되었습니다. 다시 로그인해주세요.');
>>>>>>> origin/main
      } else {
        throw Exception('일기 조회에 실패했습니다: ${response.body}');
      }
    } catch (e) {
      print('API 호출 중 에러 발생: $e');
      throw Exception('일기 조회 중 오류가 발생했습니다: $e');
    }
  }
<<<<<<< HEAD
<<<<<<< HEAD
=======

  Future<List<Map<String, dynamic>>> getAllDiaries() async {
    try {
      print('모든 일기 조회 API 호출 시작');
      
      // 인증 토큰 가져오기
      final token = await _getAuthToken();
      if (token == null) {
        throw Exception('로그인이 필요합니다');
      }
      
      final response = await http.get(
        Uri.parse('$baseUrl/api/posts/'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      print('API 응답 상태 코드: ${response.statusCode}');
      print('API 응답 내용: ${response.body}');

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return data.cast<Map<String, dynamic>>();
      } else if (response.statusCode == 401) {
        throw Exception('인증이 만료되었습니다. 다시 로그인해주세요.');
      } else {
        throw Exception('일기 목록 조회에 실패했습니다: ${response.body}');
      }
    } catch (e) {
      print('API 호출 중 에러 발생: $e');
      throw Exception('일기 목록 조회 중 오류가 발생했습니다: $e');
    }
  }
>>>>>>> origin/main
=======

  /// 이미지 업로드
  Future<String> uploadImage(File imageFile) async {
    try {
      print('이미지 업로드 API 호출 시작');
      
      // multipart 요청 생성
      var request = http.MultipartRequest(
        'POST',
        Uri.parse('$baseUrl/api/posts/upload-image'),
      );

      // 파일 추가
      request.files.add(
        await http.MultipartFile.fromPath(
          'file',
          imageFile.path,
        ),
      );

      final response = await request.send();
      final responseBody = await response.stream.bytesToString();

      print('이미지 업로드 API 응답 상태 코드: ${response.statusCode}');
      print('이미지 업로드 API 응답 내용: $responseBody');

      if (response.statusCode == 200) {
        final data = jsonDecode(responseBody);
        return data['filename'];
      } else {
        throw Exception('이미지 업로드에 실패했습니다: $responseBody');
      }
    } catch (e) {
      print('이미지 업로드 API 호출 중 에러 발생: $e');
      throw Exception('이미지 업로드 중 오류가 발생했습니다: $e');
    }
  }

  /// 이미지 삭제
  Future<bool> deleteImage(String filename) async {
    try {
      print('이미지 삭제 API 호출 시작: $filename');
      
      final response = await http.delete(
        Uri.parse('$baseUrl/api/posts/delete-image/$filename'),
        headers: {
          'Content-Type': 'application/json',
        },
      );

      print('이미지 삭제 API 응답 상태 코드: ${response.statusCode}');
      print('이미지 삭제 API 응답 내용: ${response.body}');

      return response.statusCode == 200;
    } catch (e) {
      print('이미지 삭제 API 호출 중 에러 발생: $e');
      return false;
    }
  }
>>>>>>> ec3101fac74b54c58bff6fbb00dcf6d5e01fc55e
} 