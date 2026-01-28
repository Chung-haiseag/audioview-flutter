import 'package:cloud_firestore/cloud_firestore.dart';
import '../utils/type_parser.dart';

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
  final String? director;
  final List<String> actors;
  final List<String> searchKeywords;

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
    this.director,
    this.actors = const [],
    this.searchKeywords = const [],
  });

  factory Movie.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;

    // Parse year from release_date (Timestamp, String date, or String year)
    int parseYear(dynamic dateVal) {
      if (dateVal is Timestamp) return dateVal.toDate().year;
      if (dateVal is int) return dateVal;
      if (dateVal is String) {
        // Try parsing assuming full date string
        try {
          return DateTime.parse(dateVal).year;
        } catch (_) {}
        // Try parsing just the year integer
        return TypeParser.parseInt(dateVal);
      }
      return 2024; // Default
    }

    return Movie(
      id: doc.id,
      title: data['title'] ?? '',
      year: parseYear(data['releaseDate'] ?? data['release_date']),
      country: data['country'] ?? '한국',
      duration:
          TypeParser.parseInt(data['runningTime'] ?? data['running_time']),
      genres: _parseGenres(data),
      description: data['synopsis'] ?? '',
      posterUrl: data['posterUrl'] ?? data['poster_url'] ?? '',
      // Support camelCase (actual DB) and snake_case (reference)
      hasAD:
          data['hasAudioCommentary'] ?? data['has_audio_commentary'] ?? false,
      hasCC: data['hasClosedCaption'] ?? data['has_closed_caption'] ?? false,
      hasMultiLang: false,
      director: data['director'] ?? '',
      actors: data['actors'] is List ? List<String>.from(data['actors']) : [],
      searchKeywords: data['searchKeywords'] is List
          ? List<String>.from(data['searchKeywords'])
          : [],
    );
  }

  static List<String> _parseGenres(Map<String, dynamic> data) {
    if (data['genres'] is List) {
      return List<String>.from(data['genres']);
    }
    if (data['genre'] is String) {
      return [data['genre']];
    }
    if (data['category'] is String) {
      return [data['category']];
    }
    if (data['genreId'] is String) {
      // If we only have ID, we might store it, but for UI display we usually need name.
      // But for filtering, having the ID in this list helps.
      return [data['genreId']];
    }
    return [];
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
      'director': director,
      'actors': actors,
      'searchKeywords': searchKeywords,
    };
  }
}
