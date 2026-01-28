import 'package:cloud_firestore/cloud_firestore.dart';
import '../utils/type_parser.dart';

enum NoticeType { notice, event }

class Notice {
  final String id;
  final String title;
  final String content;
  final DateTime date;
  final NoticeType type;
  final bool isNew;
  final bool isImportant;
  final int viewCount;
  final String category; // '일반', '이벤트', etc.
  final String? movieId;

  Notice({
    required this.id,
    required this.title,
    required this.content,
    required this.date,
    required this.type,
    this.isNew = false,
    this.isImportant = false,
    this.viewCount = 0,
    required this.category,
    this.movieId,
  });

  factory Notice.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;

    // 1. Title
    String title = data['title'] ?? '제목 없음';

    // 2. Content
    String content = data['content'] ?? '';

    // 3. Date (publishedAt or createdAt)
    Timestamp? timestamp =
        data['publishedAt'] as Timestamp? ?? data['createdAt'] as Timestamp?;
    DateTime date = timestamp?.toDate() ?? DateTime.now();

    // 4. Category (noticeType)
    // Firestore stores "general" or "event", map to "일반" / "이벤트"
    String rawType = data['noticeType'] ?? 'general';
    String category = (rawType == 'event') ? '이벤트' : '일반';
    NoticeType type =
        (rawType == 'event') ? NoticeType.event : NoticeType.notice;

    // 5. Importance
    bool isImportant = data['isImportant'] ?? false;

    // 6. ViewCount
    int viewCount = TypeParser.parseInt(data['viewCount']);

    // 7. Movie ID (Optional)
    String? movieId = data['movieId'];
    // print('Notice Detail - ID: ${doc.id}, Title: $title, MovieId: $movieId');
    // print('Full data keys: ${data.keys.toList()}');

    return Notice(
      id: doc.id,
      title: title,
      content: content,
      date: date,
      type: type,
      isNew: false,
      isImportant: isImportant,
      viewCount: viewCount,
      category: category,
      movieId: movieId,
    );
  }
}
