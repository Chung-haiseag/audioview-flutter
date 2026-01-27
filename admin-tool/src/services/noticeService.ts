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
    Timestamp,
    QueryConstraint,
} from 'firebase/firestore';
import { db } from './firebase';
import { Notice } from '../types';

const COLLECTION_NAME = 'notices';

// 공지사항 목록 조회
export const getNotices = async (filters?: {
    noticeType?: string;
    isImportant?: boolean;
    searchTerm?: string;
    limitCount?: number;
}) => {
    try {
        const constraints: QueryConstraint[] = [];

        if (filters?.noticeType) {
            constraints.push(where('noticeType', '==', filters.noticeType));
        }
        if (filters?.isImportant !== undefined) {
            constraints.push(where('isImportant', '==', filters.isImportant));
        }

        constraints.push(orderBy('publishedAt', 'desc'));

        if (filters?.limitCount) {
            constraints.push(limit(filters.limitCount));
        }

        const q = query(collection(db, COLLECTION_NAME), ...constraints);
        const querySnapshot = await getDocs(q);

        const notices: Notice[] = [];
        querySnapshot.forEach((doc) => {
            const data = doc.data();
            notices.push({
                noticeId: doc.id,
                ...data,
                publishedAt: data.publishedAt?.toDate(),
                expiresAt: data.expiresAt?.toDate(),
                createdAt: data.createdAt?.toDate(),
                updatedAt: data.updatedAt?.toDate(),
            } as Notice);
        });

        // 클라이언트 측 검색 필터링
        if (filters?.searchTerm) {
            const searchLower = filters.searchTerm.toLowerCase();
            return notices.filter(
                (notice) =>
                    notice.title.toLowerCase().includes(searchLower) ||
                    notice.content.toLowerCase().includes(searchLower)
            );
        }

        return notices;
    } catch (error) {
        console.error('공지사항 목록 조회 오류:', error);
        throw error;
    }
};

// 공지사항 상세 조회
export const getNotice = async (noticeId: string): Promise<Notice | null> => {
    try {
        const docRef = doc(db, COLLECTION_NAME, noticeId);
        const docSnap = await getDoc(docRef);

        if (docSnap.exists()) {
            const data = docSnap.data();
            return {
                noticeId: docSnap.id,
                ...data,
                publishedAt: data.publishedAt?.toDate(),
                expiresAt: data.expiresAt?.toDate(),
                createdAt: data.createdAt?.toDate(),
                updatedAt: data.updatedAt?.toDate(),
            } as Notice;
        }

        return null;
    } catch (error) {
        console.error('공지사항 조회 오류:', error);
        throw error;
    }
};

// 공지사항 추가
export const addNotice = async (
    noticeData: Omit<Notice, 'noticeId' | 'viewCount' | 'createdAt' | 'updatedAt'>,
    createdBy: string
) => {
    try {
        const cleanedData: any = { ...noticeData };

        // 날짜 처리
        if (cleanedData.publishedAt instanceof Date) {
            cleanedData.publishedAt = Timestamp.fromDate(cleanedData.publishedAt);
        } else {
            cleanedData.publishedAt = Timestamp.now();
        }

        if (cleanedData.expiresAt instanceof Date) {
            cleanedData.expiresAt = Timestamp.fromDate(cleanedData.expiresAt);
        } else {
            delete cleanedData.expiresAt;
        }

        // undefined 필드 제거 (Firestore는 undefined를 허용하지 않음)
        Object.keys(cleanedData).forEach(key => {
            if (cleanedData[key] === undefined) {
                delete cleanedData[key];
            }
        });

        const docRef = await addDoc(collection(db, COLLECTION_NAME), {
            ...cleanedData,
            viewCount: 0,
            createdBy,
            isPushSent: cleanedData.isPushSent || false,
            createdAt: Timestamp.now(),
            updatedAt: Timestamp.now(),
        });

        return docRef.id;
    } catch (error) {
        console.error('공지사항 추가 오류:', error);
        throw error;
    }
};

// 공지사항 수정
export const updateNotice = async (noticeId: string, noticeData: Partial<Notice>) => {
    try {
        const docRef = doc(db, COLLECTION_NAME, noticeId);

        const updateData: any = {
            ...noticeData,
            updatedAt: Timestamp.now(),
        };

        // 날짜 처리
        if (updateData.publishedAt instanceof Date) {
            updateData.publishedAt = Timestamp.fromDate(updateData.publishedAt);
        }
        if (updateData.expiresAt instanceof Date) {
            updateData.expiresAt = Timestamp.fromDate(updateData.expiresAt);
        }

        // 불필요하거나 부적절한 필드 제거
        delete updateData.noticeId;
        delete updateData.createdAt;
        delete updateData.viewCount;

        // undefined 필드 제거
        Object.keys(updateData).forEach(key => {
            if (updateData[key] === undefined) {
                delete updateData[key];
            }
        });

        await updateDoc(docRef, updateData);
    } catch (error) {
        console.error('공지사항 수정 오류:', error);
        throw error;
    }
};

// 공지사항 삭제
export const deleteNotice = async (noticeId: string) => {
    try {
        const docRef = doc(db, COLLECTION_NAME, noticeId);
        await deleteDoc(docRef);
    } catch (error) {
        console.error('공지사항 삭제 오류:', error);
        throw error;
    }
};
