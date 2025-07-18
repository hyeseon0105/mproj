import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/app_state.dart';
import '../theme.dart';
import '../ui/card.dart';
import '../ui/button.dart';
import '../services/payment_service.dart';
import 'dart:math';

class MyPage extends StatefulWidget {
  const MyPage({super.key});

  @override
  State<MyPage> createState() => _MyPageState();
}

class _MyPageState extends State<MyPage> {
  final GlobalKey _birthdayInputKey = GlobalKey(); // 생일 입력 박스의 위치를 찾기 위한 키
  bool _voiceEnabled = true;
  double _voiceVolume = 50;
  String _userName = '사용자';
  bool _isProfileDialogOpen = false;
  bool _isEmojiDialogOpen = false;
  final bool _isPremiumModalOpen = false;
  bool _isCalendarVisible = false;
  String _tempName = '사용자';
  DateTime? _tempBirthday;
  DateTime _currentCalendarDate = DateTime.now(); // 현재 표시중인 달력의 년/월 상태 추가
  
  // 사용자 설정 이모티콘 카테고리 (Firebase 이미지 URL 사용)
  Map<Emotion, List<String>> _emojiCategories = {
    Emotion.shape: [
      'https://firebasestorage.googleapis.com/v0/b/diary-3bbf7.firebasestorage.app/o/shape%2Fneutral_shape-removebg-preview.png?alt=media&token=02e85132-3a83-4257-8c1e-d2e478c7fcf5',
      'https://firebasestorage.googleapis.com/v0/b/diary-3bbf7.firebasestorage.app/o/shape%2Fexcited_shape-removebg-preview.png?alt=media&token=85fadfb8-7006-44d0-a39d-b3fd6070bb96',
      'https://firebasestorage.googleapis.com/v0/b/diary-3bbf7.firebasestorage.app/o/shape%2Fconfident_shape-removebg-preview.png?alt=media&token=8ab02bc8-8569-42ff-b78d-b9527f15d0af',
      'https://firebasestorage.googleapis.com/v0/b/diary-3bbf7.firebasestorage.app/o/shape%2Fangry_shape-removebg-preview.png?alt=media&token=92a25f79-4c1d-4b5d-9e5c-2f469e56cefa',
      'https://firebasestorage.googleapis.com/v0/b/diary-3bbf7.firebasestorage.app/o/shape%2Fdetermined_shape-removebg-preview.png?alt=media&token=69eb4cf0-ab61-4f5e-add3-b2148dc2a108',
      'https://firebasestorage.googleapis.com/v0/b/diary-3bbf7.firebasestorage.app/o/shape%2Fhappy_shape-removebg-preview.png?alt=media&token=5a8aa9dd-6ea5-4132-95af-385340846076',
      'https://firebasestorage.googleapis.com/v0/b/diary-3bbf7.firebasestorage.app/o/shape%2Fcalm_shape-removebg-preview.png?alt=media&token=cdc2fa85-10b7-46f6-881c-dd874c38b3ea',
      'https://firebasestorage.googleapis.com/v0/b/diary-3bbf7.firebasestorage.app/o/shape%2Flove_shape-removebg-preview.png?alt=media&token=1a7ec74f-4297-42a4-aeb8-97aee1e9ff6c',
      'https://firebasestorage.googleapis.com/v0/b/diary-3bbf7.firebasestorage.app/o/shape%2Fsad_shape-removebg-preview.png?alt=media&token=acbc7284-1126-4428-a3b2-f8b6e7932b98',
      'https://firebasestorage.googleapis.com/v0/b/diary-3bbf7.firebasestorage.app/o/shape%2Ftouched_shape-removebg-preview.png?alt=media&token=bbb50a1c-90d6-43fd-be40-4be4f51bc1d0',
      'https://firebasestorage.googleapis.com/v0/b/diary-3bbf7.firebasestorage.app/o/shape%2Fanxious_shape-removebg-preview.png?alt=media&token=7859ebac-cd9d-43a3-a42c-aec651d37e6e',
      'https://firebasestorage.googleapis.com/v0/b/diary-3bbf7.firebasestorage.app/o/shape%2Fconfused_shape-removebg-preview.png?alt=media&token=4794d127-9b61-4c68-86de-8478c4da8fb9'
    ],
    Emotion.fruit: [
      'https://firebasestorage.googleapis.com/v0/b/diary-3bbf7.firebasestorage.app/o/fruit%2Fneutral_fruit-removebg-preview.png?alt=media&token=9bdea06c-13e6-4c59-b961-1424422a3c39',
      'https://firebasestorage.googleapis.com/v0/b/diary-3bbf7.firebasestorage.app/o/fruit%2Fhappy_fruit-removebg-preview.png?alt=media&token=d10a503b-fee7-4bc2-b141-fd4b33dae1f1',
      'https://firebasestorage.googleapis.com/v0/b/diary-3bbf7.firebasestorage.app/o/fruit%2Fcalm_fruit-removebg-preview.png?alt=media&token=839efcad-0022-4cc9-ac38-90175d9026d2',
      'https://firebasestorage.googleapis.com/v0/b/diary-3bbf7.firebasestorage.app/o/fruit%2Flove_fruit-removebg-preview.png?alt=media&token=ba7857c6-5afd-48e0-addd-7b3f54583c15',
      'https://firebasestorage.googleapis.com/v0/b/diary-3bbf7.firebasestorage.app/o/fruit%2Fexcited_fruit-removebg-preview.png?alt=media&token=0284bce2-aa88-4766-97fb-5d5d2248cf31',
      'https://firebasestorage.googleapis.com/v0/b/diary-3bbf7.firebasestorage.app/o/fruit%2Fangry_fruit-removebg-preview.png?alt=media&token=679778b9-5a1b-469a-8e86-b01585cb1ee2',
      'https://firebasestorage.googleapis.com/v0/b/diary-3bbf7.firebasestorage.app/o/fruit%2Fconfident_fruit-removebg-preview.png?alt=media&token=6edcc903-8d78-4dd9-bcdd-1c6b26645044',
      'https://firebasestorage.googleapis.com/v0/b/diary-3bbf7.firebasestorage.app/o/fruit%2Fdetermined_fruit-removebg-preview.png?alt=media&token=ed288879-86c4-4d6d-946e-477f2aafc3ce',
      'https://firebasestorage.googleapis.com/v0/b/diary-3bbf7.firebasestorage.app/o/fruit%2Fsad_fruit-removebg-preview.png?alt=media&token=e9e0b0f7-6590-4209-a7d1-26377eb33c05',
      'https://firebasestorage.googleapis.com/v0/b/diary-3bbf7.firebasestorage.app/o/fruit%2Ftouched_fruit-removebg-preview.png?alt=media&token=c69dee6d-7d53-4af7-a884-2f751aecbe42',
      'https://firebasestorage.googleapis.com/v0/b/diary-3bbf7.firebasestorage.app/o/fruit%2Fanxious_fruit-removebg-preview.png?alt=media&token=be8f8279-2b08-47bf-9856-c39daf5eac40',
      'https://firebasestorage.googleapis.com/v0/b/diary-3bbf7.firebasestorage.app/o/fruit%2Fconfused_fruit-removebg-preview.png?alt=media&token=7adfcf22-af7a-4eb1-a225-34875b6540cf'
    ],
    Emotion.animal: [
      'https://firebasestorage.googleapis.com/v0/b/diary-3bbf7.firebasestorage.app/o/animal%2Fneutral_animal-removebg-preview.png?alt=media&token=f884e38d-5d8c-4d4a-bb62-a47a198d384f',
      'https://firebasestorage.googleapis.com/v0/b/diary-3bbf7.firebasestorage.app/o/animal%2Fhappy_animal-removebg-preview.png?alt=media&token=66ff8e2d-d941-4fd7-9d7f-9766db03cbd5',
      'https://firebasestorage.googleapis.com/v0/b/diary-3bbf7.firebasestorage.app/o/animal%2Fcalm_animal-removebg-preview.png?alt=media&token=afd7bf65-5150-40e3-8b95-cd956dff113d',
      'https://firebasestorage.googleapis.com/v0/b/diary-3bbf7.firebasestorage.app/o/animal%2Flove_animal-removebg-preview.png?alt=media&token=e0e2ccbd-b59a-4d09-968a-562208f90be1',
      'https://firebasestorage.googleapis.com/v0/b/diary-3bbf7.firebasestorage.app/o/animal%2Fexcited_animal-removebg-preview.png?alt=media&token=48442937-5504-4392-88a9-039aef405f14',
      'https://firebasestorage.googleapis.com/v0/b/diary-3bbf7.firebasestorage.app/o/animal%2Fangry_animal-removebg-preview.png?alt=media&token=9bde31db-8801-4af0-9368-e6ce4a35fbac',
      'https://firebasestorage.googleapis.com/v0/b/diary-3bbf7.firebasestorage.app/o/animal%2Fconfident__animal-removebg-preview.png?alt=media&token=2983b323-a2a6-40aa-9b6c-a381d944dd27',
      'https://firebasestorage.googleapis.com/v0/b/diary-3bbf7.firebasestorage.app/o/animal%2Fdetermined_animal-removebg-preview.png?alt=media&token=abf05981-4ab3-49b3-ba37-096ab8c22478',
      'https://firebasestorage.googleapis.com/v0/b/diary-3bbf7.firebasestorage.app/o/animal%2Fsad_animal-removebg-preview.png?alt=media&token=04c99bd8-8ad4-43de-91cd-3b7354780677',
      'https://firebasestorage.googleapis.com/v0/b/diary-3bbf7.firebasestorage.app/o/animal%2Ftouched_animal-removebg-preview.png?alt=media&token=629be9ec-be17-407f-beb0-6b67f09b7036',
      'https://firebasestorage.googleapis.com/v0/b/diary-3bbf7.firebasestorage.app/o/animal%2Fanxious_animal-removebg-preview.png?alt=media&token=bd25e31d-629b-4e79-b95e-019f8c76dac2',
      'https://firebasestorage.googleapis.com/v0/b/diary-3bbf7.firebasestorage.app/o/animal%2Fconfused__animal-removebg-preview.png?alt=media&token=74192a1e-86a7-4eb6-b690-154984c427dc'
    ],
    Emotion.weather: [
      'https://firebasestorage.googleapis.com/v0/b/diary-3bbf7.firebasestorage.app/o/wheather%2Fneutral_weather-removebg-preview.png?alt=media&token=57ad1adf-baa6-4b79-96f5-066a4ec3358f',
      'https://firebasestorage.googleapis.com/v0/b/diary-3bbf7.firebasestorage.app/o/wheather%2Fhappy_weather-removebg-preview.png?alt=media&token=fd77e998-6f47-459a-bd1c-458e309fed41',
      'https://firebasestorage.googleapis.com/v0/b/diary-3bbf7.firebasestorage.app/o/wheather%2Fcalm_weather-removebg-preview.png?alt=media&token=7703fd25-fe2b-4750-a415-5f86c4e7b058',
      'https://firebasestorage.googleapis.com/v0/b/diary-3bbf7.firebasestorage.app/o/wheather%2Flove_weather-removebg-preview.png?alt=media&token=2451105b-ab3e-482d-bf9f-12f0a6a69a53',
      'https://firebasestorage.googleapis.com/v0/b/diary-3bbf7.firebasestorage.app/o/wheather%2Fexcited_weather-removebg-preview.png?alt=media&token=5de71f38-1178-4e3c-887e-af07547caba9',
      'https://firebasestorage.googleapis.com/v0/b/diary-3bbf7.firebasestorage.app/o/wheather%2Fangry_weather-removebg-preview.png?alt=media&token=2f4c6212-697d-49b7-9d5e-ae1f2b1fa84e',
      'https://firebasestorage.googleapis.com/v0/b/diary-3bbf7.firebasestorage.app/o/wheather%2Fconfident_weather-removebg-preview.png?alt=media&token=ea30d002-312b-4ae5-ad85-933bbc009dc6',
      'https://firebasestorage.googleapis.com/v0/b/diary-3bbf7.firebasestorage.app/o/wheather%2Fdetermined_weather-removebg-preview.png?alt=media&token=0eb8fb3d-22dd-4b4f-8e12-7d830f32be6d',
      'https://firebasestorage.googleapis.com/v0/b/diary-3bbf7.firebasestorage.app/o/wheather%2Fsad_weather-removebg-preview.png?alt=media&token=aa972b9a-8952-4dc7-abe7-692ec7be0d16',
      'https://firebasestorage.googleapis.com/v0/b/diary-3bbf7.firebasestorage.app/o/wheather%2Ftouched_weather-removebg-preview.png?alt=media&token=5e224042-72ae-45a4-891a-8e6abdb5285c',
      'https://firebasestorage.googleapis.com/v0/b/diary-3bbf7.firebasestorage.app/o/wheather%2Fanxious_weather-removebg-preview.png?alt=media&token=fc718a17-8d8e-4ed1-a78a-891fa9a149d0',
      'https://firebasestorage.googleapis.com/v0/b/diary-3bbf7.firebasestorage.app/o/wheather%2Fconfused_weather-removebg-preview.png?alt=media&token=afdfb6bf-2c69-4ef2-97a1-2e5aa67e6fdb'
    ],
  };

  // Firebase 이미지 URL 매핑
  Map<Emotion, List<String>> _firebaseImageUrls = {
    Emotion.shape: [
      'https://firebasestorage.googleapis.com/v0/b/diary-3bbf7.firebasestorage.app/o/shape%2Fneutral_shape-removebg-preview.png?alt=media&token=02e85132-3a83-4257-8c1e-d2e478c7fcf5',
      'https://firebasestorage.googleapis.com/v0/b/diary-3bbf7.firebasestorage.app/o/shape%2Fexcited_shape-removebg-preview.png?alt=media&token=85fadfb8-7006-44d0-a39d-b3fd6070bb96',
      'https://firebasestorage.googleapis.com/v0/b/diary-3bbf7.firebasestorage.app/o/shape%2Fconfident_shape-removebg-preview.png?alt=media&token=8ab02bc8-8569-42ff-b78d-b9527f15d0af',
      'https://firebasestorage.googleapis.com/v0/b/diary-3bbf7.firebasestorage.app/o/shape%2Fangry_shape-removebg-preview.png?alt=media&token=92a25f79-4c1d-4b5d-9e5c-2f469e56cefa',
      'https://firebasestorage.googleapis.com/v0/b/diary-3bbf7.firebasestorage.app/o/shape%2Fdetermined_shape-removebg-preview.png?alt=media&token=69eb4cf0-ab61-4f5e-add3-b2148dc2a108'
    ],
    Emotion.fruit: [
      'https://firebasestorage.googleapis.com/v0/b/diary-3bbf7.firebasestorage.app/o/fruit%2Fneutral_fruit-removebg-preview.png?alt=media&token=9bdea06c-13e6-4c59-b961-1424422a3c39',
      'https://firebasestorage.googleapis.com/v0/b/diary-3bbf7.firebasestorage.app/o/fruit%2Fhappy_fruit-removebg-preview.png?alt=media&token=d10a503b-fee7-4bc2-b141-fd4b33dae1f1',
      'https://firebasestorage.googleapis.com/v0/b/diary-3bbf7.firebasestorage.app/o/fruit%2Fcalm_fruit-removebg-preview.png?alt=media&token=839efcad-0022-4cc9-ac38-90175d9026d2',
      'https://firebasestorage.googleapis.com/v0/b/diary-3bbf7.firebasestorage.app/o/fruit%2Flove_fruit-removebg-preview.png?alt=media&token=ba7857c6-5afd-48e0-addd-7b3f54583c15',
      'https://firebasestorage.googleapis.com/v0/b/diary-3bbf7.firebasestorage.app/o/fruit%2Fexcited_fruit-removebg-preview.png?alt=media&token=0284bce2-aa88-4766-97fb-5d5d2248cf31'
    ],
    Emotion.animal: [
      'https://firebasestorage.googleapis.com/v0/b/diary-3bbf7.firebasestorage.app/o/animal%2Fneutral_animal-removebg-preview.png?alt=media&token=f884e38d-5d8c-4d4a-bb62-a47a198d384f',
      'https://firebasestorage.googleapis.com/v0/b/diary-3bbf7.firebasestorage.app/o/animal%2Fhappy_animal-removebg-preview.png?alt=media&token=66ff8e2d-d941-4fd7-9d7f-9766db03cbd5',
      'https://firebasestorage.googleapis.com/v0/b/diary-3bbf7.firebasestorage.app/o/animal%2Fcalm_animal-removebg-preview.png?alt=media&token=afd7bf65-5150-40e3-8b95-cd956dff113d',
      'https://firebasestorage.googleapis.com/v0/b/diary-3bbf7.firebasestorage.app/o/animal%2Flove_animal-removebg-preview.png?alt=media&token=e0e2ccbd-b59a-4d09-968a-562208f90be1',
      'https://firebasestorage.googleapis.com/v0/b/diary-3bbf7.firebasestorage.app/o/animal%2Fexcited_animal-removebg-preview.png?alt=media&token=48442937-5504-4392-88a9-039aef405f14'
    ],
    Emotion.weather: [
      'https://firebasestorage.googleapis.com/v0/b/diary-3bbf7.firebasestorage.app/o/wheather%2Fneutral_weather-removebg-preview.png?alt=media&token=57ad1adf-baa6-4b79-96f5-066a4ec3358f',
      'https://firebasestorage.googleapis.com/v0/b/diary-3bbf7.firebasestorage.app/o/wheather%2Fsad_weather-removebg-preview.png?alt=media&token=aa972b9a-8952-4dc7-abe7-692ec7be0d16',
      'https://firebasestorage.googleapis.com/v0/b/diary-3bbf7.firebasestorage.app/o/wheather%2Fangry_weather-removebg-preview.png?alt=media&token=2f4c6212-697d-49b7-9d5e-ae1f2b1fa84e',
      'https://firebasestorage.googleapis.com/v0/b/diary-3bbf7.firebasestorage.app/o/wheather%2Fexcited_weather-removebg-preview.png?alt=media&token=5de71f38-1178-4e3c-887e-af07547caba9',
      'https://firebasestorage.googleapis.com/v0/b/diary-3bbf7.firebasestorage.app/o/wheather%2Fcalm_weather-removebg-preview.png?alt=media&token=7703fd25-fe2b-4750-a415-5f86c4e7b058'
    ]
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



  // 카테고리별 사용 가능한 Firebase 이미지 URL 맵
  final Map<Emotion, List<String>> _availableEmoticonsByCategory = {
    Emotion.shape: [
      'https://firebasestorage.googleapis.com/v0/b/diary-3bbf7.firebasestorage.app/o/shape%2Fneutral_shape-removebg-preview.png?alt=media&token=02e85132-3a83-4257-8c1e-d2e478c7fcf5',
      'https://firebasestorage.googleapis.com/v0/b/diary-3bbf7.firebasestorage.app/o/shape%2Fexcited_shape-removebg-preview.png?alt=media&token=85fadfb8-7006-44d0-a39d-b3fd6070bb96',
      'https://firebasestorage.googleapis.com/v0/b/diary-3bbf7.firebasestorage.app/o/shape%2Fconfident_shape-removebg-preview.png?alt=media&token=8ab02bc8-8569-42ff-b78d-b9527f15d0af',
      'https://firebasestorage.googleapis.com/v0/b/diary-3bbf7.firebasestorage.app/o/shape%2Fangry_shape-removebg-preview.png?alt=media&token=92a25f79-4c1d-4b5d-9e5c-2f469e56cefa',
      'https://firebasestorage.googleapis.com/v0/b/diary-3bbf7.firebasestorage.app/o/shape%2Fdetermined_shape-removebg-preview.png?alt=media&token=69eb4cf0-ab61-4f5e-add3-b2148dc2a108',
      'https://firebasestorage.googleapis.com/v0/b/diary-3bbf7.firebasestorage.app/o/shape%2Fhappy_shape-removebg-preview.png?alt=media&token=5a8aa9dd-6ea5-4132-95af-385340846076',
      'https://firebasestorage.googleapis.com/v0/b/diary-3bbf7.firebasestorage.app/o/shape%2Fcalm_shape-removebg-preview.png?alt=media&token=cdc2fa85-10b7-46f6-881c-dd874c38b3ea',
      'https://firebasestorage.googleapis.com/v0/b/diary-3bbf7.firebasestorage.app/o/shape%2Flove_shape-removebg-preview.png?alt=media&token=1a7ec74f-4297-42a4-aeb8-97aee1e9ff6c',
      'https://firebasestorage.googleapis.com/v0/b/diary-3bbf7.firebasestorage.app/o/shape%2Fsad_shape-removebg-preview.png?alt=media&token=acbc7284-1126-4428-a3b2-f8b6e7932b98',
      'https://firebasestorage.googleapis.com/v0/b/diary-3bbf7.firebasestorage.app/o/shape%2Ftouched_shape-removebg-preview.png?alt=media&token=bbb50a1c-90d6-43fd-be40-4be4f51bc1d0',
      'https://firebasestorage.googleapis.com/v0/b/diary-3bbf7.firebasestorage.app/o/shape%2Fanxious_shape-removebg-preview.png?alt=media&token=7859ebac-cd9d-43a3-a42c-aec651d37e6e',
      'https://firebasestorage.googleapis.com/v0/b/diary-3bbf7.firebasestorage.app/o/shape%2Fconfused_shape-removebg-preview.png?alt=media&token=4794d127-9b61-4c68-86de-8478c4da8fb9'
    ],
    Emotion.fruit: [
      'https://firebasestorage.googleapis.com/v0/b/diary-3bbf7.firebasestorage.app/o/fruit%2Fneutral_fruit-removebg-preview.png?alt=media&token=9bdea06c-13e6-4c59-b961-1424422a3c39',
      'https://firebasestorage.googleapis.com/v0/b/diary-3bbf7.firebasestorage.app/o/fruit%2Fhappy_fruit-removebg-preview.png?alt=media&token=d10a503b-fee7-4bc2-b141-fd4b33dae1f1',
      'https://firebasestorage.googleapis.com/v0/b/diary-3bbf7.firebasestorage.app/o/fruit%2Fcalm_fruit-removebg-preview.png?alt=media&token=839efcad-0022-4cc9-ac38-90175d9026d2',
      'https://firebasestorage.googleapis.com/v0/b/diary-3bbf7.firebasestorage.app/o/fruit%2Flove_fruit-removebg-preview.png?alt=media&token=ba7857c6-5afd-48e0-addd-7b3f54583c15',
      'https://firebasestorage.googleapis.com/v0/b/diary-3bbf7.firebasestorage.app/o/fruit%2Fexcited_fruit-removebg-preview.png?alt=media&token=0284bce2-aa88-4766-97fb-5d5d2248cf31',
      'https://firebasestorage.googleapis.com/v0/b/diary-3bbf7.firebasestorage.app/o/fruit%2Fangry_fruit-removebg-preview.png?alt=media&token=679778b9-5a1b-469a-8e86-b01585cb1ee2',
      'https://firebasestorage.googleapis.com/v0/b/diary-3bbf7.firebasestorage.app/o/fruit%2Fconfident_fruit-removebg-preview.png?alt=media&token=6edcc903-8d78-4dd9-bcdd-1c6b26645044',
      'https://firebasestorage.googleapis.com/v0/b/diary-3bbf7.firebasestorage.app/o/fruit%2Fdetermined_fruit-removebg-preview.png?alt=media&token=ed288879-86c4-4d6d-946e-477f2aafc3ce',
      'https://firebasestorage.googleapis.com/v0/b/diary-3bbf7.firebasestorage.app/o/fruit%2Fsad_fruit-removebg-preview.png?alt=media&token=e9e0b0f7-6590-4209-a7d1-26377eb33c05',
      'https://firebasestorage.googleapis.com/v0/b/diary-3bbf7.firebasestorage.app/o/fruit%2Ftouched_fruit-removebg-preview.png?alt=media&token=c69dee6d-7d53-4af7-a884-2f751aecbe42',
      'https://firebasestorage.googleapis.com/v0/b/diary-3bbf7.firebasestorage.app/o/fruit%2Fanxious_fruit-removebg-preview.png?alt=media&token=be8f8279-2b08-47bf-9856-c39daf5eac40',
      'https://firebasestorage.googleapis.com/v0/b/diary-3bbf7.firebasestorage.app/o/fruit%2Fconfused_fruit-removebg-preview.png?alt=media&token=7adfcf22-af7a-4eb1-a225-34875b6540cf'
    ],
    Emotion.animal: [
      'https://firebasestorage.googleapis.com/v0/b/diary-3bbf7.firebasestorage.app/o/animal%2Fneutral_animal-removebg-preview.png?alt=media&token=f884e38d-5d8c-4d4a-bb62-a47a198d384f',
      'https://firebasestorage.googleapis.com/v0/b/diary-3bbf7.firebasestorage.app/o/animal%2Fhappy_animal-removebg-preview.png?alt=media&token=66ff8e2d-d941-4fd7-9d7f-9766db03cbd5',
      'https://firebasestorage.googleapis.com/v0/b/diary-3bbf7.firebasestorage.app/o/animal%2Fcalm_animal-removebg-preview.png?alt=media&token=afd7bf65-5150-40e3-8b95-cd956dff113d',
      'https://firebasestorage.googleapis.com/v0/b/diary-3bbf7.firebasestorage.app/o/animal%2Flove_animal-removebg-preview.png?alt=media&token=e0e2ccbd-b59a-4d09-968a-562208f90be1',
      'https://firebasestorage.googleapis.com/v0/b/diary-3bbf7.firebasestorage.app/o/animal%2Fexcited_animal-removebg-preview.png?alt=media&token=48442937-5504-4392-88a9-039aef405f14',
      'https://firebasestorage.googleapis.com/v0/b/diary-3bbf7.firebasestorage.app/o/animal%2Fangry_animal-removebg-preview.png?alt=media&token=9bde31db-8801-4af0-9368-e6ce4a35fbac',
      'https://firebasestorage.googleapis.com/v0/b/diary-3bbf7.firebasestorage.app/o/animal%2Fconfident__animal-removebg-preview.png?alt=media&token=2983b323-a2a6-40aa-9b6c-a381d944dd27',
      'https://firebasestorage.googleapis.com/v0/b/diary-3bbf7.firebasestorage.app/o/animal%2Fdetermined_animal-removebg-preview.png?alt=media&token=abf05981-4ab3-49b3-ba37-096ab8c22478',
      'https://firebasestorage.googleapis.com/v0/b/diary-3bbf7.firebasestorage.app/o/animal%2Fsad_animal-removebg-preview.png?alt=media&token=04c99bd8-8ad4-43de-91cd-3b7354780677',
      'https://firebasestorage.googleapis.com/v0/b/diary-3bbf7.firebasestorage.app/o/animal%2Ftouched_animal-removebg-preview.png?alt=media&token=629be9ec-be17-407f-beb0-6b67f09b7036',
      'https://firebasestorage.googleapis.com/v0/b/diary-3bbf7.firebasestorage.app/o/animal%2Fanxious_animal-removebg-preview.png?alt=media&token=bd25e31d-629b-4e79-b95e-019f8c76dac2',
      'https://firebasestorage.googleapis.com/v0/b/diary-3bbf7.firebasestorage.app/o/animal%2Fconfused__animal-removebg-preview.png?alt=media&token=74192a1e-86a7-4eb6-b690-154984c427dc'
    ],
    Emotion.weather: [
      'https://firebasestorage.googleapis.com/v0/b/diary-3bbf7.firebasestorage.app/o/wheather%2Fneutral_weather-removebg-preview.png?alt=media&token=57ad1adf-baa6-4b79-96f5-066a4ec3358f',
      'https://firebasestorage.googleapis.com/v0/b/diary-3bbf7.firebasestorage.app/o/wheather%2Fhappy_weather-removebg-preview.png?alt=media&token=fd77e998-6f47-459a-bd1c-458e309fed41',
      'https://firebasestorage.googleapis.com/v0/b/diary-3bbf7.firebasestorage.app/o/wheather%2Fcalm_weather-removebg-preview.png?alt=media&token=7703fd25-fe2b-4750-a415-5f86c4e7b058',
      'https://firebasestorage.googleapis.com/v0/b/diary-3bbf7.firebasestorage.app/o/wheather%2Flove_weather-removebg-preview.png?alt=media&token=2451105b-ab3e-482d-bf9f-12f0a6a69a53',
      'https://firebasestorage.googleapis.com/v0/b/diary-3bbf7.firebasestorage.app/o/wheather%2Fexcited_weather-removebg-preview.png?alt=media&token=5de71f38-1178-4e3c-887e-af07547caba9',
      'https://firebasestorage.googleapis.com/v0/b/diary-3bbf7.firebasestorage.app/o/wheather%2Fangry_weather-removebg-preview.png?alt=media&token=2f4c6212-697d-49b7-9d5e-ae1f2b1fa84e',
      'https://firebasestorage.googleapis.com/v0/b/diary-3bbf7.firebasestorage.app/o/wheather%2Fconfident_weather-removebg-preview.png?alt=media&token=ea30d002-312b-4ae5-ad85-933bbc009dc6',
      'https://firebasestorage.googleapis.com/v0/b/diary-3bbf7.firebasestorage.app/o/wheather%2Fdetermined_weather-removebg-preview.png?alt=media&token=0eb8fb3d-22dd-4b4f-8e12-7d830f32be6d',
      'https://firebasestorage.googleapis.com/v0/b/diary-3bbf7.firebasestorage.app/o/wheather%2Fsad_weather-removebg-preview.png?alt=media&token=aa972b9a-8952-4dc7-abe7-692ec7be0d16',
      'https://firebasestorage.googleapis.com/v0/b/diary-3bbf7.firebasestorage.app/o/wheather%2Ftouched_weather-removebg-preview.png?alt=media&token=5e224042-72ae-45a4-891a-8e6abdb5285c',
      'https://firebasestorage.googleapis.com/v0/b/diary-3bbf7.firebasestorage.app/o/wheather%2Fanxious_weather-removebg-preview.png?alt=media&token=fc718a17-8d8e-4ed1-a78a-891fa9a149d0',
      'https://firebasestorage.googleapis.com/v0/b/diary-3bbf7.firebasestorage.app/o/wheather%2Fconfused_weather-removebg-preview.png?alt=media&token=afdfb6bf-2c69-4ef2-97a1-2e5aa67e6fdb'
    ],
  };

  @override
  void initState() {
    super.initState();
    _tempName = _userName;
    
    // AppState에서 사용자 설정 이모티콘 카테고리와 선택된 카테고리 로드
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final appState = Provider.of<AppState>(context, listen: false);
      setState(() {
        _emojiCategories = Map.from(appState.userEmoticonCategories);
        _selectedEmotion = appState.selectedEmoticonCategory;
      });
    });
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

  void _handleEmojiSelect(String imageUrl) {
    setState(() {
      var currentEmojis = _emojiCategories[_selectedEmotion]!;
      if (currentEmojis.contains(imageUrl)) {
        currentEmojis.remove(imageUrl);
      } else {
        currentEmojis.add(imageUrl);
      }
      _emojiCategories[_selectedEmotion] = List.from(currentEmojis);
    });

    // AppState에 사용자 설정 카테고리 저장
    final appState = Provider.of<AppState>(context, listen: false);
    appState.updateUserEmoticonCategory(_selectedEmotion, _emojiCategories[_selectedEmotion]!);
  }

  void _handleCategorySelect(Emotion emotion) {
    // 프리미엄 제한 제거 - 모든 카테고리 자유롭게 선택 가능
    setState(() {
      _selectedEmotion = emotion;
    });
    
    // AppState에 선택된 카테고리 저장
    final appState = Provider.of<AppState>(context, listen: false);
    appState.setSelectedEmoticonCategory(emotion);
  }

  // 프리미엄 구독 다이얼로그 제거 - 모든 카테고리 자유롭게 사용 가능

  void _resetToDefault() {
    setState(() {
      _emojiCategories = {
        Emotion.shape: [
          'https://firebasestorage.googleapis.com/v0/b/diary-3bbf7.firebasestorage.app/o/shape%2Fneutral_shape-removebg-preview.png?alt=media&token=02e85132-3a83-4257-8c1e-d2e478c7fcf5',
          'https://firebasestorage.googleapis.com/v0/b/diary-3bbf7.firebasestorage.app/o/shape%2Fexcited_shape-removebg-preview.png?alt=media&token=85fadfb8-7006-44d0-a39d-b3fd6070bb96',
          'https://firebasestorage.googleapis.com/v0/b/diary-3bbf7.firebasestorage.app/o/shape%2Fconfident_shape-removebg-preview.png?alt=media&token=8ab02bc8-8569-42ff-b78d-b9527f15d0af',
          'https://firebasestorage.googleapis.com/v0/b/diary-3bbf7.firebasestorage.app/o/shape%2Fangry_shape-removebg-preview.png?alt=media&token=92a25f79-4c1d-4b5d-9e5c-2f469e56cefa',
          'https://firebasestorage.googleapis.com/v0/b/diary-3bbf7.firebasestorage.app/o/shape%2Fdetermined_shape-removebg-preview.png?alt=media&token=69eb4cf0-ab61-4f5e-add3-b2148dc2a108',
          'https://firebasestorage.googleapis.com/v0/b/diary-3bbf7.firebasestorage.app/o/shape%2Fhappy_shape-removebg-preview.png?alt=media&token=5a8aa9dd-6ea5-4132-95af-385340846076',
          'https://firebasestorage.googleapis.com/v0/b/diary-3bbf7.firebasestorage.app/o/shape%2Fcalm_shape-removebg-preview.png?alt=media&token=cdc2fa85-10b7-46f6-881c-dd874c38b3ea',
          'https://firebasestorage.googleapis.com/v0/b/diary-3bbf7.firebasestorage.app/o/shape%2Flove_shape-removebg-preview.png?alt=media&token=1a7ec74f-4297-42a4-aeb8-97aee1e9ff6c',
          'https://firebasestorage.googleapis.com/v0/b/diary-3bbf7.firebasestorage.app/o/shape%2Fsad_shape-removebg-preview.png?alt=media&token=acbc7284-1126-4428-a3b2-f8b6e7932b98',
          'https://firebasestorage.googleapis.com/v0/b/diary-3bbf7.firebasestorage.app/o/shape%2Ftouched_shape-removebg-preview.png?alt=media&token=bbb50a1c-90d6-43fd-be40-4be4f51bc1d0',
          'https://firebasestorage.googleapis.com/v0/b/diary-3bbf7.firebasestorage.app/o/shape%2Fanxious_shape-removebg-preview.png?alt=media&token=7859ebac-cd9d-43a3-a42c-aec651d37e6e',
          'https://firebasestorage.googleapis.com/v0/b/diary-3bbf7.firebasestorage.app/o/shape%2Fconfused_shape-removebg-preview.png?alt=media&token=4794d127-9b61-4c68-86de-8478c4da8fb9'
        ],
        Emotion.fruit: [
          'https://firebasestorage.googleapis.com/v0/b/diary-3bbf7.firebasestorage.app/o/fruit%2Fneutral_fruit-removebg-preview.png?alt=media&token=9bdea06c-13e6-4c59-b961-1424422a3c39',
          'https://firebasestorage.googleapis.com/v0/b/diary-3bbf7.firebasestorage.app/o/fruit%2Fhappy_fruit-removebg-preview.png?alt=media&token=d10a503b-fee7-4bc2-b141-fd4b33dae1f1',
          'https://firebasestorage.googleapis.com/v0/b/diary-3bbf7.firebasestorage.app/o/fruit%2Fcalm_fruit-removebg-preview.png?alt=media&token=839efcad-0022-4cc9-ac38-90175d9026d2',
          'https://firebasestorage.googleapis.com/v0/b/diary-3bbf7.firebasestorage.app/o/fruit%2Flove_fruit-removebg-preview.png?alt=media&token=ba7857c6-5afd-48e0-addd-7b3f54583c15',
          'https://firebasestorage.googleapis.com/v0/b/diary-3bbf7.firebasestorage.app/o/fruit%2Fexcited_fruit-removebg-preview.png?alt=media&token=0284bce2-aa88-4766-97fb-5d5d2248cf31',
          'https://firebasestorage.googleapis.com/v0/b/diary-3bbf7.firebasestorage.app/o/fruit%2Fangry_fruit-removebg-preview.png?alt=media&token=679778b9-5a1b-469a-8e86-b01585cb1ee2',
          'https://firebasestorage.googleapis.com/v0/b/diary-3bbf7.firebasestorage.app/o/fruit%2Fconfident_fruit-removebg-preview.png?alt=media&token=6edcc903-8d78-4dd9-bcdd-1c6b26645044',
          'https://firebasestorage.googleapis.com/v0/b/diary-3bbf7.firebasestorage.app/o/fruit%2Fdetermined_fruit-removebg-preview.png?alt=media&token=ed288879-86c4-4d6d-946e-477f2aafc3ce',
          'https://firebasestorage.googleapis.com/v0/b/diary-3bbf7.firebasestorage.app/o/fruit%2Fsad_fruit-removebg-preview.png?alt=media&token=e9e0b0f7-6590-4209-a7d1-26377eb33c05',
          'https://firebasestorage.googleapis.com/v0/b/diary-3bbf7.firebasestorage.app/o/fruit%2Ftouched_fruit-removebg-preview.png?alt=media&token=c69dee6d-7d53-4af7-a884-2f751aecbe42',
          'https://firebasestorage.googleapis.com/v0/b/diary-3bbf7.firebasestorage.app/o/fruit%2Fanxious_fruit-removebg-preview.png?alt=media&token=be8f8279-2b08-47bf-9856-c39daf5eac40',
          'https://firebasestorage.googleapis.com/v0/b/diary-3bbf7.firebasestorage.app/o/fruit%2Fconfused_fruit-removebg-preview.png?alt=media&token=7adfcf22-af7a-4eb1-a225-34875b6540cf'
        ],
        Emotion.animal: [
          'https://firebasestorage.googleapis.com/v0/b/diary-3bbf7.firebasestorage.app/o/animal%2Fneutral_animal-removebg-preview.png?alt=media&token=f884e38d-5d8c-4d4a-bb62-a47a198d384f',
          'https://firebasestorage.googleapis.com/v0/b/diary-3bbf7.firebasestorage.app/o/animal%2Fhappy_animal-removebg-preview.png?alt=media&token=66ff8e2d-d941-4fd7-9d7f-9766db03cbd5',
          'https://firebasestorage.googleapis.com/v0/b/diary-3bbf7.firebasestorage.app/o/animal%2Fcalm_animal-removebg-preview.png?alt=media&token=afd7bf65-5150-40e3-8b95-cd956dff113d',
          'https://firebasestorage.googleapis.com/v0/b/diary-3bbf7.firebasestorage.app/o/animal%2Flove_animal-removebg-preview.png?alt=media&token=e0e2ccbd-b59a-4d09-968a-562208f90be1',
          'https://firebasestorage.googleapis.com/v0/b/diary-3bbf7.firebasestorage.app/o/animal%2Fexcited_animal-removebg-preview.png?alt=media&token=48442937-5504-4392-88a9-039aef405f14',
          'https://firebasestorage.googleapis.com/v0/b/diary-3bbf7.firebasestorage.app/o/animal%2Fangry_animal-removebg-preview.png?alt=media&token=9bde31db-8801-4af0-9368-e6ce4a35fbac',
          'https://firebasestorage.googleapis.com/v0/b/diary-3bbf7.firebasestorage.app/o/animal%2Fconfident__animal-removebg-preview.png?alt=media&token=2983b323-a2a6-40aa-9b6c-a381d944dd27',
          'https://firebasestorage.googleapis.com/v0/b/diary-3bbf7.firebasestorage.app/o/animal%2Fdetermined_animal-removebg-preview.png?alt=media&token=abf05981-4ab3-49b3-ba37-096ab8c22478',
          'https://firebasestorage.googleapis.com/v0/b/diary-3bbf7.firebasestorage.app/o/animal%2Fsad_animal-removebg-preview.png?alt=media&token=04c99bd8-8ad4-43de-91cd-3b7354780677',
          'https://firebasestorage.googleapis.com/v0/b/diary-3bbf7.firebasestorage.app/o/animal%2Ftouched_animal-removebg-preview.png?alt=media&token=629be9ec-be17-407f-beb0-6b67f09b7036',
          'https://firebasestorage.googleapis.com/v0/b/diary-3bbf7.firebasestorage.app/o/animal%2Fanxious_animal-removebg-preview.png?alt=media&token=bd25e31d-629b-4e79-b95e-019f8c76dac2',
          'https://firebasestorage.googleapis.com/v0/b/diary-3bbf7.firebasestorage.app/o/animal%2Fconfused__animal-removebg-preview.png?alt=media&token=74192a1e-86a7-4eb6-b690-154984c427dc'
        ],
        Emotion.weather: [
          'https://firebasestorage.googleapis.com/v0/b/diary-3bbf7.firebasestorage.app/o/wheather%2Fneutral_weather-removebg-preview.png?alt=media&token=57ad1adf-baa6-4b79-96f5-066a4ec3358f',
          'https://firebasestorage.googleapis.com/v0/b/diary-3bbf7.firebasestorage.app/o/wheather%2Fhappy_weather-removebg-preview.png?alt=media&token=fd77e998-6f47-459a-bd1c-458e309fed41',
          'https://firebasestorage.googleapis.com/v0/b/diary-3bbf7.firebasestorage.app/o/wheather%2Fcalm_weather-removebg-preview.png?alt=media&token=7703fd25-fe2b-4750-a415-5f86c4e7b058',
          'https://firebasestorage.googleapis.com/v0/b/diary-3bbf7.firebasestorage.app/o/wheather%2Flove_weather-removebg-preview.png?alt=media&token=2451105b-ab3e-482d-bf9f-12f0a6a69a53',
          'https://firebasestorage.googleapis.com/v0/b/diary-3bbf7.firebasestorage.app/o/wheather%2Fexcited_weather-removebg-preview.png?alt=media&token=5de71f38-1178-4e3c-887e-af07547caba9',
          'https://firebasestorage.googleapis.com/v0/b/diary-3bbf7.firebasestorage.app/o/wheather%2Fangry_weather-removebg-preview.png?alt=media&token=2f4c6212-697d-49b7-9d5e-ae1f2b1fa84e',
          'https://firebasestorage.googleapis.com/v0/b/diary-3bbf7.firebasestorage.app/o/wheather%2Fconfident_weather-removebg-preview.png?alt=media&token=ea30d002-312b-4ae5-ad85-933bbc009dc6',
          'https://firebasestorage.googleapis.com/v0/b/diary-3bbf7.firebasestorage.app/o/wheather%2Fdetermined_weather-removebg-preview.png?alt=media&token=0eb8fb3d-22dd-4b4f-8e12-7d830f32be6d',
          'https://firebasestorage.googleapis.com/v0/b/diary-3bbf7.firebasestorage.app/o/wheather%2Fsad_weather-removebg-preview.png?alt=media&token=aa972b9a-8952-4dc7-abe7-692ec7be0d16',
          'https://firebasestorage.googleapis.com/v0/b/diary-3bbf7.firebasestorage.app/o/wheather%2Ftouched_weather-removebg-preview.png?alt=media&token=5e224042-72ae-45a4-891a-8e6abdb5285c',
          'https://firebasestorage.googleapis.com/v0/b/diary-3bbf7.firebasestorage.app/o/wheather%2Fanxious_weather-removebg-preview.png?alt=media&token=fc718a17-8d8e-4ed1-a78a-891fa9a149d0',
          'https://firebasestorage.googleapis.com/v0/b/diary-3bbf7.firebasestorage.app/o/wheather%2Fconfused_weather-removebg-preview.png?alt=media&token=afdfb6bf-2c69-4ef2-97a1-2e5aa67e6fdb'
        ],
      };
      _selectedEmotion = Emotion.shape;
      _voiceEnabled = true;
      _voiceVolume = 50;
      _userName = '사용자';
      _tempName = _userName;
      _tempBirthday = null;
      _isProfileDialogOpen = false;
      _isCalendarVisible = false;
      _currentCalendarDate = DateTime.now();
    });

    // AppState의 사용자 설정 카테고리와 선택된 카테고리도 초기화
    final appState = Provider.of<AppState>(context, listen: false);
    appState.resetUserEmoticonCategories();
    appState.setSelectedEmoticonCategory(Emotion.shape);
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

  // 프리미엄 결제 처리 함수 제거 - 모든 카테고리 자유롭게 사용 가능

  // 달력 날짜 계산을 위한 헬퍼 함수들
  int _getDaysInMonth(int year, int month) {
    return DateTime(year, month + 1, 0).day;
  }

  int _getFirstWeekdayOfMonth(int year, int month) {
    return DateTime(year, month, 1).weekday % 7;
  }

  List<_CalendarDay> _getCalendarDays(int year, int month) {
    final List<_CalendarDay> days = [];
    
    // 이전 달의 마지막 날짜들
    final prevMonth = month - 1;
    final prevYear = prevMonth == 0 ? year - 1 : year;
    final prevMonthDays = _getDaysInMonth(prevYear, prevMonth == 0 ? 12 : prevMonth);
    final firstWeekday = _getFirstWeekdayOfMonth(year, month);
    
    for (var i = 0; i < firstWeekday; i++) {
      days.add(_CalendarDay(
        date: DateTime(prevYear, prevMonth == 0 ? 12 : prevMonth, prevMonthDays - firstWeekday + i + 1),
        isCurrentMonth: false,
      ));
    }
    
    // 현재 달의 날짜들
    final daysInMonth = _getDaysInMonth(year, month);
    for (var i = 1; i <= daysInMonth; i++) {
      days.add(_CalendarDay(
        date: DateTime(year, month, i),
        isCurrentMonth: true,
      ));
    }
    
    // 다음 달의 시작 날짜들
    final nextMonth = month + 1;
    final nextYear = nextMonth == 13 ? year + 1 : year;
    final remainingDays = 42 - days.length; // 6주 * 7일 = 42일로 맞추기
    
    for (var i = 1; i <= remainingDays; i++) {
      days.add(_CalendarDay(
        date: DateTime(nextYear, nextMonth == 13 ? 1 : nextMonth, i),
        isCurrentMonth: false,
      ));
    }
    
    return days;
  }

  // 달력의 top 위치를 계산하는 함수
  double _getCalendarTopPosition() {
    final RenderBox? renderBox = _birthdayInputKey.currentContext?.findRenderObject() as RenderBox?;
    if (renderBox != null) {
      final position = renderBox.localToGlobal(Offset.zero);
      final height = renderBox.size.height;
      return position.dy + height + 4; // 입력 박스 아래 4픽셀 간격
    }
    return 0;
  }

  // 달력의 left 위치를 계산하는 함수
  double _getCalendarLeftPosition() {
    final RenderBox? renderBox = _birthdayInputKey.currentContext?.findRenderObject() as RenderBox?;
    if (renderBox != null) {
      final position = renderBox.localToGlobal(Offset.zero);
      return position.dx;
    }
    return 0;
  }

  // 프리미엄 카테고리 여부 확인 - 모든 카테고리 자유롭게 사용 가능
  bool _isPremiumCategory(Emotion emotion) {
    return false; // 모든 카테고리 자유롭게 사용 가능
  }

  Widget _buildEmojiDialog(BuildContext context) {
    return Dialog(
      backgroundColor: const Color(0xFFF5EFE6),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Container(
        width: 448,  // 모달 너비 고정
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 상단 헤더
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  '이모티콘 카테고리 설정',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () {
                    setState(() {
                      _isEmojiDialogOpen = false;
                    });
                  },
                ),
              ],
            ),
            const SizedBox(height: 20),
            
            // 카테고리 버튼들 - 가로 스크롤
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  const SizedBox(width: 8), // 왼쪽 여백
                  _buildCategoryButton(Emotion.shape),
                  const SizedBox(width: 8),
                  _buildCategoryButton(Emotion.fruit),
                  const SizedBox(width: 8),
                  _buildCategoryButton(Emotion.animal),
                  const SizedBox(width: 8),
                  _buildCategoryButton(Emotion.weather),
                  const SizedBox(width: 8), // 오른쪽 여백
                ],
              ),
            ),
            const SizedBox(height: 24),

            // 선택된 카테고리 제목
            Row(
              children: [
                Text(
                  '${_emotionLabels[_selectedEmotion]} 카테고리 (5개)',
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                            // 프리미엄 제한 제거 - 모든 카테고리 자유롭게 사용 가능
              ],
            ),
            const SizedBox(height: 16),

            // 선택된 Firebase 이미지들
            Container(
              padding: const EdgeInsets.all(12),
              height: 220, // 스크롤 영역 높이 지정 (원하는 값으로 조정 가능)
              child: GridView.builder(
                itemCount: _emojiCategories[_selectedEmotion]!.length,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 5, // 한 줄에 5개씩
                  mainAxisSpacing: 12,
                  crossAxisSpacing: 12,
                  childAspectRatio: 1,
                ),
                itemBuilder: (context, index) {
                  final imageUrl = _emojiCategories[_selectedEmotion]![index];
                  return Container(
                    width: 56,
                    height: 56,
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: AppColors.primary,
                        width: 2,
                      ),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Image.network(
                      imageUrl,
                      fit: BoxFit.contain,
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          width: 56,
                          height: 56,
                          decoration: BoxDecoration(
                            color: AppColors.muted,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Icon(
                            Icons.error,
                            size: 24,
                            color: Colors.grey,
                          ),
                        );
                      },
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 24),

            // 하단 버튼들
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                TextButton(
                  onPressed: _resetToDefault,
                  style: TextButton.styleFrom(
                    foregroundColor: Colors.black54,
                  ),
                  child: const Text('기본값으로 초기화'),
                ),
                ElevatedButton(
                  onPressed: () {
                    setState(() {
                      _isEmojiDialogOpen = false;
                    });
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFB68D6B),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 12,
                    ),
                  ),
                  child: const Text('완료'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // 카테고리 버튼 위젯
  Widget _buildCategoryButton(Emotion emotion) {
    return Container(
      constraints: const BoxConstraints(minWidth: 80), // 최소 너비 설정
      child: TextButton(
        onPressed: () => _handleCategorySelect(emotion),
        style: ButtonStyle(
          backgroundColor: WidgetStateProperty.all(
            _selectedEmotion == emotion 
              ? const Color(0xFFB68D6B)
              : Colors.transparent,
          ),
          padding: WidgetStateProperty.all(
            const EdgeInsets.symmetric(horizontal: 12, vertical: 10), // 패딩 조정
          ),
          shape: WidgetStateProperty.all(
            RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
          ),
        ),
        child: Column( // Row를 Column으로 변경
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              _emotionLabels[emotion]!,
              style: TextStyle(
                color: _selectedEmotion == emotion ? Colors.white : Colors.black,
                fontWeight: FontWeight.w500,
                fontSize: 13, // 폰트 크기 조정
              ),
            ),
            // 프리미엄 제한 제거 - 잠금 아이콘 제거
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AppState>(
      builder: (context, appState, child) {
        final happinessData = _calculateHappinessData(appState);
        
        return Material(
          color: AppColors.background,
          child: Stack(  // SafeArea를 Stack으로 감싸기
            children: [
              SafeArea(
                child: Container(
              padding: const EdgeInsets.all(16),
                  child: Center(
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 448),
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
                                    fontSize: 18,
                                    fontWeight: FontWeight.w600,
                                    color: AppColors.foreground,
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
                                    // 프리미엄 구독 상태 표시 제거 - 모든 기능 자유롭게 사용 가능
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
                                                // 프리미엄 잠금 표시 제거 - 모든 카테고리 자유롭게 사용 가능
                                              ],
                                            ),
                                            Row(
                                              children: [
                                                ...(_firebaseImageUrls[_selectedEmotion]!.take(3).map((imageUrl) => 
                                                  Container(
                                                    width: 24,
                                                    height: 24,
                                                    margin: const EdgeInsets.only(right: 4),
                                                    child: Image.network(
                                                      imageUrl,
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
                                                  ))),
                                                if (_firebaseImageUrls[_selectedEmotion]!.length > 3)
                                                  Text(
                                                    '+${_firebaseImageUrls[_selectedEmotion]!.length - 3}',
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
                                    padding: const EdgeInsets.all(24),
                                    child: Column(
                                      children: [
                                        InkWell(
                                          onTap: appState.handleLogout,
                                          child: Container(
                              width: double.infinity,
                                            padding: const EdgeInsets.symmetric(vertical: 16),
                                            decoration: BoxDecoration(
                                              color: const Color(0xFFA97B56),  // 진한 갈색으로 변경
                                              borderRadius: BorderRadius.circular(12),
                                            ),
                                            child: const Text(
                                    '로그아웃',
                                    style: TextStyle(
                                      fontSize: 16,
                                                fontWeight: FontWeight.w600,
                                                color: AppColors.foreground,  // 텍스트 색상을 흰색으로 변경
                                              ),
                                              textAlign: TextAlign.center,
                                            ),
                                          ),
                                        ),
                                      ],
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
                ),
              ),
              // 프로필 설정 모달
              if (_isProfileDialogOpen)
                Container(
                  color: Colors.black.withOpacity(0.5),
                  child: Center(
                    child: Container(
                      margin: const EdgeInsets.all(16),
                      constraints: const BoxConstraints(maxWidth: 448),
                      child: Material(
                        color: AppColors.calendarBg,
                        borderRadius: BorderRadius.circular(24),
                        child: Padding(
                          padding: const EdgeInsets.all(24),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // 헤더
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  const Text(
                                    '프로필 설정',
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  IconButton(
                                    onPressed: () => setState(() {
                                      _isProfileDialogOpen = false;
                                    }),
                                    icon: const Icon(Icons.close),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 24),
                              // 이름 입력
                              const Text(
                                '이름',
                                style: TextStyle(
                                  fontSize: 14,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                              const SizedBox(height: 8),
                              TextField(
                                controller: TextEditingController(),  // 초기값 제거
                                onChanged: (value) => _tempName = value,
                                decoration: InputDecoration(
                                  hintText: '이름을 입력하세요.',
                                  contentPadding: const EdgeInsets.symmetric(
                                    horizontal: 12,
                                    vertical: 16,
                                  ),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(8),
                                    borderSide: BorderSide(color: AppColors.border),
                                  ),
                                  enabledBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(8),
                                    borderSide: BorderSide(color: AppColors.border),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(8),
                                    borderSide: BorderSide(color: AppColors.border),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 16),
                              // 생일 선택
                              const Text(
                                '생일',
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              const SizedBox(height: 8),
                              // 날짜 표시 박스
                              InkWell(
                                key: _birthdayInputKey, // 위치 추적을 위한 키 추가
                                onTap: () {
                                  setState(() {
                                    _isCalendarVisible = !_isCalendarVisible;
                                  });
                                },
                                child: Container(
                                  width: double.infinity,
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 12,
                                    vertical: 16,
                                  ),
                                  decoration: BoxDecoration(
                                    border: Border.all(color: AppColors.border),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Row(
                                    children: [
                                      const Icon(Icons.calendar_today, size: 16),
                                      const SizedBox(width: 8),
                                      Text(
                                        _tempBirthday != null 
                                          ? '${_tempBirthday!.year}년 ${_tempBirthday!.month}월 ${_tempBirthday!.day}일'
                                          : '생일을 선택하세요.',
                                        style: TextStyle(
                                          color: _tempBirthday == null
                                              ? AppColors.mutedForeground
                                              : AppColors.foreground,
                            ),
                          ),
                        ],
                      ),
                                ),
                              ),
                              const SizedBox(height: 24),
                              // 버튼
                              Row(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  AppButton(
                                    onPressed: () => _handleCancelProfile(appState),
                                    variant: ButtonVariant.ghost,
                                    child: const Text('취소'),
                                  ),
                                  const SizedBox(width: 8),
                                  AppButton(
                                    onPressed: () => _handleSaveProfile(appState),
                                    variant: ButtonVariant.primary,
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 8),
                                      child: const Text('저장'),
                    ),
                  ),
                ],
              ),
                            ],
            ),
          ),
                      ),
                    ),
                  ),
                ),
              // 달력 팝오버
              if (_isCalendarVisible && _isProfileDialogOpen)
                Positioned(
                  top: _getCalendarTopPosition(),
                  left: _getCalendarLeftPosition(),
                  child: Material(
                    elevation: 8,
                    borderRadius: BorderRadius.circular(8),
                    child: Container(
                      width: 320,
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          // 월 선택 헤더
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              IconButton(
                                icon: const Icon(Icons.chevron_left),
                                onPressed: () {
                                  setState(() {
                                    _currentCalendarDate = DateTime(
                                      _currentCalendarDate.year,
                                      _currentCalendarDate.month - 1,
                                    );
                                  });
      },
                              ),
                              Text(
                                '${_currentCalendarDate.year}년 ${_currentCalendarDate.month}월',
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              IconButton(
                                icon: const Icon(Icons.chevron_right),
                                onPressed: () {
                                  setState(() {
                                    _currentCalendarDate = DateTime(
                                      _currentCalendarDate.year,
                                      _currentCalendarDate.month + 1,
                                    );
                                  });
                                },
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          // 요일 헤더
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: const [
                              Text('일', style: TextStyle(fontSize: 12, color: Colors.red)),
                              Text('월', style: TextStyle(fontSize: 12)),
                              Text('화', style: TextStyle(fontSize: 12)),
                              Text('수', style: TextStyle(fontSize: 12)),
                              Text('목', style: TextStyle(fontSize: 12)),
                              Text('금', style: TextStyle(fontSize: 12)),
                              Text('토', style: TextStyle(fontSize: 12, color: Colors.blue)),
                            ],
                          ),
                          const SizedBox(height: 8),
                          // 날짜 그리드
                          GridView.builder(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 7,
                              childAspectRatio: 1,
                              mainAxisSpacing: 4,
                              crossAxisSpacing: 4,
                            ),
                            itemCount: 42,
                            itemBuilder: (context, index) {
                              final days = _getCalendarDays(_currentCalendarDate.year, _currentCalendarDate.month);
                              final day = days[index];
                              final isSelected = _tempBirthday != null &&
                                  day.date.year == _tempBirthday!.year &&
                                  day.date.month == _tempBirthday!.month &&
                                  day.date.day == _tempBirthday!.day;
                              final isWeekend = day.date.weekday == DateTime.saturday || 
                                              day.date.weekday == DateTime.sunday;
                              
                              return TextButton(
                                onPressed: () {
                                  if (day.isCurrentMonth) {
                                    setState(() {
                                      _tempBirthday = day.date;
                                    });
                                  } else {
                                    setState(() {
                                      _currentCalendarDate = DateTime(day.date.year, day.date.month, 1);
                                    });
                                  }
                                },
                                style: TextButton.styleFrom(
                                  padding: EdgeInsets.zero,
                                  minimumSize: Size.zero,
                                  backgroundColor: isSelected 
                                    ? AppColors.primary.withOpacity(0.1)
                                    : day.isCurrentMonth ? null : AppColors.muted.withOpacity(0.1),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                ),
                                child: Center(
                                  child: Text(
                                    '${day.date.day}',
                                    style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                                      color: !day.isCurrentMonth 
                                        ? AppColors.mutedForeground.withOpacity(0.5)
                                        : isSelected
                                          ? AppColors.primary
                                          : isWeekend
                                            ? day.date.weekday == DateTime.sunday ? Colors.red : Colors.blue
                                            : AppColors.foreground,
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              // 이모티콘 설정 모달
              if (_isEmojiDialogOpen)
                _buildEmojiDialog(context),
            ],
          ),
        );
      },
    );
  }

  // 카테고리 탭 위젯 - 프리미엄 제한 제거
  Widget _buildCategoryTab(Emotion emotion, String label, AppState appState) {
    // 모든 카테고리 자유롭게 사용 가능
    return InkWell(
      onTap: () {
        setState(() {
          _selectedEmotion = emotion;
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: _selectedEmotion == emotion 
            ? AppColors.primary 
            : AppColors.muted.withOpacity(0.1),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          children: [
            Text(
              label,
              style: TextStyle(
                color: _selectedEmotion == emotion 
                  ? Colors.white 
                  : AppColors.mutedForeground,
                fontWeight: _selectedEmotion == emotion 
                  ? FontWeight.bold 
                  : FontWeight.normal,
              ),
            ),
            // 프리미엄 잠금 표시 제거 - 모든 카테고리 자유롭게 사용 가능
          ],
        ),
      ),
    );
  }

  // 이모티콘 아이템 위젯
  Widget _buildEmojiItem(String emoji) {
    final isSelected = _emojiCategories[_selectedEmotion]!.contains(emoji);
    
    return InkWell(
      onTap: () {
        setState(() {
          if (isSelected) {
            _emojiCategories[_selectedEmotion]!.remove(emoji);
          } else {
            if (_emojiCategories[_selectedEmotion]!.length < 5) { // 최대 5개까지만 선택 가능
              _emojiCategories[_selectedEmotion]!.add(emoji);
            }
          }
        });
      },
      child: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: isSelected 
            ? AppColors.primary.withOpacity(0.1) 
            : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isSelected 
              ? AppColors.primary 
              : Colors.transparent,
          ),
        ),
        child: Center(
          child: Text(
            emoji,
            style: const TextStyle(fontSize: 20),
          ),
        ),
      ),
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

// 달력 날짜를 표현하는 클래스
class _CalendarDay {
  final DateTime date;
  final bool isCurrentMonth;

  _CalendarDay({
    required this.date,
    required this.isCurrentMonth,
  });
} 