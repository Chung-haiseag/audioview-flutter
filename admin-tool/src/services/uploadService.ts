import { ref, uploadBytes, getDownloadURL } from 'firebase/storage';
import { storage } from './firebase';

/**
 * 파일을 Firebase Storage에 업로드하고 URL을 반환합니다.
 * @param file 업로드할 파일 객체
 * @param path 저장할 경로 (예: 'posters')
 * @returns 업로드된 파일의 다운로드 URL
 */
export const uploadFile = async (file: File, path: string = 'general'): Promise<string> => {
    try {
        // 파일명 중복 방지를 위해 타임스탬프 추가
        const fileName = `${Date.now()}_${file.name}`;
        const storageRef = ref(storage, `${path}/${fileName}`);

        // 파일 업로드
        const snapshot = await uploadBytes(storageRef, file);

        // 다운로드 URL 가져오기
        const downloadURL = await getDownloadURL(snapshot.ref);

        return downloadURL;
    } catch (error) {
        console.error('파일 업로드 오류:', error);
        throw error;
    }
};
