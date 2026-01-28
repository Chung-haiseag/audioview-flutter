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

  // Search movies by title, director, or actors
  Future<List<Movie>> searchMovies(String query) async {
    if (query.isEmpty) return [];

    try {
      // Step 1: Query by title
      final titleSnapshot = await _firestore
          .collection('movies')
          .orderBy('title')
          .startAt([query])
          .endAt(['$query\uf8ff'])
          .limit(20)
          .get();

      // Step 2: Query by director
      final directorSnapshot = await _firestore
          .collection('movies')
          .orderBy('director')
          .startAt([query])
          .endAt(['$query\uf8ff'])
          .limit(20)
          .get();

      // Step 3: Combine and deduplicate
      Map<String, Movie> resultsMap = {};

      for (var doc in titleSnapshot.docs) {
        resultsMap[doc.id] = Movie.fromFirestore(doc);
      }

      for (var doc in directorSnapshot.docs) {
        resultsMap[doc.id] = Movie.fromFirestore(doc);
      }

      // Step 4: Actor search (Actor is a list, so we might need a different approach or fetch more)
      // Since Firestore doesn't support 'array-contains' with prefix,
      // for now we'll do an exact match or fetch all and filter client-side if needed.
      // Alternatively, check matching in actors field if those docs were already fetched.

      // Let's add a separate query for exact actor match if possible,
      // or just filter the rest of the docs.
      final actorSnapshot = await _firestore
          .collection('movies')
          .where('actors', arrayContains: query)
          .limit(20)
          .get();

      for (var doc in actorSnapshot.docs) {
        resultsMap[doc.id] = Movie.fromFirestore(doc);
      }

      return resultsMap.values.toList();
    } catch (e) {
      // print('Search error: $e');
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
