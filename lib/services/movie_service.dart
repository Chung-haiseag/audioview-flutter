import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/movie.dart';

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
}
