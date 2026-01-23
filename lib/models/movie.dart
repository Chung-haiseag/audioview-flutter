import 'package:cloud_firestore/cloud_firestore.dart';

class Movie {
  final String id;
  final String title;
  final int year;
  final String country;
  final int duration; // minutes
  final List<String> genres;
  final String? description;
  final String posterUrl;
  final bool hasAD; // Audio Description
  final bool hasCC; // Closed Caption
  final bool hasMultiLang; // Multi-language subtitles

  Movie({
    required this.id,
    required this.title,
    required this.year,
    required this.country,
    required this.duration,
    required this.genres,
    this.description,
    required this.posterUrl,
    required this.hasAD,
    required this.hasCC,
    required this.hasMultiLang,
  });

  factory Movie.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;

    // Parse year from release_date (Timestamp or String)
    int parseYear(dynamic dateVal) {
      if (dateVal is Timestamp) return dateVal.toDate().year;
      if (dateVal is String) {
        try {
          return DateTime.parse(dateVal).year;
        } catch (_) {}
      }
      return 2024; // Default
    }

    return Movie(
      id: doc.id,
      title: data['title'] ?? '',
      year: parseYear(data['release_date']),
      country: data['country'] ?? '한국', // Default if not provided
      duration: data['running_time'] ?? 0,
      genres: List<String>.from(data['genres'] ?? []),
      description: data['synopsis'] ?? '',
      posterUrl: data['poster_url'] ?? '',
      hasAD: data['has_audio_commentary'] ?? false,
      hasCC: data['has_closed_caption'] ?? false,
      hasMultiLang: false, // Not in schema, default false
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'year': year,
      'country': country,
      'duration': duration,
      'genres': genres,
      'description': description,
      'posterUrl': posterUrl,
      'hasAD': hasAD,
      'hasCC': hasCC,
      'hasMultiLang': hasMultiLang,
    };
  }
}
