import 'package:cloud_firestore/cloud_firestore.dart';
import '../utils/type_parser.dart';

class FeaturedList {
  final String listId;
  final String title;
  final String? type; // [TOP10], [NEW], etc.
  final int displayOrder;
  final bool isActive;
  final DateTime? createdAt;

  FeaturedList({
    required this.listId,
    required this.title,
    this.type,
    required this.displayOrder,
    required this.isActive,
    this.createdAt,
  });

  factory FeaturedList.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return FeaturedList(
      listId: doc.id,
      title: data['listName'] ?? '',
      type: data['type'],
      displayOrder: TypeParser.parseInt(data['displayOrder']),
      isActive: data['isActive'] ?? true,
      createdAt: (data['createdAt'] as Timestamp?)?.toDate(),
    );
  }
}

class FeaturedMovieLink {
  final String featuredId;
  final String listId;
  final String movieId;
  final int displayOrder;

  FeaturedMovieLink({
    required this.featuredId,
    required this.listId,
    required this.movieId,
    required this.displayOrder,
  });

  factory FeaturedMovieLink.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return FeaturedMovieLink(
      featuredId: doc.id,
      listId: data['listId'] ?? '',
      movieId: data['movieId'] ?? '',
      displayOrder: TypeParser.parseInt(data['displayOrder']),
    );
  }
}
