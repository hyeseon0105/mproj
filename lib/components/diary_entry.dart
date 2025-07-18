import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter/foundation.dart';
import '../models/app_state.dart';
import '../theme.dart';
import '../ui/card.dart';
import '../ui/button.dart';
import 'dart:math';
import 'package:http/http.dart' as http;
import 'dart:convert';
// import 'package:speech_to_text/speech_to_text.dart' as stt;  // 일시적으로 비활성화

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
  // bool _isRecording = false;  // 일시적으로 비활성화
  int _recordingTime = 0;
  String _recognizedText = '';
  bool _hasText = false; // 텍스트 입력 여부를 추적하는 변수 추가
  
  late AnimationController _fadeAnimationController;
  late Animation<double> _fadeAnimation;

  // stt.SpeechToText? _speech;  // 일시적으로 비활성화
  // bool _isSpeechAvailable = false;  // 일시적으로 비활성화
  // List<int>? _recordedAudioBytes;  // 일시적으로 비활성화

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
    _entryController = TextEditingController(text: widget.existingEntry?.entry ?? '');
    _isSaved = widget.existingEntry?.entry != null;
    _currentEmoji = widget.existingEntry?.emoji ?? '';
    _uploadedImages = List.from(widget.existingEntry?.images ?? []);
    _hasText = _entryController.text.trim().isNotEmpty; // 초기 텍스트 상태 설정

    _fadeAnimationController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
    _fadeAnimation = CurvedAnimation(
      parent: _fadeAnimationController,
      curve: Curves.easeInOut,
    );

    // _speech = stt.SpeechToText();  // 일시적으로 비활성화
    // _initSpeech();  // 일시적으로 비활성화

    // Generate AI message for existing entry when component mounts
    if (widget.existingEntry?.entry != null && _aiMessage.isEmpty) {
      final emotion = _analyzeEmotion(widget.existingEntry!.entry!);
      final comfortMessage = _generateComfortMessage(emotion, widget.existingEntry!.entry!);
      setState(() {
        _aiMessage = comfortMessage;
      });
      _fadeAnimationController.forward();
    }
  }

  // Future<void> _initSpeech() async {  // 일시적으로 비활성화
  //   _isSpeechAvailable = await _speech!.initialize();
  //   setState(() {});
  // }

  @override
  void dispose() {
    _entryController.dispose();
    _fadeAnimationController.dispose();
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
    if (_entryController.text.trim().isEmpty) {
      return;
    }
    setState(() {
      _isAnalyzing = true;
    });
    await Future.delayed(const Duration(milliseconds: 1500));
    final emotion = _analyzeEmotion(_entryController.text);
    final comfortMessage = _generateComfortMessage(emotion, _entryController.text);
    setState(() {
      _aiMessage = comfortMessage;
      _currentEmoji = emotionEmojis[emotion]!;
      _isAnalyzing = false;
      _isSaved = true;
    });
    _fadeAnimationController.forward();
    // 일기 데이터 저장 (이미지 포함)
    await _saveDiaryToBackend(_entryController.text, emotion, _uploadedImages.isNotEmpty ? _uploadedImages : null);
    widget.onSave(_entryController.text, emotion, _uploadedImages.isNotEmpty ? _uploadedImages : null);
  }

  Future<void> _saveDiaryToBackend(String entry, Emotion emotion, List<String>? images) async {
    try {
      // 먼저 서버 연결 테스트 (여러 IP 주소 시도)
      http.Response? testResponse;
      String serverUrl = '';
      
      // 에뮬레이터용 IP 주소들 시도
      final testUrls = [
        'http://10.0.2.2:8000/health',
        'http://10.0.3.2:8000/health',
        'http://localhost:8000/health',
      ];
      
      for (String url in testUrls) {
        try {
          testResponse = await http.get(
            Uri.parse(url),
            headers: {'Content-Type': 'application/json'},
          ).timeout(const Duration(seconds: 3));
          
          if (testResponse.statusCode == 200) {
            serverUrl = url.replaceAll('/health', '');
            break;
          }
        } catch (e) {
          continue;
        }
      }
      
      if (testResponse?.statusCode != 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('서버 연결 실패: 모든 IP 주소에서 연결할 수 없습니다')),
        );
        return;
      }

      // 일기 저장
      final response = await http.post(
        Uri.parse('$serverUrl/api/posts/'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'title': '일기',
          'content': entry,
          'status': 'published',
          'images': images ?? [],
        }),
      ).timeout(const Duration(seconds: 10));
      
      if (response.statusCode == 200 || response.statusCode == 201) {
        // 저장 성공
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('일기가 성공적으로 저장되었습니다!')),
        );
      } else {
        // 오류 처리
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('저장 실패: ${response.statusCode} - ${response.body}')),
        );
      }
    } catch (e) {
      // 오류 처리
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('서버 연결 실패: $e')),
      );
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

  Widget _buildImageWidget(String imagePath) {
    Widget errorWidget = Container(
      color: AppColors.muted,
      child: Icon(
        Icons.image,
        color: AppColors.mutedForeground,
      ),
    );

    return Image.network(
      imagePath,
      fit: BoxFit.cover,
      errorBuilder: (context, error, stackTrace) => errorWidget,
    );
  }

  Future<void> _handleImageUpload() async {
    if (_uploadedImages.length >= 3) return;

    // 현재는 이미지 업로드 기능을 비활성화
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('이미지 업로드 기능은 현재 개발 중입니다.')),
    );
  }

  void _handleImageDelete(int index) {
    setState(() {
      _uploadedImages.removeAt(index);
    });
  }

  // Future<void> _startRecording() async {  // 일시적으로 비활성화
  //   if (!_isSpeechAvailable) {
  //     await _initSpeech();
  //   }
  //   setState(() {
  //     _isRecording = true;
  //     _recordingTime = 0;
  //     _recognizedText = '';
  //     _recordedAudioBytes = null;
  //   });
  //   _speech!.listen(
  //     onResult: (result) {
  //       setState(() {
  //         _recognizedText = result.recognizedWords;
  //         _entryController.text = _recognizedText;
  //         _hasText = _entryController.text.trim().isNotEmpty;
  //       });
  //     },
  //     listenFor: const Duration(seconds: 10),
  //     pauseFor: const Duration(seconds: 2),
  //     partialResults: true,
  //     localeId: 'ko_KR',
  //     onSoundLevelChange: null,
  //     cancelOnError: true,
  //     listenMode: stt.ListenMode.confirmation,
  //   );
  //   // 타이머: 10초 후 자동 종료
  //   await Future.delayed(const Duration(seconds: 10));
  //   await _stopRecording();
  // }

  // Future<void> _stopRecording() async {  // 일시적으로 비활성화
  //   await _speech?.stop();
  //   setState(() {
  //     _isRecording = false;
  //     _recordingTime = 0;
  //   });
  //   // (선택) 오디오 파일 저장 및 Whisper 업로드
  //   // 실제로는 speech_to_text에서 오디오 파일을 직접 제공하지 않으므로,
  //   // 웹/모바일에서 별도 녹음 패키지(flutter_sound 등)와 조합 필요
  //   // 여기서는 텍스트만 Whisper로 업로드(추후 확장 가능)
  //   await _sendTextToWhisper(_entryController.text);
  // }

  // Future<void> _sendTextToWhisper(String text) async {  // 일시적으로 비활성화
  //   // 실제로는 오디오 파일 업로드가 더 정확하지만,
  //   // 데모로 텍스트를 Whisper에 전송(Whisper는 오디오만 지원, 실제 오디오 업로드는 별도 구현 필요)
  //   // 이 부분은 오디오 녹음 패키지와 연동 시 확장 가능
  //   // 현재는 speech_to_text 결과만 사용
  //   // TODO: 오디오 파일 업로드 구현 시 아래 코드 수정
  // }

  // void _handleRecordingToggle() {  // 일시적으로 비활성화
  //   if (_isRecording) {
  //     _stopRecording();
  //   } else {
  //     _startRecording();
  //   }
  // }

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

  @override
  Widget build(BuildContext context) {
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
                Padding(
                  padding: const EdgeInsets.only(bottom: 16),
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
                      ),
                      child: AppCard(
                        backgroundColor: AppColors.calendarBg,
                        borderRadius: BorderRadius.circular(24),
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Date Display with Voice Recording & Photo Upload Buttons
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                // Date Display
                                Row(
                                  children: [
                                    if (_isSaved || widget.existingEntry?.entry != null)
                                      Container(
                                        width: 48,
                                        height: 48,
                                        decoration: BoxDecoration(
                                          color: AppColors.emotionCalm,
                                          borderRadius: BorderRadius.circular(24),
                                        ),
                                        child: Center(
                                          child: Text(
                                            _currentEmoji,
                                            style: const TextStyle(fontSize: 24),
                                          ),
                                        ),
                                      ),
                                    if (_isSaved || widget.existingEntry?.entry != null)
                                      const SizedBox(width: 16),
                                    // 날짜/요일에 여백 추가
                                    Padding(
                                      padding: const EdgeInsets.only(left: 8.0), // 왼쪽 여백 추가
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          SizedBox(height: 8),
                                          Text(
                                            _formatDate(widget.selectedDate),
                                            style: TextStyle(
                                              fontSize: 18,
                                              fontWeight: FontWeight.bold,
                                              color: AppColors.foreground,
                                              height: 1.2,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),

                                // Voice Recording & Photo Upload Buttons
                                Row(
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    // 타이머 (녹음 중일 때만) - 일시적으로 비활성화
                                    // if (_isRecording) ...[
                                    //   Container(
                                    //     margin: const EdgeInsets.only(right: 8),
                                    //     padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                    //     decoration: BoxDecoration(
                                    //       color: Colors.red.withOpacity(0.1),
                                    //       borderRadius: BorderRadius.circular(12),
                                    //       border: Border.all(color: Colors.red.withOpacity(0.2)),
                                    //     ),
                                    //     child: Text(
                                    //       '${_recordingTime ~/ 60}:${(_recordingTime % 60).toString().padLeft(2, '0')}',
                                    //       style: TextStyle(
                                    //         fontSize: 12,
                                    //         fontWeight: FontWeight.w500,
                                    //         color: Colors.red,
                                    //       ),
                                    //     ),
                                    //   ),
                                    // ],
                                    // 마이크 버튼 (일시적으로 비활성화)
                                    // AppButton(
                                    //   onPressed: _handleRecordingToggle,
                                    //   variant: ButtonVariant.ghost,
                                    //   size: ButtonSize.icon,
                                    //   child: Container(
                                    //     width: 40,
                                    //     height: 40,
                                    //     decoration: BoxDecoration(
                                    //       borderRadius: BorderRadius.circular(20),
                                    //       color: _isRecording 
                                    //           ? Colors.red
                                    //           : Colors.red.withOpacity(0.1),
                                    //       border: Border.all(
                                    //         color: Colors.red.withOpacity(0.2),
                                    //         width: 2,
                                    //       ),
                                    //     ),
                                    //     child: Center(
                                    //       child: Icon(
                                    //         Icons.mic,
                                    //         size: 20,
                                    //         color: _isRecording ? Colors.white : Colors.red,
                                    //       ),
                                    //     ),
                                    //   ),
                                    // ),
                                    const SizedBox(width: 8),
                                    // 업로드 버튼
                                    if (_uploadedImages.length < 3)
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
                                  ],
                                ),
                              ],
                            ),
                            
                            const SizedBox(height: 24),

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
                                        ),
                                      ],
                                    ),
                                  );
                                },
                              ),
                              const SizedBox(height: 16),
                            ],

                            // Diary Content
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
                              ),
                            ),
                            
                            const SizedBox(height: 12),
                            
                            // Save Button with improved disabled style
                            if (!_isSaved)
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

                            // AI Message - Bottom of card
                            if ((_isSaved || widget.existingEntry?.entry != null) && _aiMessage.isNotEmpty)
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
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
} 