<<<<<<< HEAD
# 일기 앱 (Diary App)

Flutter로 개발된 일기 작성 앱입니다. 음성 인식(STT) 기능을 통해 음성으로 일기를 작성할 수 있습니다.

## 주요 기능

- 📝 일기 작성 및 편집
- 🎤 음성 인식 (OpenAI Whisper API)
- 📅 캘린더 뷰
- 😊 감정 분석 및 이모지 선택
- 📱 반응형 UI

## 환경 설정

### 1. OpenAI API 키 설정

STT 기능을 사용하기 위해 OpenAI API 키가 필요합니다.

1. `ai/` 폴더로 이동:
   ```bash
   cd ai/
   ```

2. 환경변수 파일 생성:
   ```bash
   cp env.example .env
   ```

3. `.env` 파일을 열고 OpenAI API 키를 입력:
   ```env
   OPENAI_API_KEY=your_actual_openai_api_key_here
   ```

### 2. 백엔드 서버 실행

```bash
cd ai/
pip install -r requirements.txt
python stt_service.py
```

### 3. Flutter 앱 실행

```bash
flutter pub get
flutter run
```

## 기술 스택

- **Frontend**: Flutter/Dart
- **Backend**: Python Flask
- **STT**: OpenAI Whisper API
- **Database**: MongoDB
- **Storage**: Firebase Storage

## 프로젝트 구조

```
mproj-1/
├── lib/                    # Flutter 앱 코드
│   ├── components/         # UI 컴포넌트
│   ├── services/          # 서비스 클래스
│   └── models/            # 데이터 모델
├── ai/                    # 백엔드 서버
│   ├── stt_service.py     # STT 서비스
│   └── requirements.txt   # Python 의존성
└── backend/               # 메인 백엔드
```

## 주의사항

- `.env` 파일은 절대 Git에 커밋하지 마세요
- OpenAI API 키는 안전하게 보관하세요
- API 사용량에 따른 비용이 발생할 수 있습니다
=======
# my_flutter_app

A new Flutter project.

## Getting Started

This project is a starting point for a Flutter application.

A few resources to get you started if this is your first Flutter project:

- [Lab: Write your first Flutter app](https://docs.flutter.dev/get-started/codelab)
- [Cookbook: Useful Flutter samples](https://docs.flutter.dev/cookbook)

For help getting started with Flutter development, view the
[online documentation](https://docs.flutter.dev/), which offers tutorials,
samples, guidance on mobile development, and a full API reference.
>>>>>>> origin/main
