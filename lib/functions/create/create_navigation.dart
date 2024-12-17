import 'dart:convert';
import 'dart:io';

import 'package:recase/recase.dart';
import 'package:refreshed_cli/common/utils/logger/log_utils.dart';
import 'package:refreshed_cli/core/internationalization.dart';
import 'package:refreshed_cli/core/locales.g.dart';
import 'package:refreshed_cli/core/structure.dart';
import 'package:refreshed_cli/functions/create/create_single_file.dart';
import 'package:refreshed_cli/functions/formatter_dart_file/frommatter_dart_file.dart';
import 'package:refreshed_cli/samples/impl/arctekko/arc_navigation.dart';

void createNavigation() {
  ArcNavigationSample().create(skipFormatter: true);
}

void addNavigation(String name) {
  var navigationFile = File(Structure.replaceAsExpected(
      path: 'lib/infrastructure/navigation/navigation.dart'));

  if (!navigationFile.existsSync()) {
    createNavigation();
  }

  List<String> lines = _getFileLines(navigationFile);

  var indexStartNavClass = _findIndexOfNavClass(lines);
  var index = _findIndexOfRouteEnd(lines, indexStartNavClass);

  // Insert the new route at the appropriate position
  lines.insert(index, _generateNewRoute(name));

  // Write the updated content back to the file
  writeFile(navigationFile.path, lines.join('\n'),
      overwrite: true, logger: true);

  LogService.success(Translation(
      LocaleKeys.sucess_navigation_added.trArgs([name.pascalCase])));
}

List<String> _getFileLines(File file) {
  var content = formatterDartFile(file.readAsStringSync());
  return LineSplitter.split(content).toList();
}

int _findIndexOfNavClass(List<String> lines) {
  return lines.indexWhere((line) => line.contains('class Nav'));
}

int _findIndexOfRouteEnd(List<String> lines, int indexStartNavClass) {
  return lines.indexWhere(
      (element) => element.contains('];'), indexStartNavClass);
}

String _generateNewRoute(String name) {
  return '''    GetPage(
      name: Routes.${name.snakeCase.toUpperCase()},
      page: () => const ${name.pascalCase}Screen(),
      binding: ${name.pascalCase}ControllerBinding(),
    ),''';
}
