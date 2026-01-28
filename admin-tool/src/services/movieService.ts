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
import { Movie } from '../types';

const COLLECTION_NAME = 'movies';

// 영화 목록 조회
export const getMovies = async (filters?: {
    genreId?: string;
    hasAudioCommentary?: boolean;
    hasClosedCaption?: boolean;
    isLatest?: boolean;
    isPopular?: boolean;
    searchTerm?: string;
    limitCount?: number;
}) => {
    try {
        const constraints: QueryConstraint[] = [];

        if (filters?.genreId) {
            constraints.push(where('genreId', '==', filters.genreId));
        }
        if (filters?.hasAudioCommentary !== undefined) {
            constraints.push(where('hasAudioCommentary', '==', filters.hasAudioCommentary));
        }
        if (filters?.hasClosedCaption !== undefined) {
            constraints.push(where('hasClosedCaption', '==', filters.hasClosedCaption));
        }
        if (filters?.isLatest !== undefined) {
            constraints.push(where('isLatest', '==', filters.isLatest));
        }
        if (filters?.isPopular !== undefined) {
            constraints.push(where('isPopular', '==', filters.isPopular));
        }

        constraints.push(orderBy('releaseDate', 'desc'));

        if (filters?.limitCount) {
            constraints.push(limit(filters.limitCount));
        }

        const q = query(collection(db, COLLECTION_NAME), ...constraints);
        const querySnapshot = await getDocs(q);

        const movies: Movie[] = [];
        querySnapshot.forEach((doc) => {
            const data = doc.data();
            movies.push({
                movieId: doc.id,
                ...data,
                releaseDate: data.releaseDate?.toDate(),
                createdAt: data.createdAt?.toDate(),
                updatedAt: data.updatedAt?.toDate(),
            } as Movie);
        });

        // 클라이언트 측 검색 필터링
        if (filters?.searchTerm) {
            const searchLower = filters.searchTerm.toLowerCase();
            return movies.filter(
                (movie) =>
                    movie.title.toLowerCase().includes(searchLower) ||
                    movie.directorName?.toLowerCase().includes(searchLower)
            );
        }

        return movies;
    } catch (error) {
        console.error('영화 목록 조회 오류:', error);
        throw error;
    }
};

// 영화 상세 조회
export const getMovie = async (movieId: string): Promise<Movie | null> => {
    try {
        const docRef = doc(db, COLLECTION_NAME, movieId);
        const docSnap = await getDoc(docRef);

        if (docSnap.exists()) {
            const data = docSnap.data();
            return {
                movieId: docSnap.id,
                ...data,
                releaseDate: data.releaseDate?.toDate(),
                createdAt: data.createdAt?.toDate(),
                updatedAt: data.updatedAt?.toDate(),
            } as Movie;
        }

        return null;
    } catch (error) {
        console.error('영화 조회 오류:', error);
        throw error;
    }
};

// 영화 추가
export const addMovie = async (movieData: Omit<Movie, 'movieId' | 'createdAt' | 'updatedAt'>) => {
    try {
        const dataToSave = {
            ...movieData,
            releaseDate: movieData.releaseDate instanceof Date ? Timestamp.fromDate(movieData.releaseDate) : null,
            createdAt: Timestamp.now(),
            updatedAt: Timestamp.now(),
        };

        // undefined 값 제거
        Object.keys(dataToSave).forEach(key => {
            if ((dataToSave as any)[key] === undefined) {
                delete (dataToSave as any)[key];
            }
        });

        const docRef = await addDoc(collection(db, COLLECTION_NAME), dataToSave);
        return docRef.id;
    } catch (error) {
        console.error('영화 추가 오류 상세:', error);
        throw error;
    }
};

// 영화 수정
export const updateMovie = async (movieId: string, movieData: Partial<Movie>) => {
    try {
        const docRef = doc(db, COLLECTION_NAME, movieId);
        const updateData: any = {
            ...movieData,
            updatedAt: Timestamp.now(),
        };

        if (movieData.releaseDate instanceof Date) {
            updateData.releaseDate = Timestamp.fromDate(movieData.releaseDate);
        }

        // 민감하거나 불필요한 필드 제거
        delete updateData.movieId;
        delete updateData.createdAt;

        // undefined 값 제거
        Object.keys(updateData).forEach(key => {
            if (updateData[key] === undefined) {
                delete updateData[key];
            }
        });

        await updateDoc(docRef, updateData);
    } catch (error) {
        console.error('영화 수정 오류 상세:', error);
        throw error;
    }
};

// 영화 삭제
export const deleteMovie = async (movieId: string) => {
    try {
        const docRef = doc(db, COLLECTION_NAME, movieId);
        await deleteDoc(docRef);
    } catch (error) {
        console.error('영화 삭제 오류:', error);
        throw error;
    }
};
