# 베리어프리 영화 관리자 대시보드

React + TypeScript + Firebase로 구축된 베리어프리 영화 서비스 관리자 대시보드입니다.

## 🚀 시작하기

### 1. 환경 변수 설정

`.env.local` 파일을 생성하고 Firebase 설정을 추가하세요:

```bash
cp .env.example .env.local
```

`.env.local` 파일을 열고 Firebase Console에서 가져온 실제 값으로 교체하세요.

### 2. 의존성 설치

```bash
npm install
```

### 3. 개발 서버 실행

```bash
npm run dev
```

브라우저에서 http://localhost:5173 을 열어 확인하세요.

## 📦 기술 스택

- **React 18** - UI 라이브러리
- **TypeScript** - 타입 안정성
- **Vite** - 빌드 도구
- **Material-UI (MUI)** - UI 컴포넌트
- **Firebase** - 백엔드 (Auth, Firestore, Storage)
- **React Router** - 라우팅
- **TanStack Query** - 서버 상태 관리
- **date-fns** - 날짜 포맷팅

## 🎯 주요 기능

### 인증
- 관리자 로그인 (이메일/비밀번호)
- 관리자 권한 검증 (Firebase Custom Claims)
- 자동 로그인 유지

### 대시보드
- 전체 통계 (영화 수, 회원 수, 신규 회원, 다운로드)
- 최근 활동 타임라인

### 영화 관리
- 영화 목록 조회 (검색, 필터링)
- 영화 추가/수정/삭제
- 베리어프리 파일 관리

### 회원 관리
- 회원 목록 조회
- 회원 상세 정보
- 회원 상태 관리

### 공지사항 관리
- 공지사항 목록 조회
- 공지사항 작성/수정/삭제
- 중요 공지 설정

## 📁 프로젝트 구조

```
src/
├── components/          # 재사용 컴포넌트
│   ├── layout/
│   │   └── AppLayout.tsx
│   └── ProtectedRoute.tsx
├── contexts/            # React Context
│   └── AuthContext.tsx
├── pages/               # 페이지 컴포넌트
│   ├── Dashboard.tsx
│   ├── Login.tsx
│   ├── Movies.tsx
│   ├── Users.tsx
│   └── Notices.tsx
├── services/            # Firebase 서비스
│   ├── firebase.ts
│   ├── authService.ts
│   ├── movieService.ts
│   ├── userService.ts
│   └── noticeService.ts
├── types/               # TypeScript 타입
│   └── index.ts
├── App.tsx
├── main.tsx
└── theme.ts
```

## 🔐 관리자 권한 설정

관리자 계정에 권한을 부여하려면 Firebase Admin SDK를 사용하세요:

```bash
cd ..
node admin-setup.js admin@example.com
```

## 🛠️ 빌드

프로덕션 빌드:

```bash
npm run build
```

빌드 결과물은 `dist/` 폴더에 생성됩니다.

## 📝 환경 변수

| 변수명 | 설명 |
|--------|------|
| `VITE_FIREBASE_API_KEY` | Firebase API 키 |
| `VITE_FIREBASE_AUTH_DOMAIN` | Firebase Auth 도메인 |
| `VITE_FIREBASE_PROJECT_ID` | Firebase 프로젝트 ID |
| `VITE_FIREBASE_STORAGE_BUCKET` | Firebase Storage 버킷 |
| `VITE_FIREBASE_MESSAGING_SENDER_ID` | Firebase 메시징 발신자 ID |
| `VITE_FIREBASE_APP_ID` | Firebase 앱 ID |

## 🚀 배포

Firebase Hosting에 배포:

```bash
npm run build
firebase deploy --only hosting
```

## 📄 라이선스

MIT
