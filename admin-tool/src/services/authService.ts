import {
    signInWithEmailAndPassword,
    signOut as firebaseSignOut,
    onAuthStateChanged,
    User
} from 'firebase/auth';
import { auth } from './firebase';

// 로그인
export const signIn = async (email: string, password: string) => {
    try {
        const userCredential = await signInWithEmailAndPassword(auth, email, password);

        // 관리자 권한 확인
        const idTokenResult = await userCredential.user.getIdTokenResult();
        if (!idTokenResult.claims.admin) {
            await firebaseSignOut(auth);
            throw new Error('관리자 권한이 없습니다.');
        }

        return userCredential.user;
    } catch (error: any) {
        console.error('로그인 오류:', error);
        throw error;
    }
};

// 로그아웃
export const signOut = async () => {
    try {
        await firebaseSignOut(auth);
    } catch (error) {
        console.error('로그아웃 오류:', error);
        throw error;
    }
};

// 현재 사용자 가져오기
export const getCurrentUser = (): Promise<User | null> => {
    return new Promise((resolve, reject) => {
        const unsubscribe = onAuthStateChanged(
            auth,
            (user) => {
                unsubscribe();
                resolve(user);
            },
            reject
        );
    });
};

// 관리자 권한 확인
export const checkAdminRole = async (user: User): Promise<boolean> => {
    try {
        const idTokenResult = await user.getIdTokenResult();
        return !!idTokenResult.claims.admin;
    } catch (error) {
        console.error('권한 확인 오류:', error);
        return false;
    }
};
