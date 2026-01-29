import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';

class PointService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseFunctions _functions = FirebaseFunctions.instance;

  // 일일 방문 체크인 API 호출
  Future<Map<String, dynamic>> dailyCheckIn() async {
    try {
      final HttpsCallable callable = _functions.httpsCallable('dailyCheckIn');
      final result = await callable.call();
      return Map<String, dynamic>.from(result.data);
    } catch (e) {
      return {
        'success': false,
        'message': e.toString(),
      };
    }
  }

  // 사용자의 포인트 내역 가져오기
  Stream<QuerySnapshot> getPointHistory(String userId) {
    return _firestore
        .collection('point_history')
        .where('user_id', isEqualTo: userId)
        .orderBy('created_at', descending: true)
        .snapshots();
  }

  // 사용자의 현재 포인트 조회 (실시간)
  Stream<DocumentSnapshot> getUserPoints(String userId) {
    return _firestore.collection('users').doc(userId).snapshots();
  }
}
