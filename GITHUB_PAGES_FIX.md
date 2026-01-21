# GitHub Pages 404 에러 수정 방법

현재 `https://chung-haiseag.github.io/audioview-flutter/` 에서 404 에러가 발생하고 있습니다.

## 🔧 해결 방법

### 1단계: GitHub Pages 활성화

1. **저장소로 이동**
   ```
   https://github.com/Chung-haiseag/audioview-flutter
   ```

2. **Settings 탭 클릭**
   - 저장소 상단 메뉴에서 `Settings` 클릭

3. **Pages 메뉴로 이동**
   - 왼쪽 사이드바에서 `Pages` 클릭

4. **Source 설정**
   - **Build and deployment** 섹션에서
   - **Source**: `GitHub Actions` 선택
   - 이미 선택되어 있다면 다음 단계로

5. **저장 확인**
   - 설정이 자동으로 저장됩니다

---

### 2단계: Actions 실행 확인

1. **Actions 탭으로 이동**
   ```
   https://github.com/Chung-haiseag/audioview-flutter/actions
   ```

2. **워크플로우 상태 확인**
   - "Deploy Flutter Web to GitHub Pages" 워크플로우가 실행되었는지 확인
   - 녹색 체크마크(✓): 성공
   - 노란색 점: 실행 중
   - 빨간색 X: 실패

3. **워크플로우가 없는 경우**
   - 워크플로우를 수동으로 실행해야 합니다
   - 또는 새 커밋을 푸시하면 자동 실행됩니다

---

### 3단계: 수동으로 워크플로우 실행

워크플로우가 아직 실행되지 않았다면:

1. **Actions 탭**에서 "Deploy Flutter Web to GitHub Pages" 클릭
2. 우측 상단 **"Run workflow"** 버튼 클릭
3. Branch는 **"main"** 선택
4. **"Run workflow"** 확인 버튼 클릭
5. 2-5분 대기

---

### 4단계: Actions 권한 확인

워크플로우가 실패하는 경우:

1. **Settings → Actions → General**로 이동
2. **Workflow permissions** 섹션에서:
   - ✅ "Read and write permissions" 선택
   - ✅ "Allow GitHub Actions to create and approve pull requests" 체크
3. **Save** 클릭

---

### 5단계: 빌드 강제 실행 (새 커밋 푸시)

워크플로우를 강제로 실행하기 위해 작은 변경사항을 푸시하겠습니다:

```bash
cd C:/Users/정해석/Downloads/audioview

# README에 배포 상태 배지 추가
echo "" >> README.md
git add README.md
git commit -m "Trigger: Force GitHub Actions workflow"
git push
```

이 명령어를 실행하면 GitHub Actions가 자동으로 실행됩니다.

---

## 🔍 문제 진단

### 현재 상태 확인

#### 1. GitHub Pages 설정
```
Settings → Pages
```
- **Source**: GitHub Actions로 설정되어 있어야 함
- **Custom domain**: 비어있어야 함
- **Enforce HTTPS**: 체크되어 있어야 함

#### 2. 워크플로우 파일 확인
```
.github/workflows/deploy.yml 파일이 존재하는지 확인
```

#### 3. 최근 Actions 실행 기록
```
Actions 탭에서 최근 실행 기록 확인
```

---

## 🚨 일반적인 에러 원인

### 1. Pages가 비활성화됨
- **해결**: Settings → Pages에서 Source를 "GitHub Actions"로 설정

### 2. 워크플로우가 한 번도 실행되지 않음
- **해결**: 수동으로 "Run workflow" 실행하거나 새 커밋 푸시

### 3. 워크플로우 권한 부족
- **해결**: Settings → Actions → General에서 권한 설정

### 4. base-href 경로 문제
- **현재 설정**: `/audioview-flutter/`
- **저장소 이름과 일치해야 함**

### 5. 빌드 실패
- **해결**: Actions 탭에서 에러 로그 확인

---

## ✅ 해결 후 확인사항

### 1. 워크플로우 성공 확인
```
Actions → Deploy Flutter Web to GitHub Pages → ✓ 녹색 체크마크
```

### 2. Pages 배포 확인
```
Settings → Pages → "Your site is live at ..."
```

### 3. 웹사이트 접속
```
https://chung-haiseag.github.io/audioview-flutter/
```

### 4. 화면 확인
- 홈 화면이 제대로 로드되는지
- 이미지가 표시되는지
- 네비게이션이 작동하는지

---

## 🔄 즉시 실행할 명령어

터미널에서 다음 명령어를 실행하여 워크플로우를 강제 실행하세요:

```bash
cd C:/Users/정해석/Downloads/audioview

# 작은 변경사항 추가
echo "" >> README.md

# 커밋 및 푸시
git add README.md
git commit -m "Trigger: Deploy to GitHub Pages"
git push

# 이제 다음 URL로 이동하여 워크플로우 실행 상태 확인
# https://github.com/Chung-haiseag/audioview-flutter/actions
```

---

## 📞 추가 확인 링크

- **저장소**: https://github.com/Chung-haiseag/audioview-flutter
- **Settings → Pages**: https://github.com/Chung-haiseag/audioview-flutter/settings/pages
- **Actions**: https://github.com/Chung-haiseag/audioview-flutter/actions
- **워크플로우 파일**: https://github.com/Chung-haiseag/audioview-flutter/blob/main/.github/workflows/deploy.yml

---

**작성일**: 2026-01-21
**다음 단계**: 위의 "즉시 실행할 명령어"를 터미널에서 실행하세요! 🚀
