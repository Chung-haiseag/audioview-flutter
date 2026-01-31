import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/movie.dart';
import '../models/genre.dart';
import '../models/featured_list.dart';

class MovieService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Cache for home screen lists
  List<Movie>? _newMoviesCache;
  List<Movie>? _popularMoviesCache;
  List<Genre>? _genresCache;

  // New: Fetch Featured Lists (Special Lists)
  Stream<List<FeaturedList>> getFeaturedLists() {
    return _firestore
        .collection('featured_lists')
        .where('isActive', isEqualTo: true)
        .orderBy('displayOrder', descending: false)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => FeaturedList.fromFirestore(doc))
          .toList();
    });
  }

  // New: Fetch movies in a specific Featured List
  Stream<List<Movie>> getMoviesByFeaturedList(String listId) {
    return _firestore
        .collection('featured_movies')
        .where('listId', isEqualTo: listId)
        .orderBy('displayOrder', descending: false)
        .snapshots()
        .asyncMap((snapshot) async {
      final movieIds =
          snapshot.docs.map((doc) => doc.data()['movieId'] as String).toList();

      if (movieIds.isEmpty) return [];

      // Fetch actual movie documents for these IDs
      // Firestore 'in' query supports up to 10 IDs. If more, we'd need batching.
      // Usually TOP10 is exactly 10, so it's fine.
      final moviesSnapshot = await _firestore
          .collection('movies')
          .where(FieldPath.documentId, whereIn: movieIds)
          .get();

      final moviesMap = {
        for (var doc in moviesSnapshot.docs) doc.id: Movie.fromFirestore(doc)
      };

      // Return movies in the original display order of the featured_movies collection
      return movieIds
          .where((id) => moviesMap.containsKey(id))
          .map((id) => moviesMap[id]!)
          .toList();
    });
  }

  // Fetch "New" movies (isLatest or is_latest)
  Stream<List<Movie>> getNewMovies() {
    if (_newMoviesCache != null) {
      return Stream.value(_newMoviesCache!);
    }
    return _firestore
        .collection('movies')
        .where('isLatest', isEqualTo: true)
        .limit(20)
        .snapshots()
        .map((snapshot) {
      final movies =
          snapshot.docs.map((doc) => Movie.fromFirestore(doc)).toList();
      _newMoviesCache = movies;
      return movies;
    });
  }

  // Fetch "Popular" movies (isPopular or is_popular)
  Stream<List<Movie>> getPopularMovies() {
    if (_popularMoviesCache != null) {
      return Stream.value(_popularMoviesCache!);
    }
    return _firestore
        .collection('movies')
        .where('isPopular', isEqualTo: true)
        .limit(20)
        .snapshots()
        .map((snapshot) {
      final movies =
          snapshot.docs.map((doc) => Movie.fromFirestore(doc)).toList();
      _popularMoviesCache = movies;
      return movies;
    });
  }

  List<Movie>? _cachedMovies;

  // Search movies by keywords (title, director, actors, etc.)
  Future<List<Movie>> searchMovies(String query) async {
    if (query.isEmpty) return [];

    try {
      // 1. Load all movies if not cached (for client-side partial filtering)
      if (_cachedMovies == null) {
        final snapshot = await _firestore.collection('movies').get();
        _cachedMovies =
            snapshot.docs.map((doc) => Movie.fromFirestore(doc)).toList();
      }

      final lowercaseQuery = query.toLowerCase();

      // 2. Perform partial match filtering (Substring search)
      return _cachedMovies!.where((movie) {
        final titleMatch = movie.title.toLowerCase().contains(lowercaseQuery);
        final directorMatch =
            movie.director?.toLowerCase().contains(lowercaseQuery) ?? false;
        final actorMatch = movie.actors
            .any((actor) => actor.toLowerCase().contains(lowercaseQuery));
        final keywordMatch = movie.searchKeywords
            .any((keyword) => keyword.toLowerCase().contains(lowercaseQuery));

        return titleMatch || directorMatch || actorMatch || keywordMatch;
      }).toList();
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
    if (_genresCache != null) {
      return Stream.value(_genresCache!);
    }
    return _firestore.collection('genres').snapshots().map((snapshot) {
      final genres =
          snapshot.docs.map((doc) => Genre.fromFirestore(doc)).toList();
      _genresCache = genres;
      return genres;
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
