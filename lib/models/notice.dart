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
}
