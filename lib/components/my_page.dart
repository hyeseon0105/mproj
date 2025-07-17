import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/app_state.dart';
import '../theme.dart';
import '../ui/card.dart';
import '../ui/button.dart';
import 'dart:math';

class MyPage extends StatefulWidget {
  const MyPage({super.key});

  @override
  State<MyPage> createState() => _MyPageState();
}

class _MyPageState extends State<MyPage> {
  bool _voiceEnabled = true;
  double _voiceVolume = 50;
  String _userName = '사용자';
  bool _isProfileDialogOpen = false;
  bool _isEmojiDialogOpen = false;
  bool _isPremiumModalOpen = false;
  String _tempName = '사용자';
  DateTime? _tempBirthday;
  
  // Emoji categories state
  Map<Emotion, List<String>> _emojiCategories = {
    Emotion.shape: ['⭐', '🔶', '🔷', '⚫', '🔺'],
    Emotion.fruit: ['🍎', '🍊', '🍌', '🍇', '🍓'],
    Emotion.animal: ['🐶', '🐱', '🐰', '🐸', '🐼'],
    Emotion.weather: ['☀️', '🌧️', '⛈️', '🌈', '❄️']
  };
  
  Emotion _selectedEmotion = Emotion.shape;

  final Map<Emotion, String> _emotionLabels = {
    Emotion.shape: '도형',
    Emotion.fruit: '과일',
    Emotion.animal: '동물',
    Emotion.weather: '날씨'
  };

  final Map<Emotion, int> _emotionScores = {
    Emotion.shape: 70,
    Emotion.fruit: 80,
    Emotion.animal: 85,
    Emotion.weather: 75
  };

  final List<String> _availableEmojis = [
    // 과일
    '🍎', '🍊', '🍋', '🍌', '🍍', '🥭', '🍑', '🍒', '🍓', '🫐', '🥝', '🍅', '🫒', '🥥', '🥑', '🍆', '🥔', '🥕', '🌽', '🌶️', '🫑', '🥒', '🥬', '🥦', '🧄', '🧅', '🍄', '🥜', '🌰', '🍇', '🍈', '🍉',
    // 동물
    '🐶', '🐱', '🐭', '🐹', '🐰', '🦊', '🐻', '🐼', '🐨', '🐯', '🦁', '🐮', '🐷', '🐸', '🐵', '🙈', '🙉', '🙊', '🐒', '🐔', '🐧', '🐦', '🐤', '🐣', '🐥', '🦆', '🦅', '🦉', '🦇', '🐺', '🐗', '🐴', '🦄', '🐝', '🪱', '🐛', '🦋', '🐌', '🐞', '🐜', '🪰', '🪲', '🪳', '🦗', '🕷️', '🕸️', '🦂', '🐢', '🐍', '🦎', '🦖', '🦕', '🐙', '🦑', '🦐', '🦞', '🦀', '🐡', '🐠', '🐟', '🐬', '🐳', '🐋', '🦈', '🐊', '🐅', '🐆', '🦓', '🦍', '🦧', '🐘', '🦛', '🦏', '🐪', '🐫', '🦒', '🦘', '🐃', '🐂', '🐄', '🐎', '🐖', '🐏', '🐑', '🦙', '🐐', '🦌', '🐕', '🐩', '🦮', '🐈', '🪶', '🐓', '🦃', '🦚', '🦜', '🦢', '🦩', '🕊️', '🐇', '🦝', '🦨', '🦡', '🦫',
    // 도형
    '⭐', '🌟', '✨', '⚡', '💥', '🔥', '🌈', '☀️', '🌞', '🌝', '🌛', '🌜', '🌚', '🌕', '🌖', '🌗', '🌘', '🌑', '🌒', '🌓', '🌔', '🔴', '🟠', '🟡', '🟢', '🔵', '🟣', '🟤', '⚫', '⚪', '🟥', '🟧', '🟨', '🟩', '🟦', '🟪', '🟫', '⬛', '⬜', '◼️', '◻️', '◾', '◽', '▪️', '▫️', '🔶', '🔷', '🔸', '🔹', '🔺', '🔻', '💠', '🔘', '🔳', '🔲',
    // 날씨
    '☀️', '🌤️', '⛅', '🌥️', '🌦️', '🌧️', '⛈️', '🌩️', '🌨️', '❄️', '☃️', '⛄', '🌬️', '💨', '🌪️', '🌫️', '🌈', '☂️', '☔', '⚡', '🌊', '💧', '💦', '🧊'
  ];

  @override
  void initState() {
    super.initState();
    _tempName = _userName;
  }

  String _formatDate(DateTime? date) {
    if (date == null) return '생일 미설정';
    return '${date.year}년 ${date.month.toString().padLeft(2, '0')}월 ${date.day.toString().padLeft(2, '0')}일';
  }

  void _handleSaveProfile(AppState appState) {
    setState(() {
      _userName = _tempName;
    });
    if (_tempBirthday != null) {
      appState.setUserBirthday(_tempBirthday!);
    }
    setState(() {
      _isProfileDialogOpen = false;
    });
  }

  void _handleCancelProfile(AppState appState) {
    setState(() {
      _tempName = _userName;
      _tempBirthday = appState.userBirthday;
      _isProfileDialogOpen = false;
    });
  }

  void _handleEmojiSelect(String emoji) {
    setState(() {
      if (_emojiCategories[_selectedEmotion]!.contains(emoji)) {
        _emojiCategories[_selectedEmotion]!.remove(emoji);
      } else {
        _emojiCategories[_selectedEmotion]!.add(emoji);
      }
    });
  }

  void _resetToDefault() {
    setState(() {
      _emojiCategories = {
        Emotion.shape: ['⭐', '🔶', '🔷', '⚫', '🔺'],
        Emotion.fruit: ['🍎', '🍊', '🍌', '🍇', '🍓'],
        Emotion.animal: ['🐶', '🐱', '🐰', '🐸', '🐼'],
        Emotion.weather: ['☀️', '🌧️', '⛈️', '🌈', '❄️']
      };
    });
  }

  // 행복 지수 계산
  Map<String, dynamic> _calculateHappinessData(AppState appState) {
    final now = DateTime.now();
    final currentMonthPrefix = '${now.year}-${now.month.toString().padLeft(2, '0')}-';
    
    final currentMonthData = appState.emotionData.entries
        .where((entry) => entry.key.startsWith(currentMonthPrefix) && entry.value.entry != null)
        .toList();
    
    final totalDays = currentMonthData.length;
    
    if (totalDays == 0) {
      return {
        'totalDays': 0,
        'happinessIndex': 50,
        'happinessEmoji': '🐸',
        'happinessColor': const Color(0xFFEAB308),
        'gaugeAngle': 90.0
      };
    }
    
    final averageScore = currentMonthData.fold(0, (sum, entry) => 
        sum + _emotionScores[entry.value.emotion]!) / totalDays;
    
    final happinessIndex = averageScore.round();
    final gaugeAngle = 180 - (happinessIndex / 100) * 180; // 180 to 0 degrees
    final happinessEmoji = happinessIndex >= 51 ? '🐶' : happinessIndex >= 21 ? '🐸' : '🐱';
    
    // 행복 색상 계산 (빨강에서 초록으로)
    final red = max(0, 255 - (happinessIndex * 2.55));
    final green = min(255, happinessIndex * 2.55);
    final happinessColor = Color.fromARGB(255, red.round(), green.round(), 0);
    
    return {
      'totalDays': totalDays,
      'happinessIndex': happinessIndex,
      'happinessEmoji': happinessEmoji,
      'happinessColor': happinessColor,
      'gaugeAngle': gaugeAngle
    };
  }

  // 프리미엄 결제 처리 (시뮬레이션)
  Future<void> _handlePremiumSubscription(AppState appState) async {
    try {
      // 실제 결제 처리는 여기에 구현
      // 예: iamport_flutter 패키지 사용
      
      await Future.delayed(const Duration(seconds: 2)); // 결제 시뮬레이션
      
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('프리미엄 구독이 완료되었습니다! 모든 기능을 이용하실 수 있습니다.'),
          backgroundColor: Colors.green,
        ),
      );
      
      appState.setUserSubscription(UserSubscription.premium);
      setState(() {
        _isPremiumModalOpen = false;
      });
      
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('결제 중 오류가 발생했습니다. 다시 시도해 주세요.'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AppState>(
      builder: (context, appState, child) {
        final happinessData = _calculateHappinessData(appState);
        
        return Container(
          color: AppColors.background,
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  // Header
                  Row(
                    children: [
                      AppButton(
                        onPressed: () => appState.handleBackToCalendar(),
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
                      const Expanded(
                        child: Text(
                          '마이페이지',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      const SizedBox(width: 40),
                    ],
                  ),
                  
                  const SizedBox(height: 24),
                  
                  Expanded(
                    child: SingleChildScrollView(
                      child: Column(
                        children: [
                          // Profile Section
                          AppCard(
                            backgroundColor: AppColors.calendarBg,
                            borderRadius: BorderRadius.circular(24),
                            padding: const EdgeInsets.all(24),
                            child: Row(
                              children: [
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        _userName,
                                        style: const TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        _formatDate(appState.userBirthday),
                                        style: TextStyle(
                                          fontSize: 14,
                                          color: AppColors.mutedForeground,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Row(
                                  children: [
                                    // Subscription Status
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(20),
                                        gradient: appState.userSubscription == UserSubscription.premium
                                            ? const LinearGradient(
                                                colors: [Color(0xFFFBBF24), Color(0xFFF59E0B)],
                                              )
                                            : null,
                                        color: appState.userSubscription != UserSubscription.premium
                                            ? AppColors.muted
                                            : null,
                                      ),
                                      child: Text(
                                        appState.userSubscription == UserSubscription.premium ? '프리미엄' : '노멀',
                                        style: TextStyle(
                                          fontSize: 12,
                                          fontWeight: FontWeight.w500,
                                          color: appState.userSubscription == UserSubscription.premium
                                              ? Colors.white
                                              : AppColors.mutedForeground,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    AppButton(
                                      onPressed: () {
                                        setState(() {
                                          _tempName = _userName;
                                          _tempBirthday = appState.userBirthday;
                                          _isProfileDialogOpen = true;
                                        });
                                      },
                                      variant: ButtonVariant.ghost,
                                      size: ButtonSize.icon,
                                      child: Container(
                                        width: 40,
                                        height: 40,
                                        decoration: BoxDecoration(
                                          borderRadius: BorderRadius.circular(20),
                                          color: AppColors.calendarDateHover,
                                        ),
                                        child: const Icon(Icons.settings, size: 20),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          
                          const SizedBox(height: 24),
                          
                          // Mood Data Section
                          AppCard(
                            backgroundColor: AppColors.calendarBg,
                            borderRadius: BorderRadius.circular(24),
                            padding: const EdgeInsets.all(24),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  '이번 달 기분 분석',
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                const SizedBox(height: 24),
                                
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      '총 일기 수',
                                      style: TextStyle(
                                        fontSize: 14,
                                        color: AppColors.mutedForeground,
                                      ),
                                    ),
                                    Text(
                                      '${happinessData['totalDays']}일',
                                      style: const TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ],
                                ),
                                
                                const SizedBox(height: 24),
                                
                                // Happiness Gauge
                                Center(
                                  child: Column(
                                    children: [
                                      SizedBox(
                                        width: 200,
                                        height: 120,
                                        child: CustomPaint(
                                          painter: HappinessGaugePainter(
                                            happinessIndex: happinessData['happinessIndex'],
                                            gaugeAngle: happinessData['gaugeAngle'],
                                            happinessColor: happinessData['happinessColor'],
                                            happinessEmoji: happinessData['happinessEmoji'],
                                          ),
                                        ),
                                      ),
                                      const SizedBox(height: 16),
                                      Column(
                                        children: [
                                          Text(
                                            '${happinessData['happinessIndex']}%',
                                            style: TextStyle(
                                              fontSize: 24,
                                              fontWeight: FontWeight.bold,
                                              color: happinessData['happinessColor'],
                                            ),
                                          ),
                                          Text(
                                            '행복 지수',
                                            style: TextStyle(
                                              fontSize: 14,
                                              color: AppColors.mutedForeground,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                          
                          const SizedBox(height: 24),
                          
                          // Voice Setting
                          AppCard(
                            backgroundColor: AppColors.calendarBg,
                            borderRadius: BorderRadius.circular(24),
                            padding: const EdgeInsets.all(24),
                            child: Column(
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    const Text(
                                      'AI 목소리 음성 기능',
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                    Switch(
                                      value: _voiceEnabled,
                                      onChanged: (value) {
                                        setState(() {
                                          _voiceEnabled = value;
                                        });
                                      },
                                      activeColor: AppColors.primary,
                                    ),
                                  ],
                                ),
                                
                                if (_voiceEnabled) ...[
                                  const SizedBox(height: 16),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      const Text(
                                        '음성 볼륨',
                                        style: TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                      Text(
                                        '${_voiceVolume.round()}%',
                                        style: TextStyle(
                                          fontSize: 14,
                                          color: AppColors.mutedForeground,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 8),
                                  Slider(
                                    value: _voiceVolume,
                                    min: 0,
                                    max: 100,
                                    divisions: 100,
                                    onChanged: (value) {
                                      setState(() {
                                        _voiceVolume = value;
                                      });
                                    },
                                    activeColor: AppColors.primary,
                                  ),
                                ],
                              ],
                            ),
                          ),
                          
                          const SizedBox(height: 24),
                          
                          // Emoticon Setting
                          AppCard(
                            backgroundColor: AppColors.calendarBg,
                            borderRadius: BorderRadius.circular(24),
                            padding: const EdgeInsets.all(24),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        const Text(
                                          '이모티콘 표시',
                                          style: TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          '캘린더에 감정 이모티콘을 표시합니다',
                                          style: TextStyle(
                                            fontSize: 14,
                                            color: AppColors.mutedForeground,
                                          ),
                                        ),
                                      ],
                                    ),
                                    Switch(
                                      value: appState.emoticonEnabled,
                                      onChanged: appState.setEmoticonEnabled,
                                      activeColor: AppColors.primary,
                                    ),
                                  ],
                                ),
                                
                                if (appState.emoticonEnabled) ...[
                                  const SizedBox(height: 16),
                                  Container(
                                    width: double.infinity,
                                    height: 1,
                                    color: AppColors.border,
                                  ),
                                  const SizedBox(height: 16),
                                  
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      const Text(
                                        '이모티콘 카테고리 관리',
                                        style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                      AppButton(
                                        onPressed: () {
                                          setState(() {
                                            _isEmojiDialogOpen = true;
                                          });
                                        },
                                        variant: ButtonVariant.outline,
                                        child: const Text('편집'),
                                      ),
                                    ],
                                  ),
                                  
                                  const SizedBox(height: 16),
                                  
                                  // Quick Preview
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        '현재 설정된 카테고리',
                                        style: TextStyle(
                                          fontSize: 14,
                                          color: AppColors.mutedForeground,
                                        ),
                                      ),
                                      const SizedBox(height: 8),
                                      Container(
                                        padding: const EdgeInsets.all(12),
                                        decoration: BoxDecoration(
                                          color: AppColors.muted.withOpacity(0.5),
                                          borderRadius: BorderRadius.circular(8),
                                        ),
                                        child: Row(
                                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                          children: [
                                            Row(
                                              children: [
                                                Text(
                                                  _emotionLabels[_selectedEmotion]!,
                                                  style: const TextStyle(fontSize: 12),
                                                ),
                                                if (appState.userSubscription != UserSubscription.premium && 
                                                    _selectedEmotion != Emotion.shape)
                                                  const Text('🔒', style: TextStyle(fontSize: 12)),
                                              ],
                                            ),
                                            Row(
                                              children: [
                                                ...(_emojiCategories[_selectedEmotion]!.take(3).map((emoji) => 
                                                  Text(emoji, style: const TextStyle(fontSize: 12)))),
                                                if (_emojiCategories[_selectedEmotion]!.length > 3)
                                                  Text(
                                                    '+${_emojiCategories[_selectedEmotion]!.length - 3}',
                                                    style: TextStyle(
                                                      fontSize: 12,
                                                      color: AppColors.mutedForeground,
                                                    ),
                                                  ),
                                              ],
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ],
                            ),
                          ),
                          
                          const SizedBox(height: 32),
                          
                          // Logout Button
                          AppCard(
                            backgroundColor: AppColors.calendarBg,
                            borderRadius: BorderRadius.circular(24),
                            padding: const EdgeInsets.all(16),
                            child: SizedBox(
                              width: double.infinity,
                              child: AppButton(
                                onPressed: appState.handleLogout,
                                variant: ButtonVariant.primary,
                                child: const Padding(
                                  padding: EdgeInsets.symmetric(vertical: 12),
                                  child: Text(
                                    '로그아웃',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

// 행복 지수 게이지를 그리는 CustomPainter
class HappinessGaugePainter extends CustomPainter {
  final int happinessIndex;
  final double gaugeAngle;
  final Color happinessColor;
  final String happinessEmoji;

  HappinessGaugePainter({
    required this.happinessIndex,
    required this.gaugeAngle,
    required this.happinessColor,
    required this.happinessEmoji,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height - 20);
    final radius = 80.0;
    
    // Gradient colors for the gauge
    final gradient = LinearGradient(
      colors: [
        const Color(0xFFDC2626), // Red for unhappy
        const Color(0xFFEAB308), // Yellow for neutral
        const Color(0xFF22C55E), // Green for happy
      ],
    );
    
    // Draw gauge background (semicircle with gradient)
    final paint = Paint()
      ..shader = gradient.createShader(Rect.fromCircle(center: center, radius: radius))
      ..strokeWidth = 8
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;
    
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      pi, // Start from left (180 degrees)
      pi, // Draw half circle (180 degrees)
      false,
      paint..color = paint.color.withOpacity(0.6),
    );
    
    // Draw needle
    final needleAngle = gaugeAngle * pi / 180;
    final needleEnd = Offset(
      center.dx + 60 * cos(needleAngle),
      center.dy - 60 * sin(needleAngle),
    );
    
    final needlePaint = Paint()
      ..color = happinessColor
      ..strokeWidth = 3
      ..strokeCap = StrokeCap.round;
    
    canvas.drawLine(center, needleEnd, needlePaint);
    
    // Draw center dot
    final centerPaint = Paint()..color = happinessColor;
    canvas.drawCircle(center, 6, centerPaint);
    
    // Draw labels
    final textStyle = TextStyle(
      fontSize: 12,
      color: AppColors.mutedForeground,
    );
    
    final unhappyPainter = TextPainter(
      text: TextSpan(text: '불행', style: textStyle),
      textDirection: TextDirection.ltr,
    );
    unhappyPainter.layout();
    unhappyPainter.paint(canvas, Offset(20, size.height - 10));
    
    final happyPainter = TextPainter(
      text: TextSpan(text: '행복', style: textStyle),
      textDirection: TextDirection.ltr,
    );
    happyPainter.layout();
    happyPainter.paint(canvas, Offset(size.width - 40, size.height - 10));
    
    // Draw emoji on needle tip
    final emojiPainter = TextPainter(
      text: TextSpan(
        text: happinessEmoji,
        style: const TextStyle(fontSize: 20),
      ),
      textDirection: TextDirection.ltr,
    );
    emojiPainter.layout();
    emojiPainter.paint(
      canvas,
      Offset(
        center.dx + 70 * cos(needleAngle) - emojiPainter.width / 2,
        center.dy - 70 * sin(needleAngle) - emojiPainter.height / 2,
      ),
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
} 