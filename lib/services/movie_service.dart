import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/movie.dart';
import '../models/genre.dart';

class MovieService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Fetch "New" movies (isLatest or is_latest)
  // Screenshot shows 'isLatest', 'isPopular' in camelCase
  Stream<List<Movie>> getNewMovies() {
    return _firestore
        .collection('movies')
        .where('isLatest', isEqualTo: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) => Movie.fromFirestore(doc)).toList();
    });
  }

  // Fetch "Popular" movies (isPopular or is_popular)
  Stream<List<Movie>> getPopularMovies() {
    return _firestore
        .collection('movies')
        .where('isPopular', isEqualTo: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) => Movie.fromFirestore(doc)).toList();
    });
  }

  // Search movies by title (prefix search)
  Future<List<Movie>> searchMovies(String query) async {
    if (query.isEmpty) return [];

    // Simple prefix search: title >= query AND title <= query + '\uf8ff'
    // Note: Firestore is case sensitive. Ideally, store a lowercase search field.
    // For now, we assume titles are stored as regular case and this basic search works strictly.
    // Or better, do a client-side filter if dataset is small, but let's try Firestore query first.
    // Actually, effective search usually requires a dedicated search service (Algolia/Typesense).
    // Let's implement client-side filtering over "New" or "All" for simplicity if dataset is small?
    // No, let's try the Firestore prefix query on 'title'.

    try {
      final snapshot = await _firestore
          .collection('movies')
          .orderBy('title')
          .startAt([query]).endAt([query + '\uf8ff']).get();

      return snapshot.docs.map((doc) => Movie.fromFirestore(doc)).toList();
    } catch (e) {
      print('Search error: $e');
      return [];
    }
  }

  // Fetch movies by genre (Client-side filtering for robustness)
  Stream<List<Movie>> getMoviesByGenre(String genre) {
    return _firestore.collection('movies').snapshots().map((snapshot) {
      final allMovies =
          snapshot.docs.map((doc) => Movie.fromFirestore(doc)).toList();

      return allMovies.where((movie) {
        // Check exact match, case-insensitive, or trimmed match
        return movie.genres.any((g) => g.trim() == genre.trim());
      }).toList();
    });
  }

  // Fetch all genres from 'genres' collection
  Stream<List<Genre>> getGenres() {
    return _firestore.collection('genres').snapshots().map((snapshot) {
      return snapshot.docs.map((doc) => Genre.fromFirestore(doc)).toList();
    });
  }
}
