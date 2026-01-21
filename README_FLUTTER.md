# AudioView Flutter 앱

React/TypeScript 웹 앱을 Flutter 모바일 앱으로 변환한 프로젝트입니다.

## 프로젝트 구조

```
lib/
├── config/              # 테마 및 설정
│   └── theme.dart
├── constants/           # 상수 및 Mock 데이터
│   └── mock_data.dart
├── models/              # 데이터 모델
│   ├── movie.dart
│   └── category.dart
├── providers/           # 상태 관리 (Provider)
│   └── auth_provider.dart
├── screens/             # 화면들
│   ├── auth/
│   │   └── login_screen.dart
│   ├── home/
│   │   └── home_screen.dart
│   ├── settings/
│   │   └── settings_screen.dart
│   ├── search/
│   │   └── search_screen.dart
│   └── downloads/
│       └── downloads_screen.dart
├── widgets/             # 공통 위젯
│   ├── badges.dart
│   ├── custom_header.dart
│   └── bottom_navigation.dart
└── main.dart            # 앱 진입점
```

## 주요 기능

### 1. 홈 화면
- 카테고리 칩 (예능, 드라마, 영화 등)
- 새로 올라온 영화 섹션
- 실시간 인기영화 섹션
- 오늘의 TOP 10 섹션 (순위 표시)

### 2. 검색 화면
- 실시간 검색 기능
- 추천 검색어 태그
- 그리드 형태의 검색 결과
- AD/CC 배지 표시

### 3. 설정 화면
- 환경설정 탭
  - 로그인/로그아웃
  - 3G/LTE 사용 설정
  - 스마트 안경 연동
  - 접근성 기능 (화면해설, 자막 등)
- 고객센터 탭
  - 개인정보 처리방침
  - 이용약관
  - FAQ
  - 연락처 정보

### 4. MY AUDIOVIEW (다운로드)
- 사용자 프로필
- 시청 기록 (인증 필요)

### 5. 공통 기능
- 상단 헤더 (뒤로가기, 타이틀, 밝기 조절)
- 하단 네비게이션 바
- 밝기 조절 오버레이
- AD/CC 배지

## 설치 및 실행

### 사전 요구사항
- Flutter SDK 3.0.0 이상
- Android Studio / Xcode
- Dart 3.0 이상

### 설치
```bash
# 의존성 설치
flutter pub get

# Android 실행
flutter run

# iOS 실행 (macOS에서)
flutter run -d ios
```

### 빌드
```bash
# Android APK 빌드
flutter build apk --release

# iOS 빌드
flutter build ios --release
```

## 사용된 주요 패키지

- `provider`: 상태 관리
- `shared_preferences`: 로컬 저장소
- `google_fonts`: 폰트
- `flutter_animate`: 애니메이션

## 색상 테마

- 배경: `#0A0A0A`, `#141414`, `#1A1A1A`
- 강조: `#E50914` (Netflix 레드)
- 텍스트: `#FFFFFF`, `#808080`
- AD 배지: `#0051C4` (블루)
- CC 배지: `#FFFFFF` (화이트)

## 상태 관리

Provider 패턴을 사용하여 전역 상태를 관리합니다:
- `AuthProvider`: 인증 상태 관리

## 다음 단계

추가 구현이 필요한 기능들:
1. 영화 상세 화면
2. 플레이어 화면
3. 카테고리 목록 화면
4. API 연동
5. 오프라인 다운로드 기능
6. 음성 검색 기능

## 라이선스

제작: (사)한국시각장애인연합회
