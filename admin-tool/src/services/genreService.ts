import {
    collection,
    doc,
    getDocs,
    addDoc,
    updateDoc,
    deleteDoc,
    query,
    orderBy,
    Timestamp,
} from 'firebase/firestore';
import { db } from './firebase';

export interface Genre {
    genreId: string;
    genreName: string;
    genreDescription?: string;
    createdAt?: Date;
    updatedAt?: Date;
}

const COLLECTION_NAME = 'genres';

// 장르 목록 조회
export const getGenres = async (): Promise<Genre[]> => {
    try {
        const q = query(collection(db, COLLECTION_NAME), orderBy('genreName', 'asc'));
        const querySnapshot = await getDocs(q);

        return querySnapshot.docs.map(doc => ({
            genreId: doc.id,
            ...doc.data(),
            createdAt: doc.data().createdAt?.toDate(),
            updatedAt: doc.data().updatedAt?.toDate(),
        } as Genre));
    } catch (error) {
        console.error('장르 목록 조회 오류:', error);
        throw error;
    }
};

// 장르 추가
export const addGenre = async (genreData: Omit<Genre, 'genreId' | 'createdAt' | 'updatedAt'>) => {
    try {
        const docRef = await addDoc(collection(db, COLLECTION_NAME), {
            ...genreData,
            createdAt: Timestamp.now(),
            updatedAt: Timestamp.now(),
        });
        return docRef.id;
    } catch (error) {
        console.error('장르 추가 오류:', error);
        throw error;
    }
};

// 장르 수정
export const updateGenre = async (genreId: string, genreData: Partial<Genre>) => {
    try {
        const docRef = doc(db, COLLECTION_NAME, genreId);
        await updateDoc(docRef, {
            ...genreData,
            updatedAt: Timestamp.now(),
        });
    } catch (error) {
        console.error('장르 수정 오류:', error);
        throw error;
    }
};

// 장르 삭제
export const deleteGenre = async (genreId: string) => {
    try {
        const docRef = doc(db, COLLECTION_NAME, genreId);
        await deleteDoc(docRef);
    } catch (error) {
        console.error('장르 삭제 오류:', error);
        throw error;
    }
};
