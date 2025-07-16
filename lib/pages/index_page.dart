import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/app_state.dart';
import '../components/auth_page.dart';
import '../components/diary_calendar.dart';
import '../components/diary_entry.dart';
import '../components/my_page.dart';

class IndexPage extends StatelessWidget {
  const IndexPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<AppState>(
      builder: (BuildContext context, AppState appState, Widget? child) {
        // Show auth page if not authenticated
        if (!appState.isAuthenticated) {
          return const AuthPage();
        }

        // Show different views based on current view state
        switch (appState.currentView) {
          case CurrentView.entry:
            final existingEntry = appState.emotionData[appState.selectedDate];
            return DiaryEntry(
              selectedDate: appState.selectedDate,
              existingEntry: existingEntry,
              onBack: () => appState.handleBackToCalendar(),
              onSave: (String entry, Emotion emotion, List<String>? images) {
                appState.saveDiary(entry, emotion, images);
              },
            );
          
          case CurrentView.mypage:
            return const MyPage();
          
          case CurrentView.calendar:
          default:
            return const DiaryCalendar();
        }
      },
    );
  }
} 