import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/movie.dart';

class MovieService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Fetch "New" movies (is_latest = true)
  Stream<List<Movie>> getNewMovies() {
    return _firestore
        .collection('movies')
        .where('is_latest', isEqualTo: true)
        // .orderBy('release_date', descending: true) // Requires index, use if available
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) => Movie.fromFirestore(doc)).toList();
    });
  }

  // Fetch "Popular" movies (is_popular = true)
  Stream<List<Movie>> getPopularMovies() {
    return _firestore
        .collection('movies')
        .where('is_popular', isEqualTo: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) => Movie.fromFirestore(doc)).toList();
    });
  }
}
