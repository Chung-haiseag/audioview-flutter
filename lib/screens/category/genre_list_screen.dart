import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/genre.dart';
import '../../services/movie_service.dart';
import '../category/category_list_screen.dart';
import '../../providers/auth_provider.dart';

class GenreListScreen extends StatelessWidget {
  const GenreListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthProvider>(context);
    final isLiteMode = auth.userData?['isVisuallyImpaired'] == true;

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: isLiteMode ? _buildLiteModeAppBar(context) : null,
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
                style: TextStyle(
                  color: Colors.grey[400],
                  fontSize: isLiteMode ? 24 : 16,
                ),
              ),
            );
          }

          final genres = snapshot.data ?? [];

          if (genres.isEmpty) {
            return Center(
              child: Text(
                '등록된 장르가 없습니다.',
                style: TextStyle(
                  color: Colors.grey,
                  fontSize: isLiteMode ? 24 : 16,
                ),
              ),
            );
          }

          if (isLiteMode) {
            return _buildLiteModeList(context, genres);
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

  AppBar _buildLiteModeAppBar(BuildContext context) {
    return AppBar(
      automaticallyImplyLeading: false,
      backgroundColor: Colors.black,
      elevation: 0,
      title: Row(
        children: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            style: TextButton.styleFrom(
              foregroundColor: Colors.white,
              minimumSize: const Size(60, 48),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
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
    );
  }

  Widget _buildLiteModeList(BuildContext context, List<Genre> genres) {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(vertical: 20),
      itemCount: genres.length,
      itemBuilder: (context, index) {
        final genre = genres[index];
        return Semantics(
          label: genre.name,
          button: true,
          child: InkWell(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => CategoryListScreen(genre: genre),
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
              child: Text(
                genre.name,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
