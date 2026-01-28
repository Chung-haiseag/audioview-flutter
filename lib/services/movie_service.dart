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

  // Search movies by keywords (title, director, actors, etc.) using searchKeywords field
  Future<List<Movie>> searchMovies(String query) async {
    if (query.isEmpty) return [];

    try {
      // 1. Array contains (Exact keyword match from searchKeywords list)
      final snapshot = await _firestore
          .collection('movies')
          .where('searchKeywords', arrayContains: query)
          .limit(20)
          .get();

      if (snapshot.docs.isNotEmpty) {
        return snapshot.docs.map((doc) => Movie.fromFirestore(doc)).toList();
      }

      // 2. Prefix search fallback on title for partial matches (better UX for typing)
      final titleSnapshot = await _firestore
          .collection('movies')
          .orderBy('title')
          .startAt([query])
          .endAt(['$query\uf8ff'])
          .limit(10)
          .get();

      return titleSnapshot.docs.map((doc) => Movie.fromFirestore(doc)).toList();
    } catch (e) {
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

  // Fetch a single movie by ID
  Future<Movie?> getMovieById(String movieId) async {
    final doc = await _firestore.collection('movies').doc(movieId).get();
    if (doc.exists) {
      return Movie.fromFirestore(doc);
    }
    return null;
  }
}
