import {
    collection,
    doc,
    getDoc,
    getDocs,
    addDoc,
    updateDoc,
    deleteDoc,
    query,
    where,
    orderBy,
    limit,
    QueryConstraint,
    Timestamp,
} from 'firebase/firestore';
import { db } from './firebase';
import { User, UserFavorite, UserDownloadHistory, UserPoint, PointHistory } from '../types';

const COLLECTION_NAME = 'users';

// 회원 목록 조회
export const getUsers = async (filters?: {
    authProvider?: string;
    disabilityType?: string;
    isActive?: boolean;
    searchTerm?: string;
    limitCount?: number;
}) => {
    try {
        const constraints: QueryConstraint[] = [];

        if (filters?.authProvider) {
            constraints.push(where('authProvider', '==', filters.authProvider));
        }
        if (filters?.disabilityType) {
            constraints.push(where('disabilityType', '==', filters.disabilityType));
        }
        if (filters?.isActive !== undefined) {
            constraints.push(where('isActive', '==', filters.isActive));
        }

        constraints.push(orderBy('createdAt', 'desc'));

        if (filters?.limitCount) {
            constraints.push(limit(filters.limitCount));
        }

        const q = query(collection(db, COLLECTION_NAME), ...constraints);
        const querySnapshot = await getDocs(q);

        const users: User[] = [];
        querySnapshot.forEach((doc) => {
            const data = doc.data();
            users.push({
                userId: doc.id,
                ...data,
                lastLoginAt: data.lastLoginAt?.toDate(),
                createdAt: data.createdAt?.toDate(),
                updatedAt: data.updatedAt?.toDate(),
            } as User);
        });

        // 클라이언트 측 검색 필터링
        if (filters?.searchTerm) {
            const searchLower = filters.searchTerm.toLowerCase();
            return users.filter(
                (user) =>
                    user.email?.toLowerCase().includes(searchLower) ||
                    user.username.toLowerCase().includes(searchLower)
            );
        }

        return users;
    } catch (error) {
        console.error('회원 목록 조회 오류:', error);
        throw error;
    }
};

// 회원 상세 조회
export const getUser = async (userId: string): Promise<User | null> => {
    try {
        const docRef = doc(db, COLLECTION_NAME, userId);
        const docSnap = await getDoc(docRef);

        if (docSnap.exists()) {
            const data = docSnap.data();
            return {
                userId: docSnap.id,
                ...data,
                lastLoginAt: data.lastLoginAt?.toDate(),
                createdAt: data.createdAt?.toDate(),
                updatedAt: data.updatedAt?.toDate(),
            } as User;
        }

        return null;
    } catch (error) {
        console.error('회원 조회 오류:', error);
        throw error;
    }
};

// 회원 정보 업데이트
export const updateUser = async (userId: string, userData: Partial<User>) => {
    try {
        const docRef = doc(db, COLLECTION_NAME, userId);
        const updateData: any = {
            ...userData,
            updatedAt: Timestamp.now(),
        };

        // 데이터 정제 (undefined 제거 및 자동 생성 필드 보호)
        delete updateData.userId;
        delete updateData.createdAt;

        Object.keys(updateData).forEach(key => {
            if (updateData[key] === undefined) {
                delete updateData[key];
            }
        });

        await updateDoc(docRef, updateData);
    } catch (error) {
        console.error('회원 업데이트 오류 상세:', error);
        throw error;
    }
};

// 회원 추가
export const addUser = async (userData: Omit<User, 'userId' | 'createdAt' | 'updatedAt'>) => {
    try {
        const docRef = await addDoc(collection(db, COLLECTION_NAME), {
            ...userData,
            isActive: userData.isActive ?? true,
            createdAt: Timestamp.now(),
            updatedAt: Timestamp.now(),
        });
        return docRef.id;
    } catch (error) {
        console.error('회원 추가 오류:', error);
        throw error;
    }
};

// 회원 삭제
export const deleteUser = async (userId: string) => {
    try {
        const docRef = doc(db, COLLECTION_NAME, userId);
        await deleteDoc(docRef);
    } catch (error) {
        console.error('회원 삭제 오류:', error);
        throw error;
    }
};

// 회원 통계
export const getUserStats = async () => {
    try {
        const allUsersSnapshot = await getDocs(collection(db, COLLECTION_NAME));
        const totalUsers = allUsersSnapshot.size;

        // 이번 달 신규 회원
        const now = new Date();
        const firstDayOfMonth = new Date(now.getFullYear(), now.getMonth(), 1);
        const q = query(
            collection(db, COLLECTION_NAME),
            where('createdAt', '>=', Timestamp.fromDate(firstDayOfMonth))
        );
        const newUsersSnapshot = await getDocs(q);
        const newUsersThisMonth = newUsersSnapshot.size;

        return {
            totalUsers,
            newUsersThisMonth,
        };
    } catch (error) {
        console.error('회원 통계 조회 오류:', error);
        throw error;
    }
};

// 회원의 찜하기 목록 조회
export const getUserFavorites = async (userId: string): Promise<UserFavorite[]> => {
    try {
        const q = query(
            collection(db, 'userFavorites'),
            where('userId', '==', userId),
            orderBy('createdAt', 'desc')
        );
        const querySnapshot = await getDocs(q);

        const favorites: any[] = [];
        querySnapshot.forEach((docSnap) => {
            favorites.push({
                favoriteId: docSnap.id,
                ...docSnap.data(),
                createdAt: docSnap.data().createdAt?.toDate(),
            });
        });

        // 영화 상세 정보 조인
        const moviePromises = favorites.map(async (fav) => {
            const movieRef = doc(db, 'movies', fav.movieId);
            const movieSnap = await getDoc(movieRef);
            return movieSnap.exists() ? { ...fav, movie: { movieId: movieSnap.id, ...movieSnap.data() } } : fav;
        });

        return Promise.all(moviePromises);
    } catch (error) {
        console.error('회원 찜하기 조회 오류:', error);
        return [];
    }
};

// 회원의 다운로드 이력 조회
export const getUserDownloadHistory = async (userId: string): Promise<UserDownloadHistory[]> => {
    try {
        const q = query(
            collection(db, 'userDownloadHistory'),
            where('userId', '==', userId),
            orderBy('downloadedAt', 'desc')
        );
        const querySnapshot = await getDocs(q);

        const history: any[] = [];
        querySnapshot.forEach((docSnap) => {
            history.push({
                downloadId: docSnap.id,
                ...docSnap.data(),
                downloadedAt: docSnap.data().downloadedAt?.toDate(),
            });
        });

        // 영화 상세 정보 조인
        const moviePromises = history.map(async (item) => {
            const movieRef = doc(db, 'movies', item.movieId);
            const movieSnap = await getDoc(movieRef);
            return movieSnap.exists() ? { ...item, movie: { movieId: movieSnap.id, ...movieSnap.data() } } : item;
        });

        return Promise.all(moviePromises);
    } catch (error) {
        console.error('회원 다운로드 이력 조회 오류:', error);
        return [];
    }
};

// 회원의 포인트 정보 조회
export const getUserPoints = async (userId: string): Promise<UserPoint | null> => {
    try {
        const docRef = doc(db, 'userPoints', userId);
        const docSnap = await getDoc(docRef);

        if (docSnap.exists()) {
            const data = docSnap.data();
            return {
                userId: docSnap.id,
                ...data,
                createdAt: data.createdAt?.toDate(),
                updatedAt: data.updatedAt?.toDate(),
            } as UserPoint;
        }
        return null;
    } catch (error) {
        console.error('회원 포인트 조회 오류:', error);
        throw error;
    }
};

// 회원의 포인트 이력 조회
export const getPointHistory = async (userId: string): Promise<PointHistory[]> => {
    try {
        const q = query(
            collection(db, 'pointHistory'),
            where('userId', '==', userId),
            orderBy('createdAt', 'desc')
        );
        const querySnapshot = await getDocs(q);

        const history: PointHistory[] = [];
        querySnapshot.forEach((docSnap) => {
            const data = docSnap.data();
            history.push({
                historyId: docSnap.id,
                ...data,
                createdAt: data.createdAt?.toDate(),
            } as PointHistory);
        });

        return history;
    } catch (error) {
        console.error('포인트 이력 조회 오류:', error);
        return [];
    }
};
