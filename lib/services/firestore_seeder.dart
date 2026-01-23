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
        'release_date': DateTime(movie.year, 1, 1), // Approx date
        'country': movie.country,
        'running_time': movie.duration,
        'genres': movie.genres,
        'synopsis': '영화 설명이 여기에 들어갑니다. (${movie.title})',
        'poster_url': movie.posterUrl,
        'has_audio_commentary': movie.hasAD,
        'has_closed_caption': movie.hasCC,
        'noticeType': 'general', // Default
        'is_latest': movie.year >= 2025, // Logic for "New"
        'is_popular': movie.year < 2025, // Logic for "Popular" for testing
        'viewCount': 0,
        'createdAt': FieldValue.serverTimestamp(),
      });
      print('Uploaded movie: ${movie.title}');
    }
  }
}
