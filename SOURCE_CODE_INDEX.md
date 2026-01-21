# AudioView Flutter - 전체 소스코드 목록

## 📦 압축 파일 위치
```
C:\Users\정해석\Downloads\audioview_flutter_complete.tar.gz (18KB)
```

## 📁 프로젝트 구조

```
audioview/
├── lib/                              # Flutter 소스코드
│   ├── config/
│   │   └── theme.dart               # 앱 테마 설정 (다크 테마)
│   │
│   ├── constants/
│   │   └── mock_data.dart           # Mock 데이터 (16개 영화)
│   │
│   ├── models/
│   │   ├── category.dart            # 카테고리 모델
│   │   └── movie.dart               # 영화 모델
│   │
│   ├── providers/
│   │   └── auth_provider.dart       # 인증 Provider (로그인/로그아웃)
│   │
│   ├── screens/
│   │   ├── auth/
│   │   │   └── login_screen.dart    # 로그인 화면
│   │   │
│   │   ├── downloads/
│   │   │   └── downloads_screen.dart # MY 화면 (시청 기록)
│   │   │
│   │   ├── home/
│   │   │   └── home_screen.dart     # 홈 화면 (신작/인기/TOP10)
│   │   │
│   │   ├── search/
│   │   │   └── search_screen.dart   # 검색 화면
│   │   │
│   │   └── settings/
│   │       └── settings_screen.dart  # 설정 화면 (환경설정/고객센터)
│   │
│   ├── widgets/
│   │   ├── badges.dart              # AD/CC 배지 위젯
│   │   ├── bottom_navigation.dart    # 하단 네비게이션 바
│   │   └── custom_header.dart       # 커스텀 헤더 (밝기 조절)
│   │
│   └── main.dart                     # 앱 진입점 (메인 화면)
│
├── android/                          # Android 설정
│   ├── app/
│   │   ├── src/main/
│   │   │   ├── AndroidManifest.xml  # 앱 권한 및 설정
│   │   │   └── kotlin/com/audioview/app/
│   │   │       └── MainActivity.kt   # 메인 액티비티
│   │   └── build.gradle             # 앱 빌드 설정
│   ├── build.gradle                 # 프로젝트 빌드 설정
│   ├── settings.gradle              # Gradle 설정
│   └── gradle.properties            # Gradle 속성
│
├── pubspec.yaml                     # 의존성 패키지 설정
│
└── 문서/
    ├── README_FLUTTER.md            # Flutter 앱 개요
    ├── FLUTTER_MIGRATION_GUIDE.md   # React → Flutter 마이그레이션 가이드
    ├── DEPLOYMENT_GUIDE.md          # 배포 가이드
    └── SOURCE_CODE_INDEX.md         # 이 파일
```

## 📄 주요 파일 설명

### 1. 핵심 파일

#### `lib/main.dart` (110줄)
- 앱의 시작점
- MainScreen: 4개 탭 네비게이션
- 밝기 조절 오버레이
- 인증 상태 관리

#### `pubspec.yaml`
```yaml
dependencies:
  flutter:
    sdk: flutter
  provider: ^6.0.0           # 상태 관리
  shared_preferences: ^2.2.0 # 로컬 저장
  google_fonts: ^6.1.0       # 폰트
  flutter_animate: ^4.2.0    # 애니메이션
  intl: ^0.18.0             # 국제화
```

### 2. 화면별 파일

#### `lib/screens/home/home_screen.dart` (약 250줄)
**기능:**
- 카테고리 칩 (예능, 드라마, 영화 등)
- 새로 올라온 영화 섹션
- 실시간 인기영화 섹션
- 오늘의 TOP 10 섹션 (순위 표시)

**주요 위젯:**
- `CustomScrollView`: 스크롤 가능한 레이아웃
- `SingleChildScrollView`: 카테고리 칩 가로 스크롤
- `ListView.builder`: 영화 목록

#### `lib/screens/settings/settings_screen.dart` (약 350줄)
**기능:**
- 환경설정 탭
  - 로그인/로그아웃
  - 3G/LTE 사용 설정
  - 스마트 안경 연동
  - 접근성 기능 (화면해설, 자막)
- 고객센터 탭
  - 개인정보 처리방침
  - 이용약관
  - FAQ
  - 연락처 정보

#### `lib/screens/search/search_screen.dart` (약 200줄)
**기능:**
- 실시간 검색
- 추천 검색어 태그
- 그리드 형태 검색 결과
- AD/CC 배지 표시

#### `lib/screens/downloads/downloads_screen.dart` (약 100줄)
**기능:**
- 사용자 프로필
- 시청 기록 (인증 필요)
- 빈 상태 UI

#### `lib/screens/auth/login_screen.dart` (약 80줄)
**기능:**
- 로그인 UI
- Provider 연동

### 3. 위젯 파일

#### `lib/widgets/badges.dart` (약 50줄)
```dart
class ADBadge // 화면해설 배지 (파란색)
class CCBadge // 자막 배지 (흰색)
```

#### `lib/widgets/custom_header.dart` (약 80줄)
```dart
class CustomHeader // 상단 헤더 + 밝기 조절
```

#### `lib/widgets/bottom_navigation.dart` (약 70줄)
```dart
class CustomBottomNavigation // 하단 네비게이션 바
// 홈, 설정, 검색, MY
```

### 4. 데이터 파일

#### `lib/models/movie.dart` (약 60줄)
```dart
class Movie {
  final String id;
  final String title;
  final int year;
  final String country;
  final int duration;
  final List<String> genres;
  final String posterUrl;
  final bool hasAD;    // 화면해설
  final bool hasCC;    // 자막
  final bool hasMultiLang;
}
```

#### `lib/constants/mock_data.dart` (약 200줄)
- 16개 영화 데이터
- 3개 카테고리 데이터
- 6개 카테고리 칩

### 5. 설정 파일

#### `lib/config/theme.dart` (약 50줄)
```dart
class AppTheme {
  static ThemeData darkTheme // 다크 테마 설정
  // 색상: #0A0A0A, #141414, #E50914
}
```

#### `lib/providers/auth_provider.dart` (약 40줄)
```dart
class AuthProvider extends ChangeNotifier {
  bool isAuthenticated;
  void login();
  void logout();
}
```

### 6. Android 설정

#### `android/app/src/main/AndroidManifest.xml`
```xml
<uses-permission android:name="android.permission.INTERNET"/>
<application android:label="AudioView">
  <activity android:name=".MainActivity">
```

#### `android/app/build.gradle`
```gradle
android {
  compileSdkVersion 34
  defaultConfig {
    applicationId "com.audioview.app"
    minSdkVersion 21
    targetSdkVersion 34
  }
}
```

## 📊 코드 통계

| 구분 | 파일 수 | 총 라인 수 (예상) |
|-----|---------|------------------|
| 화면 (Screens) | 5개 | ~1,000줄 |
| 위젯 (Widgets) | 3개 | ~200줄 |
| 모델 (Models) | 2개 | ~120줄 |
| Provider | 1개 | ~40줄 |
| 설정/상수 | 2개 | ~250줄 |
| 메인 | 1개 | ~110줄 |
| **합계** | **14개** | **~1,720줄** |

## 🎨 디자인 시스템

### 색상 팔레트
```dart
// 배경색
Color(0xFF0A0A0A)  // 메인 배경
Color(0xFF141414)  // 헤더/네비게이션
Color(0xFF1A1A1A)  // 카드 배경
Color(0xFF2A2A2A)  // 테두리
Color(0xFF2F2F2F)  // 입력 필드

// 강조색
Color(0xFFE50914)  // Netflix 레드 (버튼/강조)
Color(0xFF0051C4)  // AD 배지 블루
Color(0xFFF5C518)  // 음성 검색 아이콘

// 텍스트
Colors.white       // 주 텍스트
Colors.grey        // 부 텍스트
Colors.white70     // 약한 텍스트
```

### 타이포그래피
```dart
// 제목
fontSize: 20-24, fontWeight: FontWeight.bold

// 부제목
fontSize: 16-18, fontWeight: FontWeight.w600

// 본문
fontSize: 14, fontWeight: FontWeight.normal

// 작은 텍스트
fontSize: 11-12
```

### 간격
```dart
// 화면 패딩
padding: EdgeInsets.all(16)

// 섹션 간격
SizedBox(height: 24-40)

// 요소 간격
SizedBox(height: 8-12)
```

## 🔧 사용된 주요 Flutter 위젯

### 레이아웃
- `Scaffold`: 기본 화면 구조
- `Column` / `Row`: 세로/가로 배치
- `Stack`: 겹침 배치
- `Container`: 박스 모델
- `Padding` / `SizedBox`: 간격

### 스크롤
- `SingleChildScrollView`: 단순 스크롤
- `ListView.builder`: 목록 스크롤
- `CustomScrollView`: 복합 스크롤
- `GridView.builder`: 그리드 레이아웃

### 입력
- `TextField`: 텍스트 입력
- `Switch`: 토글 스위치
- `Slider`: 슬라이더

### 네비게이션
- `Navigator.push/pop`: 화면 전환
- `BottomNavigationBar`: 하단 탭

### 이미지
- `Image.network`: 네트워크 이미지
- `ClipRRect`: 둥근 모서리

### 상태 관리
- `StatefulWidget`: 상태 있는 위젯
- `StatelessWidget`: 상태 없는 위젯
- `Provider`: 전역 상태
- `Consumer`: Provider 구독

## 📝 개발 가이드

### 새 화면 추가하기
1. `lib/screens/` 폴더에 새 화면 파일 생성
2. `Scaffold`로 기본 구조 작성
3. `lib/main.dart`의 `_screens` 리스트에 추가
4. 필요시 라우트 추가

### 새 위젯 추가하기
1. `lib/widgets/` 폴더에 파일 생성
2. `StatelessWidget` 또는 `StatefulWidget` 상속
3. 재사용 가능하도록 파라미터 설계

### 데이터 모델 추가하기
1. `lib/models/` 폴더에 파일 생성
2. `toJson()`, `fromJson()` 메서드 구현
3. 필수/선택 필드 구분

## 🚀 빌드 명령어

```bash
# 개발 모드 실행
flutter run

# Release APK
flutter build apk --release

# Split APK (용량 최적화)
flutter build apk --split-per-abi --release

# App Bundle (Play Store)
flutter build appbundle --release

# 웹 빌드
flutter build web --release

# iOS (macOS 필요)
flutter build ios --release
```

## 📦 패키지 관리

```bash
# 의존성 설치
flutter pub get

# 의존성 업데이트
flutter pub upgrade

# 캐시 정리
flutter clean
flutter pub get
```

## 🐛 디버깅

```bash
# 로그 확인
flutter logs

# 기기 확인
flutter devices

# 빌드 분석
flutter analyze

# 테스트 실행
flutter test
```

## 📞 지원

제작: (사)한국시각장애인연합회
- 이메일: kbu1004@hanmail.com
- 전화: 02-799-1000

---

**생성일**: 2026-01-21
**버전**: 1.0.0
**Flutter**: 3.0.0+
**Dart**: 3.0.0+

**전체 소스코드 압축 파일**:
```
C:\Users\정해석\Downloads\audioview_flutter_complete.tar.gz (18KB)
```

압축 해제:
```bash
tar -xzf audioview_flutter_complete.tar.gz
```
