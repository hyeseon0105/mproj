import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
<<<<<<< HEAD
=======
import '../services/user_settings_service.dart';
import '../services/diary_service.dart';
>>>>>>> origin/main

enum Emotion { fruit, animal, shape, weather }

class EmotionData {
  final Emotion emotion;
  final String emoji;
  final String? entry;
  final List<String>? images;

  EmotionData({
    required this.emotion,
    required this.emoji,
    this.entry,
    this.images,
  });

  Map<String, dynamic> toJson() {
    return {
      'emotion': emotion.name,
      'emoji': emoji,
      'entry': entry,
      'images': images,
    };
  }

  factory EmotionData.fromJson(Map<String, dynamic> json) {
    return EmotionData(
      emotion: Emotion.values.firstWhere((e) => e.name == json['emotion']),
      emoji: json['emoji'],
      entry: json['entry'],
      images: json['images']?.cast<String>(),
    );
  }
}

enum CurrentView { calendar, entry, mypage }

<<<<<<< HEAD
enum UserSubscription { normal, premium }
=======

>>>>>>> origin/main

class AppState extends ChangeNotifier {
  bool _isAuthenticated = false;
  CurrentView _currentView = CurrentView.calendar;
  String _selectedDate = '';
<<<<<<< HEAD
  UserSubscription _userSubscription = UserSubscription.normal;
  DateTime? _userBirthday;
  bool _emoticonEnabled = true;
  String _userName = '사용자';
  String _userEmail = '';
  String _accessToken = '';
  Emotion _selectedEmoticonCategory = Emotion.shape;
  
  final Map<String, EmotionData> _emotionData = {
    '2024-02-01': EmotionData(emotion: Emotion.fruit, emoji: 'https://firebasestorage.googleapis.com/v0/b/diary-3bbf7.firebasestorage.app/o/fruit%2Fneutral_fruit-removebg-preview.png?alt=media&token=9bdea06c-13e6-4c59-b961-1424422a3c39'),
    '2024-02-02': EmotionData(emotion: Emotion.animal, emoji: 'https://firebasestorage.googleapis.com/v0/b/diary-3bbf7.firebasestorage.app/o/animal%2Fneutral_animal-removebg-preview.png?alt=media&token=f884e38d-5d8c-4d4a-bb62-a47a198d384f'),
    '2024-02-03': EmotionData(emotion: Emotion.shape, emoji: 'https://firebasestorage.googleapis.com/v0/b/diary-3bbf7.firebasestorage.app/o/shape%2Fneutral_shape-removebg-preview.png?alt=media&token=02e85132-3a83-4257-8c1e-d2e478c7fcf5'),
    '2024-02-04': EmotionData(emotion: Emotion.weather, emoji: 'https://firebasestorage.googleapis.com/v0/b/diary-3bbf7.firebasestorage.app/o/wheather%2Fneutral_weather-removebg-preview.png?alt=media&token=57ad1adf-baa6-4b79-96f5-066a4ec3358f'),
    '2024-02-05': EmotionData(emotion: Emotion.fruit, emoji: 'https://firebasestorage.googleapis.com/v0/b/diary-3bbf7.firebasestorage.app/o/fruit%2Fneutral_fruit-removebg-preview.png?alt=media&token=9bdea06c-13e6-4c59-b961-1424422a3c39'),
    '2024-02-06': EmotionData(emotion: Emotion.animal, emoji: 'https://firebasestorage.googleapis.com/v0/b/diary-3bbf7.firebasestorage.app/o/animal%2Fneutral_animal-removebg-preview.png?alt=media&token=f884e38d-5d8c-4d4a-bb62-a47a198d384f'),
    '2024-02-07': EmotionData(emotion: Emotion.shape, emoji: 'https://firebasestorage.googleapis.com/v0/b/diary-3bbf7.firebasestorage.app/o/shape%2Fneutral_shape-removebg-preview.png?alt=media&token=02e85132-3a83-4257-8c1e-d2e478c7fcf5'),
    '2024-02-08': EmotionData(emotion: Emotion.weather, emoji: 'https://firebasestorage.googleapis.com/v0/b/diary-3bbf7.firebasestorage.app/o/wheather%2Fneutral_weather-removebg-preview.png?alt=media&token=57ad1adf-baa6-4b79-96f5-066a4ec3358f'),
    '2024-02-09': EmotionData(emotion: Emotion.fruit, emoji: 'https://firebasestorage.googleapis.com/v0/b/diary-3bbf7.firebasestorage.app/o/fruit%2Fneutral_fruit-removebg-preview.png?alt=media&token=9bdea06c-13e6-4c59-b961-1424422a3c39'),
    '2024-02-10': EmotionData(emotion: Emotion.animal, emoji: 'https://firebasestorage.googleapis.com/v0/b/diary-3bbf7.firebasestorage.app/o/animal%2Fneutral_animal-removebg-preview.png?alt=media&token=f884e38d-5d8c-4d4a-bb62-a47a198d384f'),
    '2024-02-11': EmotionData(emotion: Emotion.shape, emoji: 'https://firebasestorage.googleapis.com/v0/b/diary-3bbf7.firebasestorage.app/o/shape%2Fneutral_shape-removebg-preview.png?alt=media&token=02e85132-3a83-4257-8c1e-d2e478c7fcf5'),
    '2024-02-12': EmotionData(emotion: Emotion.weather, emoji: 'https://firebasestorage.googleapis.com/v0/b/diary-3bbf7.firebasestorage.app/o/wheather%2Fneutral_weather-removebg-preview.png?alt=media&token=57ad1adf-baa6-4b79-96f5-066a4ec3358f'),
    '2024-02-13': EmotionData(emotion: Emotion.fruit, emoji: 'https://firebasestorage.googleapis.com/v0/b/diary-3bbf7.firebasestorage.app/o/fruit%2Fneutral_fruit-removebg-preview.png?alt=media&token=9bdea06c-13e6-4c59-b961-1424422a3c39'),
    '2024-02-14': EmotionData(emotion: Emotion.animal, emoji: 'https://firebasestorage.googleapis.com/v0/b/diary-3bbf7.firebasestorage.app/o/animal%2Fneutral_animal-removebg-preview.png?alt=media&token=f884e38d-5d8c-4d4a-bb62-a47a198d384f'),
    '2024-02-15': EmotionData(emotion: Emotion.shape, emoji: 'https://firebasestorage.googleapis.com/v0/b/diary-3bbf7.firebasestorage.app/o/shape%2Fneutral_shape-removebg-preview.png?alt=media&token=02e85132-3a83-4257-8c1e-d2e478c7fcf5'),
    '2024-02-16': EmotionData(emotion: Emotion.weather, emoji: 'https://firebasestorage.googleapis.com/v0/b/diary-3bbf7.firebasestorage.app/o/wheather%2Fneutral_weather-removebg-preview.png?alt=media&token=57ad1adf-baa6-4b79-96f5-066a4ec3358f'),
    '2024-02-17': EmotionData(emotion: Emotion.fruit, emoji: 'https://firebasestorage.googleapis.com/v0/b/diary-3bbf7.firebasestorage.app/o/fruit%2Fneutral_fruit-removebg-preview.png?alt=media&token=9bdea06c-13e6-4c59-b961-1424422a3c39'),
    '2024-02-18': EmotionData(emotion: Emotion.animal, emoji: 'https://firebasestorage.googleapis.com/v0/b/diary-3bbf7.firebasestorage.app/o/animal%2Fneutral_animal-removebg-preview.png?alt=media&token=f884e38d-5d8c-4d4a-bb62-a47a198d384f'),
    '2024-02-19': EmotionData(emotion: Emotion.shape, emoji: 'https://firebasestorage.googleapis.com/v0/b/diary-3bbf7.firebasestorage.app/o/shape%2Fneutral_shape-removebg-preview.png?alt=media&token=02e85132-3a83-4257-8c1e-d2e478c7fcf5'),
    '2024-02-20': EmotionData(emotion: Emotion.weather, emoji: 'https://firebasestorage.googleapis.com/v0/b/diary-3bbf7.firebasestorage.app/o/wheather%2Fneutral_weather-removebg-preview.png?alt=media&token=57ad1adf-baa6-4b79-96f5-066a4ec3358f'),
    '2024-02-21': EmotionData(emotion: Emotion.fruit, emoji: 'https://firebasestorage.googleapis.com/v0/b/diary-3bbf7.firebasestorage.app/o/fruit%2Fneutral_fruit-removebg-preview.png?alt=media&token=9bdea06c-13e6-4c59-b961-1424422a3c39'),
    '2024-02-22': EmotionData(emotion: Emotion.animal, emoji: 'https://firebasestorage.googleapis.com/v0/b/diary-3bbf7.firebasestorage.app/o/animal%2Fneutral_animal-removebg-preview.png?alt=media&token=f884e38d-5d8c-4d4a-bb62-a47a198d384f'),
    '2024-02-23': EmotionData(emotion: Emotion.shape, emoji: 'https://firebasestorage.googleapis.com/v0/b/diary-3bbf7.firebasestorage.app/o/shape%2Fneutral_shape-removebg-preview.png?alt=media&token=02e85132-3a83-4257-8c1e-d2e478c7fcf5'),
    '2024-02-24': EmotionData(emotion: Emotion.weather, emoji: 'https://firebasestorage.googleapis.com/v0/b/diary-3bbf7.firebasestorage.app/o/wheather%2Fneutral_weather-removebg-preview.png?alt=media&token=57ad1adf-baa6-4b79-96f5-066a4ec3358f'),
    '2024-02-25': EmotionData(emotion: Emotion.fruit, emoji: 'https://firebasestorage.googleapis.com/v0/b/diary-3bbf7.firebasestorage.app/o/fruit%2Fneutral_fruit-removebg-preview.png?alt=media&token=9bdea06c-13e6-4c59-b961-1424422a3c39'),
    '2024-02-26': EmotionData(emotion: Emotion.animal, emoji: 'https://firebasestorage.googleapis.com/v0/b/diary-3bbf7.firebasestorage.app/o/animal%2Fneutral_animal-removebg-preview.png?alt=media&token=f884e38d-5d8c-4d4a-bb62-a47a198d384f'),
    '2024-02-27': EmotionData(emotion: Emotion.shape, emoji: 'https://firebasestorage.googleapis.com/v0/b/diary-3bbf7.firebasestorage.app/o/shape%2Fneutral_shape-removebg-preview.png?alt=media&token=02e85132-3a83-4257-8c1e-d2e478c7fcf5'),
    '2024-02-28': EmotionData(emotion: Emotion.weather, emoji: 'https://firebasestorage.googleapis.com/v0/b/diary-3bbf7.firebasestorage.app/o/wheather%2Fneutral_weather-removebg-preview.png?alt=media&token=57ad1adf-baa6-4b79-96f5-066a4ec3358f'),
    '2024-02-29': EmotionData(emotion: Emotion.fruit, emoji: 'https://firebasestorage.googleapis.com/v0/b/diary-3bbf7.firebasestorage.app/o/fruit%2Fneutral_fruit-removebg-preview.png?alt=media&token=9bdea06c-13e6-4c59-b961-1424422a3c39'),
=======

  DateTime? _userBirthday;
  bool _emoticonEnabled = true;
  bool _voiceEnabled = true;
  int _voiceVolume = 50;
  Map<String, List<String>> _emoticonCategories = {
    'shape': ['⭐', '🔶', '🔷', '⚫', '🔺'],
    'fruit': ['🍎', '🍊', '🍌', '🍇', '🍓'],
    'animal': ['🐶', '🐱', '🐰', '🐸', '🐼'],
    'weather': ['☀️', '🌧️', '⛈️', '🌈', '❄️']
  };
  String _lastSelectedEmotionCategory = 'shape'; // 마지막 선택된 카테고리
  
  final Map<String, EmotionData> _emotionData = {
    '2024-02-01': EmotionData(emotion: Emotion.fruit, emoji: '🍎'),
    '2024-02-02': EmotionData(emotion: Emotion.animal, emoji: '🐶'),
    '2024-02-03': EmotionData(emotion: Emotion.shape, emoji: '⭐'),
    '2024-02-04': EmotionData(emotion: Emotion.weather, emoji: '☀️'),
    '2024-02-05': EmotionData(emotion: Emotion.fruit, emoji: '🍊'),
    '2024-02-06': EmotionData(emotion: Emotion.animal, emoji: '🐱'),
    '2024-02-07': EmotionData(emotion: Emotion.shape, emoji: '🔶'),
    '2024-02-08': EmotionData(emotion: Emotion.weather, emoji: '🌧️'),
    '2024-02-09': EmotionData(emotion: Emotion.fruit, emoji: '🍌'),
    '2024-02-10': EmotionData(emotion: Emotion.animal, emoji: '🐰'),
    '2024-02-11': EmotionData(emotion: Emotion.shape, emoji: '🔷'),
    '2024-02-12': EmotionData(emotion: Emotion.weather, emoji: '⛈️'),
    '2024-02-13': EmotionData(emotion: Emotion.fruit, emoji: '🍇'),
    '2024-02-14': EmotionData(emotion: Emotion.animal, emoji: '🐸'),
    '2024-02-15': EmotionData(emotion: Emotion.shape, emoji: '⚫'),
    '2024-02-16': EmotionData(emotion: Emotion.weather, emoji: '🌈'),
    '2024-02-17': EmotionData(emotion: Emotion.fruit, emoji: '🍓'),
    '2024-02-18': EmotionData(emotion: Emotion.animal, emoji: '🐼'),
    '2024-02-19': EmotionData(emotion: Emotion.shape, emoji: '🔺'),
    '2024-02-20': EmotionData(emotion: Emotion.weather, emoji: '❄️'),
    '2024-02-21': EmotionData(emotion: Emotion.fruit, emoji: '🥝'),
    '2024-02-22': EmotionData(emotion: Emotion.animal, emoji: '🦊'),
    '2024-02-23': EmotionData(emotion: Emotion.shape, emoji: '🌟'),
    '2024-02-24': EmotionData(emotion: Emotion.weather, emoji: '🌤️'),
    '2024-02-25': EmotionData(emotion: Emotion.fruit, emoji: '🍑'),
    '2024-02-26': EmotionData(emotion: Emotion.animal, emoji: '🐻'),
    '2024-02-27': EmotionData(emotion: Emotion.shape, emoji: '✨'),
    '2024-02-28': EmotionData(emotion: Emotion.weather, emoji: '⛅'),
    '2024-02-29': EmotionData(emotion: Emotion.fruit, emoji: '🥭'),
>>>>>>> origin/main
  };

  static const Map<Emotion, String> emotionEmojis = {
    Emotion.fruit: '🍎',
    Emotion.animal: '🐶',
    Emotion.shape: '⭐',
    Emotion.weather: '☀️',
  };

  // Getters
  bool get isAuthenticated => _isAuthenticated;
  CurrentView get currentView => _currentView;
  String get selectedDate => _selectedDate;
<<<<<<< HEAD
  UserSubscription get userSubscription => _userSubscription;
  DateTime? get userBirthday => _userBirthday;
  bool get emoticonEnabled => _emoticonEnabled;
  Map<String, EmotionData> get emotionData => Map.unmodifiable(_emotionData);
  String get userName => _userName;
  String get userEmail => _userEmail;
  String get accessToken => _accessToken;
  Emotion get selectedEmoticonCategory => _selectedEmoticonCategory;

  AppState() {
    _loadEmoticonSetting();
=======

  DateTime? get userBirthday => _userBirthday;
  bool get emoticonEnabled => _emoticonEnabled;
  bool get voiceEnabled => _voiceEnabled;
  int get voiceVolume => _voiceVolume;
  Map<String, List<String>> get emoticonCategories => Map.unmodifiable(_emoticonCategories);
  String get lastSelectedEmotionCategory => _lastSelectedEmotionCategory;
  Map<String, EmotionData> get emotionData => Map.unmodifiable(_emotionData);

  AppState() {
    _loadEmoticonSetting();
    _checkAuthStatus();
  }
  
  void _checkAuthStatus() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('access_token');
    if (token != null) {
      setAuthenticated(true);
      // 토큰이 있을 때만 설정 로드
      await _loadUserSettings();
    }
>>>>>>> origin/main
  }

  void _loadEmoticonSetting() async {
    final prefs = await SharedPreferences.getInstance();
    _emoticonEnabled = prefs.getBool('emoticonEnabled') ?? true;
    notifyListeners();
  }

<<<<<<< HEAD
  void setAuthenticated(bool value) {
    _isAuthenticated = value;
    notifyListeners();
=======
  // 사용자 설정 로드
  Future<void> _loadUserSettings() async {
    try {
      final settings = await UserSettingsService.getUserSettings();
      _emoticonEnabled = settings['emoticon_enabled'] ?? true;
      _voiceEnabled = settings['voice_enabled'] ?? true;
      _voiceVolume = settings['voice_volume'] ?? 50;
      _emoticonCategories = Map<String, List<String>>.from(
        settings['emoticon_categories'] ?? UserSettingsService.defaultSettings['emoticon_categories']
      );
      _lastSelectedEmotionCategory = settings['last_selected_emotion_category'] ?? 'shape';
      notifyListeners();
    } catch (e) {
      print('사용자 설정 로드 실패: $e');
      // 기본 설정 사용
    }
  }

  void setAuthenticated(bool value) {
    _isAuthenticated = value;
    if (value) {
      // 로그인 시 설정 로드 및 일기 데이터 로드 (비동기로 처리)
      _loadUserSettings().then((_) {
        loadDiaryData().then((_) {
          notifyListeners();
        });
      });
    } else {
      notifyListeners();
    }
>>>>>>> origin/main
  }

  void setCurrentView(CurrentView view) {
    _currentView = view;
    notifyListeners();
  }

  void setSelectedDate(String date) {
    _selectedDate = date;
    notifyListeners();
  }

<<<<<<< HEAD
  void setUserSubscription(UserSubscription subscription) {
    _userSubscription = subscription;
    notifyListeners();
  }
=======

>>>>>>> origin/main

  void setUserBirthday(DateTime? birthday) {
    _userBirthday = birthday;
    notifyListeners();
  }

<<<<<<< HEAD
  void setEmoticonEnabled(bool enabled) async {
    _emoticonEnabled = enabled;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('emoticonEnabled', enabled);
    notifyListeners();
  }

  void saveDiary(String entry, Emotion emotion, List<String>? images) {
    final Map<Emotion, String> firebaseEmojis = {
      Emotion.fruit: 'https://firebasestorage.googleapis.com/v0/b/diary-3bbf7.firebasestorage.app/o/fruit%2Fneutral_fruit-removebg-preview.png?alt=media&token=9bdea06c-13e6-4c59-b961-1424422a3c39',
      Emotion.animal: 'https://firebasestorage.googleapis.com/v0/b/diary-3bbf7.firebasestorage.app/o/animal%2Fneutral_animal-removebg-preview.png?alt=media&token=f884e38d-5d8c-4d4a-bb62-a47a198d384f',
      Emotion.shape: 'https://firebasestorage.googleapis.com/v0/b/diary-3bbf7.firebasestorage.app/o/shape%2Fneutral_shape-removebg-preview.png?alt=media&token=02e85132-3a83-4257-8c1e-d2e478c7fcf5',
      Emotion.weather: 'https://firebasestorage.googleapis.com/v0/b/diary-3bbf7.firebasestorage.app/o/wheather%2Fneutral_weather-removebg-preview.png?alt=media&token=57ad1adf-baa6-4b79-96f5-066a4ec3358f',
    };
    
    _emotionData[_selectedDate] = EmotionData(
      emotion: emotion,
      emoji: firebaseEmojis[emotion]!,
=======
  // 이모티콘 설정 업데이트
  Future<void> setEmoticonEnabled(bool enabled) async {
    _emoticonEnabled = enabled;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('emoticonEnabled', enabled);
    
    try {
      await UserSettingsService.updateUserSettings(emoticonEnabled: enabled);
    } catch (e) {
      print('이모티콘 설정 업데이트 실패: $e');
    }
    
    notifyListeners();
  }

  // 음성 설정 업데이트
  Future<void> setVoiceEnabled(bool enabled) async {
    _voiceEnabled = enabled;
    try {
      await UserSettingsService.updateUserSettings(voiceEnabled: enabled);
    } catch (e) {
      print('음성 설정 업데이트 실패: $e');
    }
    notifyListeners();
  }

  // 음성 볼륨 설정 업데이트
  Future<void> setVoiceVolume(int volume) async {
    _voiceVolume = volume;
    try {
      await UserSettingsService.updateUserSettings(voiceVolume: volume);
    } catch (e) {
      print('음성 볼륨 설정 업데이트 실패: $e');
    }
    notifyListeners();
  }

  // 이모티콘 카테고리 업데이트
  Future<void> setEmoticonCategories(Map<String, List<String>> categories) async {
    _emoticonCategories = Map<String, List<String>>.from(categories);
    try {
      await UserSettingsService.updateEmoticonCategories(categories);
    } catch (e) {
      print('이모티콘 카테고리 업데이트 실패: $e');
    }
    notifyListeners();
  }

  // 마지막 선택된 이모티콘 카테고리 설정
  Future<void> setLastSelectedEmotionCategory(String category) async {
    _lastSelectedEmotionCategory = category;
    try {
      await UserSettingsService.updateUserSettings(
        lastSelectedEmotionCategory: category
      );
    } catch (e) {
      print('마지막 선택된 카테고리 저장 실패: $e');
    }
    notifyListeners();
  }

  // 설정 초기화
  Future<void> resetUserSettings() async {
    try {
      final settings = await UserSettingsService.resetUserSettings();
      _emoticonEnabled = settings['emoticon_enabled'] ?? true;
      _voiceEnabled = settings['voice_enabled'] ?? true;
      _voiceVolume = settings['voice_volume'] ?? 50;
      _emoticonCategories = Map<String, List<String>>.from(
        settings['emoticon_categories'] ?? UserSettingsService.defaultSettings['emoticon_categories']
      );
      notifyListeners();
    } catch (e) {
      print('설정 초기화 실패: $e');
    }
  }

  // 이모티콘 카테고리만 초기화
  Future<void> resetEmoticonCategories() async {
    try {
      final defaultCategories = UserSettingsService.defaultSettings['emoticon_categories'] as Map<String, List<String>>;
      _emoticonCategories = Map<String, List<String>>.from(defaultCategories);
      _lastSelectedEmotionCategory = 'shape';
      
      await UserSettingsService.updateUserSettings(
        emoticonCategories: defaultCategories,
        lastSelectedEmotionCategory: 'shape'
      );
      notifyListeners();
    } catch (e) {
      print('이모티콘 카테고리 초기화 실패: $e');
    }
  }

  void saveDiary(String entry, Emotion emotion, List<String>? images) {
    _emotionData[_selectedDate] = EmotionData(
      emotion: emotion,
      emoji: emotionEmojis[emotion]!,
>>>>>>> origin/main
      entry: entry,
      images: images,
    );
    notifyListeners();
  }

<<<<<<< HEAD
=======
  // 서버에서 일기 데이터 로드
  Future<void> loadDiaryData() async {
    if (!_isAuthenticated) return;
    
    try {
      final diaryService = DiaryService();
      final posts = await diaryService.getAllDiaries();
      
      // 기존 데이터 초기화
      _emotionData.clear();
      
      // 서버 데이터로 업데이트
      for (final post in posts) {
        final emotion = _analyzeEmotion(post['content']);
        _emotionData[post['id']] = EmotionData(
          emotion: emotion,
          emoji: emotionEmojis[emotion]!,
          entry: post['content'],
          images: List<String>.from(post['images'].map((img) => img['file_path'])),
        );
      }
      notifyListeners();
    } catch (e) {
      print('일기 데이터 로드 실패: $e');
    }
  }

  // 감정 분석 (간단한 키워드 기반)
  Emotion _analyzeEmotion(String text) {
    final fruitWords = ['과일', '사과', '바나나', '딸기', '포도', '맛있', '달콤', '상큼'];
    final animalWords = ['동물', '강아지', '고양이', '새', '토끼', '귀여', '애완동물', '반려동물'];
    final shapeWords = ['모양', '원', '사각형', '삼각형', '별', '도형', '그림', '디자인'];
    final weatherWords = ['날씨', '맑은', '비', '눈', '구름', '햇빛', '바람', '기온'];

    final lowerText = text.toLowerCase();
    
    if (fruitWords.any((word) => lowerText.contains(word))) return Emotion.fruit;
    if (animalWords.any((word) => lowerText.contains(word))) return Emotion.animal;
    if (shapeWords.any((word) => lowerText.contains(word))) return Emotion.shape;
    if (weatherWords.any((word) => lowerText.contains(word))) return Emotion.weather;
    
    return Emotion.fruit; // default
  }

>>>>>>> origin/main
  void handleDateSelect(String date) {
    print('AppState.handleDateSelect called: $date'); // 디버깅용 로그
    setSelectedDate(date);
    print('Selected date set to: $date'); // 디버깅용 로그
    setCurrentView(CurrentView.entry);
    print('Current view set to: entry'); // 디버깅용 로그
  }

  void handleBackToCalendar() {
    setCurrentView(CurrentView.calendar);
  }

  void handleSettingsClick() {
    setCurrentView(CurrentView.mypage);
  }

<<<<<<< HEAD
  void setUserInfo(String name, String email, String token, {String? birthday}) {
    print('AppState.setUserInfo 호출됨: name=$name, email=$email, birthday=$birthday'); // 디버깅용 로그
    print('이전 사용자명: $_userName'); // 디버깅용 로그
    _userName = name;
    _userEmail = email;
    _accessToken = token;
    if (birthday != null) {
      try {
        _userBirthday = DateTime.parse(birthday);
      } catch (e) {
        print('생일 파싱 오류: $e');
        _userBirthday = null;
      }
    }
    print('설정된 사용자명: $_userName'); // 디버깅용 로그
    notifyListeners();
  }

  void setSelectedEmoticonCategory(Emotion category) {
    _selectedEmoticonCategory = category;
    notifyListeners();
  }

=======
>>>>>>> origin/main
  void handleLogin() {
    setAuthenticated(true);
  }

<<<<<<< HEAD
  void handleLogout() {
    setAuthenticated(false);
    setCurrentView(CurrentView.calendar);
    _userName = '사용자';
    _userEmail = '';
    _accessToken = '';
    notifyListeners();
=======
  void handleLogout() async {
    // 저장된 토큰과 사용자 정보 삭제
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('access_token');
    await prefs.remove('user_id');
    await prefs.remove('username');
    await prefs.remove('email');
    await prefs.remove('birthday');
    
    // 일기 데이터 초기화
    _emotionData.clear();
    
    setAuthenticated(false);
    setCurrentView(CurrentView.calendar);
>>>>>>> origin/main
  }
} 