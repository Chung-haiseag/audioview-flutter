import * as functions from "firebase-functions";
import * as admin from "firebase-admin";

/**
 * Kakao 액세스 토큰 검증 및 커스텀 토큰 발급
 */
export const verifyKakaoToken = functions.https.onCall(async (data, context) => {
    // 0. Ensure Admin Intialized
    if (admin.apps.length === 0) {
        admin.initializeApp();
        console.log("Initialized Firebase Admin inside verifyKakaoToken");
    }

    const { accessToken } = data;
    console.log("verifyKakaoToken called with accessToken length:", accessToken ? accessToken.length : "null");

    if (!accessToken) {
        throw new functions.https.HttpsError("invalid-argument", "Access token is required.");
    }

    try {
        // 1. 카카오 API 호출하여 사용자 정보 가져오기
        console.log("Fetching Kakao User info...");
        const response = await fetch("https://kapi.kakao.com/v2/user/me", {
            headers: {
                Authorization: `Bearer ${accessToken}`,
                "Content-type": "application/x-www-form-urlencoded;charset=utf-8",
            },
        });

        console.log("Kakao API Response Status:", response.status);

        if (!response.ok) {
            const errorText = await response.text();
            console.error("Kakao API Error Body:", errorText);
            throw new functions.https.HttpsError("internal", `Kakao verification failed: ${errorText}`);
        }

        const kakaoUser = await response.json();
        const kakaoId = kakaoUser.id.toString();
        console.log("Kakao User ID:", kakaoId);

        // 0. Ensure Admin Intialized
        const email = kakaoUser.kakao_account?.email || null; // Firestore does not accept undefined
        const nickname = kakaoUser.properties?.nickname || "Kakao User"; // Default nickname if missing
        const profileImage = kakaoUser.properties?.profile_image || null;

        // 2. 파이어베이스 UID 생성 (접두사 추가하여 충돌 방지)
        const firebaseUid = `kakao:${kakaoId}`;

        // 3. 사용자 정보 업데이트/생성
        try {
            await admin.auth().getUser(firebaseUid);
            console.log("Existing user found:", firebaseUid);
        } catch (error: any) {
            if (error.code === "auth/user-not-found") {
                console.log("Creating new user:", firebaseUid);
                await admin.auth().createUser({
                    uid: firebaseUid,
                    displayName: nickname,
                    email: email || undefined, // Auth create accepts undefined but not null
                    photoURL: profileImage || undefined,
                });
            } else {
                throw error;
            }
        }

        // 4. Firestore 유저 레코드 생성/업데이트
        // Firestore requires explicitly null for missing values, not undefined
        await admin.firestore().collection("users").doc(firebaseUid).set({
            username: nickname,
            email: email,
            profileImage: profileImage,
            authProvider: "kakao",
            lastLogin: admin.firestore.FieldValue.serverTimestamp(),
            isActive: true,
        }, { merge: true });

        // 5. 커스텀 토큰 생성
        const customToken = await admin.auth().createCustomToken(firebaseUid);
        console.log("Custom token generated successfully");

        return { customToken };
    } catch (error) {
        console.error("Kakao Login Error Details:", error);
        throw new functions.https.HttpsError("internal", "Social login failed.");
    }
});

/**
 * Naver 액세스 토큰 검증 및 커스텀 토큰 발급
 */
export const verifyNaverToken = functions.https.onCall(async (data, context) => {
    const { accessToken } = data;

    if (!accessToken) {
        throw new functions.https.HttpsError("invalid-argument", "Access token is required.");
    }

    try {
        // 1. 네이버 API 호출하여 사용자 정보 가져오기
        const response = await fetch("https://openapi.naver.com/v1/nid/me", {
            headers: {
                Authorization: `Bearer ${accessToken}`,
            },
        });

        if (!response.ok) {
            throw new functions.https.HttpsError("internal", "Naver verification failed.");
        }

        const naverData = await response.json();
        if (naverData.resultcode !== "00") {
            throw new functions.https.HttpsError("internal", `Naver API error: ${naverData.message}`);
        }

        const naverUser = naverData.response;
        const naverId = naverUser.id;
        const email = naverUser.email;
        const nickname = naverUser.nickname;
        const profileImage = naverUser.profile_image;

        // 2. 파이어베이스 UID 생성
        const firebaseUid = `naver:${naverId}`;

        // 3. 사용자 정보 업데이트/생성 (동일 로직)
        try {
            await admin.auth().getUser(firebaseUid);
        } catch (error: any) {
            if (error.code === "auth/user-not-found") {
                await admin.auth().createUser({
                    uid: firebaseUid,
                    displayName: nickname,
                    email: email,
                    photoURL: profileImage,
                });
            } else {
                throw error;
            }
        }

        await admin.firestore().collection("users").doc(firebaseUid).set({
            username: nickname,
            email: email,
            profileImage: profileImage,
            authProvider: "naver",
            lastLogin: admin.firestore.FieldValue.serverTimestamp(),
            isActive: true,
        }, { merge: true });

        const customToken = await admin.auth().createCustomToken(firebaseUid);

        return { customToken };
    } catch (error) {
        console.error("Naver Login Error:", error);
        throw new functions.https.HttpsError("internal", "Social login failed.");
    }
});
