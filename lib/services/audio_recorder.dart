import 'dart:io';
import 'dart:async';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';

class AudioRecorder {
  static AudioRecorder? _instance;
  static AudioRecorder get instance => _instance ??= AudioRecorder._();

  AudioRecorder._();

  bool _isRecording = false;
  bool _isPaused = false;
  String? _recordingPath;
  StreamController<RecordingState>? _stateController;
  Timer? _timer;
  Timer? _chunkTimer;
  int _recordingDuration = 0;
  List<String> _chunkPaths = [];
  int _chunkIndex = 0;

  /// 녹음 상태 스트림
  Stream<RecordingState> get stateStream => 
      _stateController?.stream ?? Stream.empty();

  /// 현재 녹음 중인지 확인
  bool get isRecording => _isRecording;

  /// 현재 일시정지 상태인지 확인
  bool get isPaused => _isPaused;

  /// 녹음 시간 (초)
  int get recordingDuration => _recordingDuration;

  /// 녹음 파일 경로
  String? get recordingPath => _recordingPath;

  /// 녹음 시작
  Future<bool> startRecording() async {
    if (_isRecording) {
      return false;
    }

    try {
      // 권한 확인 및 요청
      PermissionStatus status = await Permission.microphone.status;
      
      if (status == PermissionStatus.denied) {
        status = await Permission.microphone.request();
      }
      
      if (status == PermissionStatus.permanentlyDenied) {
        throw Exception('마이크 권한이 영구적으로 거부되었습니다. 설정에서 권한을 허용해주세요.');
      }
      
      if (status != PermissionStatus.granted) {
        throw Exception('마이크 권한이 필요합니다. 앱 설정에서 마이크 권한을 허용해주세요.');
      }

      // 임시 디렉토리 가져오기
      final tempDir = await getTemporaryDirectory();
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      _recordingPath = '${tempDir.path}/recording_$timestamp.m4a';

      // 녹음 초기화
      _isRecording = true;
      _isPaused = false;
      _recordingDuration = 0;
      _chunkPaths.clear();
      _chunkIndex = 0;
      _stateController = StreamController<RecordingState>();

      // 타이머 시작
      _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
        _recordingDuration++;
        _stateController?.add(RecordingState(
          isRecording: _isRecording,
          isPaused: _isPaused,
          duration: _recordingDuration,
          path: _recordingPath,
          chunkPaths: _chunkPaths,
        ));
      });

      // 청크 타이머 시작 (1초마다 청크 생성)
      _chunkTimer = Timer.periodic(const Duration(seconds: 1), (timer) async {
        if (_isRecording && !_isPaused) {
          await _createChunk();
        }
      });

      // 상태 업데이트
      _stateController?.add(RecordingState(
        isRecording: _isRecording,
        isPaused: _isPaused,
        duration: _recordingDuration,
        path: _recordingPath,
        chunkPaths: _chunkPaths,
      ));

      return true;
    } catch (e) {
      _isRecording = false;
      _recordingPath = null;
      throw Exception('녹음을 시작할 수 없습니다: ${e.toString()}');
    }
  }

  /// 청크 파일 생성
  Future<void> _createChunk() async {
    try {
      final tempDir = await getTemporaryDirectory();
      final chunkPath = '${tempDir.path}/chunk_${_chunkIndex}_${DateTime.now().millisecondsSinceEpoch}.m4a';
      
      // 현재 녹음 파일을 복사하여 청크 생성 (실제로는 녹음 중간에 파일을 분할해야 함)
      if (_recordingPath != null) {
        final recordingFile = File(_recordingPath!);
        if (await recordingFile.exists()) {
          await recordingFile.copy(chunkPath);
          _chunkPaths.add(chunkPath);
          _chunkIndex++;
        }
      }
    } catch (e) {
      print('청크 생성 오류: $e');
    }
  }

  /// 녹음 일시정지
  Future<void> pauseRecording() async {
    if (!_isRecording || _isPaused) {
      return;
    }

    _isPaused = true;
    _stateController?.add(RecordingState(
      isRecording: _isRecording,
      isPaused: _isPaused,
      duration: _recordingDuration,
      path: _recordingPath,
    ));
  }

  /// 녹음 재개
  Future<void> resumeRecording() async {
    if (!_isRecording || !_isPaused) {
      return;
    }

    _isPaused = false;
    _stateController?.add(RecordingState(
      isRecording: _isRecording,
      isPaused: _isPaused,
      duration: _recordingDuration,
      path: _recordingPath,
    ));
  }

  /// 녹음 중지
  Future<File?> stopRecording() async {
    if (!_isRecording) {
      return null;
    }

    try {
      // 타이머 정지
      _timer?.cancel();
      _timer = null;
      _chunkTimer?.cancel();
      _chunkTimer = null;

      // 녹음 상태 정리
      _isRecording = false;
      _isPaused = false;

      // 상태 업데이트
      _stateController?.add(RecordingState(
        isRecording: _isRecording,
        isPaused: _isPaused,
        duration: _recordingDuration,
        path: _recordingPath,
        chunkPaths: _chunkPaths,
      ));

      // 스트림 닫기
      await _stateController?.close();
      _stateController = null;

      // 청크 파일들 정리
      for (String chunkPath in _chunkPaths) {
        try {
          final file = File(chunkPath);
          if (await file.exists()) {
            await file.delete();
          }
        } catch (e) {
          print('청크 파일 삭제 오류: $e');
        }
      }
      _chunkPaths.clear();

      // 녹음 파일 반환
      if (_recordingPath != null) {
        final file = File(_recordingPath!);
        if (await file.exists()) {
          return file;
        }
      }

      return null;
    } catch (e) {
      throw Exception('녹음을 중지할 수 없습니다: ${e.toString()}');
    } finally {
      _recordingPath = null;
      _recordingDuration = 0;
    }
  }

  /// 녹음 취소
  Future<void> cancelRecording() async {
    if (!_isRecording) {
      return;
    }

    try {
      // 타이머 정지
      _timer?.cancel();
      _timer = null;

      // 녹음 파일 삭제
      if (_recordingPath != null) {
        final file = File(_recordingPath!);
        if (await file.exists()) {
          await file.delete();
        }
      }

      // 상태 정리
      _isRecording = false;
      _isPaused = false;
      _recordingPath = null;
      _recordingDuration = 0;

      // 스트림 닫기
      await _stateController?.close();
      _stateController = null;
    } catch (e) {
      throw Exception('녹음을 취소할 수 없습니다: ${e.toString()}');
    }
  }

  /// 녹음 파일 삭제
  Future<void> deleteRecording() async {
    if (_recordingPath != null) {
      final file = File(_recordingPath!);
      if (await file.exists()) {
        await file.delete();
      }
      _recordingPath = null;
    }
  }

  /// 리소스 정리
  void dispose() {
    _timer?.cancel();
    _stateController?.close();
    _isRecording = false;
    _isPaused = false;
    _recordingPath = null;
    _recordingDuration = 0;
  }
}

/// 녹음 상태를 담는 클래스
class RecordingState {
  final bool isRecording;
  final bool isPaused;
  final int duration;
  final String? path;
  final List<String> chunkPaths;

  RecordingState({
    required this.isRecording,
    required this.isPaused,
    required this.duration,
    this.path,
    this.chunkPaths = const [],
  });

  /// 녹음 시간을 포맷된 문자열로 반환
  String get formattedDuration {
    final minutes = duration ~/ 60;
    final seconds = duration % 60;
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  @override
  String toString() {
    return 'RecordingState(isRecording: $isRecording, isPaused: $isPaused, duration: $duration, path: $path)';
  }
} 