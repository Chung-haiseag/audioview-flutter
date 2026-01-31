class TypeParser {
  /// Safely parses an integer from dynamic value.
  /// Handles int, String (including those with non-digit characters), and null.
  static int parseInt(dynamic value) {
    if (value == null) return 0;
    if (value is num) {
      if (value.isNaN || value.isInfinite) return 0;
      return value.toInt();
    }
    if (value is String) {
      if (value.isEmpty) return 0;
      // Remove non-digit characters (e.g., "100분" -> "100")
      final cleanStr = value.replaceAll(RegExp(r'[^0-9]'), '');
      if (cleanStr.isEmpty) return 0;
      return int.tryParse(cleanStr) ?? 0;
    }
    return 0;
  }
}
