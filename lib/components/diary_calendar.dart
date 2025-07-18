import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/app_state.dart';
import '../theme.dart';
import '../ui/card.dart';
import '../ui/button.dart';
import '../services/payment_service.dart';
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
    Emotion.fruit: '🍎',
    Emotion.animal: '🐶',
    Emotion.shape: '⭐',
    Emotion.weather: '☀️',
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
    try {
      // 로딩 표시
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const Center(
          child: CircularProgressIndicator(),
        ),
      );

      // 결제 정보 준비
      final merchantUid = PaymentService.generateMerchantUid();
      const amount = 9900; // 9,900원
      const productName = '하루그램 프리미엄 구독';

      // 로딩 다이얼로그 닫기
      Navigator.of(context).pop();

      // WebView로 결제창 띄우기
      final paymentResult = await PaymentService.requestPayment(
        context: context,
        merchantUid: merchantUid,
        amount: amount,
        name: productName,
        buyerEmail: 'user@example.com', // 실제 사용자 이메일로 변경 필요
        buyerName: '사용자', // 실제 사용자 이름으로 변경 필요
      );

      if (paymentResult['success']) {
        // 결제 성공 시 검증
        final verifyResult = await PaymentService.verifyPayment(
          impUid: paymentResult['imp_uid'],
          merchantUid: paymentResult['merchant_uid'],
          amount: paymentResult['amount'],
        );

        if (verifyResult['success']) {
          // 프리미엄 구독 상태 업데이트
          final appState = Provider.of<AppState>(context, listen: false);
          appState.setUserSubscription(UserSubscription.premium);
          
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('프리미엄 구독이 완료되었습니다!'),
                backgroundColor: Colors.green,
              ),
            );
          }
        } else {
          throw Exception('결제 검증 실패');
        }
      } else {
        // 결제 실패
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('결제가 취소되었습니다: ${paymentResult['error']}'),
              backgroundColor: Colors.orange,
            ),
          );
        }
      }
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('결제 중 오류가 발생했습니다: $error'),
            backgroundColor: Colors.red,
          ),
        );
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
      days.add(const SizedBox(height: 90));
    }

    // Days of the month
    for (int day = 1; day <= daysInMonth; day++) {
      final dateKey = _getDateKey(day);
      final dayData = emotionData[dateKey];
      final isToday = DateTime.now().year == year && 
                     DateTime.now().month == month && 
                     DateTime.now().day == day;

      days.add(
        SizedBox(
          height: 90, // 셀 높이를 늘려서 이모지가 짤리지 않도록 함
          child: Stack(
            clipBehavior: Clip.none, // 이모지가 짤리지 않도록 설정
            children: [
              Positioned.fill(
                child: Padding(
                  padding: const EdgeInsets.all(4.0),
                  child: Material(
                    color: AppColors.calendarBg,
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
                                  offset: const Offset(0, -20),
                                  child: Container(
                                    width: 24,
                                    height: 24,
                                    child: Image.network(
                                      dayData.emoji,
                                      fit: BoxFit.contain,
                                      errorBuilder: (context, error, stackTrace) {
                                        return Container(
                                          width: 24,
                                          height: 24,
                                          decoration: BoxDecoration(
                                            color: AppColors.muted,
                                            borderRadius: BorderRadius.circular(4),
                                          ),
                                          child: const Icon(
                                            Icons.error,
                                            size: 16,
                                            color: Colors.grey,
                                          ),
                                        );
                                      },
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
              ),
            ],
          ),
        ),
      );
    }

    return days;
  }

  Widget _renderFortuneSection() {
    if (widget.userSubscription == 'normal') {
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
                  colors: [AppColors.primaryGradientStart, AppColors.primaryGradientEnd],
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
            const SizedBox(height: 8),
            Text(
              '프리미엄 구독하고 매일 개인 맞춤 운세를 확인해보세요!',
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
                onPressed: _handlePremiumSubscription,
                text: '프리미엄 구독하기',
                variant: ButtonVariant.primary,
              ),
            ),
          ],
        ),
      );
    }

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

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Container(
        constraints: const BoxConstraints(minHeight: double.infinity),
        color: AppColors.background,
        padding: const EdgeInsets.all(16),
        child: SingleChildScrollView(
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
                        child: SizedBox(
                          height: 50,
                          child: Image.asset(
                            'assets/images/logo.png',
                            fit: BoxFit.contain,
                          ),
                        ),
                      ),
                      // Settings Button
                      AppButton(
                        onPressed: widget.onSettingsClick,
                        variant: ButtonVariant.ghost,
                        size: ButtonSize.icon,
                        child: Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Icon(
                            Icons.settings,
                            size: 20,
                            color: AppColors.foreground,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // Calendar Card
                  AppCard(
                    backgroundColor: AppColors.calendarBg,
                    borderRadius: BorderRadius.circular(24),
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      children: [
                        // Month Navigation
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            AppButton(
                              onPressed: () => _navigateMonth('prev'),
                              variant: ButtonVariant.ghost,
                              size: ButtonSize.icon,
                              child: Container(
                                width: 32,
                                height: 32,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                child: const Icon(Icons.chevron_left, size: 16),
                              ),
                            ),
                            Text(
                              '$year.${month.toString().padLeft(2, '0')}',
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: AppColors.foreground,
                              ),
                            ),
                            AppButton(
                              onPressed: () => _navigateMonth('next'),
                              variant: ButtonVariant.ghost,
                              size: ButtonSize.icon,
                              child: Container(
                                width: 32,
                                height: 32,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                child: const Icon(Icons.chevron_right, size: 16),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 24),

                        // Day Headers
                        GridView.count(
                          crossAxisCount: 7,
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          childAspectRatio: 1,
                          mainAxisSpacing: 4,
                          crossAxisSpacing: 4,
                          children: [
                            ...dayNames.map((day) => Container(
                              height: 32,
                              alignment: Alignment.center,
                              child: Text(
                                day,
                                style: TextStyle(
                                  fontSize: 14,
                                  color: AppColors.mutedForeground,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            )),
                          ],
                        ),
                        const SizedBox(height: 16),

                        // Calendar Grid
                        GridView.count(
                          crossAxisCount: 7,
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          childAspectRatio: 1,
                          mainAxisSpacing: 4,
                          crossAxisSpacing: 4,
                          children: _renderCalendarDays(),
                        ),
                      ],
                    ),
                  ),

                  // Today's Fortune Section
                  _renderFortuneSection(),
                ],
              ),
            ),
          ),
        ), // SingleChildScrollView 닫는 괄호
      ),
    );
  }
} 