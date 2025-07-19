import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

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

enum UserSubscription { normal, premium }

class AppState extends ChangeNotifier {
  bool _isAuthenticated = false;
  CurrentView _currentView = CurrentView.calendar;
  String _selectedDate = '';
  UserSubscription _userSubscription = UserSubscription.normal;
  DateTime? _userBirthday;
  bool _emoticonEnabled = true;
  
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
  UserSubscription get userSubscription => _userSubscription;
  DateTime? get userBirthday => _userBirthday;
  bool get emoticonEnabled => _emoticonEnabled;
  Map<String, EmotionData> get emotionData => Map.unmodifiable(_emotionData);

  AppState() {
    _loadEmoticonSetting();
  }

  void _loadEmoticonSetting() async {
    final prefs = await SharedPreferences.getInstance();
    _emoticonEnabled = prefs.getBool('emoticonEnabled') ?? true;
    notifyListeners();
  }

  void setAuthenticated(bool value) {
    _isAuthenticated = value;
    notifyListeners();
  }

  void setCurrentView(CurrentView view) {
    _currentView = view;
    notifyListeners();
  }

  void setSelectedDate(String date) {
    _selectedDate = date;
    notifyListeners();
  }

  void setUserSubscription(UserSubscription subscription) {
    _userSubscription = subscription;
    notifyListeners();
  }

  void setUserBirthday(DateTime? birthday) {
    _userBirthday = birthday;
    notifyListeners();
  }

  void setEmoticonEnabled(bool enabled) async {
    _emoticonEnabled = enabled;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('emoticonEnabled', enabled);
    notifyListeners();
  }

  void saveDiary(String entry, Emotion emotion, List<String>? images) {
    _emotionData[_selectedDate] = EmotionData(
      emotion: emotion,
      emoji: emotionEmojis[emotion]!,
      entry: entry,
      images: images,
    );
    notifyListeners();
  }

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

  void handleLogin() {
    setAuthenticated(true);
  }

  void handleLogout() {
    setAuthenticated(false);
    setCurrentView(CurrentView.calendar);
  }
} 