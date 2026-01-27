import { initializeApp } from 'firebase/app';
import { getAuth } from 'firebase/auth';
import { getFirestore } from 'firebase/firestore';
import { getStorage } from 'firebase/storage';

// Firebase 설정
const firebaseConfig = {
    apiKey: import.meta.env.VITE_FIREBASE_API_KEY || "YOUR_API_KEY",
    authDomain: import.meta.env.VITE_FIREBASE_AUTH_DOMAIN || "YOUR_PROJECT_ID.firebaseapp.com",
    projectId: import.meta.env.VITE_FIREBASE_PROJECT_ID || "YOUR_PROJECT_ID",
    storageBucket: import.meta.env.VITE_FIREBASE_STORAGE_BUCKET || "YOUR_PROJECT_ID.appspot.com",
    messagingSenderId: import.meta.env.VITE_FIREBASE_MESSAGING_SENDER_ID || "YOUR_MESSAGING_SENDER_ID",
    appId: import.meta.env.VITE_FIREBASE_APP_ID || "YOUR_APP_ID"
};

// 디버깅: 환경 변수 확인
console.log('Firebase Config:', {
    apiKey: firebaseConfig.apiKey?.substring(0, 10) + '...',
    authDomain: firebaseConfig.authDomain,
    projectId: firebaseConfig.projectId,
});

// Firebase 초기화
const app = initializeApp(firebaseConfig);

// Firebase 서비스
export const auth = getAuth(app);
export const db = getFirestore(app);
export const storage = getStorage(app);

export default app;
