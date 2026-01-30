# GitHub 업로드 가이드

AudioView Flutter 프로젝트를 GitHub에 업로드하는 방법입니다.

## 🎯 방법 1: GitHub Desktop 사용 (가장 쉬움)

### 1단계: GitHub Desktop 설치
1. https://desktop.github.com 에서 다운로드
2. GitHub 계정으로 로그인

### 2단계: 저장소 생성
1. GitHub Desktop에서 `File` → `New Repository`
2. 또는 기존 폴더 추가: `File` → `Add Local Repository`
   - 폴더: `<your-project-path>` (예: `C:\projects\audioview`)

### 3단계: 업로드
1. 변경사항 확인 (좌측 패널)
2. Commit 메시지 작성: "Initial commit: AudioView Flutter app"
3. `Publish repository` 클릭
4. 저장소 이름: `audioview-flutter`
5. Description: "배리어프리 OTT 플랫폼 - Flutter 모바일 앱"
6. Private/Public 선택
7. `Publish Repository` 클릭

✅ 완료! GitHub에서 확인 가능합니다.

---

## 🎯 방법 2: Git 명령어 사용 (전통적인 방법)

### 사전 준비

#### Git 설치 확인
```bash
git --version
```

설치 안 되어 있다면: https://git-scm.com/download/win

#### Git 설정 (최초 1회)
```bash
git config --global user.name "Your Name"
git config --global user.email "your.email@example.com"
```

### 1단계: GitHub에서 저장소 생성

1. https://github.com 로그인
2. 우측 상단 `+` → `New repository` 클릭
3. 저장소 정보 입력:
   - **Repository name**: `audioview-flutter`
   - **Description**: `배리어프리 OTT 플랫폼 - Flutter 모바일 앱`
   - **Public** 또는 **Private** 선택
   - ❌ **Initialize this repository with a README** 체크 해제 (우리가 이미 가지고 있음)
4. `Create repository` 클릭

### 2단계: 로컬 프로젝트와 연결

```bash
# 프로젝트 폴더로 이동
cd <your-project-path>

# Git 저장소 초기화
git init

# 모든 파일 추가
git add .

# 첫 커밋 생성
git commit -m "Initial commit: AudioView Flutter app"

# 브랜치 이름을 main으로 변경 (GitHub 표준)
git branch -M main

# GitHub 원격 저장소 연결 (YOUR_USERNAME을 본인 GitHub 아이디로 변경)
git remote add origin https://github.com/YOUR_USERNAME/audioview-flutter.git

# GitHub에 업로드
git push -u origin main
```

### 3단계: 인증

GitHub 로그인 창이 나타나면:
- **Username**: GitHub 아이디
- **Password**: Personal Access Token (PAT) 사용

**Personal Access Token 생성 방법:**
1. GitHub → Settings → Developer settings
2. Personal access tokens → Tokens (classic)
3. Generate new token
4. 권한: `repo` 체크
5. 생성된 토큰 복사 (비밀번호 대신 사용)

---

## 🎯 방법 3: VS Code 사용

### 1단계: VS Code에서 폴더 열기
```
File → Open Folder → <your-project-path>
```

### 2단계: Source Control 사용
1. 좌측 사이드바에서 Source Control 아이콘 클릭 (Ctrl+Shift+G)
2. `Initialize Repository` 클릭
3. 변경사항 확인
4. 메시지 입력: "Initial commit: AudioView Flutter app"
5. `Commit` 클릭 (Ctrl+Enter)

### 3단계: GitHub에 게시
1. Source Control 패널 상단 `···` 클릭
2. `Remote` → `Add Remote` 선택
3. GitHub URL 입력: `https://github.com/YOUR_USERNAME/audioview-flutter.git`
4. `Publish Branch` 클릭

---

## 📋 업로드 전 체크리스트

### ✅ 필수 확인사항

- [ ] `.gitignore` 파일 확인 (불필요한 파일 제외)
- [ ] `README.md` 파일 확인 (프로젝트 설명)
- [ ] 민감한 정보 제거
  - [ ] API 키
  - [ ] 비밀번호
  - [ ] 개인정보
- [ ] 빌드 파일 제외 (`build/`, `.dart_tool/` 등)

### ✅ 현재 상태 확인

```bash
cd <your-project-path>

# Git 상태 확인
git status

# 추적되지 않는 파일 확인
git ls-files --others --exclude-standard

# 무시되는 파일 확인
git status --ignored
```

---

## 🗂️ 업로드될 파일 목록

### ✅ 포함되는 파일
```
lib/                          # Flutter 소스코드
├── config/
├── constants/
├── models/
├── providers/
├── screens/
├── widgets/
└── main.dart

android/                      # Android 설정
├── app/
│   ├── build.gradle
│   └── src/main/
│       ├── AndroidManifest.xml
│       └── kotlin/
├── build.gradle
├── settings.gradle
└── gradle.properties

pubspec.yaml                  # 의존성
README.md                     # 프로젝트 설명
.gitignore                    # Git 제외 파일 목록
FLUTTER_MIGRATION_GUIDE.md    # 마이그레이션 가이드
DEPLOYMENT_GUIDE.md           # 배포 가이드
SOURCE_CODE_INDEX.md          # 소스코드 인덱스
```

### ❌ 제외되는 파일 (`.gitignore`에 의해)
```
build/                        # 빌드 결과물
.dart_tool/                   # Dart 도구 캐시
.packages                     # 패키지 정보
node_modules/                 # Node 의존성
dist/                         # 웹 빌드 결과
*.log                         # 로그 파일
.env.local                    # 환경 변수
*.tar.gz                      # 압축 파일
*.apk                         # APK 파일
```

---

## 🔄 업데이트 방법 (이미 업로드한 경우)

### 파일 수정 후 업로드

```bash
# 프로젝트 폴더로 이동
cd <your-project-path>

# 변경사항 확인
git status

# 모든 변경사항 추가
git add .

# 커밋 메시지와 함께 저장
git commit -m "Update: 기능 추가 또는 버그 수정 설명"

# GitHub에 푸시
git push
```

### 특정 파일만 업데이트

```bash
# 특정 파일만 추가
git add lib/screens/home/home_screen.dart

# 커밋
git commit -m "Update: 홈 화면 UI 개선"

# 푸시
git push
```

---

## 🌿 브랜치 사용 (협업 시)

### 새 기능 개발

```bash
# 새 브랜치 생성 및 이동
git checkout -b feature/new-player

# 작업 후 커밋
git add .
git commit -m "Add: 새로운 플레이어 기능"

# GitHub에 푸시
git push -u origin feature/new-player

# GitHub에서 Pull Request 생성
```

### 메인 브랜치로 병합

```bash
# 메인 브랜치로 이동
git checkout main

# 브랜치 병합
git merge feature/new-player

# GitHub에 푸시
git push
```

---

## 🔒 Private 저장소로 만들기

### GitHub 웹에서
1. 저장소 페이지 → `Settings`
2. `General` → `Danger Zone`
3. `Change repository visibility` → `Change to private`

### 협업자 추가
1. 저장소 페이지 → `Settings` → `Collaborators`
2. `Add people` 클릭
3. GitHub 아이디 또는 이메일 입력

---

## 🏷️ 릴리즈 만들기

### GitHub 웹에서
1. 저장소 페이지 → `Releases` → `Create a new release`
2. Tag 생성: `v1.0.0`
3. 릴리즈 제목: `AudioView v1.0.0 - 첫 번째 릴리즈`
4. 설명 작성
5. APK 파일 첨부 (선택사항)
6. `Publish release` 클릭

---

## 📊 GitHub 저장소 설정 추천

### About 섹션 설정
- **Description**: 배리어프리 OTT 플랫폼 - Flutter 모바일 앱
- **Website**: https://www.audioview.kr (있는 경우)
- **Topics**:
  - `flutter`
  - `dart`
  - `accessibility`
  - `barrier-free`
  - `ott`
  - `mobile-app`
  - `korean`

### README 뱃지 추가
저장소 상단에 표시되는 뱃지:
- Flutter 버전
- 빌드 상태
- 라이선스
- 플랫폼

---

## 🆘 문제 해결

### "Permission denied" 오류
```bash
# SSH 키 설정 또는 Personal Access Token 사용
# HTTPS 대신 SSH 사용:
git remote set-url origin git@github.com:YOUR_USERNAME/audioview-flutter.git
```

### "Remote already exists" 오류
```bash
# 기존 remote 제거 후 재추가
git remote remove origin
git remote add origin https://github.com/YOUR_USERNAME/audioview-flutter.git
```

### 대용량 파일 오류
```bash
# .gitignore에 추가
echo "큰파일명" >> .gitignore
git rm --cached 큰파일명
git commit -m "Remove large file"
```

### 커밋 취소
```bash
# 마지막 커밋 취소 (변경사항 유지)
git reset --soft HEAD~1

# 마지막 커밋 취소 (변경사항도 삭제)
git reset --hard HEAD~1
```

---

## 📞 추가 도움이 필요하신 경우

1. **GitHub 공식 문서**: https://docs.github.com
2. **Git 튜토리얼**: https://git-scm.com/book/ko/v2
3. **Flutter GitHub 가이드**: https://docs.flutter.dev/development/tools/github

---

## ✅ 업로드 후 확인사항

1. [ ] GitHub 저장소 페이지에서 파일 확인
2. [ ] README.md가 제대로 표시되는지 확인
3. [ ] 민감한 정보가 포함되지 않았는지 확인
4. [ ] .gitignore가 제대로 작동하는지 확인
5. [ ] 저장소 설정 (Public/Private) 확인

---

**생성일**: 2026-01-21
**작성자**: Claude AI
**문의**: kbu1004@hanmail.com
