import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../models/notice.dart';
import '../../services/movie_service.dart';
import '../movie/movie_detail_screen.dart';

class NoticeDetailScreen extends StatelessWidget {
  final Notice notice;

  const NoticeDetailScreen({super.key, required this.notice});

  void _navigateToMovie(BuildContext context) async {
    if (notice.movieId == null) return;

    // Show loading indicator
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(child: CircularProgressIndicator()),
    );

    try {
      final movie = await MovieService().getMovieById(notice.movieId!);
      if (context.mounted) {
        Navigator.pop(context); // Remove loading
        if (movie != null) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => MovieDetailScreen(movie: movie),
            ),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('영화를 찾을 수 없습니다.')),
          );
        }
      }
    } catch (e) {
      if (context.mounted) {
        Navigator.pop(context); // Remove loading
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('데이터를 불러오는 중 오류가 발생했습니다.')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          notice.type == NoticeType.event ? '이벤트' : '공지사항',
          style:
              const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              notice.title,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              DateFormat('yyyy.MM.dd').format(notice.date),
              style: TextStyle(
                color: Colors.grey[500],
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 24),
            Divider(color: Colors.grey[800]),
            const SizedBox(height: 24),
            Text(
              notice.content,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 16,
                height: 1.6,
              ),
            ),
            // --- DEBUG START ---
            Padding(
              padding: const EdgeInsets.only(top: 8.0),
              child: Text(
                'Debug ID: [${notice.movieId}]',
                style: const TextStyle(color: Colors.grey, fontSize: 10),
              ),
            ),
            // --- DEBUG END ---
            if (notice.movieId != null && notice.movieId!.isNotEmpty) ...[
              const SizedBox(height: 48),
              Center(
                child: ElevatedButton.icon(
                  onPressed: () => _navigateToMovie(context),
                  icon: const Icon(Icons.movie_outlined, color: Colors.white),
                  label: const Text(
                    '관련 영화 보러가기',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFE50914), // Netflix Red
                    padding: const EdgeInsets.symmetric(
                        horizontal: 32, vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    elevation: 4,
                  ),
                ),
              ),
              const SizedBox(height: 24),
            ],
          ],
        ),
      ),
    );
  }
}
