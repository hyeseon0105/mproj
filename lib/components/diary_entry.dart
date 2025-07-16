import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/app_state.dart';
import '../theme.dart';
import '../ui/card.dart';
import '../ui/button.dart';
import 'dart:math';

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
  
  late AnimationController _fadeAnimationController;
  late Animation<double> _fadeAnimation;

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

    _fadeAnimationController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
    _fadeAnimation = CurvedAnimation(
      parent: _fadeAnimationController,
      curve: Curves.easeInOut,
    );

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
        "귀여운 동물들처럼 순수하고 따뜻한 마음이 느껴져요! 이런 순간들이 마음을 치유해주죠 🐱",
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
    
    // Simulate AI analysis delay
    await Future.delayed(const Duration(milliseconds: 1500));
    
    final emotion = _analyzeEmotion(_entryController.text);
    
    // Generate comfort message and update emoji
    final comfortMessage = _generateComfortMessage(emotion, _entryController.text);
    setState(() {
      _aiMessage = comfortMessage;
      _currentEmoji = emotionEmojis[emotion]!; // 새로 분석된 감정에 따라 이모티콘 업데이트
      _isAnalyzing = false;
      _isSaved = true;
    });
    
    _fadeAnimationController.forward();
    
    // 일기 데이터 저장 (이미지 포함)
    widget.onSave(_entryController.text, emotion, _uploadedImages.isNotEmpty ? _uploadedImages : null);
  }

  String _formatDate(String dateStr) {
    final date = DateTime.parse(dateStr);
    final month = date.month;
    final day = date.day;
    final dayNames = ['일요일', '월요일', '화요일', '수요일', '목요일', '금요일', '토요일'];
    final dayName = dayNames[date.weekday % 7];
    
    return '${month}월 ${day}일\n$dayName';
  }

  Future<void> _handleImageUpload() async {
    if (_uploadedImages.length >= 3) return;

    // 시뮬레이션: 더미 이미지 추가
    setState(() {
      _uploadedImages.add('https://picsum.photos/200/200?random=${_uploadedImages.length}');
    });
  }

  void _handleImageDelete(int index) {
    setState(() {
      _uploadedImages.removeAt(index);
    });
  }

  Future<void> _startRecording() async {
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
        child: Column(
          children: List.generate(13, (index) => 
            Container(
              height: 32,
              decoration: const BoxDecoration(
                border: Border(
                  bottom: BorderSide(
                    color: Color(0x33000000), // muted-foreground/20
                    width: 1,
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(minHeight: double.infinity),
      color: AppColors.background,
      padding: const EdgeInsets.all(16),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 896), // max-w-4xl
          child: Column(
            children: [
              // Header
              Row(
                children: [
                  const SizedBox(width: 216), // ml-[216px]
                  AppButton(
                    onPressed: widget.onBack,
                    variant: ButtonVariant.ghost,
                    size: ButtonSize.icon,
                    child: Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const Icon(Icons.arrow_back, size: 20),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // Main Content
              Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 448), // max-w-md
                  child: AppCard(
                    backgroundColor: AppColors.calendarBg,
                    borderRadius: BorderRadius.circular(24),
                    padding: const EdgeInsets.all(24),
                    child: Stack(
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Voice Recording & Photo Upload Buttons
                            Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                // Voice Recording Button with Timer
                                Column(
                                  children: [
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
                                            color: _isRecording 
                                                ? Colors.red 
                                                : Colors.red.withOpacity(0.2),
                                            width: 2,
                                          ),
                                        ),
                                        child: Icon(
                                          Icons.mic,
                                          size: 20,
                                          color: _isRecording ? Colors.white : Colors.red,
                                        ),
                                      ),
                                    ),
                                    
                                    // Recording Timer
                                    if (_isRecording) ...[
                                      const SizedBox(height: 4),
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                        decoration: BoxDecoration(
                                          color: Colors.red.withOpacity(0.1),
                                          borderRadius: BorderRadius.circular(12),
                                          border: Border.all(color: Colors.red.withOpacity(0.2)),
                                        ),
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
                                  ],
                                ),
                                
                                const SizedBox(width: 8),
                                
                                // Photo Upload Button
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
                            
                            const SizedBox(height: 24),

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
                                const SizedBox(width: 16),
                                Expanded(
                                  child: Text(
                                    _formatDate(widget.selectedDate),
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                      color: AppColors.foreground,
                                      height: 1.2,
                                    ),
                                  ),
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
                                          child: Image.network(
                                            _uploadedImages[index],
                                            fit: BoxFit.cover,
                                            errorBuilder: (context, error, stackTrace) {
                                              return Container(
                                                color: AppColors.muted,
                                                child: Icon(
                                                  Icons.image,
                                                  color: AppColors.mutedForeground,
                                                ),
                                              );
                                            },
                                          ),
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
                            SizedBox(
                              height: 400,
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
                                          height: 2.0, // leading-8
                                          fontSize: 16,
                                        ),
                                        decoration: InputDecoration(
                                          hintText: widget.existingEntry?.entry != null 
                                              ? "일기를 수정해보세요..." 
                                              : "오늘의 이야기를 작성해보세요...",
                                          hintStyle: TextStyle(
                                            color: AppColors.mutedForeground,
                                          ),
                                          border: InputBorder.none,
                                          contentPadding: EdgeInsets.zero,
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            
                            const SizedBox(height: 48),
                            
                            // Save Button
                            if (!_isSaved)
                              SizedBox(
                                width: double.infinity,
                                child: AppButton(
                                  onPressed: _entryController.text.trim().isNotEmpty && !_isAnalyzing 
                                      ? _handleSave 
                                      : null,
                                  variant: ButtonVariant.primary,
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(vertical: 12),
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
                                                color: AppColors.primaryForeground,
                                              ),
                                              const SizedBox(width: 8),
                                              Text(
                                                widget.existingEntry?.entry != null 
                                                    ? '일기 수정하기' 
                                                    : '일기 저장하기',
                                                style: TextStyle(
                                                  color: AppColors.primaryForeground,
                                                ),
                                              ),
                                            ],
                                          ),
                                  ),
                                ),
                              ),

                            // AI Message - Bottom of card
                            if ((_isSaved || widget.existingEntry?.entry != null) && _aiMessage.isNotEmpty)
                              FadeTransition(
                                opacity: _fadeAnimation,
                                child: Container(
                                  margin: const EdgeInsets.only(top: 32),
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
                          ],
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
    );
  }
} 