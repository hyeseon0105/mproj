import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter/foundation.dart';
<<<<<<< HEAD
import 'package:app_settings/app_settings.dart';
=======
>>>>>>> origin/main
import '../models/app_state.dart';
import '../theme.dart';
import '../ui/card.dart';
import '../ui/button.dart';
import 'dart:math';
import 'package:flutter/foundation.dart';
<<<<<<< HEAD
// import 'package:image_picker/image_picker.dart'; // 패키지가 없어서 주석 처리
import '../services/diary_service.dart';
import '../services/stt_service.dart';
import '../services/audio_recorder.dart';
import 'dart:io';
import 'dart:async';
import 'package:path_provider/path_provider.dart'; // 임시 파일 저장을 위한 패키지
import 'package:image_picker/image_picker.dart'; // 이미지 선택을 위한 패키지

=======
import '../services/diary_service.dart';
>>>>>>> origin/main
// dart:html은 웹에서만 사용 가능하므로 조건부 import

typedef SaveDiaryCallback = void Function(String entry, Emotion emotion, List<String>? images);

class EmotionChainItem {
  final String emoji;
  final Emotion type;

  EmotionChainItem({required this.emoji, required this.type});
}

class DiaryEntry extends StatefulWidget {
  final String selectedDate;
  final VoidCallback onBack;
  final SaveDiaryCallback onSave;
  final EmotionData? existingEntry;

  const DiaryEntry({
    super.key,
    required this.selectedDate,
    required this.onBack,
    required this.onSave,
    this.existingEntry,
  });

  @override
  State<DiaryEntry> createState() => _DiaryEntryState();
}

class _DiaryEntryState extends State<DiaryEntry> with TickerProviderStateMixin {
  late TextEditingController _entryController;
  bool _isAnalyzing = false;
  bool _isSaved = false;
  String _aiMessage = '';
  String _currentEmoji = '';
  List<String> _uploadedImages = [];
  bool _isRecording = false;
  int _recordingTime = 0;
  String _recognizedText = '';
  bool _hasText = false; // 텍스트 입력 여부를 추적하는 변수 추가
<<<<<<< HEAD
  bool _isTranscribing = false; // STT 변환 중 상태
  String _partialText = ''; // 부분 인식 텍스트
  String _status = ''; // 녹음 상태 메시지
  
  late AnimationController _fadeAnimationController;
  late Animation<double> _fadeAnimation;
  late Emotion _currentEmotion; // ← 이 줄 추가!
=======
  
  late AnimationController _fadeAnimationController;
  late Animation<double> _fadeAnimation;
>>>>>>> origin/main

  final _diaryService = DiaryService();
  final AudioRecorder _audioRecorder = AudioRecorder();
  final ImagePicker _imagePicker = ImagePicker();
  Timer? _recordingTimer;
  Timer? _statusTimer;

  // ImagePicker는 실제 앱에서 image_picker 패키지로 구현

  // 감정 체인 데이터
  final List<EmotionChainItem> emotionChain = [
    EmotionChainItem(emoji: '🍎', type: Emotion.fruit),
    EmotionChainItem(emoji: '🐶', type: Emotion.animal),
    EmotionChainItem(emoji: '⭐', type: Emotion.shape),
    EmotionChainItem(emoji: '☀️', type: Emotion.weather),
    EmotionChainItem(emoji: '🍇', type: Emotion.fruit),
    EmotionChainItem(emoji: '🐱', type: Emotion.animal),
  ];

<<<<<<< HEAD
  // 감정에 따른 이모티콘 매핑 (Firebase URL)
  final Map<Emotion, String> emotionEmojis = {
    Emotion.fruit: 'https://firebasestorage.googleapis.com/v0/b/diary-3bbf7.firebasestorage.app/o/fruit%2Fneutral_fruit-removebg-preview.png?alt=media&token=9bdea06c-13e6-4c59-b961-1424422a3c39',
    Emotion.animal: 'https://firebasestorage.googleapis.com/v0/b/diary-3bbf7.firebasestorage.app/o/animal%2Fneutral_animal-removebg-preview.png?alt=media&token=f884e38d-5d8c-4d4a-bb62-a47a198d384f',
    Emotion.shape: 'https://firebasestorage.googleapis.com/v0/b/diary-3bbf7.firebasestorage.app/o/shape%2Fneutral_shape-removebg-preview.png?alt=media&token=02e85132-3a83-4257-8c1e-d2e478c7fcf5',
    Emotion.weather: 'https://firebasestorage.googleapis.com/v0/b/diary-3bbf7.firebasestorage.app/o/wheather%2Fneutral_weather-removebg-preview.png?alt=media&token=57ad1adf-baa6-4b79-96f5-066a4ec3358f',
  };

  // 사용자 설정 카테고리에서 이모지 가져오기
  String _getUserEmoticon(Emotion emotion) {
    final appState = Provider.of<AppState>(context, listen: false);
    final selectedCategory = appState.selectedEmoticonCategory;
    
    // 사용자가 선택한 카테고리와 다른 감정인 경우, 선택된 카테고리의 기본 이모지 사용
    if (emotion != selectedCategory) {
      switch (selectedCategory) {
        case Emotion.fruit:
          return emotionEmojis[Emotion.fruit]!;
        case Emotion.animal:
          return emotionEmojis[Emotion.animal]!;
        case Emotion.shape:
          return emotionEmojis[Emotion.shape]!;
        case Emotion.weather:
          return emotionEmojis[Emotion.weather]!;
      }
    }
    
    // 선택된 카테고리와 같은 감정인 경우 원래 이모지 사용
    return emotionEmojis[emotion] ?? emotionEmojis[Emotion.shape]!;
  }

  @override
  void initState() {
    super.initState();
    _entryController = TextEditingController(text: widget.existingEntry?.entry ?? '');
    _isSaved = widget.existingEntry?.entry != null;
    if (widget.existingEntry?.emotion != null) {
      _currentEmotion = widget.existingEntry!.emotion!;
    } else if (widget.existingEntry?.entry != null) {
      _currentEmotion = _analyzeEmotion(widget.existingEntry!.entry!);
    } else {
      // 여기서 AppState의 selectedEmoticonCategory를 기본값으로 사용
      final appState = Provider.of<AppState>(context, listen: false);
      _currentEmotion = appState.selectedEmoticonCategory;
    }
    _currentEmoji = _getUserEmoticon(_currentEmotion);
    _uploadedImages = List.from(widget.existingEntry?.images ?? []);
    _hasText = _entryController.text.trim().isNotEmpty;
=======
  // 감정에 따른 이모티콘 매핑
  final Map<Emotion, String> emotionEmojis = {
    Emotion.fruit: '🍎',
    Emotion.animal: '🐶',
    Emotion.shape: '⭐',
    Emotion.weather: '☀️',
  };

  @override
  void initState() {
    super.initState();
    _loadDiaryData();
    _entryController = TextEditingController(text: widget.existingEntry?.entry ?? '');
    _isSaved = widget.existingEntry?.entry != null;
    _currentEmoji = widget.existingEntry?.emoji ?? '';
    _uploadedImages = List.from(widget.existingEntry?.images ?? []);
    _hasText = _entryController.text.trim().isNotEmpty; // 초기 텍스트 상태 설정
>>>>>>> origin/main

    _fadeAnimationController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
    _fadeAnimation = CurvedAnimation(
      parent: _fadeAnimationController,
      curve: Curves.easeInOut,
    );

<<<<<<< HEAD
    // AI 메시지는 기존 entry로만 생성(이모티콘, entry는 건드리지 않음)
=======
    // Generate AI message for existing entry when component mounts
>>>>>>> origin/main
    if (widget.existingEntry?.entry != null && _aiMessage.isEmpty) {
      final emotion = _analyzeEmotion(widget.existingEntry!.entry!);
      final comfortMessage = _generateComfortMessage(emotion, widget.existingEntry!.entry!);
      setState(() {
        _aiMessage = comfortMessage;
      });
      _fadeAnimationController.forward();
    }

    // STT 서비스 연결 테스트
    _testSTTConnection();
  }

  /// STT 서비스 연결 테스트
  Future<void> _testSTTConnection() async {
    try {
      print('STT 서비스 연결 테스트 시작...');
      final health = await STTService.healthCheck();
      print('STT 서비스 연결 성공: $health');
    } catch (e) {
      print('STT 서비스 연결 실패: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('STT 서비스에 연결할 수 없습니다: $e'),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 5),
        ),
      );
    }
  }

<<<<<<< HEAD
=======
  Future<void> _loadDiaryData() async {
    // 인증 상태 확인
    final appState = Provider.of<AppState>(context, listen: false);
    if (!appState.isAuthenticated) {
      return; // 인증되지 않은 경우 일기 데이터 로드하지 않음
    }
    
    try {
      final diaryData = await _diaryService.getDiaryByDate(widget.selectedDate);
      if (diaryData != null) {
        setState(() {
          _entryController.text = diaryData['content'];
          _uploadedImages = List<String>.from(diaryData['images']);
          _isSaved = true;
          _hasText = true;
          
          // 감정 분석 및 메시지 생성
          final emotion = _analyzeEmotion(diaryData['content']);
          _aiMessage = _generateComfortMessage(emotion, diaryData['content']);
          _currentEmoji = emotionEmojis[emotion] ?? '';
          _fadeAnimationController.forward();
        });
      }
    } catch (e) {
      print('일기 데이터 로드 중 오류 발생: $e');
      // 인증 에러인 경우 로그인 페이지로 이동
      if (e.toString().contains('로그인이 필요합니다') || e.toString().contains('인증이 만료되었습니다')) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('로그인이 필요합니다'),
              backgroundColor: Colors.orange,
              action: SnackBarAction(
                label: '로그인',
                onPressed: () {
                  appState.setAuthenticated(false); // 로그인 페이지로 이동
                },
              ),
            ),
          );
        }
      }
    }
  }

>>>>>>> origin/main
  @override
  void dispose() {
    _entryController.dispose();
    _fadeAnimationController.dispose();
<<<<<<< HEAD
<<<<<<< HEAD
    _recordingSubscription?.cancel();
    _realtimeTimer?.cancel();
    AudioRecorder.instance.dispose();
=======
>>>>>>> origin/main
=======
    _recordingTimer?.cancel();
    _statusTimer?.cancel();
    _audioRecorder.dispose();
    
>>>>>>> ec3101fac74b54c58bff6fbb00dcf6d5e01fc55e
    super.dispose();
  }

  // 음성 인식 지원 확인 (웹에서만 사용 가능)
  bool _isSpeechRecognitionSupported() {
    // Flutter에서는 speech_to_text 패키지를 사용
    // 여기서는 시뮬레이션
    return true;
  }

  Emotion _analyzeEmotion(String text) {
    // Simple emotion analysis based on keywords
    final fruitWords = ['과일', '사과', '바나나', '딸기', '포도', '맛있', '달콤', '상큼'];
    final animalWords = ['동물', '강아지', '고양이', '새', '토끼', '귀여', '애완동물', '반려동물'];
    final shapeWords = ['모양', '원', '사각형', '삼각형', '별', '도형', '그림', '디자인'];
    final weatherWords = ['날씨', '맑은', '비', '눈', '구름', '햇빛', '바람', '기온'];

    final lowerText = text.toLowerCase();
    
    if (fruitWords.any((word) => lowerText.contains(word))) return Emotion.fruit;
    if (animalWords.any((word) => lowerText.contains(word))) return Emotion.animal;
    if (shapeWords.any((word) => lowerText.contains(word))) return Emotion.shape;
    if (weatherWords.any((word) => lowerText.contains(word))) return Emotion.weather;
    
    return Emotion.fruit; // default to fruit
  }

  String _generateComfortMessage(Emotion emotion, String entryText) {
    final messages = {
      Emotion.fruit: [
        "오늘은 과일처럼 상큼하고 달콤한 하루였나 봐요! 자연의 맛과 향을 만끽하는 순간들이 소중해요 🍎",
        "신선하고 건강한 에너지가 느껴져요! 과일의 생명력처럼 활기찬 하루를 보내셨네요 🍓",
        "달콤하고 맛있는 순간들이 가득했군요! 이런 즐거운 경험들이 더 많이 이어지길 바라요 🍊"
      ],
      Emotion.animal: [
        "동물들과 함께한 특별한 하루였나 봐요! 작은 생명들과의 교감은 정말 소중한 경험이에요 🐶",
        "귀여운 동물들처럼 순수하고 따뜻한 마음이 느껴져요! 이런 순간들이 마음을 치유해죠 🐱",
        "자연과 생명에 대한 사랑이 전해져요! 동물들과의 만남이 특별한 의미를 준 하루였군요 🐸"
      ],
      Emotion.shape: [
        "창의적이고 아름다운 모양들을 발견한 하루였나 봐요! 예술적 감성이 풍부하게 느껴져요 ⭐",
        "기하학적이고 조화로운 패턴들처럼, 오늘 하루도 균형 잡힌 모습이었군요 🔶",
        "다양한 형태와 색깔들이 어우러진 특별한 하루였네요! 디자인적 영감이 가득한 시간이었어요 🔷"
      ],
      Emotion.weather: [
        "날씨만큼이나 변화무쌍하고 아름다운 하루였나 봐요! 자연의 힘을 느끼는 순간들이 소중해요 ☀️",
        "맑은 하늘처럼 깨끗하고 상쾌한 기분이 드는 하루였군요! 좋은 날씨가 마음도 밝게 해줬나 봐요 🌈",
        "계절의 변화를 온몸으로 느끼며 보낸 의미 있는 하루였네요! 자연과 하나 되는 기분이었어요 🌧️"
      ]
    };

    final emotionMessages = messages[emotion] ?? messages[Emotion.fruit]!;
    final random = Random();
    return emotionMessages[random.nextInt(emotionMessages.length)];
  }

  Future<void> _handleSave() async {
<<<<<<< HEAD
    if (_isSaved) return; // 이미 저장된 경우 아무 동작도 하지 않음
=======
>>>>>>> origin/main
    if (_entryController.text.trim().isEmpty) {
      return;
    }
    
<<<<<<< HEAD
=======
    // 인증 상태 확인
    final appState = Provider.of<AppState>(context, listen: false);
    if (!appState.isAuthenticated) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('일기를 저장하려면 로그인이 필요합니다'),
          backgroundColor: Colors.orange,
          action: SnackBarAction(
            label: '로그인',
            onPressed: () {
              appState.setAuthenticated(false); // 로그인 페이지로 이동
            },
          ),
        ),
      );
      return;
    }
    
>>>>>>> origin/main
    setState(() {
      _isAnalyzing = true;
    });
    
    try {
      // 감정 분석
      final emotion = _analyzeEmotion(_entryController.text);
      
      // 일기 저장 API 호출
      final postId = await _diaryService.createDiary(
        content: _entryController.text,
        emotion: emotion,
        images: _uploadedImages.isNotEmpty ? _uploadedImages : null,
      );
      
      // 위로의 메시지 생성
      final comfortMessage = _generateComfortMessage(emotion, _entryController.text);
      
      setState(() {
        _aiMessage = comfortMessage;
<<<<<<< HEAD
        _currentEmotion = emotion;
        _currentEmoji = _getUserEmoticon(emotion); // 저장 시에만 이모티콘 변경
=======
        _currentEmoji = emotionEmojis[emotion]!;
>>>>>>> origin/main
        _isAnalyzing = false;
        _isSaved = true;
      });
      
      _fadeAnimationController.forward();
      
      // 일기 데이터 저장 콜백 호출
      widget.onSave(_entryController.text, emotion, _uploadedImages.isNotEmpty ? _uploadedImages : null);

      // 성공 메시지 표시
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('일기가 저장되었습니다'),
            backgroundColor: AppColors.primary,
          ),
        );
      }
    } catch (e) {
      // 에러 처리
      if (mounted) {
        setState(() {
          _isAnalyzing = false;
        });
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('일기 저장에 실패했습니다: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  String _formatDate(String dateStr) {
    final date = DateTime.parse(dateStr);
    final month = date.month;
    final day = date.day;
    final dayNames = ['일요일', '월요일', '화요일', '수요일', '목요일', '금요일', '토요일'];
    final dayName = dayNames[date.weekday % 7];
    
    return '${month}월 ${day}일\n$dayName';
  }

  String _formatDuration(int seconds) {
    final minutes = seconds ~/ 60;
    final remainingSeconds = seconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${remainingSeconds.toString().padLeft(2, '0')}';
  }

  /// 상태 메시지를 3초 후 자동으로 지우는 메서드
  void _clearStatusAfterDelay() {
    _statusTimer?.cancel();
    _statusTimer = Timer(const Duration(seconds: 3), () {
      if (mounted) {
        setState(() {
          _status = '';
        });
      }
    });
  }

  Widget _buildImageWidget(String imagePath) {
    Widget errorWidget = Container(
      color: AppColors.muted,
      child: Icon(
        Icons.image,
        color: AppColors.mutedForeground,
      ),
    );

    // 백엔드에서 업로드된 이미지인지 확인 (파일명만 있는 경우)
    if (imagePath.contains('/') || imagePath.startsWith('http://') || imagePath.startsWith('https://')) {
      // 로컬 파일 경로 또는 네트워크 이미지
      if (imagePath.startsWith('http://') || imagePath.startsWith('https://')) {
        // 네트워크 이미지
        return Image.network(
          imagePath,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) => errorWidget,
        );
      } else {
        // 로컬 파일
        return Image.file(
          File(imagePath),
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) => errorWidget,
        );
      }
    } else {
      // 백엔드에서 업로드된 이미지 (파일명만 있는 경우)
      // API 엔드포인트를 통해 이미지 조회
      final String imageUrl = 'http://192.168.43.129:8000/api/images/$imagePath';
      return Image.network(
        imageUrl,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) => errorWidget,
      );
    }
  }

  Future<void> _handleImageUpload() async {
<<<<<<< HEAD
    if (_uploadedImages.length >= 3) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('이미지는 최대 3장까지 업로드할 수 있습니다.')),
      );
      return;
    }
<<<<<<< HEAD
=======
    if (_uploadedImages.length >= 3) return;

>>>>>>> origin/main
    // 웹에서만 동작하므로 조건부 처리
    if (kIsWeb) {
      // 웹에서는 dart:html을 사용할 수 없으므로 이미지 업로드 기능을 비활성화
      // 실제 구현에서는 image_picker 패키지를 사용해야 함
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('이미지 업로드 기능은 모바일에서만 사용 가능합니다.')),
=======

    try {
      // 이미지 소스 선택 다이얼로그
      final ImageSource? source = await _showImageSourceDialog();
      if (source == null) return;

      // 이미지 선택
      final XFile? image = await _imagePicker.pickImage(
        source: source,
        maxWidth: 1920,
        maxHeight: 1920,
        imageQuality: 85,
>>>>>>> ec3101fac74b54c58bff6fbb00dcf6d5e01fc55e
      );

      if (image != null) {
        // 백엔드에 이미지 업로드
        final File imageFile = File(image.path);
        final String uploadedFilename = await _diaryService.uploadImage(imageFile);
        
        setState(() {
          _uploadedImages.add(uploadedFilename);
        });

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('이미지가 성공적으로 업로드되었습니다.'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('이미지 업로드에 실패했습니다: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  /// 이미지 소스 선택 다이얼로그
  Future<ImageSource?> _showImageSourceDialog() async {
    return showDialog<ImageSource>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('이미지 선택'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.camera_alt),
                title: const Text('카메라'),
                onTap: () => Navigator.of(context).pop(ImageSource.camera),
              ),
              ListTile(
                leading: const Icon(Icons.photo_library),
                title: const Text('갤러리'),
                onTap: () => Navigator.of(context).pop(ImageSource.gallery),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('취소'),
            ),
          ],
        );
      },
    );
  }



  Future<void> _handleImageDelete(int index) async {
    final String imagePath = _uploadedImages[index];
    
    try {
      // 백엔드에서 이미지 삭제
      final bool success = await _diaryService.deleteImage(imagePath);
      
      if (success) {
        setState(() {
          _uploadedImages.removeAt(index);
        });
        
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('이미지가 삭제되었습니다.'),
            backgroundColor: Colors.orange,
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('이미지 삭제에 실패했습니다.'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      print('이미지 삭제 오류: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('이미지 삭제 중 오류가 발생했습니다: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _startRecording() async {
<<<<<<< HEAD
    try {
      setState(() {
        _status = '마이크 권한 확인 중...';

      });
      final success = await _audioRecorder.startRecording();
      if (success) {
        setState(() {
          _isRecording = true;
          _recordingTime = 0;
          _partialText = '';
          _status = '마이크 녹음 중...';
        });
        // 타이머로 녹음 시간 관리
        _recordingTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
          if (_isRecording) {
            setState(() {
              _recordingTime++;
            });
          }
        });
      }
    } catch (e) {
      String errorMessage = e.toString();
      if (errorMessage.contains('권한')) {
        _showPermissionDialog();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('마이크 녹음을 시작할 수 없습니다: $errorMessage'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  /// 권한 설정 안내 다이얼로그
  void _showPermissionDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('마이크 권한 필요'),
          content: const Text(
            '음성 녹음을 위해 마이크 권한이 필요합니다.\n\n'
            '설정에서 마이크 권한을 허용해주세요.',
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('취소'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                AppSettings.openAppSettings();
              },
              child: const Text('설정으로 이동'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _stopRecording() async {
    try {
      setState(() {
        _status = '마이크 녹음 중지 중...';
      });
      _recordingTimer?.cancel();
      _recordingTimer = null;
      final audioPath = await _audioRecorder.stopRecording();
      setState(() {
        _isRecording = false;
        _recordingTime = 0;
        _status = '음성 인식(STT) 변환 중...';
      });
      if (audioPath != null) {
        await _transcribeAudio(File(audioPath));
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('마이크 녹음을 중지할 수 없습니다: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }



  Future<void> _transcribeAudio(File audioFile) async {
    setState(() {
      _isTranscribing = true;
    });

    try {
      final result = await STTService.transcribeAudio(audioFile);
      
      if (result.success && result.text.isNotEmpty) {
        setState(() {
          _recognizedText = result.text;
          // 기존 텍스트에 새로운 텍스트 누적 (덮어쓰지 않음)
          if (_entryController.text.isNotEmpty) {
            _entryController.text += ' ' + result.text;
          } else {
            _entryController.text = result.text;
          }
          _hasText = _entryController.text.trim().isNotEmpty;
          _partialText = ''; // 부분 텍스트 초기화
          _status = '음성 인식 완료!';
        });

        // 3초 후 상태 메시지 자동 제거
        _clearStatusAfterDelay();

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('실제 마이크 음성이 텍스트로 변환되었습니다'),
            backgroundColor: AppColors.primary,
          ),
        );
      } else {
        setState(() {
          _status = '음성 인식 실패';
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('실제 마이크 음성을 인식할 수 없습니다. 다시 시도해주세요.'),
            backgroundColor: Colors.orange,
          ),
        );
      }
    } catch (e) {
      setState(() {
        _status = '음성 변환 오류';
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('실제 마이크 음성 변환에 실패했습니다: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() {
        _isTranscribing = false;
      });
    }
  }

  /// 시뮬레이션된 STT 변환 (429 에러 방지용)
  Future<void> _transcribeAudioSimulated(File audioFile) async {
    setState(() {
      _isTranscribing = true;
    });

    try {
      // 네트워크 지연 시뮬레이션
      await Future.delayed(const Duration(seconds: 2));
      
      // 시뮬레이션된 변환 결과
      final simulatedText = '오늘은 정말 좋은 하루였어요. 친구들과 함께 영화를 봤는데 정말 재미있었습니다. 내일도 좋은 하루가 되길 바라요.';
      
      setState(() {
        _recognizedText = simulatedText;
        _entryController.text = simulatedText;
        _hasText = simulatedText.trim().isNotEmpty;
        _partialText = ''; // 부분 텍스트 초기화
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('음성이 텍스트로 변환되었습니다 (시뮬레이션)'),
          backgroundColor: AppColors.primary,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('음성 변환에 실패했습니다: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() {
        _isTranscribing = false;
      });
    }
  }

=======
    // Flutter에서는 speech_to_text 패키지를 사용
    // 여기서는 시뮬레이션
    setState(() {
      _isRecording = true;
      _recordingTime = 0;
    });

    // 시뮬레이션: 1초마다 녹음 시간 증가
    while (_isRecording) {
      await Future.delayed(const Duration(seconds: 1));
      if (_isRecording) {
        setState(() {
          _recordingTime++;
        });
      }
    }
  }

  void _stopRecording() {
    setState(() {
      _isRecording = false;
      _recordingTime = 0;
    });
  }

>>>>>>> origin/main
  void _handleRecordingToggle() {
    if (_isRecording) {
      _stopRecording();
    } else {
      _startRecording();
    }
  }

  Widget _buildNotebookLines() {
    return Positioned.fill(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: LayoutBuilder(
          builder: (context, constraints) {
            // 사용 가능한 높이를 라인 높이로 나누어 라인 개수 계산
            final lineHeight = 32.0;
            final availableHeight = constraints.maxHeight - 32; // 패딩 고려
            final lineCount = (availableHeight / lineHeight).floor();
            
<<<<<<< HEAD
            // 음수 값 방지
            if (lineCount <= 0) {
              return const SizedBox.shrink();
            }
            
=======
>>>>>>> origin/main
            return Column(
              children: List.generate(lineCount, (index) => 
                Container(
                  height: lineHeight,
                  decoration: BoxDecoration(
                    border: Border(
                      bottom: BorderSide(
                        color: AppColors.border.withOpacity(0.3),
                        width: 1,
                      ),
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildRecordingSection() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.mic, color: Colors.blue, size: 20),
              const SizedBox(width: 8),
              Text(
                '음성 녹음',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey[800],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: _isRecording ? _stopRecording : _startRecording,
                  icon: Icon(_isRecording ? Icons.stop : Icons.mic),
                  label: Text(_isRecording ? '녹음 중지' : '녹음 시작'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _isRecording ? Colors.grey[600] : Colors.red,
                    foregroundColor: Colors.white,
                  ),
                ),
              ),
            ],
          ),
          if (_isRecording) ...[
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.red[50],
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.red[200]!),
              ),
              child: Row(
                children: [
                  Container(
                    width: 8,
                    height: 8,
                    decoration: const BoxDecoration(
                      color: Colors.red,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    '녹음 중... ${_formatDuration(_recordingTime)}',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.red[700],
                    ),
                  ),
                ],
              ),
            ),
          ],
          if (_isTranscribing) ...[
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.blue[50],
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.blue[200]!),
              ),
              child: Row(
                children: [
                  SizedBox(
                    width: 12,
                    height: 12,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.blue[700]!),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    '음성 변환 중...',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.blue[700],
                    ),
                  ),
                ],
              ),
            ),
          ],
          if (_status.isNotEmpty) ...[
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.orange[50],
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.orange[200]!),
              ),
              child: Row(
                children: [
                  const Icon(Icons.info_outline, color: Colors.orange, size: 16),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      _status,
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.orange[700],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
<<<<<<< HEAD
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 896), // max-w-4xl
                child: Column(
                  children: [
                    // Back Button
                    Container(
                      margin: const EdgeInsets.only(bottom: 16, top: 20),
                      child: Align(
                        alignment: Alignment.centerLeft,
                        child: AppButton(
                          onPressed: widget.onBack,
                          variant: ButtonVariant.ghost,
                          size: ButtonSize.icon,
                          child: Container(
                            width: 40,
                            height: 40,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(20),
                              color: AppColors.calendarDateHover,
                            ),
                            child: const Icon(Icons.arrow_back, size: 20),
=======
    final appState = Provider.of<AppState>(context);
    
    // 인증되지 않은 사용자를 위한 안내 화면
    if (!appState.isAuthenticated) {
      return Scaffold(
        backgroundColor: AppColors.background,
        body: Padding(
          padding: const EdgeInsets.all(16),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 896),
              child: Column(
                children: [
                  // Back Button
                  Container(
                    margin: const EdgeInsets.only(bottom: 16, top: 20),
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: AppButton(
                        onPressed: widget.onBack,
                        variant: ButtonVariant.ghost,
                        size: ButtonSize.icon,
                        child: Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(20),
                            color: AppColors.calendarDateHover,
                          ),
                          child: const Icon(Icons.arrow_back, size: 20),
                        ),
                      ),
                    ),
                  ),
                  
                  // 로그인 안내 메시지
                  Expanded(
                    child: Center(
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 448),
                        child: AppCard(
                          backgroundColor: AppColors.calendarBg,
                          borderRadius: BorderRadius.circular(24),
                          padding: const EdgeInsets.all(32),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.lock_outline,
                                size: 64,
                                color: AppColors.mutedForeground,
                              ),
                              const SizedBox(height: 24),
                              Text(
                                '로그인이 필요합니다',
                                style: TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.foreground,
                                ),
                                textAlign: TextAlign.center,
                              ),
                              const SizedBox(height: 16),
                              Text(
                                '일기를 작성하고 저장하려면\n로그인해주세요',
                                style: TextStyle(
                                  fontSize: 16,
                                  color: AppColors.mutedForeground,
                                  height: 1.5,
                                ),
                                textAlign: TextAlign.center,
                              ),
                              const SizedBox(height: 32),
                              AppButton(
                                onPressed: () {
                                  appState.setAuthenticated(false); // 로그인 페이지로 이동
                                },
                                variant: ButtonVariant.primary,
                                size: ButtonSize.large,
                                child: Text('로그인하기'),
                              ),
                            ],
>>>>>>> origin/main
                          ),
                        ),
                      ),
                    ),
<<<<<<< HEAD
                    
                    // Main Content
                    ConstrainedBox(
                      constraints: const BoxConstraints(
                        maxWidth: 448, // max-w-md
                        minHeight: 600, // 최소 높이 설정
=======
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    }
    
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 896), // max-w-4xl
            child: Column(
              children: [
                // Back Button
                Container(
                  margin: const EdgeInsets.only(bottom: 16, top: 20),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: AppButton(
                      onPressed: widget.onBack,
                      variant: ButtonVariant.ghost,
                      size: ButtonSize.icon,
                      child: Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(20),
                          color: AppColors.calendarDateHover,
                        ),
                        child: const Icon(Icons.arrow_back, size: 20),
                      ),
                    ),
                  ),
                ),
                
                // Main Content
                Expanded(
                  child: Center(
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(
                        maxWidth: 448, // max-w-md
                        maxHeight: 800, // 세로 길이 제한 추가
>>>>>>> origin/main
                      ),
                      child: AppCard(
                        backgroundColor: AppColors.calendarBg,
                        borderRadius: BorderRadius.circular(24),
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Date Display
                            Row(
                              children: [
<<<<<<< HEAD
                                // Date Display
                                Row(
                                  children: [
                                    if (_isSaved || widget.existingEntry?.entry != null)
                                      Container(
                                        width: 48,
                                        height: 48,
                                        decoration: BoxDecoration(
<<<<<<< HEAD
                                          color: AppColors.calendarBg, // 더 부드러운 배경색으로 변경
                                          borderRadius: BorderRadius.circular(24),
                                        ),
                                        child: Center(
                                          // 이모티콘 크기 키우기 (width: 56, height: 56)
                                          child: Image.network(
                                            _currentEmoji,
                                            width: 150,
                                            height: 150,
                                            fit: BoxFit.contain,
                                            errorBuilder: (context, error, stackTrace) {
                                              return Text(
                                                '😊',
                                                style: const TextStyle(fontSize: 56),
                                              );
                                            },
=======
                                          color: AppColors.emotionCalm,
                                          borderRadius: BorderRadius.circular(24),
                                        ),
                                        child: Center(
                                          child: Text(
                                            _currentEmoji,
                                            style: const TextStyle(fontSize: 24),
>>>>>>> origin/main
                                          ),
=======
                                if (_isSaved || widget.existingEntry?.entry != null)
                                  Container(
                                    width: 48,
                                    height: 48,
                                    decoration: BoxDecoration(
                                      color: AppColors.calendarBg,
                                      borderRadius: BorderRadius.circular(24),
                                    ),
                                    child: Center(
                                      child: Image.network(
                                        _currentEmoji,
                                        width: 150,
                                        height: 150,
                                        fit: BoxFit.contain,
                                        errorBuilder: (context, error, stackTrace) {
                                          return Text(
                                            '😊',
                                            style: const TextStyle(fontSize: 56),
                                          );
                                        },
                                      ),
                                    ),
                                  ),
                                if (_isSaved || widget.existingEntry?.entry != null)
                                  const SizedBox(width: 16),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        _formatDate(widget.selectedDate),
                                        style: TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold,
                                          color: AppColors.foreground,
                                          height: 1.2,
>>>>>>> ec3101fac74b54c58bff6fbb00dcf6d5e01fc55e
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                // 업로드 버튼 (3장 미만 & 저장 전만 노출)
                                if (_uploadedImages.length < 3 && !_isSaved)
                                  AppButton(
                                    onPressed: _handleImageUpload,
                                    variant: ButtonVariant.ghost,
                                    size: ButtonSize.icon,
                                    child: Container(
                                      width: 40,
                                      height: 40,
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(20),
                                        color: AppColors.primary.withOpacity(0.1),
                                        border: Border.all(
                                          color: AppColors.primary.withOpacity(0.2),
                                          width: 2,
                                        ),
                                      ),
                                      child: Icon(
                                        Icons.upload,
                                        size: 20,
                                        color: AppColors.primary,
                                      ),
                                    ),
                                  ),
                                const SizedBox(width: 8),
                                // 녹음 버튼 (저장 전만 노출)
                                if (!_isSaved)
                                  AppButton(
                                    onPressed: _isRecording ? _stopRecording : _startRecording,
                                    variant: ButtonVariant.ghost,
                                    size: ButtonSize.icon,
                                    child: Container(
                                      width: 40,
                                      height: 40,
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(20),
                                        color: _isRecording 
                                            ? Colors.red.withOpacity(0.1)
                                            : AppColors.primary.withOpacity(0.1),
                                        border: Border.all(
                                          color: _isRecording 
                                              ? Colors.red.withOpacity(0.2)
                                              : AppColors.primary.withOpacity(0.2),
                                          width: 2,
                                        ),
                                      ),
                                      child: Icon(
                                        _isRecording ? Icons.stop : Icons.mic,
                                        size: 20,
                                        color: _isRecording ? Colors.red : AppColors.primary,
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                            

                            
                            const SizedBox(height: 24),
                            
                            // 녹음 상태 표시 (저장 전만 노출)
                            if (!_isSaved && (_isRecording || _isTranscribing || _status.isNotEmpty)) ...[
                              Container(
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: AppColors.calendarBg,
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(color: AppColors.calendarDateHover),
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    if (_isRecording) ...[
                                      Row(
                                        children: [
                                          Container(
                                            width: 8,
                                            height: 8,
                                            decoration: const BoxDecoration(
                                              color: Colors.red,
                                              shape: BoxShape.circle,
                                            ),
                                          ),
                                          const SizedBox(width: 8),
                                          Text(
                                            '녹음 중... ${_formatDuration(_recordingTime)}',
                                            style: TextStyle(
                                              fontSize: 12,
                                              color: Colors.red[700],
                                              fontWeight: FontWeight.w500,
                                            ),
                                          ),
                                        ],
                                      ),
<<<<<<< HEAD
                                    ),
                                  ],
                                ),

                                // Voice Recording & Photo Upload Buttons
                                Row(
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    // 타이머 (녹음 중일 때만)
                                    if (_isRecording) ...[
                                      Container(
                                        margin: const EdgeInsets.only(right: 8),
                                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                        decoration: BoxDecoration(
                                          color: Colors.red.withOpacity(0.1),
                                          borderRadius: BorderRadius.circular(12),
                                          border: Border.all(color: Colors.red.withOpacity(0.2)),
                                        ),
<<<<<<< HEAD
                                        child: Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            Text(
                                              '${_recordingTime ~/ 60}:${(_recordingTime % 60).toString().padLeft(2, '0')}',
                                              style: TextStyle(
                                                fontSize: 12,
                                                fontWeight: FontWeight.w500,
                                                color: Colors.red,
                                              ),
=======
                                    ],
                                    if (_isTranscribing) ...[
                                      if (_isRecording) const SizedBox(height: 8),
                                      Row(
                                        children: [
                                          SizedBox(
                                            width: 12,
                                            height: 12,
                                            child: CircularProgressIndicator(
                                              strokeWidth: 2,
                                              valueColor: AlwaysStoppedAnimation<Color>(Colors.blue[700]!),
>>>>>>> ec3101fac74b54c58bff6fbb00dcf6d5e01fc55e
                                            ),
                                          ),
                                          const SizedBox(width: 8),
                                          Text(
                                            '음성 변환 중...',
                                            style: TextStyle(
                                              fontSize: 12,
                                              color: Colors.blue[700],
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                    if (_status.isNotEmpty) ...[
                                      if (_isRecording || _isTranscribing) const SizedBox(height: 8),
                                      Row(
                                        children: [
                                          const Icon(Icons.info_outline, color: Colors.orange, size: 16),
                                          const SizedBox(width: 8),
                                          Expanded(
                                            child: Text(
                                              _status,
                                              style: TextStyle(
                                                fontSize: 12,
                                                color: Colors.orange[700],
                                              ),
                                            ),
                                          ),
<<<<<<< HEAD
                                          child: Center(
                                            child: _isTranscribing
                                                ? SizedBox(
                                                    width: 16,
                                                    height: 16,
                                                    child: CircularProgressIndicator(
                                                      strokeWidth: 2,
                                                      valueColor: AlwaysStoppedAnimation<Color>(Colors.grey),
                                                    ),
                                                  )
                                                : Icon(
                                                    Icons.mic,
                                                    size: 20,
                                                    color: _isRecording ? Colors.white : Colors.red,
                                                  ),
                                          ),
                                        ),
                                      ),
                                    const SizedBox(width: 8),
                                    // 업로드 버튼 (3장 미만 & 저장 전만 노출)
                                    if (_uploadedImages.length < 3 && !_isSaved)
=======
                                        child: Text(
                                          '${_recordingTime ~/ 60}:${(_recordingTime % 60).toString().padLeft(2, '0')}',
                                          style: TextStyle(
                                            fontSize: 12,
                                            fontWeight: FontWeight.w500,
                                            color: Colors.red,
                                          ),
                                        ),
                                      ),
                                    ],
                                    // 마이크 버튼
                                    AppButton(
                                      onPressed: _handleRecordingToggle,
                                      variant: ButtonVariant.ghost,
                                      size: ButtonSize.icon,
                                      child: Container(
                                        width: 40,
                                        height: 40,
                                        decoration: BoxDecoration(
                                          borderRadius: BorderRadius.circular(20),
                                          color: _isRecording 
                                              ? Colors.red
                                              : Colors.red.withOpacity(0.1),
                                          border: Border.all(
                                            color: Colors.red.withOpacity(0.2),
                                            width: 2,
                                          ),
                                        ),
                                        child: Center(
                                          child: Icon(
                                            Icons.mic,
                                            size: 20,
                                            color: _isRecording ? Colors.white : Colors.red,
                                          ),
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    // 업로드 버튼
                                    if (_uploadedImages.length < 3)
>>>>>>> origin/main
                                      AppButton(
                                        onPressed: _handleImageUpload,
                                        variant: ButtonVariant.ghost,
                                        size: ButtonSize.icon,
                                        child: Container(
                                          width: 40,
                                          height: 40,
                                          decoration: BoxDecoration(
                                            borderRadius: BorderRadius.circular(20),
                                            color: AppColors.primary.withOpacity(0.1),
                                            border: Border.all(
                                              color: AppColors.primary.withOpacity(0.2),
                                              width: 2,
                                            ),
                                          ),
                                          child: Icon(
                                            Icons.upload,
                                            size: 20,
                                            color: AppColors.primary,
                                          ),
                                        ),
=======
                                        ],
>>>>>>> ec3101fac74b54c58bff6fbb00dcf6d5e01fc55e
                                      ),
                                    ],
                                  ],
                                ),
                              ),
                              const SizedBox(height: 16),
                            ],

                            // Uploaded Images Preview
                            if (_uploadedImages.isNotEmpty) ...[
                              GridView.builder(
                                shrinkWrap: true,
                                physics: const NeverScrollableScrollPhysics(),
                                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                                  crossAxisCount: 3,
                                  crossAxisSpacing: 8,
                                  mainAxisSpacing: 8,
                                  childAspectRatio: 1,
                                ),
                                itemCount: _uploadedImages.length,
                                itemBuilder: (context, index) {
                                  return ClipRRect(
                                    borderRadius: BorderRadius.circular(12),
                                    child: Stack(
                                      children: [
                                        Container(
                                          width: double.infinity,
                                          height: 128,
                                          decoration: BoxDecoration(
                                            color: AppColors.muted,
                                            borderRadius: BorderRadius.circular(12),
                                          ),
                                          child: _buildImageWidget(_uploadedImages[index]),
                                        ),
                                        Positioned(
                                          top: 4,
                                          right: 4,
<<<<<<< HEAD
                                          // 이미지 삭제 버튼 (저장 전만 노출)
                                          child: !_isSaved
                                              ? GestureDetector(
                                                  onTap: () => _handleImageDelete(index),
                                                  child: Container(
                                                    width: 24,
                                                    height: 24,
                                                    decoration: BoxDecoration(
                                                      color: Colors.black.withOpacity(0.5),
                                                      borderRadius: BorderRadius.circular(12),
                                                    ),
                                                    child: const Icon(
                                                      Icons.close,
                                                      size: 12,
                                                      color: Colors.white,
                                                    ),
                                                  ),
                                                )
                                              : const SizedBox.shrink(),
=======
                                          child: GestureDetector(
                                            onTap: () => _handleImageDelete(index),
                                            child: Container(
                                              width: 24,
                                              height: 24,
                                              decoration: BoxDecoration(
                                                color: Colors.black.withOpacity(0.5),
                                                borderRadius: BorderRadius.circular(12),
                                              ),
                                              child: const Icon(
                                                Icons.close,
                                                size: 12,
                                                color: Colors.white,
                                              ),
                                            ),
                                          ),
>>>>>>> origin/main
                                        ),
                                      ],
                                    ),
                                  );
                                },
                              ),
                              const SizedBox(height: 16),
                            ],

                            // Diary Content
<<<<<<< HEAD
                            Container(
                              height: 400, // 고정 높이 설정
                              decoration: BoxDecoration(
                                color: AppColors.calendarBg,
                              ),
                              child: Stack(
                                children: [
                                  // Notebook lines
                                  _buildNotebookLines(),
                                  
                                  // Writing Area
                                  Positioned.fill(
                                    child: Padding(
                                      padding: const EdgeInsets.all(16),
                                      child: TextField(
                                        controller: _entryController,
                                        maxLines: null,
                                        expands: true,
                                        textAlignVertical: TextAlignVertical.top,
                                        readOnly: _isSaved,
                                        enabled: !_isSaved,
                                        style: TextStyle(
                                          color: AppColors.foreground,
                                          height: 2.0,
                                          fontSize: 16,
                                        ),
                                        decoration: InputDecoration(
                                          hintText: widget.existingEntry?.entry != null 
                                              ? "일기를 수정해보세요..." 
                                              : "오늘의 이야기를 작성해보세요...",
                                          hintStyle: TextStyle(
                                            color: AppColors.mutedForeground.withOpacity(0.7),
                                          ),
                                          border: InputBorder.none,
                                          enabledBorder: InputBorder.none,
                                          focusedBorder: InputBorder.none,
                                          errorBorder: InputBorder.none,
                                          focusedErrorBorder: InputBorder.none,
                                          disabledBorder: InputBorder.none,
                                          contentPadding: EdgeInsets.zero,
                                          filled: false,
                                        ),
                                        onChanged: (text) {
                                          setState(() {
                                            _hasText = text.trim().isNotEmpty;
                                          });
                                        },
                                      ),
                                    ),
                                  ),
                                ],
=======
                            Expanded(
                              child: Container(
                                decoration: BoxDecoration(
                                  color: AppColors.calendarBg,
                                ),
                                child: Stack(
                                  children: [
                                    // Notebook lines
                                    _buildNotebookLines(),
                                    
                                    // Writing Area
                                    Positioned.fill(
                                      child: Padding(
                                        padding: const EdgeInsets.all(16),
                                        child: TextField(
                                          controller: _entryController,
                                          maxLines: null,
                                          expands: true,
                                          textAlignVertical: TextAlignVertical.top,
                                          style: TextStyle(
                                            color: AppColors.foreground,
                                            height: 2.0,
                                            fontSize: 16,
                                          ),
                                          decoration: InputDecoration(
                                            hintText: widget.existingEntry?.entry != null 
                                                ? "일기를 수정해보세요..." 
                                                : "오늘의 이야기를 작성해보세요...",
                                            hintStyle: TextStyle(
                                              color: AppColors.mutedForeground.withOpacity(0.7),
                                            ),
                                            border: InputBorder.none,
                                            enabledBorder: InputBorder.none,
                                            focusedBorder: InputBorder.none,
                                            errorBorder: InputBorder.none,
                                            focusedErrorBorder: InputBorder.none,
                                            disabledBorder: InputBorder.none,
                                            contentPadding: EdgeInsets.zero,
                                            filled: false,
                                          ),
                                          onChanged: (text) {
                                            setState(() {
                                              _hasText = text.trim().isNotEmpty;
                                            });
                                          },
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
>>>>>>> origin/main
                              ),
                            ),
                            
                            const SizedBox(height: 12),
                            
                            // Save Button with improved disabled style
<<<<<<< HEAD
                            if (!_isSaved) ...[
=======
                            if (!_isSaved)
>>>>>>> origin/main
                              SizedBox(
                                width: double.infinity,
                                child: Container(
                                  decoration: BoxDecoration(
                                    color: _hasText && !_isAnalyzing 
                                        ? AppColors.primary
                                        : AppColors.primary.withOpacity(0.4),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Material(
                                    color: Colors.transparent,
                                    child: InkWell(
                                      onTap: _hasText && !_isAnalyzing ? _handleSave : null,
                                      borderRadius: BorderRadius.circular(8),
                                      child: Padding(
                                        padding: const EdgeInsets.symmetric(vertical: 8),
                                        child: Center(
                                          child: _isAnalyzing
                                              ? Row(
                                                  mainAxisAlignment: MainAxisAlignment.center,
                                                  children: [
                                                    SizedBox(
                                                      width: 16,
                                                      height: 16,
                                                      child: CircularProgressIndicator(
                                                        strokeWidth: 2,
                                                        valueColor: AlwaysStoppedAnimation<Color>(
                                                          AppColors.primaryForeground,
                                                        ),
                                                      ),
                                                    ),
                                                    const SizedBox(width: 8),
                                                    Text(
                                                      '감정 분석 중...',
                                                      style: TextStyle(
                                                        color: AppColors.primaryForeground,
                                                        fontWeight: FontWeight.w500,
                                                      ),
                                                    ),
                                                  ],
                                                )
                                              : Row(
                                                  mainAxisAlignment: MainAxisAlignment.center,
                                                  children: [
                                                    Icon(
                                                      Icons.send,
                                                      size: 16,
                                                      color: _hasText && !_isAnalyzing 
                                                          ? AppColors.primaryForeground
                                                          : AppColors.primaryForeground.withOpacity(0.7),
                                                    ),
                                                    const SizedBox(width: 8),
                                                    Text(
                                                      widget.existingEntry?.entry != null 
                                                          ? '일기 수정하기' 
                                                          : '일기 저장하기',
                                                      style: TextStyle(
                                                        color: _hasText && !_isAnalyzing 
                                                            ? AppColors.primaryForeground
                                                            : AppColors.primaryForeground.withOpacity(0.7),
                                                        fontWeight: FontWeight.w500,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
<<<<<<< HEAD
                            ],

                            // AI Message - Bottom of card
                            if ((_isSaved || widget.existingEntry?.entry != null) && _aiMessage.isNotEmpty) ...[
=======

                            // AI Message - Bottom of card
                            if ((_isSaved || widget.existingEntry?.entry != null) && _aiMessage.isNotEmpty)
>>>>>>> origin/main
                              FadeTransition(
                                opacity: _fadeAnimation,
                                child: Padding(
                                  padding: const EdgeInsets.only(left: 8.0), // 왼쪽 여백 추가
                                  child: Container(
                                    margin: const EdgeInsets.only(top: 16),
                                    padding: const EdgeInsets.all(24),
                                    decoration: BoxDecoration(
                                      color: AppColors.primary.withOpacity(0.1),
                                      borderRadius: BorderRadius.circular(16),
                                      border: Border.all(
                                        color: AppColors.primary.withOpacity(0.2),
                                      ),
                                    ),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          children: [
                                            Container(
                                              width: 40,
                                              height: 40,
                                              decoration: BoxDecoration(
                                                color: AppColors.primary,
                                                borderRadius: BorderRadius.circular(20),
                                              ),
                                              child: Center(
                                                child: Text(
                                                  '🤖',
                                                  style: TextStyle(
                                                    fontSize: 18,
                                                    color: AppColors.primaryForeground,
                                                  ),
                                                ),
                                              ),
                                            ),
                                            const SizedBox(width: 12),
                                            Column(
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  '오늘의 한마디',
                                                  style: TextStyle(
                                                    fontSize: 18,
                                                    fontWeight: FontWeight.w600,
                                                    color: AppColors.primary,
                                                  ),
                                                ),
                                                Text(
                                                  'AI 친구가 전하는 메시지',
                                                  style: TextStyle(
                                                    fontSize: 12,
                                                    color: AppColors.mutedForeground,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ],
                                        ),
                                        const SizedBox(height: 16),
                                        Text(
                                          _aiMessage,
                                          style: TextStyle(
                                            color: AppColors.foreground,
                                            height: 1.5,
                                            fontSize: 14,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
<<<<<<< HEAD
                            ],
=======
>>>>>>> origin/main
                          ],
                        ),
                      ),
                    ),
<<<<<<< HEAD
                  ],
                ),
              ),
=======
                  ),
                ),
              ],
>>>>>>> origin/main
            ),
          ),
        ),
      ),
    );
  }
} 