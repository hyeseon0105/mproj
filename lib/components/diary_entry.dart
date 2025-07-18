import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter/foundation.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import '../models/app_state.dart';
import '../theme.dart';
import '../ui/card.dart';
import '../ui/button.dart';
import 'dart:math';
// 웹 전용 이미지 업로드 (조건부 import)
import 'web_image_upload.dart' if (dart.library.io) 'web_image_upload_stub.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
// import 'package:speech_to_text/speech_to_text.dart' as stt;  // 모바일에서 문제가 있어서 임시로 비활성화

typedef SaveDiaryCallback = void Function(String entry, Emotion emotion, List<String>? images);

class EmotionChainItem {
  final String emoji;
  final Emotion type;

  EmotionChainItem({required this.emoji, required this.type});
}



// 세부 감정 타입 추가
enum DetailedEmotion {
  angry, anxious, calm, confident, confused, determined, 
  excited, happy, love, neutral, sad, touched
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
  
  late AnimationController _fadeAnimationController;
  late Animation<double> _fadeAnimation;

  // stt.SpeechToText? _speech;  // 모바일에서 문제가 있어서 임시로 비활성화
  // bool _isSpeechAvailable = false;  // 모바일에서 문제가 있어서 임시로 비활성화
  // List<int>? _recordedAudioBytes;  // 모바일에서 문제가 있어서 임시로 비활성화

  // ImagePicker는 실제 앱에서 image_picker 패키지로 구현

  // 감정 체인 데이터 (Firebase 이미지 URL 사용)
  final List<EmotionChainItem> emotionChain = [
    EmotionChainItem(emoji: 'https://firebasestorage.googleapis.com/v0/b/diary-3bbf7.firebasestorage.app/o/fruit%2Fneutral_fruit-removebg-preview.png?alt=media&token=9bdea06c-13e6-4c59-b961-1424422a3c39', type: Emotion.fruit),
    EmotionChainItem(emoji: 'https://firebasestorage.googleapis.com/v0/b/diary-3bbf7.firebasestorage.app/o/animal%2Fneutral_animal-removebg-preview.png?alt=media&token=f884e38d-5d8c-4d4a-bb62-a47a198d384f', type: Emotion.animal),
    EmotionChainItem(emoji: 'https://firebasestorage.googleapis.com/v0/b/diary-3bbf7.firebasestorage.app/o/shape%2Fneutral_shape-removebg-preview.png?alt=media&token=02e85132-3a83-4257-8c1e-d2e478c7fcf5', type: Emotion.shape),
    EmotionChainItem(emoji: 'https://firebasestorage.googleapis.com/v0/b/diary-3bbf7.firebasestorage.app/o/wheather%2Fneutral_weather-removebg-preview.png?alt=media&token=57ad1adf-baa6-4b79-96f5-066a4ec3358f', type: Emotion.weather),
    EmotionChainItem(emoji: 'https://firebasestorage.googleapis.com/v0/b/diary-3bbf7.firebasestorage.app/o/fruit%2Fhappy_fruit-removebg-preview.png?alt=media&token=d10a503b-fee7-4bc2-b141-fd4b33dae1f1', type: Emotion.fruit),
    EmotionChainItem(emoji: 'https://firebasestorage.googleapis.com/v0/b/diary-3bbf7.firebasestorage.app/o/animal%2Fhappy_animal-removebg-preview.png?alt=media&token=66ff8e2d-d941-4fd7-9d7f-9766db03cbd5', type: Emotion.animal),
  ];

  // 감정에 따른 Firebase 이미지 URL 매핑 (기본값은 neutral)
  final Map<Emotion, String> emotionEmojis = {
    Emotion.fruit: 'https://firebasestorage.googleapis.com/v0/b/diary-3bbf7.firebasestorage.app/o/fruit%2Fneutral_fruit-removebg-preview.png?alt=media&token=9bdea06c-13e6-4c59-b961-1424422a3c39',
    Emotion.animal: 'https://firebasestorage.googleapis.com/v0/b/diary-3bbf7.firebasestorage.app/o/animal%2Fneutral_animal-removebg-preview.png?alt=media&token=f884e38d-5d8c-4d4a-bb62-a47a198d384f',
    Emotion.shape: 'https://firebasestorage.googleapis.com/v0/b/diary-3bbf7.firebasestorage.app/o/shape%2Fneutral_shape-removebg-preview.png?alt=media&token=02e85132-3a83-4257-8c1e-d2e478c7fcf5',
    Emotion.weather: 'https://firebasestorage.googleapis.com/v0/b/diary-3bbf7.firebasestorage.app/o/wheather%2Fneutral_weather-removebg-preview.png?alt=media&token=57ad1adf-baa6-4b79-96f5-066a4ec3358f',
  };

  // 상세 감정별 아이콘 URL 매핑
  final Map<DetailedEmotion, Map<Emotion, String>> detailedEmotionIcons = {
    DetailedEmotion.angry: {
      Emotion.animal: 'https://firebasestorage.googleapis.com/v0/b/diary-3bbf7.firebasestorage.app/o/animal%2Fangry_animal-removebg-preview.png?alt=media&token=9bde31db-8801-4af0-9368-e6ce4a35fbac',
      Emotion.fruit: 'https://firebasestorage.googleapis.com/v0/b/diary-3bbf7.firebasestorage.app/o/fruit%2Fangry_fruit-removebg-preview.png?alt=media&token=679778b9-5a1b-469a-8e86-b01585cb1ee2',
      Emotion.weather: 'https://firebasestorage.googleapis.com/v0/b/diary-3bbf7.firebasestorage.app/o/wheather%2Fangry_weather-removebg-preview.png?alt=media&token=2f4c6212-697d-49b7-9d5e-ae1f2b1fa84e',
      Emotion.shape: 'https://firebasestorage.googleapis.com/v0/b/diary-3bbf7.firebasestorage.app/o/shape%2Fangry_shape-removebg-preview.png?alt=media&token=92a25f79-4c1d-4b5d-9e5c-2f469e56cefa',

    },
    DetailedEmotion.anxious: {
      Emotion.animal: 'https://firebasestorage.googleapis.com/v0/b/diary-3bbf7.firebasestorage.app/o/animal%2Fanxious_animal-removebg-preview.png?alt=media&token=bd25e31d-629b-4e79-b95e-019f8c76dac2',
      Emotion.fruit: 'https://firebasestorage.googleapis.com/v0/b/diary-3bbf7.firebasestorage.app/o/fruit%2Fanxious_fruit-removebg-preview.png?alt=media&token=be8f8279-2b08-47bf-9856-c39daf5eac40',
      Emotion.weather: 'https://firebasestorage.googleapis.com/v0/b/diary-3bbf7.firebasestorage.app/o/wheather%2Fanxious_weather-removebg-preview.png?alt=media&token=fc718a17-8d8e-4ed1-a78a-891fa9a149d0',
      Emotion.shape: 'https://firebasestorage.googleapis.com/v0/b/diary-3bbf7.firebasestorage.app/o/shape%2Fanxious_shape-removebg-preview.png?alt=media&token=7859ebac-cd9d-43a3-a42c-aec651d37e6e',
    },
    DetailedEmotion.calm: {
      Emotion.animal: 'https://firebasestorage.googleapis.com/v0/b/diary-3bbf7.firebasestorage.app/o/animal%2Fcalm_animal-removebg-preview.png?alt=media&token=afd7bf65-5150-40e3-8b95-cd956dff113d',
      Emotion.fruit: 'https://firebasestorage.googleapis.com/v0/b/diary-3bbf7.firebasestorage.app/o/fruit%2Fcalm_fruit-removebg-preview.png?alt=media&token=839efcad-0022-4cc9-ac38-90175d9026d2',
      Emotion.weather: 'https://firebasestorage.googleapis.com/v0/b/diary-3bbf7.firebasestorage.app/o/wheather%2Fcalm_weather-removebg-preview.png?alt=media&token=7703fd25-fe2b-4750-a415-5f86c4e7b058',
      Emotion.shape: 'https://firebasestorage.googleapis.com/v0/b/diary-3bbf7.firebasestorage.app/o/shape%2Fcalm_shape-removebg-preview.png?alt=media&token=cdc2fa85-10b7-46f6-881c-dd874c38b3ea',
    },
    DetailedEmotion.confident: {
      Emotion.animal: 'https://firebasestorage.googleapis.com/v0/b/diary-3bbf7.firebasestorage.app/o/animal%2Fconfident__animal-removebg-preview.png?alt=media&token=2983b323-a2a6-40aa-9b6c-a381d944dd27',
      Emotion.fruit: 'https://firebasestorage.googleapis.com/v0/b/diary-3bbf7.firebasestorage.app/o/fruit%2Fconfident_fruit-removebg-preview.png?alt=media&token=6edcc903-8d78-4dd9-bcdd-1c6b26645044',
      Emotion.weather: 'https://firebasestorage.googleapis.com/v0/b/diary-3bbf7.firebasestorage.app/o/wheather%2Fconfident_weather-removebg-preview.png?alt=media&token=ea30d002-312b-4ae5-ad85-933bbc009dc6',
      Emotion.shape: 'https://firebasestorage.googleapis.com/v0/b/diary-3bbf7.firebasestorage.app/o/shape%2Fconfident_shape-removebg-preview.png?alt=media&token=8ab02bc8-8569-42ff-b78d-b9527f15d0af',
    },
    DetailedEmotion.confused: {
      Emotion.animal: 'https://firebasestorage.googleapis.com/v0/b/diary-3bbf7.firebasestorage.app/o/animal%2Fconfused__animal-removebg-preview.png?alt=media&token=74192a1e-86a7-4eb6-b690-154984c427dc',
      Emotion.fruit: 'https://firebasestorage.googleapis.com/v0/b/diary-3bbf7.firebasestorage.app/o/fruit%2Fconfused_fruit-removebg-preview.png?alt=media&token=7adfcf22-af7a-4eb1-a225-34875b6540cf',
      Emotion.weather: 'https://firebasestorage.googleapis.com/v0/b/diary-3bbf7.firebasestorage.app/o/wheather%2Fconfused_weather-removebg-preview.png?alt=media&token=afdfb6bf-2c69-4ef2-97a1-2e5aa67e6fdb',
      Emotion.shape: 'https://firebasestorage.googleapis.com/v0/b/diary-3bbf7.firebasestorage.app/o/shape%2Fconfused_shape-removebg-preview.png?alt=media&token=4794d127-9b61-4c68-86de-8478c4da8fb9',
    },
    DetailedEmotion.determined: {
      Emotion.animal: 'https://firebasestorage.googleapis.com/v0/b/diary-3bbf7.firebasestorage.app/o/animal%2Fdetermined_animal-removebg-preview.png?alt=media&token=abf05981-4ab3-49b3-ba37-096ab8c22478',
      Emotion.fruit: 'https://firebasestorage.googleapis.com/v0/b/diary-3bbf7.firebasestorage.app/o/fruit%2Fdetermined_fruit-removebg-preview.png?alt=media&token=ed288879-86c4-4d6d-946e-477f2aafc3ce',
      Emotion.weather: 'https://firebasestorage.googleapis.com/v0/b/diary-3bbf7.firebasestorage.app/o/wheather%2Fdetermined_weather-removebg-preview.png?alt=media&token=0eb8fb3d-22dd-4b4f-8e12-7d830f32be6d',
      Emotion.shape: 'https://firebasestorage.googleapis.com/v0/b/diary-3bbf7.firebasestorage.app/o/shape%2Fdetermined_shape-removebg-preview.png?alt=media&token=69eb4cf0-ab61-4f5e-add3-b2148dc2a108',
    },
    DetailedEmotion.excited: {
      Emotion.animal: 'https://firebasestorage.googleapis.com/v0/b/diary-3bbf7.firebasestorage.app/o/animal%2Fexcited_animal-removebg-preview.png?alt=media&token=48442937-5504-4392-88a9-039aef405f14',
      Emotion.fruit: 'https://firebasestorage.googleapis.com/v0/b/diary-3bbf7.firebasestorage.app/o/fruit%2Fexcited_fruit-removebg-preview.png?alt=media&token=0284bce2-aa88-4766-97fb-5d5d2248cf31',
      Emotion.weather: 'https://firebasestorage.googleapis.com/v0/b/diary-3bbf7.firebasestorage.app/o/wheather%2Fexcited_weather-removebg-preview.png?alt=media&token=5de71f38-1178-4e3c-887e-af07547caba9',
      Emotion.shape: 'https://firebasestorage.googleapis.com/v0/b/diary-3bbf7.firebasestorage.app/o/shape%2Fexcited_shape-removebg-preview.png?alt=media&token=85fadfb8-7006-44d0-a39d-b3fd6070bb96',
    },
    DetailedEmotion.happy: {
      Emotion.animal: 'https://firebasestorage.googleapis.com/v0/b/diary-3bbf7.firebasestorage.app/o/animal%2Fhappy_animal-removebg-preview.png?alt=media&token=66ff8e2d-d941-4fd7-9d7f-9766db03cbd5',
      Emotion.fruit: 'https://firebasestorage.googleapis.com/v0/b/diary-3bbf7.firebasestorage.app/o/fruit%2Fhappy_fruit-removebg-preview.png?alt=media&token=d10a503b-fee7-4bc2-b141-fd4b33dae1f1',
      Emotion.weather: 'https://firebasestorage.googleapis.com/v0/b/diary-3bbf7.firebasestorage.app/o/wheather%2Fhappy_weather-removebg-preview.png?alt=media&token=fd77e998-6f47-459a-bd1c-458e309fed41',
      Emotion.shape: 'https://firebasestorage.googleapis.com/v0/b/diary-3bbf7.firebasestorage.app/o/shape%2Fhappy_shape-removebg-preview.png?alt=media&token=5a8aa9dd-6ea5-4132-95af-385340846076',
    },
    DetailedEmotion.love: {
      Emotion.animal: 'https://firebasestorage.googleapis.com/v0/b/diary-3bbf7.firebasestorage.app/o/animal%2Flove_animal-removebg-preview.png?alt=media&token=e0e2ccbd-b59a-4d09-968a-562208f90be1',
      Emotion.fruit: 'https://firebasestorage.googleapis.com/v0/b/diary-3bbf7.firebasestorage.app/o/fruit%2Flove_fruit-removebg-preview.png?alt=media&token=ba7857c6-5afd-48e0-addd-7b3f54583c15',
      Emotion.weather: 'https://firebasestorage.googleapis.com/v0/b/diary-3bbf7.firebasestorage.app/o/wheather%2Flove_weather-removebg-preview.png?alt=media&token=2451105b-ab3e-482d-bf9f-12f0a6a69a53',
      Emotion.shape: 'https://firebasestorage.googleapis.com/v0/b/diary-3bbf7.firebasestorage.app/o/shape%2Flove_shape-removebg-preview.png?alt=media&token=1a7ec74f-4297-42a4-aeb8-97aee1e9ff6c',
    },
    DetailedEmotion.neutral: {
      Emotion.animal: 'https://firebasestorage.googleapis.com/v0/b/diary-3bbf7.firebasestorage.app/o/animal%2Fneutral_animal-removebg-preview.png?alt=media&token=f884e38d-5d8c-4d4a-bb62-a47a198d384f',
      Emotion.fruit: 'https://firebasestorage.googleapis.com/v0/b/diary-3bbf7.firebasestorage.app/o/fruit%2Fneutral_fruit-removebg-preview.png?alt=media&token=9bdea06c-13e6-4c59-b961-1424422a3c39',
      Emotion.weather: 'https://firebasestorage.googleapis.com/v0/b/diary-3bbf7.firebasestorage.app/o/wheather%2Fneutral_weather-removebg-preview.png?alt=media&token=57ad1adf-baa6-4b79-96f5-066a4ec3358f',
      Emotion.shape: 'https://firebasestorage.googleapis.com/v0/b/diary-3bbf7.firebasestorage.app/o/shape%2Fneutral_shape-removebg-preview.png?alt=media&token=02e85132-3a83-4257-8c1e-d2e478c7fcf5',
    },
    DetailedEmotion.sad: {
      Emotion.animal: 'https://firebasestorage.googleapis.com/v0/b/diary-3bbf7.firebasestorage.app/o/animal%2Fsad_animal-removebg-preview.png?alt=media&token=04c99bd8-8ad4-43de-91cd-3b7354780677',
      Emotion.fruit: 'https://firebasestorage.googleapis.com/v0/b/diary-3bbf7.firebasestorage.app/o/fruit%2Fsad_fruit-removebg-preview.png?alt=media&token=e9e0b0f7-6590-4209-a7d1-26377eb33c05',
      Emotion.weather: 'https://firebasestorage.googleapis.com/v0/b/diary-3bbf7.firebasestorage.app/o/wheather%2Fsad_weather-removebg-preview.png?alt=media&token=aa972b9a-8952-4dc7-abe7-692ec7be0d16',
      Emotion.shape: 'https://firebasestorage.googleapis.com/v0/b/diary-3bbf7.firebasestorage.app/o/shape%2Fsad_shape-removebg-preview.png?alt=media&token=acbc7284-1126-4428-a3b2-f8b6e7932b98',
    },
    DetailedEmotion.touched: {
      Emotion.animal: 'https://firebasestorage.googleapis.com/v0/b/diary-3bbf7.firebasestorage.app/o/animal%2Ftouched_animal-removebg-preview.png?alt=media&token=629be9ec-be17-407f-beb0-6b67f09b7036',
      Emotion.fruit: 'https://firebasestorage.googleapis.com/v0/b/diary-3bbf7.firebasestorage.app/o/fruit%2Ftouched_fruit-removebg-preview.png?alt=media&token=c69dee6d-7d53-4af7-a884-2f751aecbe42',
      Emotion.weather: 'https://firebasestorage.googleapis.com/v0/b/diary-3bbf7.firebasestorage.app/o/wheather%2Ftouched_weather-removebg-preview.png?alt=media&token=5e224042-72ae-45a4-891a-8e6abdb5285c',
      Emotion.shape: 'https://firebasestorage.googleapis.com/v0/b/diary-3bbf7.firebasestorage.app/o/shape%2Ftouched_shape-removebg-preview.png?alt=media&token=bbb50a1c-90d6-43fd-be40-4be4f51bc1d0',
    },
  };

  // 현재 선택된 감정 상태
  DetailedEmotion _currentDetailedEmotion = DetailedEmotion.happy;
  Emotion _currentEmotionCategory = Emotion.animal;

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

    // _speech = stt.SpeechToText();  // 모바일에서 문제가 있어서 임시로 비활성화
    // _initSpeech();  // 모바일에서 문제가 있어서 임시로 비활성화

    // Generate AI message for existing entry when component mounts
    if (widget.existingEntry?.entry != null && _aiMessage.isEmpty) {
      final detailedEmotion = _analyzeDetailedEmotion(widget.existingEntry!.entry!);
      final comfortMessage = _generateComfortMessage(detailedEmotion, widget.existingEntry!.entry!);
      setState(() {
        _aiMessage = comfortMessage;
      });
      _fadeAnimationController.forward();
    }
  }

  Future<void> _initSpeech() async {
    // 음성 인식 기능은 현재 모바일에서 비활성화됨
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

  // AI 감정 분석 - DetailedEmotion 반환
  DetailedEmotion _analyzeDetailedEmotion(String text) {
    final angryWords = ['화나', '분노', '짜증', '열받', '빡치', '열불'];
    final anxiousWords = ['불안', '걱정', '긴장', '두려움', '떨림', '초조'];
    final calmWords = ['평온', '차분', '여유', '편안', '안정', '고요'];
    final confidentWords = ['자신', '확신', '똑똑', '능력', '성공', '자부심'];
    final confusedWords = ['혼란', '헷갈', '어려움', '모르겠', '복잡', '난감'];
    final determinedWords = ['의지', '결심', '목표', '노력', '도전', '포기하지'];
    final excitedWords = ['설렘', '기대', '떨림', '긴장', '두근', '흥분'];
    final happyWords = ['행복', '기쁨', '웃음', '즐거움', '신나', '좋아'];
    final loveWords = ['사랑', '연애', '데이트', '키스', '포옹', '로맨틱'];
    final neutralWords = ['보통', '평범', '일반', '그냥', '그저', '그대로'];
    final sadWords = ['슬픔', '우울', '눈물', '힘들', '아픔', '외로움'];
    final touchedWords = ['감동', '감사', '따뜻', '마음', '소중', '감동적'];

    final lowerText = text.toLowerCase();
    
    if (angryWords.any((word) => lowerText.contains(word))) return DetailedEmotion.angry;
    if (anxiousWords.any((word) => lowerText.contains(word))) return DetailedEmotion.anxious;
    if (calmWords.any((word) => lowerText.contains(word))) return DetailedEmotion.calm;
    if (confidentWords.any((word) => lowerText.contains(word))) return DetailedEmotion.confident;
    if (confusedWords.any((word) => lowerText.contains(word))) return DetailedEmotion.confused;
    if (determinedWords.any((word) => lowerText.contains(word))) return DetailedEmotion.determined;
    if (excitedWords.any((word) => lowerText.contains(word))) return DetailedEmotion.excited;
    if (happyWords.any((word) => lowerText.contains(word))) return DetailedEmotion.happy;
    if (loveWords.any((word) => lowerText.contains(word))) return DetailedEmotion.love;
    if (neutralWords.any((word) => lowerText.contains(word))) return DetailedEmotion.neutral;
    if (sadWords.any((word) => lowerText.contains(word))) return DetailedEmotion.sad;
    if (touchedWords.any((word) => lowerText.contains(word))) return DetailedEmotion.touched;
    
    return DetailedEmotion.happy; // 기본값
  }

  String _generateComfortMessage(DetailedEmotion detailedEmotion, String entryText) {
    final messages = {
      DetailedEmotion.angry: [
        "화가 난 하루였군요. 이런 감정도 자연스러운 거예요. 마음을 진정시켜보세요 🔥",
        "분노가 가득한 하루였나 봐요. 깊은 숨을 쉬며 마음을 차분히 해보세요 💪",
      ],
      DetailedEmotion.anxious: [
        "불안한 하루였군요. 걱정이 많았나 봐요. 모든 일이 잘 될 거예요 🌸",
        "긴장된 하루였나 봐요. 차분히 생각해보면 해결책이 보일 거예요 🕊️",
      ],
      DetailedEmotion.calm: [
        "평온하고 차분한 하루였군요. 안정된 마음으로 보낸 소중한 시간이었어요 😌",
        "고요한 하루였군요. 편안함과 평온함이 가득한 하루였네요! 🌿",
      ],
      DetailedEmotion.confident: [
        "자신감 넘치는 하루였군요! 당신의 능력을 믿어요 💪",
        "확신에 찬 하루였나 봐요. 이런 자신감이 계속 이어지길 바라요 ⭐",
      ],
      DetailedEmotion.confused: [
        "헷갈리는 하루였군요. 복잡한 마음이었나 봐요. 천천히 정리해보세요 🤔",
        "혼란스러운 하루였나 봐요. 시간이 지나면 답이 보일 거예요 💭",
      ],
      DetailedEmotion.determined: [
        "의지가 가득한 하루였군요! 목표를 향해 나아가는 모습이 멋져요 🎯",
        "결심이 굳은 하루였나 봐요. 포기하지 않는 당신이 자랑스러워요 💪",
      ],
      DetailedEmotion.excited: [
        "설렘이 가득한 하루였군요! 떨림과 긴장이 모두 넘치는 즐거운 시간이었어요 🤩",
        "두근거리는 하루였군요. 흥분과 기대가 가득한 하루였네요! ✨",
      ],
      DetailedEmotion.happy: [
        "정말 행복한 하루였나 봐요! 이런 기쁨이 계속 이어지길 바라요 😄",
        "웃음이 가득한 하루였군요! 행복한 순간들이 더 많이 찾아올 거예요 😄",
      ],
      DetailedEmotion.love: [
        "사랑스러운 하루였군요! 연애와 로맨틱한 순간들이 가득했네요 💕",
        "키스와 포옹이 가득한 하루였군요. 따뜻한 사랑이 가득한 하루였네요! 💕",
      ],
      DetailedEmotion.neutral: [
        "평범한 하루였군요. 이런 일상의 소중함을 느끼는 시간이었어요 🌟",
        "보통의 하루였나 봐요. 작은 행복들이 모여 큰 기쁨이 되는 거예요 ✨",
      ],
      DetailedEmotion.sad: [
        "힘든 하루였군요. 슬픔도 자연스러운 감정이에요. 곧 좋은 일들이 찾아올 거예요 😢",
        "마음이 아픈 하루였나 봐요. 이런 감정도 인정하고 받아들이는 게 중요해요 💙",
      ],
      DetailedEmotion.touched: [
        "감동적인 하루였군요! 마음이 따뜻해지는 순간들이 있었나 봐요 💖",
        "감사한 하루였나 봐요. 소중한 순간들을 만끽하는 시간이었어요 🙏",
      ],
    };

    final emotionMessages = messages[detailedEmotion] ?? messages[DetailedEmotion.happy]!;
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
    final detailedEmotion = _analyzeDetailedEmotion(_entryController.text);
    final comfortMessage = _generateComfortMessage(detailedEmotion, _entryController.text);
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
      final response = await http.post(
        Uri.parse('http://localhost:8000/api/posts/'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'title': '일기',
          'content': entry,
          'status': 'published',
          'images': images ?? [],
        }),
      );
      if (response.statusCode == 200 || response.statusCode == 201) {
        // 저장 성공
      } else {
        // 오류 처리
      }
    } catch (e) {
      // 오류 처리
    }
  }

  Emotion _analyzeEmotion(String text) {
    // 간단한 감정 분석 로직 - 실제 Emotion enum에 맞게 수정
    final lowerText = text.toLowerCase();
    
    if (lowerText.contains('행복') || lowerText.contains('기쁘') || lowerText.contains('좋') || 
        lowerText.contains('즐거') || lowerText.contains('웃') || lowerText.contains('😊') || 
        lowerText.contains('😄') || lowerText.contains('😍')) {
      return Emotion.fruit; // happy -> fruit
    } else if (lowerText.contains('슬프') || lowerText.contains('우울') || lowerText.contains('눈물') || 
               lowerText.contains('😢') || lowerText.contains('😭') || lowerText.contains('😔')) {
      return Emotion.weather; // sad -> weather
    } else if (lowerText.contains('화나') || lowerText.contains('짜증') || lowerText.contains('분노') || 
               lowerText.contains('😠') || lowerText.contains('😡') || lowerText.contains('💢')) {
      return Emotion.animal; // angry -> animal
    } else if (lowerText.contains('걱정') || lowerText.contains('불안') || lowerText.contains('긴장') || 
               lowerText.contains('😰') || lowerText.contains('😨') || lowerText.contains('😱')) {
      return Emotion.shape; // anxious -> shape
    } else if (lowerText.contains('사랑') || lowerText.contains('감동') || lowerText.contains('따뜻') || 
               lowerText.contains('💕') || lowerText.contains('💖') || lowerText.contains('🥰')) {
      return Emotion.fruit; // love -> fruit
    } else if (lowerText.contains('열정') || lowerText.contains('의지') || lowerText.contains('도전') || 
               lowerText.contains('💪') || lowerText.contains('🔥') || lowerText.contains('⚡')) {
      return Emotion.animal; // determined -> animal
    } else if (lowerText.contains('평온') || lowerText.contains('차분') || lowerText.contains('여유') || 
               lowerText.contains('😌') || lowerText.contains('🧘') || lowerText.contains('🌸')) {
      return Emotion.weather; // calm -> weather
    } else if (lowerText.contains('신뢰') || lowerText.contains('자신') || lowerText.contains('확신') || 
               lowerText.contains('😎') || lowerText.contains('💪') || lowerText.contains('✨')) {
      return Emotion.shape; // confident -> shape
    } else if (lowerText.contains('혼란') || lowerText.contains('어려움') || lowerText.contains('막막') || 
               lowerText.contains('😵') || lowerText.contains('🤔') || lowerText.contains('❓')) {
      return Emotion.shape; // confused -> shape
    } else if (lowerText.contains('흥미') || lowerText.contains('재미') || lowerText.contains('새로움') || 
               lowerText.contains('😃') || lowerText.contains('🎉') || lowerText.contains('🎊')) {
      return Emotion.fruit; // excited -> fruit
    } else if (lowerText.contains('감사') || lowerText.contains('고마') || lowerText.contains('은혜') || 
               lowerText.contains('🙏') || lowerText.contains('💝') || lowerText.contains('✨')) {
      return Emotion.weather; // touched -> weather
    }
    
    // 기본값
    return Emotion.fruit; // neutral -> fruit
  }

  String _formatDate(String dateStr) {
    final date = DateTime.parse(dateStr);
    final month = date.month;
    final day = date.day;
    final dayNames = ['일요일', '월요일', '화요일', '수요일', '목요일', '금요일', '토요일'];
    final dayName = dayNames[date.weekday % 7];
    
    return '$month월 $day일\n$dayName';
  }

  Widget _buildImageWidget(String imagePath) {
    Widget errorWidget = Container(
      color: AppColors.muted,
      child: Icon(
        Icons.image,
        color: AppColors.mutedForeground,
      ),
    );

    // 웹에서는 모든 이미지가 네트워크 이미지 또는 data URL로 처리
    if (kIsWeb) {
      return Image.network(
        imagePath,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) => errorWidget,
      );
    } else {
      // 모바일에서는 기본 이미지 아이콘 표시
      return errorWidget;
    }
  }

  Future<void> _handleImageUpload() async {
    if (_uploadedImages.length >= 3) return;

    // 웹에서만 동작하도록 조건부 처리
    if (kIsWeb) {
      // 웹 전용 코드
      WebImageUpload.uploadImage((imageData) {
        setState(() {
          _uploadedImages.add(imageData);
        });
      });
    } else {
      // 모바일에서는 이미지 업로드 기능을 비활성화
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('이미지 업로드는 웹에서만 지원됩니다.')),
      );
    }
  }

  void _handleImageDelete(int index) {
    setState(() {
      _uploadedImages.removeAt(index);
    });
  }

  Future<void> _startRecording() async {
    // 음성 인식 기능은 현재 모바일에서 비활성화됨
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('음성 인식 기능은 웹에서만 지원됩니다.')),
    );
  }

  Future<void> _stopRecording() async {
    // 음성 인식 기능은 현재 모바일에서 비활성화됨
  }

  Future<void> _sendTextToWhisper(String text) async {
    // 음성 인식 기능은 현재 모바일에서 비활성화됨
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
                                          child: Container(
                                            width: 32,
                                            height: 32,
                                            child: Image.network(
                                            _currentEmoji,
                                              fit: BoxFit.contain,
                                              errorBuilder: (context, error, stackTrace) {
                                                return Container(
                                                  width: 32,
                                                  height: 32,
                                                  decoration: BoxDecoration(
                                                    color: AppColors.muted,
                                                    borderRadius: BorderRadius.circular(16),
                                                  ),
                                                  child: const Icon(
                                                    Icons.error,
                                                    size: 20,
                                                    color: Colors.grey,
                                                  ),
                                                );
                                              },
                                            ),
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