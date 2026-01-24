import 'package:cloud_firestore/cloud_firestore.dart';

class Genre {
  final String id;
  final String name;

  Genre({
    required this.id,
    required this.name,
  });

  factory Genre.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return Genre(
      id: doc.id,
      name: data['genreName'] ?? '',
    );
  }
}
