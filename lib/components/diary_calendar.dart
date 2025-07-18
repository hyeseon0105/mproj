import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/app_state.dart';
import '../theme.dart';
import '../ui/card.dart';
import '../ui/button.dart';
import 'dart:math';

class DiaryCalendar extends StatefulWidget {
  final Function(String)? onDateSelect;
  final Map<String, EmotionData>? emotionData;
  final VoidCallback? onSettingsClick;
  final bool emoticonEnabled;
  final String userSubscription;
  final DateTime? userBirthday;
  final VoidCallback? onGoToMyPage;

  const DiaryCalendar({
    super.key,
    this.onDateSelect,
    this.emotionData,
    this.onSettingsClick,
    this.emoticonEnabled = true,
    this.userSubscription = 'normal',
    this.userBirthday,
    this.onGoToMyPage,
  });

  @override
  State<DiaryCalendar> createState() => _DiaryCalendarState();
}

class _DiaryCalendarState extends State<DiaryCalendar> {
  late DateTime currentDate;
  late Map<String, EmotionData> emotionData;

  final Map<Emotion, String> emotionEmojis = {
    Emotion.fruit: 'https://firebasestorage.googleapis.com/v0/b/diary-3bbf7.firebasestorage.app/o/fruit%2Fneutral_fruit-removebg-preview.png?alt=media&token=9bdea06c-13e6-4c59-b961-1424422a3c39',
    Emotion.animal: 'https://firebasestorage.googleapis.com/v0/b/diary-3bbf7.firebasestorage.app/o/animal%2Fneutral_animal-removebg-preview.png?alt=media&token=f884e38d-5d8c-4d4a-bb62-a47a198d384f',
    Emotion.shape: 'https://firebasestorage.googleapis.com/v0/b/diary-3bbf7.firebasestorage.app/o/shape%2Fneutral_shape-removebg-preview.png?alt=media&token=02e85132-3a83-4257-8c1e-d2e478c7fcf5',
    Emotion.weather: 'https://firebasestorage.googleapis.com/v0/b/diary-3bbf7.firebasestorage.app/o/wheather%2Fneutral_weather-removebg-preview.png?alt=media&token=57ad1adf-baa6-4b79-96f5-066a4ec3358f',
  };

  final Map<Emotion, Color> emotionColors = {
    Emotion.fruit: const Color(0xFFEA580C), // orange-500
    Emotion.animal: const Color(0xFF22C55E), // green-500
    Emotion.shape: const Color(0xFF3B82F6), // blue-500
    Emotion.weather: const Color(0xFFEAB308), // yellow-500
  };

  final List<String> monthNames = [
    '1월', '2월', '3월', '4월', '5월', '6월',
    '7월', '8월', '9월', '10월', '11월', '12월'
  ];

  final List<String> dayNames = ['일', '월', '화', '수', '목', '금', '토'];

  @override
  void initState() {
    super.initState();
    currentDate = DateTime.now();
    emotionData = widget.emotionData ?? _generateCurrentMonthSampleData();
  }

  Map<String, EmotionData> _generateCurrentMonthSampleData() {
    final now = DateTime.now();
    final year = now.year;
    final month = now.month;
    final daysInCurrentMonth = DateTime(year, month + 1, 0).day;
    
    final Map<String, EmotionData> sampleData = {};
    final emotions = Emotion.values;
    final emojis = ['🍎', '🐶', '⭐', '☀️'];
    final random = Random();
    
    // Add some sample entries for the current month
    for (int day = 1; day <= min(daysInCurrentMonth, 10); day++) {
      final randomIndex = random.nextInt(emotions.length);
      sampleData['$year-${month.toString().padLeft(2, '0')}-${day.toString().padLeft(2, '0')}'] = EmotionData(
        emotion: emotions[randomIndex],
        emoji: emojis[randomIndex],
      );
    }
    
    return sampleData;
  }

  void _navigateMonth(String direction) {
    setState(() {
      if (direction == 'prev') {
        currentDate = DateTime(currentDate.year, currentDate.month - 1);
      } else {
        currentDate = DateTime(currentDate.year, currentDate.month + 1);
      }
    });
  }

  String _getDateKey(int day) {
    return '${currentDate.year}-${currentDate.month.toString().padLeft(2, '0')}-${day.toString().padLeft(2, '0')}';
  }

  void _handleDateClick(int day) {
    final dateKey = _getDateKey(day);
    print('Calendar date clicked: $dateKey');
    
    if (widget.onDateSelect != null) {
      widget.onDateSelect!(dateKey);
    } else {
      // Provider를 사용한 fallback
      final appState = Provider.of<AppState>(context, listen: false);
      appState.handleDateSelect(dateKey);
    }
  }

  String _generateTodaysFortune(DateTime birthday) {
    final today = DateTime.now();
    final birthMonth = birthday.month;
    final birthDay = birthday.day;
    final todayNumber = today.day + birthMonth + birthDay;
    
    final fortunes = [
      "오늘은 새로운 기회가 찾아올 수 있는 날입니다. 열린 마음으로 하루를 시작해보세요! ✨",
      "소중한 사람과의 만남이나 연락이 있을 것 같아요. 따뜻한 마음으로 대화해보세요 💕",
      "창의적인 아이디어가 떠오르는 날이에요. 새로운 것을 시도해보는 것도 좋겠어요 🎨",
      "조금 조심스러운 하루가 될 수 있어요. 신중하게 판단하시고 무리하지 마세요 🤗",
      "행운이 함께하는 날입니다! 긍정적인 마음가짐으로 하루를 보내세요 🍀",
      "평온하고 안정적인 하루가 될 것 같아요. 여유로운 마음으로 하루를 즐겨보세요 🌸",
      "새로운 배움이나 깨달음이 있을 수 있는 날이에요. 호기심을 가지고 하루를 보내세요 📚",
      "주변 사람들과의 관계가 더욱 돈독해질 것 같아요. 감사하는 마음을 표현해보세요 💝"
    ];
    
    return fortunes[todayNumber % fortunes.length];
  }

  Future<void> _handlePremiumSubscription() async {
    // Flutter에서는 in_app_purchase 패키지를 사용하여 결제 처리
    // 여기서는 시뮬레이션으로 처리
    try {
      // 실제 구현에서는 in_app_purchase 패키지 사용
      if (mounted) {
        // 안전한 ScaffoldMessenger 사용
        final messenger = ScaffoldMessenger.of(context);
        if (messenger.mounted) {
          messenger.showSnackBar(
            const SnackBar(
              content: Text('결제 완료! 프리미엄 구독이 완료되었습니다.'),
              backgroundColor: Colors.green,
              duration: Duration(seconds: 2),
            ),
          );
        }
      }
    } catch (error) {
      if (mounted) {
        // 안전한 ScaffoldMessenger 사용
        final messenger = ScaffoldMessenger.of(context);
        if (messenger.mounted) {
          messenger.showSnackBar(
            const SnackBar(
              content: Text('결제 중 오류가 발생했습니다. 다시 시도해 주세요.'),
              backgroundColor: Colors.red,
              duration: Duration(seconds: 3),
            ),
          );
        }
      }
    }
  }

  List<Widget> _renderCalendarDays() {
    final year = currentDate.year;
    final month = currentDate.month;
    final daysInMonth = DateTime(year, month + 1, 0).day;
    final firstDayOfMonth = DateTime(year, month, 1).weekday % 7;

    final days = <Widget>[];

    // Empty cells for days before the first day of the month
    for (int i = 0; i < firstDayOfMonth; i++) {
      days.add(Container(
        height: 60, // 높이를 줄여서 레이아웃 문제 해결
        decoration: BoxDecoration(
          color: Colors.transparent,
          borderRadius: BorderRadius.circular(16),
        ),
      ));
    }

    // Days of the month
    for (int day = 1; day <= daysInMonth; day++) {
      final dateKey = _getDateKey(day);
      final dayData = emotionData[dateKey];
      final isToday = DateTime.now().year == year && 
                     DateTime.now().month == month && 
                     DateTime.now().day == day;

      days.add(
        Container(
          height: 60, // 높이를 줄여서 레이아웃 문제 해결
          child: Stack(
            clipBehavior: Clip.none, // 이모지가 짤리지 않도록 설정
            children: [
              Positioned.fill(
                child: Padding(
                  padding: const EdgeInsets.all(4.0),
                  child: Material(
                    color: AppColors.background, // 날짜 셀 배경색을 전체 앱 배경색과 같게 설정
                    borderRadius: BorderRadius.circular(16),
                    child: InkWell(
                      borderRadius: BorderRadius.circular(16),
                      onTap: () => _handleDateClick(day),
                      hoverColor: AppColors.calendarDateHover,
                      child: Stack(
                        children: [
                          // 오늘 날짜 표시
                          if (isToday)
                            Positioned.fill(
                              child: Container(
                                decoration: BoxDecoration(
                                  border: Border.all(
                                    color: AppColors.primary,
                                    width: 2,
                                  ),
                                  borderRadius: BorderRadius.circular(16),
                                ),
                              ),
                            ),
                          // 감정 데이터가 있을 때 배경색
                          if (dayData != null)
                            Positioned.fill(
                              child: Container(
                                decoration: BoxDecoration(
                                  color: emotionColors[dayData.emotion]?.withValues(alpha: 0.1),
                                  borderRadius: BorderRadius.circular(16),
                                ),
                              ),
                            ),
                          // 숫자 - 항상 중앙에 고정
                          Positioned.fill(
                            child: Center(
                              child: Text(
                                day.toString(),
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: isToday ? FontWeight.bold : FontWeight.normal,
                                  color: isToday 
                                    ? AppColors.primary
                                    : AppColors.mutedForeground,
                                ),
                              ),
                            ),
                          ),
                          // 이모티콘 - Transform으로 셀 밖으로 이동 (절대 짤리지 않음)
                          if (dayData != null && widget.emoticonEnabled)
                            Positioned(
                              top: 0,
                              left: 0,
                              right: 0,
                              child: Center(
                                child: Transform.translate(
                                  offset: const Offset(0, -15), // 높이를 줄였으므로 오프셋도 조정
                                  child: Builder(
                                    builder: (context) {
                                      final appState = Provider.of<AppState>(context, listen: false);
                                      final userEmoticon = appState.getUserEmoticon(dayData.emotion);
                                      return Image.network(
                                        userEmoticon,
                                        width: 24, // 이모지 크기 조정
                                        height: 24,
                                        fit: BoxFit.contain,
                                        errorBuilder: (context, error, stackTrace) {
                                          return const Text(
                                            '😊',
                                            style: TextStyle(fontSize: 12),
                                          );
                                        },
                                      );
                                    },
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
      );
    }

    return days;
  }

  Widget _renderFortuneSection() {
    if (widget.userBirthday == null) {
      return AppCard(
        backgroundColor: AppColors.calendarBg,
        borderRadius: BorderRadius.circular(24),
        padding: const EdgeInsets.all(24),
        margin: const EdgeInsets.only(top: 24),
        child: Column(
          children: [
            Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    AppColors.primaryGradientStart.withValues(alpha: 0.8),
                    AppColors.primaryGradientEnd,
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(32),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.1),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: const Center(
                child: Text('🎂', style: TextStyle(fontSize: 24)),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              '오늘의 운세',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColors.foreground,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              '생년월일을 설정하시면 개인 맞춤 운세를 확인할 수 있어요!',
              style: TextStyle(
                fontSize: 14,
                color: AppColors.mutedForeground,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: AppButton(
                onPressed: widget.onGoToMyPage,
                text: '마이페이지에서 생년월일 설정하기',
                variant: ButtonVariant.outline,
              ),
            ),
          ],
        ),
      );
    }

    final todaysFortune = _generateTodaysFortune(widget.userBirthday!);
    final today = DateTime.now();
    final formatToday = '${today.month}월 ${today.day}일';

    return AppCard(
      backgroundColor: AppColors.calendarBg,
      borderRadius: BorderRadius.circular(24),
      padding: const EdgeInsets.all(24),
      margin: const EdgeInsets.only(top: 24),
      child: Column(
        children: [
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  AppColors.primaryGradientStart.withValues(alpha: 0.8),
                  AppColors.primaryGradientEnd,
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(32),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.1),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: const Center(
              child: Text('🔮', style: TextStyle(fontSize: 24)),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            '오늘의 운세',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppColors.foreground,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            formatToday,
            style: TextStyle(
              fontSize: 12,
              color: AppColors.mutedForeground,
            ),
          ),
          const SizedBox(height: 16),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  AppColors.primaryGradientStart.withValues(alpha: 0.1),
                  AppColors.primaryGradientEnd.withValues(alpha: 0.2),
                ],
              ),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: AppColors.primaryGradientStart.withValues(alpha: 0.3),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  blurRadius: 4,
                  offset: const Offset(0, 1),
                ),
              ],
            ),
            child: Text(
              todaysFortune,
              style: TextStyle(
                fontSize: 14,
                color: AppColors.foreground,
                height: 1.5,
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final year = currentDate.year;
    final month = currentDate.month;
    final appState = Provider.of<AppState>(context);

    return SafeArea(
      child: SingleChildScrollView(
        child: Container(
          color: AppColors.background,
          padding: const EdgeInsets.all(16),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 448), // max-w-md
              child: Column(
                children: [
                  // Header with Logo and Settings
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Logo
                      Padding(
                        padding: const EdgeInsets.only(top: 16), // 원하는 만큼 조절 (예: 16)
                        child: Container(
                          width: 120,
                          height: 40,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Image.asset(
                            'assets/images/logo.png',
                            fit: BoxFit.contain,
                          ),
                        ),
                      ),
                      // Settings Button
                      IconButton(
                        onPressed: widget.onSettingsClick ?? () {
                          final appState = Provider.of<AppState>(context, listen: false);
                          appState.handleSettingsClick();
                        },
                        icon: const Icon(Icons.settings, color: AppColors.foreground),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  // Calendar Header
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      IconButton(
                        onPressed: () => _navigateMonth('prev'),
                        icon: const Icon(Icons.chevron_left, color: AppColors.foreground),
                      ),
                      Text(
                        '${monthNames[month - 1]} $year',
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: AppColors.foreground,
                          decoration: TextDecoration.none,
                        ),
                      ),
                      IconButton(
                        onPressed: () => _navigateMonth('next'),
                        icon: const Icon(Icons.chevron_right, color: AppColors.foreground),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  // Day Headers
                  Row(
                    children: ['일', '월', '화', '수', '목', '금', '토'].map((day) => 
                      Expanded(
                        child: Center(
                          child: Text(
                            day,
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                              color: AppColors.mutedForeground,
                              decoration: TextDecoration.none,
                            ),
                          ),
                        ),
                      )
                    ).toList(),
                  ),
                  const SizedBox(height: 8),
                  // Calendar Grid
                  GridView.count(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    crossAxisCount: 7,
                    childAspectRatio: 1,
                    children: _renderCalendarDays(),
                  ),
                  // Fortune Section
                  _renderFortuneSection(),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
} 