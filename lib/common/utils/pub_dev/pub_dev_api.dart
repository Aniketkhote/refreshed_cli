import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart';
import 'package:refreshed_cli/common/utils/logger/log_utils.dart';
import 'package:refreshed_cli/core/internationalization.dart';
import 'package:refreshed_cli/core/locales.g.dart';

class PubDevApi {
  static Future<String?> getLatestVersionFromPackage(String package) async {
    final languageCode = Platform.localeName.split('_')[0];
    final pubSite = languageCode == 'zh'
        ? 'https://pub.flutter-io.cn/api/packages/$package'
        : 'https://pub.dev/api/packages/$package';
    var uri = Uri.parse(pubSite);

    try {
      var response = await get(uri);

      // Handle different HTTP status codes
      if (response.statusCode == 200) {
        final version =
            json.decode(response.body)['latest']['version'] as String?;
        if (version != null) {
          return version;
        } else {
          _logError(LocaleKeys.error_package_not_found.trArgs([package]));
        }
      } else if (response.statusCode == 404) {
        _logPackageNotFound(package);
      } else {
        _logError('Unexpected status code: ${response.statusCode}');
      }
    } on Exception catch (err) {
      _logError('Exception occurred: $err');
    }
    return null;
  }

  // Helper method for logging package not found
  static void _logPackageNotFound(String package) {
    LogService.info(
      LocaleKeys.error_package_not_found.trArgs([package]),
      false,
      false,
    );
  }

  // Helper method for logging errors
  static void _logError(String message) {
    LogService.error(message);
  }
}
