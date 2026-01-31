import {
    collection,
    doc,
    getDocs,
    getDoc,
    addDoc,
    updateDoc,
    deleteDoc,
    query,
    where,
    orderBy,
    Timestamp,
    writeBatch,
} from 'firebase/firestore';
import { db } from './firebase';
import { FeaturedList, FeaturedMovie, Movie } from '../types';

const LIST_COLLECTION = 'featured_lists';
const MOVIE_LINK_COLLECTION = 'featured_movies';

// 특별 목록 리스트 조회
export const getFeaturedLists = async (): Promise<FeaturedList[]> => {
    try {
        const q = query(collection(db, LIST_COLLECTION), orderBy('displayOrder', 'asc'));
        const querySnapshot = await getDocs(q);
        return querySnapshot.docs.map(doc => ({
            listId: doc.id,
            ...doc.data(),
            createdAt: doc.data().createdAt?.toDate(),
        } as FeaturedList));
    } catch (error) {
        console.error('Featured 목록 조회 오류:', error);
        throw error;
    }
};

// 특별 목록 추가
export const addFeaturedList = async (data: Omit<FeaturedList, 'listId' | 'createdAt'>) => {
    try {
        const docRef = await addDoc(collection(db, LIST_COLLECTION), {
            ...data,
            createdAt: Timestamp.now(),
        });
        return docRef.id;
    } catch (error) {
        console.error('Featured 목록 추가 오류:', error);
        throw error;
    }
};

// 특별 목록 수정
export const updateFeaturedList = async (listId: string, data: Partial<FeaturedList>) => {
    try {
        const docRef = doc(db, LIST_COLLECTION, listId);
        await updateDoc(docRef, { ...data });
    } catch (error) {
        console.error('Featured 목록 수정 오류:', error);
        throw error;
    }
};

// 특별 목록 삭제
export const deleteFeaturedList = async (listId: string) => {
    try {
        const batch = writeBatch(db);

        // 1. 해당 목록에 연결된 영화들 삭제
        const q = query(collection(db, MOVIE_LINK_COLLECTION), where('listId', '==', listId));
        const snapshots = await getDocs(q);
        snapshots.forEach(d => batch.delete(d.ref));

        // 2. 목록 자체 삭제
        batch.delete(doc(db, LIST_COLLECTION, listId));

        await batch.commit();
    } catch (error) {
        console.error('Featured 목록 삭제 오류:', error);
        throw error;
    }
};

// 특정 목록의 영화들 조회
export const getFeaturedMovies = async (listId: string): Promise<(FeaturedMovie & { movie?: Movie })[]> => {
    try {
        // orderBy를 제거하여 displayOrder 필드가 없는 문서도 모두 가져오도록 수정
        // (Firestore의 orderBy는 필드가 없는 문서를 결과에서 제외함)
        const q = query(
            collection(db, MOVIE_LINK_COLLECTION),
            where('listId', '==', listId)
        );
        const querySnapshot = await getDocs(q);

        const featuredMovies = querySnapshot.docs.map(d => ({
            featuredId: d.id,
            ...d.data(),
            featuredDate: d.data().featuredDate?.toDate(),
            createdAt: d.data().createdAt?.toDate(),
        } as FeaturedMovie));

        // 메모리에서 정렬 처리
        featuredMovies.sort((a, b) => (a.displayOrder || 0) - (b.displayOrder || 0));

        // 영화 정보 병합 (필요 시)
        const results = await Promise.all(featuredMovies.map(async (fm) => {
            const movieDoc = await getDoc(doc(db, 'movies', fm.movieId));
            return {
                ...fm,
                movie: movieDoc.exists() ? { movieId: movieDoc.id, ...movieDoc.data() } as Movie : undefined
            };
        }));

        return results;
    } catch (error) {
        console.error('목록 내 영화 조회 오류:', error);
        throw error;
    }
};

// 목록에 영화 추가
export const addMovieToFeatured = async (listId: string, movieId: string, displayOrder: number) => {
    try {
        // 이미 등록되어 있는지 확인
        const q = query(
            collection(db, MOVIE_LINK_COLLECTION),
            where('listId', '==', listId),
            where('movieId', '==', movieId)
        );
        const snapshot = await getDocs(q);
        if (!snapshot.empty) throw new Error('이미 목록에 존재하는 영화입니다.');

        await addDoc(collection(db, MOVIE_LINK_COLLECTION), {
            listId,
            movieId,
            displayOrder,
            featuredDate: Timestamp.now(),
            createdAt: Timestamp.now(),
        });
    } catch (error) {
        console.error('목록에 영화 추가 오류:', error);
        throw error;
    }
};

// 목록에서 영화 제거
export const removeMovieFromFeatured = async (featuredId: string) => {
    try {
        await deleteDoc(doc(db, MOVIE_LINK_COLLECTION, featuredId));
    } catch (error) {
        console.error('목록에서 영화 제거 오류:', error);
        throw error;
    }
};
