import 'dart:io';

import 'package:path/path.dart';
import 'package:refreshed_cli/common/utils/logger/log_utils.dart';
import 'package:refreshed_cli/common/utils/pubspec/pubspec_utils.dart';
import 'package:refreshed_cli/core/internationalization.dart';
import 'package:refreshed_cli/core/locales.g.dart';
import 'package:refreshed_cli/core/structure.dart';
import 'package:refreshed_cli/functions/sorter_imports/sort.dart';
import 'package:refreshed_cli/samples/interface/sample_interface.dart';

File handleFileCreate(String name, String command, String on, bool extraFolder,
    Sample sample, String folderName,
    [String sep = '_']) {
  final fileModel = Structure.model(name, command, extraFolder,
      on: on, folderName: folderName);
  var path = '${fileModel.path}$sep${fileModel.commandName}.dart';
  sample.path = path;
  return sample.create();
}

/// Create or edit the contents of a file
File writeFile(
  String path,
  String content, {
  bool overwrite = false,
  bool skipFormatter = false,
  bool logger = true,
  bool skipRename = false,
  bool useRelativeImport = false,
}) {
  var newFile = File(Structure.replaceAsExpected(path: path));

  // Only create or overwrite if the file doesn't exist or overwrite is true
  if (!newFile.existsSync() || overwrite) {
    // Format content if necessary
    if (!skipFormatter && path.endsWith('.dart')) {
      try {
        content = sortImports(
          content,
          renameImport: !skipRename,
          filePath: path,
          useRelative: useRelativeImport,
        );
      } catch (e) {
        if (newFile.existsSync()) {
          LogService.info(LocaleKeys.error_invalid_dart.trArgs([newFile.path]));
        }
        rethrow;
      }
    }

    // Rename file if needed
    if (!skipRename && newFile.path != 'pubspec.yaml') {
      var separatorFileType = PubspecUtils.separatorFileType ?? '';
      if (separatorFileType.isNotEmpty) {
        newFile = _renameFileIfNecessary(newFile, path, separatorFileType);
      }
    }

    // Create file and write content
    newFile.createSync(recursive: true);
    newFile.writeAsStringSync(content);

    // Log success
    if (logger) {
      LogService.success(
        LocaleKeys.sucess_file_created
            .trArgs([basename(newFile.path), newFile.path]),
      );
    }
  }
  return newFile;
}

// Helper function for renaming the file
File _renameFileIfNecessary(
    File newFile, String path, String separatorFileType) {
  if (newFile.existsSync()) {
    newFile =
        newFile.renameSync(replacePathTypeSeparator(path, separatorFileType));
  } else {
    newFile = File(replacePathTypeSeparator(path, separatorFileType));
  }
  return newFile;
}

/// Replace the file name separator
String replacePathTypeSeparator(String path, String separator) {
  if (separator.isEmpty) return path;

  final dartFileTypes = {
    'controller.dart',
    'model.dart',
    'provider.dart',
    'binding.dart',
    'view.dart',
    'screen.dart',
    'widget.dart',
    'repository.dart'
  };

  var index = dartFileTypes.firstWhere(
    (type) => path.contains(type),
    orElse: () => '',
  );

  if (index.isNotEmpty) {
    var chars = path.split('');
    var targetIndex = path.indexOf(index);
    if (targetIndex != -1) {
      chars[targetIndex] = separator;
    }
    return chars.join();
  }

  return path;
}
