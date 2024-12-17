import 'dart:io';

import 'package:process_run/shell_run.dart';
import 'package:refreshed_cli/common/utils/logger/log_utils.dart';
import 'package:refreshed_cli/common/utils/pub_dev/pub_dev_api.dart';
import 'package:refreshed_cli/common/utils/pubspec/pubspec_lock.dart';
import 'package:refreshed_cli/core/generator.dart';
import 'package:refreshed_cli/core/internationalization.dart';
import 'package:refreshed_cli/core/locales.g.dart';

class ShellUtils {
  static Future<void> pubGet() async {
    LogService.info('Running `flutter pub get` …');
    await run('dart pub get', verbose: true);
  }

  static Future<void> addPackage(String package) async {
    LogService.info('Adding package $package …');
    await run('dart pub add $package', verbose: true);
  }

  static Future<void> removePackage(String package) async {
    LogService.info('Removing package $package …');
    await run('dart pub remove $package', verbose: true);
  }

  static Future<void> flutterCreate(
    String path,
    String? org,
    String iosLang,
    String androidLang,
  ) async {
    LogService.info('Running `flutter create $path`');

    await run(
      'flutter create --no-pub -i $iosLang -a $androidLang --org $org'
      ' "$path"',
      verbose: true,
    );
  }

  static Future<void> update(
      [bool isGit = false, bool forceUpdate = false]) async {
    isGit = GetCli.arguments.contains('--git');
    forceUpdate = GetCli.arguments.contains('-f');
    if (!isGit && !forceUpdate) {
      var versionInPubDev =
          await PubDevApi.getLatestVersionFromPackage('refreshed_cli');

      var versionInstalled = await PubspecLock.getVersionCli(disableLog: true);

      if (versionInstalled == versionInPubDev) {
        return LogService.info(
            Translation(LocaleKeys.info_cli_last_version_already_installed.tr)
                .toString());
      }
    }

    LogService.info('Upgrading refreshed_cli …');

    try {
      if (Platform.script.path.contains('flutter')) {
        if (isGit) {
          await run(
              'flutter pub global activate -sgit https://github.com/Aniketkhote/refreshed_cli/',
              verbose: true);
        } else {
          await run('flutter pub global activate refreshed_cli', verbose: true);
        }
      } else {
        if (isGit) {
          await run(
              'flutter pub global activate -sgit https://github.com/Aniketkhote/refreshed_cli/',
              verbose: true);
        } else {
          await run('flutter pub global activate refreshed_cli', verbose: true);
        }
      }
      return LogService.success(LocaleKeys.sucess_update_cli.tr);
    } on Exception catch (err) {
      LogService.info(err.toString());
      return LogService.error(LocaleKeys.error_update_cli.tr);
    }
  }
}
