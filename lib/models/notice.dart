import 'package:cloud_firestore/cloud_firestore.dart';

enum NoticeType { notice, event }

class Notice {
  final String id;
  final String title;
  final String content;
  final DateTime date;
  final NoticeType type;
  final bool isNew;

  Notice({
    required this.id,
    required this.title,
    required this.content,
    required this.date,
    required this.type,
    this.isNew = false,
  });

  factory Notice.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return Notice(
      id: doc.id,
      title: data['title'] ?? '',
      content: data['content'] ?? '',
      date: (data['date'] as Timestamp).toDate(),
      type: data['type'] == 'event' ? NoticeType.event : NoticeType.notice,
      isNew: data['isNew'] ?? false,
    );
  }
}
