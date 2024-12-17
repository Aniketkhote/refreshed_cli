bool isURL(String s) {
  // Improved regex pattern for URL validation
  final pattern = r'^(https?|ftp):\/\/[^\s/$.?#].[^\s]*$';
  return _hasMatch(s, pattern);
}

bool _hasMatch(String value, String pattern) {
  return RegExp(pattern).hasMatch(value);
}
