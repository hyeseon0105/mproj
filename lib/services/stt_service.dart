import 'dart:io';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:path/path.dart' as path;

class STTService {
  static const String _baseUrl = 'http://192.168.0.12:5001';
  
  /// 오디오 파일을 텍스트로 변환
  static Future<STTResult> transcribeAudio(File audioFile, {String language = 'ko'}) async {
    try {
      // multipart request 생성
      var request = http.MultipartRequest(
        'POST',
        Uri.parse('$_baseUrl/stt/transcribe'),
      );

      // 오디오 파일 추가
      request.files.add(
        await http.MultipartFile.fromPath(
          'audio',
          audioFile.path,
        ),
      );

      // 언어 설정 추가
      request.fields['language'] = language;

      // 요청 전송
      var response = await request.send();
      var responseData = await response.stream.bytesToString();
      var jsonData = json.decode(responseData);

      if (response.statusCode == 200) {
        return STTResult.fromJson(jsonData);
      } else {
        throw STTException(jsonData['error'] ?? 'STT 변환에 실패했습니다.');
      }
    } catch (e) {
      if (e is STTException) {
        rethrow;
      }
      throw STTException('네트워크 오류: ${e.toString()}');
    }
  }

  /// 오디오 청크를 텍스트로 변환 (실시간용)
  static Future<STTResult> transcribeAudioChunk(File audioFile, {String language = 'ko'}) async {
    try {
      // multipart request 생성
      var request = http.MultipartRequest(
        'POST',
        Uri.parse('$_baseUrl/stt/transcribe-chunk'),
      );

      // 오디오 파일 추가
      request.files.add(
        await http.MultipartFile.fromPath(
          'audio',
          audioFile.path,
        ),
      );

      // 언어 설정 추가
      request.fields['language'] = language;

      // 요청 전송
      var response = await request.send();
      var responseData = await response.stream.bytesToString();
      var jsonData = json.decode(responseData);

      if (response.statusCode == 200) {
        return STTResult.fromJson(jsonData);
      } else {
        throw STTException(jsonData['error'] ?? 'STT 청크 변환에 실패했습니다.');
      }
    } catch (e) {
      if (e is STTException) {
        rethrow;
      }
      throw STTException('네트워크 오류: ${e.toString()}');
    }
  }

  /// 서비스 상태 확인
  static Future<Map<String, dynamic>> healthCheck() async {
    try {
      final response = await http.get(Uri.parse('$_baseUrl/stt/health'));
      
      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw STTException('서비스 상태 확인에 실패했습니다.');
      }
    } catch (e) {
      throw STTException('서비스 연결 오류: ${e.toString()}');
    }
  }

  /// 지원하는 언어 목록 가져오기
  static Future<Map<String, String>> getSupportedLanguages() async {
    try {
      final response = await http.get(Uri.parse('$_baseUrl/stt/supported-languages'));
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return Map<String, String>.from(data['languages']);
      } else {
        throw STTException('언어 목록을 가져오는데 실패했습니다.');
      }
    } catch (e) {
      throw STTException('언어 목록 조회 오류: ${e.toString()}');
    }
  }
}

/// STT 결과를 담는 클래스
class STTResult {
  final bool success;
  final String text;
  final String language;
  final double duration;
  final List<STTSegment> segments;
  final String timestamp;

  STTResult({
    required this.success,
    required this.text,
    required this.language,
    required this.duration,
    required this.segments,
    required this.timestamp,
  });

  factory STTResult.fromJson(Map<String, dynamic> json) {
    return STTResult(
      success: json['success'] ?? false,
      text: json['text'] ?? '',
      language: json['language'] ?? 'ko',
      duration: (json['duration'] ?? 0).toDouble(),
      segments: (json['segments'] as List<dynamic>?)
          ?.map((segment) => STTSegment.fromJson(segment))
          .toList() ?? [],
      timestamp: json['timestamp'] ?? '',
    );
  }

  @override
  String toString() {
    return 'STTResult(success: $success, text: $text, language: $language, duration: $duration)';
  }
}

/// STT 세그먼트 정보
class STTSegment {
  final int id;
  final double start;
  final double end;
  final String text;
  final double confidence;

  STTSegment({
    required this.id,
    required this.start,
    required this.end,
    required this.text,
    required this.confidence,
  });

  factory STTSegment.fromJson(Map<String, dynamic> json) {
    return STTSegment(
      id: json['id'] ?? 0,
      start: (json['start'] ?? 0).toDouble(),
      end: (json['end'] ?? 0).toDouble(),
      text: json['text'] ?? '',
      confidence: (json['confidence'] ?? 0).toDouble(),
    );
  }
}

/// STT 관련 예외 클래스
class STTException implements Exception {
  final String message;

  STTException(this.message);

  @override
  String toString() => 'STTException: $message';
} 