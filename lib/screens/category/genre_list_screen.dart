import 'package:flutter/material.dart';
import '../../models/genre.dart';
import '../../services/movie_service.dart';
import '../category/category_list_screen.dart';

class GenreListScreen extends StatelessWidget {
  const GenreListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: StreamBuilder<List<Genre>>(
        stream: MovieService().getGenres(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(color: Color(0xFFE50914)),
            );
          }

          if (snapshot.hasError) {
            return Center(
              child: Text(
                '장르를 불러오는 중 오류가 발생했습니다.',
                style: TextStyle(color: Colors.grey[400]),
              ),
            );
          }

          final genres = snapshot.data ?? [];

          if (genres.isEmpty) {
            return const Center(
              child: Text(
                '등록된 장르가 없습니다.',
                style: TextStyle(color: Colors.grey),
              ),
            );
          }

          return ListView.separated(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            itemCount: genres.length,
            separatorBuilder: (context, index) => Divider(
              color: Colors.grey[900],
              height: 32,
              thickness: 0.5,
            ),
            itemBuilder: (context, index) {
              final genre = genres[index];
              return ListTile(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => CategoryListScreen(genre: genre),
                    ),
                  );
                },
                contentPadding: EdgeInsets.zero,
                leading: Container(
                  width: 8,
                  height: 8,
                  decoration: const BoxDecoration(
                    color: Color(0xFFE50914),
                    shape: BoxShape.circle,
                  ),
                ),
                title: Text(
                  genre.name,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w500,
                    letterSpacing: -0.5,
                  ),
                ),
                trailing: Icon(
                  Icons.chevron_right,
                  color: Colors.grey[700],
                  size: 20,
                ),
              );
            },
          );
        },
      ),
    );
  }
}
