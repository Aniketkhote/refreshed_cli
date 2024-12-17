import 'dart:io';

import 'package:path/path.dart';
import 'package:refreshed_cli/common/utils/logger/log_utils.dart';
import 'package:refreshed_cli/core/internationalization.dart';
import 'package:refreshed_cli/core/locales.g.dart';
import 'package:refreshed_cli/functions/version/check_dev_version.dart';
import 'package:yaml/yaml.dart';

class PubspecLock {
  static Future<String?> getVersionCli({bool disableLog = false}) async {
    try {
      var scriptFile = Platform.script.toFilePath();
      var pathToPubLock = join(dirname(scriptFile), '../pubspec.lock');
      final file = File(pathToPubLock);
      var text = loadYaml(await file.readAsString());
      if (text['packages']['refreshed_cli'] == null) {
        if (isDevVersion()) {
          if (!disableLog) {
            LogService.info('Development version');
          }
        }
        return null;
      }
      var version = text['packages']['refreshed_cli']['version'].toString();
      return version;
    } on Exception catch (_) {
      if (!disableLog) {
        LogService.error(
            Translation(LocaleKeys.error_cli_version_not_found).tr);
      }
      return null;
    }
  }
}
