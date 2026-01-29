import * as functions from "firebase-functions";
import * as admin from "firebase-admin";

// Firebase Admin 초기화
admin.initializeApp();

const db = admin.firestore();

export * from "./social_auth";

/**
 * 회원가입 시 기본 포인트(100P) 적립
 * 트리거: users 컬렉션에 새 문서 추가
 */
export const onUserCreate = functions.firestore
  .document("users/{userId}")
  .onCreate(async (snap, _context) => {
    const userId = snap.id;
    const signupPoints = 100;

    try {
      // 포인트 업데이트
      await snap.ref.update({
        points: admin.firestore.FieldValue.increment(signupPoints),
        updated_at: admin.firestore.FieldValue.serverTimestamp(),
      });

      // 포인트 히스토리 기록
      await db.collection("point_history").add({
        user_id: userId,
        points: signupPoints,
        type: "signup",
        description: "회원가입 축하 포인트",
        created_at: admin.firestore.FieldValue.serverTimestamp(),
      });

      functions.logger.info(`회원가입 포인트 적립 완료: ${userId} - ${signupPoints}포인트`);
    } catch (error) {
      functions.logger.error("회원가입 포인트 적립 실패:", error);
    }
  });

/**
 * 일일 방문 체크인 (10P)
 */
export const dailyCheckIn = functions.https.onCall(async (data, context) => {
  // 인증 확인
  if (!context.auth) {
    throw new functions.https.HttpsError("unauthenticated", "로그인이 필요합니다.");
  }

  const userId = context.auth.uid;
  const today = new Date();
  const dateString = today.toISOString().split('T')[0]; // YYYY-MM-DD
  const checkInId = `${userId}_${dateString}`;
  const checkInPoints = 10;

  try {
    const checkInRef = db.collection("daily_check_ins").doc(checkInId);
    const checkInDoc = await checkInRef.get();

    if (checkInDoc.exists) {
      return { success: false, message: "이미 오늘 체크인을 완료하셨습니다." };
    }

    // 트랜잭션으로 체크인 기록 및 포인트 지급
    await db.runTransaction(async (transaction) => {
      // 1. 체크인 기록 생성
      transaction.set(checkInRef, {
        user_id: userId,
        date: dateString,
        created_at: admin.firestore.FieldValue.serverTimestamp(),
      });

      // 2. 유저 포인트 업데이트
      const userRef = db.collection("users").doc(userId);
      transaction.update(userRef, {
        points: admin.firestore.FieldValue.increment(checkInPoints),
        last_check_in: dateString,
        updated_at: admin.firestore.FieldValue.serverTimestamp(),
      });

      // 3. 포인트 히스토리 추가
      const historyRef = db.collection("point_history").doc();
      transaction.set(historyRef, {
        user_id: userId,
        points: checkInPoints,
        type: "checkin",
        description: "일일 방문 체크인",
        created_at: admin.firestore.FieldValue.serverTimestamp(),
      });
    });

    return { success: true, points: checkInPoints, message: "10포인트가 적립되었습니다!" };
  } catch (error) {
    functions.logger.error("체크인 실패:", error);
    throw new functions.https.HttpsError("internal", "체크인 처리 중 오류가 발생했습니다.");
  }
});


/**
 * 리뷰 작성 시 포인트 적립
 * 트리거: reviews 컬렉션에 새 문서 추가
 */
export const onReviewCreate = functions.firestore
  .document("reviews/{reviewId}")
  .onCreate(async (snap, _context) => {
    const reviewData = snap.data();
    const userId = reviewData.user_id;

    try {
      const userRef = db.collection("users").doc(userId);
      const userDoc = await userRef.get();

      if (!userDoc.exists) {
        functions.logger.error(`User not found: ${userId}`);
        return;
      }

      // 포인트 적립 (리뷰 작성: 5포인트)
      const reviewPoints = 5;
      await userRef.update({
        points: admin.firestore.FieldValue.increment(reviewPoints),
        updated_at: admin.firestore.FieldValue.serverTimestamp(),
      });

      // 포인트 히스토리 기록
      await db.collection("point_history").add({
        user_id: userId,
        points: reviewPoints,
        type: "review_write",
        description: "리뷰 작성",
        related_id: snap.id,
        created_at: admin.firestore.FieldValue.serverTimestamp(),
      });

      functions.logger.info(`리뷰 포인트 적립 완료: ${userId} - ${reviewPoints}포인트`);
    } catch (error) {
      functions.logger.error("리뷰 포인트 적립 실패:", error);
    }
  });

/**
 * 공지사항 발송 시 FCM 푸시 알림 전송
 * 트리거: notices 컬렉션에 새 문서 추가
 */
export const onNoticeCreate = functions.firestore
  .document("notices/{noticeId}")
  .onCreate(async (snap, _context) => {
    const noticeData = snap.data();
    functions.logger.info("새 공지사항 감지:", { noticeId: snap.id, push_enabled: noticeData.push_enabled, title: noticeData.title });

    // 푸시 알림을 활성화한 사용자만 대상
    if (!noticeData.push_enabled) {
      functions.logger.info("푸시 알림이 비활성화된 공지사항입니다.");
      return;
    }

    try {
      // 모든 사용자의 FCM 토큰 가져오기 (컬렉션 그룹 쿼리 고려 가능하지만 일단 users 컬렉션만)
      functions.logger.info("FCM 토큰을 가진 사용자 검색 시작...");

      const usersSnapshot = await db.collection("users")
        .where("fcm_token", "!=", null)
        .get();

      if (usersSnapshot.empty) {
        functions.logger.info("푸시 알림을 받을 사용자가 없습니다. (fcm_token 필드를 가진 유저 0명)");
        return;
      }

      const tokens: string[] = [];
      usersSnapshot.forEach((doc) => {
        const userData = doc.data();
        if (userData.fcm_token && typeof userData.fcm_token === 'string' && userData.fcm_token.length > 0) {
          tokens.push(userData.fcm_token);
        }
      });

      functions.logger.info(`유효 토큰 수집 완료: ${tokens.length}개`);

      if (tokens.length === 0) {
        functions.logger.info("유효한 FCM 토큰이 없습니다 (필드는 있으나 값이 비었거나 형식이 다름).");
        return;
      }

      // FCM 메시지 구성
      // Note: sendEachForMulticast는 최대 500개 토큰까지 지원. 
      // 사용자가 많아지면 배치 처리로 변경해야 함.
      const message = {
        notification: {
          title: noticeData.pushTitle || noticeData.title || "새 공지사항",
          body: noticeData.pushMessage || (noticeData.content ? noticeData.content.substring(0, 100) : "내용 없음"),
        },
        data: {
          notice_id: snap.id,
          type: "notice",
        },
        tokens: tokens,
      };

      // 푸시 알림 전송
      functions.logger.info(`FCM 멀티캐스트 전송 시도... 대상 토큰 수: ${tokens.length}`);
      functions.logger.info("대상 토큰 목록 (보안 주의):", tokens);
      const response = await admin.messaging().sendEachForMulticast(message);
      functions.logger.info(`푸시 알림 전송 결과 - 성공: ${response.successCount}, 실패: ${response.failureCount}`);

      if (response.failureCount > 0) {
        const failedTokens: any[] = [];
        response.responses.forEach((resp, idx) => {
          if (!resp.success) {
            failedTokens.push({ token: tokens[idx], error: resp.error });
          }
        });
        functions.logger.error("실패한 토큰 상세:", failedTokens);
      }
    } catch (error) {
      functions.logger.error("푸시 알림 전송 중 예외 발생:", error);
    }
  });

/**
 * 이벤트 발송 시 FCM 푸시 알림 전송
 * 트리거: events 컬렉션에 새 문서 추가
 */
export const onEventCreate = functions.firestore
  .document("events/{eventId}")
  .onCreate(async (snap, _context) => {
    const eventData = snap.data();

    // 푸시 알림을 활성화한 이벤트만 대상
    if (!eventData.push_enabled) {
      functions.logger.info("푸시 알림이 비활성화된 이벤트입니다.");
      return;
    }

    try {
      // 모든 사용자의 FCM 토큰 가져오기
      const usersSnapshot = await db.collection("users")
        .where("fcm_token", "!=", null)
        .get();

      if (usersSnapshot.empty) {
        functions.logger.info("푸시 알림을 받을 사용자가 없습니다.");
        return;
      }

      const tokens: string[] = [];
      usersSnapshot.forEach((doc) => {
        const userData = doc.data();
        if (userData.fcm_token) {
          tokens.push(userData.fcm_token);
        }
      });

      if (tokens.length === 0) {
        functions.logger.info("유효한 FCM 토큰이 없습니다.");
        return;
      }

      // FCM 메시지 구성
      const message = {
        notification: {
          title: `🎉 ${eventData.title}`,
          body: eventData.content.substring(0, 100),
        },
        data: {
          event_id: snap.id,
          type: "event",
        },
        tokens: tokens,
      };

      // 푸시 알림 전송
      const response = await admin.messaging().sendEachForMulticast(message);
      functions.logger.info(`이벤트 푸시 알림 전송 완료: ${response.successCount}/${tokens.length}`);

      if (response.failureCount > 0) {
        functions.logger.info(`실패한 토큰 수: ${response.failureCount}`);
      }
    } catch (error) {
      functions.logger.error("이벤트 푸시 알림 전송 실패:", error);
    }
  });

/**
 * 영화 데이터 변경 시 통계 업데이트
 * 트리거: movies 컬렉션의 문서 업데이트
 */
export const onMovieUpdate = functions.firestore
  .document("movies/{movieId}")
  .onUpdate(async (change, context) => {
    const before = change.before.data();
    const after = change.after.data();

    // 좋아요 수 변경 시
    if (before.like_count !== after.like_count) {
      const movieId = context.params.movieId;
      functions.logger.info(`영화 ${movieId} 좋아요 수 변경: ` +
        `${before.like_count} -> ${after.like_count}`);
    }

    // 조회수 변경 시
    if (before.view_count !== after.view_count) {
      const movieId = context.params.movieId;
      functions.logger.info(`영화 ${movieId} 조회수 변경: ` +
        `${before.view_count} -> ${after.view_count}`);
    }
  });
