import 'dart:convert';

import 'package:refreshed_cli/common/utils/pubspec/pubspec_utils.dart';
import 'package:refreshed_cli/extensions.dart';
import 'package:refreshed_cli/functions/create/create_single_file.dart';
import 'package:refreshed_cli/functions/formatter_dart_file/frommatter_dart_file.dart';
import 'package:refreshed_cli/functions/path/replace_to_relative.dart';

const dartImportPrefix = 'dart:';
const flutterImportPrefix = 'package:flutter/';
const projectImportPrefix = 'package:';

String sortImports(
  String content, {
  String? packageName,
  bool renameImport = false,
  String filePath = '',
  bool useRelative = false,
}) {
  packageName = packageName ?? PubspecUtils.projectName;
  content = formatterDartFile(content);
  var lines = LineSplitter.split(content).toList();

  var contentLines = <String>[];

  var dartImports = <String>[];
  var flutterImports = <String>[];
  var packageImports = <String>[];
  var projectImports = <String>[];
  var projectRelativeImports = <String>[];
  var exports = <String>[];
  var librarys = <String>[];

  var stringLine = false;
  for (var i = 0; i < lines.length; i++) {
    if (lines[i].startsWith('import ') &&
        !stringLine &&
        lines[i].endsWith(';')) {
      if (lines[i].startsWith(dartImportPrefix)) {
        dartImports.add(lines[i]);
      } else if (lines[i].startsWith(flutterImportPrefix)) {
        flutterImports.add(lines[i]);
      } else if (lines[i].startsWith('package:$packageName/')) {
        projectImports.add(lines[i]);
      } else if (!lines[i].contains('package:')) {
        projectRelativeImports.add(lines[i]);
      } else {
        packageImports.add(lines[i]);
      }
    } else if (lines[i].startsWith('export ') &&
        lines[i].endsWith(';') &&
        !stringLine) {
      exports.add(lines[i]);
    } else if (lines[i].startsWith('library ') &&
        lines[i].endsWith(';') &&
        !stringLine) {
      librarys.add(lines[i]);
    } else {
      if (lines[i].contains("'''")) {
        stringLine = !stringLine;
      }
      contentLines.add(lines[i]);
    }
  }

  if (dartImports.isEmpty &&
      flutterImports.isEmpty &&
      packageImports.isEmpty &&
      projectImports.isEmpty &&
      projectRelativeImports.isEmpty &&
      exports.isEmpty) {
    return content;
  }

  if (renameImport) {
    projectImports.replaceAll(_replacePath);
    projectRelativeImports.replaceAll(_replacePath);
  }

  if (filePath.isNotEmpty && useRelative) {
    projectImports
        .replaceAll((element) => replaceToRelativeImport(element, filePath));
    projectRelativeImports.addAll(projectImports);
    projectImports.clear();
  }

  // Sort imports
  _sortImportsList(dartImports);
  _sortImportsList(flutterImports);
  _sortImportsList(packageImports);
  _sortImportsList(projectImports);
  _sortImportsList(projectRelativeImports);
  _sortImportsList(exports);
  _sortImportsList(librarys);

  var sortedLines = <String>[
    ...librarys,
    '',
    ...dartImports,
    '',
    ...flutterImports,
    '',
    ...packageImports,
    '',
    ...projectImports,
    '',
    ...projectRelativeImports,
    '',
    ...exports,
    '',
    ...contentLines
  ];

  return formatterDartFile(sortedLines.join('\n'));
}

void _sortImportsList(List<String> imports) {
  imports.sort();
}

String _replacePath(String str) {
  var separator = PubspecUtils.separatorFileType!;
  return replacePathTypeSeparator(str, separator);
}
