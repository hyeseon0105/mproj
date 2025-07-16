import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/app_state.dart';
import '../theme.dart';

class MyPage extends StatelessWidget {
  const MyPage({super.key});

  @override
  Widget build(BuildContext context) {
    final appState = Provider.of<AppState>(context);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('마이페이지'),
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.primaryForeground,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            appState.handleBackToCalendar();
          },
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '사용자 설정',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: AppColors.foreground,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          '이모티콘 표시',
                          style: TextStyle(
                            color: AppColors.foreground,
                          ),
                        ),
                        Switch(
                          value: appState.emoticonEnabled,
                          onChanged: (value) {
                            appState.setEmoticonEnabled(value);
                          },
                          activeColor: AppColors.primary,
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          '구독 상태',
                          style: TextStyle(
                            color: AppColors.foreground,
                          ),
                        ),
                        Text(
                          appState.userSubscription == UserSubscription.premium ? 'Premium' : 'Normal',
                          style: TextStyle(
                            color: appState.userSubscription == UserSubscription.premium
                                ? AppColors.primary
                                : AppColors.mutedForeground,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '통계',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: AppColors.foreground,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      '총 일기 개수: ${appState.emotionData.length}개',
                      style: TextStyle(
                        color: AppColors.foreground,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const Spacer(),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  appState.handleLogout();
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.destructive,
                  foregroundColor: AppColors.destructiveForeground,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: const Text('로그아웃'),
              ),
            ),
          ],
        ),
      ),
    );
  }
} 