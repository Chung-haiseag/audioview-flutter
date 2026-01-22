import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../models/notice.dart';
import '../../constants/mock_notices.dart';
import 'notice_detail_screen.dart';

class NoticeListScreen extends StatelessWidget {
  const NoticeListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Separate notices and events
    final notices =
        mockNotices.where((n) => n.type == NoticeType.notice).toList();
    final events =
        mockNotices.where((n) => n.type == NoticeType.event).toList();

    // Sort by date descending
    notices.sort((a, b) => b.date.compareTo(a.date));
    events.sort((a, b) => b.date.compareTo(a.date));

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        backgroundColor: Colors.black,
        appBar: AppBar(
          backgroundColor: Colors.black,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () => Navigator.pop(context),
          ),
          title: const Text(
            '공지사항',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          ),
          bottom: const TabBar(
            indicatorColor: Color(0xFFE50914),
            labelColor: Color(0xFFE50914),
            unselectedLabelColor: Colors.grey,
            tabs: [
              Tab(text: '공지사항'),
              Tab(text: '이벤트'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            _buildNoticeList(notices),
            _buildNoticeList(
                events), // Reusing list builder but could be customized for events
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
              const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          title: Row(
            children: [
              if (notice.isNew)
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  margin: const EdgeInsets.only(right: 8),
                  decoration: BoxDecoration(
                    color: const Color(0xFFE50914),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: const Text(
                    'N',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              Expanded(
                child: Text(
                  notice.title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          subtitle: Padding(
            padding: const EdgeInsets.only(top: 8.0),
            child: Text(
              DateFormat('yyyy.MM.dd').format(notice.date),
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 14,
              ),
            ),
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
}
