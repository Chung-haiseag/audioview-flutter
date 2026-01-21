# Flutter 마이그레이션 가이드

React/TypeScript 웹 앱을 Flutter 모바일 앱으로 완전히 변환했습니다.

## 변환 완료 항목

### ✅ 핵심 구조
- [x] Flutter 프로젝트 구조 설정
- [x] Android 설정 파일
- [x] 테마 및 색상 시스템
- [x] 상태 관리 (Provider)

### ✅ 데이터 모델
- [x] Movie 모델
- [x] Category 모델
- [x] Mock 데이터 (16개 영화)

### ✅ 공통 위젯
- [x] CustomHeader (헤더 + 밝기 조절)
- [x] CustomBottomNavigation (하단 네비게이션)
- [x] ADBadge (화면해설 배지)
- [x] CCBadge (자막 배지)

### ✅ 화면 구현
- [x] HomeScreen (홈)
  - 카테고리 칩
  - 새로 올라온 영화
  - 실시간 인기영화
  - 오늘의 TOP 10
- [x] SettingsScreen (설정)
  - 환경설정 탭
  - 고객센터 탭
  - 로그인/로그아웃
  - 접근성 설정
- [x] SearchScreen (검색)
  - 검색 입력
  - 추천 태그
  - 검색 결과 그리드
- [x] DownloadsScreen (MY)
  - 프로필
  - 시청 기록
- [x] LoginScreen (로그인)

### ✅ 기능
- [x] 인증 시스템 (Provider)
- [x] 화면 네비게이션
- [x] 밝기 조절 오버레이
- [x] 하단 탭 네비게이션

## 실행 방법

### 1. 의존성 설치
```bash
flutter pub get
```

### 2. 앱 실행
```bash
# Android 에뮬레이터 또는 연결된 기기에서 실행
flutter run

# 특정 기기 선택
flutter devices
flutter run -d <device-id>
```

### 3. 빌드
```bash
# Android APK
flutter build apk --release

# Android App Bundle
flutter build appbundle --release
```

## 프로젝트 구조

```
lib/
├── config/
│   └── theme.dart                    # 앱 테마 설정
├── constants/
│   └── mock_data.dart                # Mock 영화 데이터
├── models/
│   ├── movie.dart                    # 영화 모델
│   └── category.dart                 # 카테고리 모델
├── providers/
│   └── auth_provider.dart            # 인증 Provider
├── screens/
│   ├── auth/
│   │   └── login_screen.dart         # 로그인 화면
│   ├── home/
│   │   └── home_screen.dart          # 홈 화면
│   ├── settings/
│   │   └── settings_screen.dart      # 설정 화면
│   ├── search/
│   │   └── search_screen.dart        # 검색 화면
│   └── downloads/
│       └── downloads_screen.dart     # 다운로드/MY 화면
├── widgets/
│   ├── badges.dart                   # AD/CC 배지
│   ├── custom_header.dart            # 커스텀 헤더
│   └── bottom_navigation.dart        # 하단 네비게이션
└── main.dart                         # 앱 진입점

android/
├── app/
│   ├── src/main/
│   │   ├── AndroidManifest.xml       # Android 매니페스트
│   │   └── kotlin/.../MainActivity.kt # 메인 액티비티
│   └── build.gradle                  # 앱 수준 Gradle
├── build.gradle                      # 프로젝트 수준 Gradle
├── settings.gradle                   # Gradle 설정
└── gradle.properties                 # Gradle 속성
```

## React → Flutter 변환 매핑

| React/TypeScript | Flutter | 설명 |
|-----------------|---------|------|
| `useState` | `StatefulWidget` + `setState` | 상태 관리 |
| `useEffect` | `initState`, `didChangeDependencies` | 생명주기 |
| `useNavigate` | `Navigator.push/pop` | 라우팅 |
| `localStorage` | `SharedPreferences` | 로컬 저장 |
| `className` | `style` 속성 | 스타일링 |
| `onClick` | `onTap`, `onPressed` | 이벤트 처리 |
| `div` | `Container`, `Column`, `Row` | 레이아웃 |
| `img` | `Image.network` | 이미지 |
| Context API | `Provider` | 전역 상태 |

## 스타일 가이드

### 색상
```dart
const brandDark = Color(0xFF0A0A0A);      // 배경
const surface = Color(0xFF141414);         // 표면
const surfaceLight = Color(0xFF1A1A1A);    // 밝은 표면
const primary = Color(0xFFE50914);         // 강조 (빨강)
const adBlue = Color(0xFF0051C4);          // AD 배지
```

### 타이포그래피
- 큰 제목: 20-24px, Bold
- 중간 제목: 16-18px, Bold
- 본문: 14px, Regular
- 작은 텍스트: 11-12px, Regular

### 간격
- 화면 패딩: 16px
- 섹션 간격: 24-40px
- 요소 간격: 8-12px

## 주요 변경사항

1. **상태 관리**: Context API → Provider
2. **라우팅**: React Router → Navigator
3. **스타일링**: CSS/Tailwind → Flutter 위젯 스타일
4. **레이아웃**: HTML/Flexbox → Column/Row/Stack
5. **이미지**: `<img>` → `Image.network`
6. **스크롤**: CSS overflow → `SingleChildScrollView`, `ListView`

## 추가 구현 필요 항목

현재 기본 UI는 완성되었으며, 다음 기능들을 추가로 구현할 수 있습니다:

1. **영화 상세 화면**
   - 영화 정보 표시
   - 재생 버튼
   - 관련 영화 추천

2. **플레이어 화면**
   - 비디오 재생
   - 자막 표시
   - 재생 컨트롤

3. **카테고리 목록 화면**
   - 카테고리별 필터링
   - 정렬 기능

4. **API 연동**
   - HTTP 클라이언트 (dio)
   - API 서비스 레이어
   - 에러 처리

5. **고급 기능**
   - 오프라인 다운로드
   - 음성 검색
   - 푸시 알림

## 의존성 패키지

현재 사용 중인 패키지:
- `provider: ^6.0.0` - 상태 관리
- `shared_preferences: ^2.2.0` - 로컬 저장
- `google_fonts: ^6.1.0` - 폰트
- `flutter_animate: ^4.2.0` - 애니메이션
- `intl: ^0.18.0` - 국제화

추가 권장 패키지:
- `dio: ^5.0.0` - HTTP 클라이언트
- `cached_network_image: ^3.3.0` - 이미지 캐싱
- `video_player: ^2.8.0` - 비디오 재생
- `flutter_secure_storage: ^9.0.0` - 보안 저장소

## 테스트

```bash
# 단위 테스트
flutter test

# 위젯 테스트
flutter test test/widget_test.dart

# 통합 테스트
flutter drive --target=test_driver/app.dart
```

## 배포

### Android
1. 앱 서명 설정
2. `flutter build appbundle --release`
3. Google Play Console에 업로드

### iOS (macOS 필요)
1. 프로비저닝 프로파일 설정
2. `flutter build ios --release`
3. Xcode로 아카이브 및 App Store Connect 업로드

## 문제 해결

### 의존성 오류
```bash
flutter pub get
flutter clean
flutter pub get
```

### Android 빌드 오류
- Java 버전 확인 (Java 11 이상)
- Gradle 버전 확인
- Android SDK 업데이트

### iOS 빌드 오류 (macOS)
- Xcode 버전 확인
- CocoaPods 업데이트: `pod repo update`

## 지원

제작: (사)한국시각장애인연합회
- 이메일: kbu1004@hanmail.com
- 전화: 02-799-1000

---

**변환 완료 날짜**: 2026-01-21
**Flutter 버전**: 3.0.0+
**Dart 버전**: 3.0.0+
