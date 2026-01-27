import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/movie.dart';
import '../models/genre.dart';

class MovieService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Fetch "New" movies (isLatest or is_latest)
  Stream<List<Movie>> getNewMovies() {
    return _firestore
        .collection('movies')
        .where('isLatest', isEqualTo: true)
        .limit(20)
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
        .limit(20)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) => Movie.fromFirestore(doc)).toList();
    });
  }

  // Search movies by title (prefix search)
  Future<List<Movie>> searchMovies(String query) async {
    if (query.isEmpty) return [];

    try {
      final snapshot = await _firestore
          .collection('movies')
          .orderBy('title')
          .startAt([query])
          .endAt(['$query\uf8ff'])
          .limit(20)
          .get();

      return snapshot.docs.map((doc) => Movie.fromFirestore(doc)).toList();
    } catch (e) {
      print('Search error: $e');
      return [];
    }
  }

  // Fetch movies by genre (Server-side filtering)
  Stream<List<Movie>> getMoviesByGenre(Genre genre) {
    // Requires an index on 'genreId' if combined with other orderBys,
    // but simple equality where usually works without composite index.
    return _firestore
        .collection('movies')
        .where('genreId', isEqualTo: genre.id)
        .limit(20)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) => Movie.fromFirestore(doc)).toList();
    });
  }

  // Fetch all genres from 'genres' collection
  Stream<List<Genre>> getGenres() {
    return _firestore.collection('genres').snapshots().map((snapshot) {
      return snapshot.docs.map((doc) => Genre.fromFirestore(doc)).toList();
    });
  }
}
