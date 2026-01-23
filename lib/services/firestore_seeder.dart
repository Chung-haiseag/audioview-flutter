import 'package:cloud_firestore/cloud_firestore.dart';
import '../constants/mock_data.dart';
// import '../models/movie.dart'; // Not directly used if type inference works, or keep if needed

class FirestoreSeeder {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> seedMovies() async {
    final CollectionReference moviesRef = _firestore.collection('movies');

    // 1. Check if legacy data exists (optional, safely skipped)

    // 2. Upload mock movies
    for (var movie in mockMovies) {
      // Create a document with a specific ID if provided, or auto-id
      // Using movie.id as doc ID for consistency
      await moviesRef.doc(movie.id).set({
        'title': movie.title,
        'releaseDate': DateTime(movie.year, 1, 1), // Approx date
        'country': movie.country,
        'runningTime': movie.duration,
        'genres': movie.genres,
        'synopsis': '영화 설명이 여기에 들어갑니다. (${movie.title})',
        'posterUrl': movie.posterUrl,
        'hasAudioCommentary': movie.hasAD,
        'hasClosedCaption': movie.hasCC,
        'noticeType': 'general',
        'isLatest': movie.year >= 2025,
        'isPopular': movie.year < 2025,
        'viewCount': 0,
        'createdAt': FieldValue.serverTimestamp(),
      });
      print('Uploaded movie: ${movie.title}');
    }
  }
}
