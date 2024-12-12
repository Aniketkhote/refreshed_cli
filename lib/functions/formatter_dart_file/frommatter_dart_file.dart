import 'package:dart_style/dart_style.dart';

/// Format a dart file
String formatterDartFile(String content) {
  var formatter =
      DartFormatter(languageVersion: DartFormatter.latestLanguageVersion);
  return formatter.format(content);
}
