import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../models/notice.dart';
import '../../services/notice_service.dart'; // Import NoticeService
import 'notice_detail_screen.dart';
import '../../providers/auth_provider.dart';

class NoticeListScreen extends StatelessWidget {
  const NoticeListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthProvider>(context);
    final isLiteMode = auth.userData?['isVisuallyImpaired'] == true;

    if (isLiteMode) {
      return _buildLiteModeUI(context);
    }

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        backgroundColor: Colors.black,
        body: Column(
          children: [
            const TabBar(
              indicatorColor: Color(0xFFE50914),
              labelColor: Color(0xFFE50914),
              unselectedLabelColor: Colors.grey,
              tabs: [
                Tab(text: '공지사항'),
                Tab(text: '이벤트'),
              ],
            ),
            Expanded(
              child: StreamBuilder<List<Notice>>(
                stream: NoticeService().getNotices(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (snapshot.hasError) {
                    return Center(
                      child: Text(
                        '오류가 발생했습니다: ${snapshot.error}',
                        style: const TextStyle(color: Colors.white),
                      ),
                    );
                  }

                  final allNotices = snapshot.data ?? [];
                  final notices = allNotices
                      .where((n) => n.type == NoticeType.notice)
                      .toList();
                  final events = allNotices
                      .where((n) => n.type == NoticeType.event)
                      .toList();

                  return TabBarView(
                    children: [
                      _buildNoticeList(notices),
                      _buildNoticeList(events),
                    ],
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNoticeList(List<Notice> items) {
    if (items.isEmpty) {
      return const Center(
        child: Text(
          '등록된 게시물이 없습니다.',
          style: TextStyle(color: Colors.grey),
        ),
      );
    }

    return ListView.builder(
      itemCount: items.length,
      itemBuilder: (context, index) {
        final notice = items[index];
        return _buildNoticeItem(context, notice);
      },
    );
  }

  Widget _buildNoticeItem(BuildContext context, Notice notice) {
    return Column(
      children: [
        ListTile(
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          title: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 1. Importance / New Badge / Category Badge
              if (notice.isImportant)
                const Padding(
                  padding: EdgeInsets.only(right: 8.0, top: 2),
                  child: Icon(Icons.error_outline,
                      color: Color(0xFFE50914), size: 16),
                )
              else if (notice.category == '이벤트')
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  margin: const EdgeInsets.only(right: 8, top: 2),
                  decoration: BoxDecoration(
                    color: Colors.green, // Event color
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: const Text(
                    '이벤트',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                )
              else
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  margin: const EdgeInsets.only(right: 8, top: 2),
                  decoration: BoxDecoration(
                    color: Colors.grey[700], // General color
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: const Text(
                    '일반',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),

              // 2. Title
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      notice.title,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    // 3. Date and View Count
                    Row(
                      children: [
                        Text(
                          DateFormat('yyyy-MM-dd').format(notice.date),
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 14,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Icon(Icons.remove_red_eye_outlined,
                            size: 14, color: Colors.grey[600]),
                        const SizedBox(width: 4),
                        Text(
                          '${notice.viewCount}',
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => NoticeDetailScreen(notice: notice),
              ),
            );
          },
        ),
        Divider(height: 1, color: Colors.grey[800]),
      ],
    );
  }

  Widget _buildLiteModeUI(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: Colors.black,
        elevation: 0,
        title: Row(
          children: [
            TextButton(
              onPressed: () {
                if (Navigator.of(context).canPop()) {
                  Navigator.of(context).pop();
                } else {
                  Navigator.of(context)
                      .pushNamedAndRemoveUntil('/main', (route) => false);
                }
              },
              style: TextButton.styleFrom(
                foregroundColor: Colors.white,
                minimumSize: const Size(60, 48),
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: const [
                  Icon(Icons.arrow_back, size: 28),
                  SizedBox(width: 8),
                  Text(
                    "뒤로가기",
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      body: StreamBuilder<List<Notice>>(
        stream: NoticeService().getNotices(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(
              child: Text(
                '오류가 발생했습니다',
                style: const TextStyle(color: Colors.white, fontSize: 24),
              ),
            );
          }

          final allNotices = snapshot.data ?? [];

          if (allNotices.isEmpty) {
            return const Center(
              child: Text(
                '등록된 공지가 없습니다',
                style: TextStyle(color: Colors.grey, fontSize: 24),
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.symmetric(vertical: 20),
            itemCount: allNotices.length,
            itemBuilder: (context, index) {
              final notice = allNotices[index];
              return _buildLiteModeNoticeItem(context, notice);
            },
          );
        },
      ),
    );
  }

  Widget _buildLiteModeNoticeItem(BuildContext context, Notice notice) {
    return Semantics(
      label:
          "${notice.title}, ${DateFormat('yyyy년 MM월 dd일').format(notice.date)}",
      button: true,
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => NoticeDetailScreen(notice: notice),
            ),
          );
        },
        child: Container(
          width: double.infinity,
          constraints: const BoxConstraints(minHeight: 80),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
          decoration: const BoxDecoration(
            border: Border(
              bottom: BorderSide(color: Colors.grey, width: 0.5),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                notice.title,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                DateFormat('yyyy-MM-dd').format(notice.date),
                style: const TextStyle(
                  color: Colors.grey,
                  fontSize: 20,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
