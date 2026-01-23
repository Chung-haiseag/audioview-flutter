import 'package:cloud_firestore/cloud_firestore.dart';

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
  });

  factory Notice.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;

    // Map Firestore 'category' string to NoticeType for older app logic if needed,
    // or just use category string directly.
    // Assuming Admin saves '분류' as 'category' field.
    String category = data['category'] ?? '일반';
    NoticeType type = category == '이벤트' ? NoticeType.event : NoticeType.notice;

    return Notice(
      id: doc.id,
      title: data['title'] ?? '',
      content: data['content'] ?? '',
      date: (data['date'] as Timestamp).toDate(),
      type: type,
      isNew: data['isNew'] ?? false,
      isImportant: data['isImportant'] ?? false,
      viewCount: data['viewCount'] ?? 0,
      category: category,
    );
  }
}
