class Category {
  final String id;
  final String name;
  final int count;
  final String imageUrl;

  Category({
    required this.id,
    required this.name,
    required this.count,
    required this.imageUrl,
  });

  factory Category.fromJson(Map<String, dynamic> json) {
    return Category(
      id: json['id'],
      name: json['name'],
      count: json['count'],
      imageUrl: json['imageUrl'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'count': count,
      'imageUrl': imageUrl,
    };
  }
}
