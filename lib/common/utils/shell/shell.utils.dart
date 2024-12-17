import 'package:process_run/shell_run.dart';
import 'package:refreshed_cli/common/utils/logger/log_utils.dart';
import 'package:refreshed_cli/common/utils/pub_dev/pub_dev_api.dart';
import 'package:refreshed_cli/common/utils/pubspec/pubspec_lock.dart';
import 'package:refreshed_cli/core/generator.dart';
import 'package:refreshed_cli/core/internationalization.dart';
import 'package:refreshed_cli/core/locales.g.dart';

class ShellUtils {
  static const _flutterCreateCmd = 'flutter create --no-pub';
  static const _activateCliCmd = 'flutter pub global activate refreshed_cli';
  static const _activateCliGitCmd =
      'flutter pub global activate -sgit https://github.com/Aniketkhote/refreshed_cli/';

  static Future<void> pubGet() async {
    LogService.info('Running `flutter pub get` …');
    await _runCommand('dart pub get');
  }

  static Future<void> addPackage(String package) async {
    LogService.info('Adding package $package …');
    await _runCommand('dart pub add $package');
  }

  static Future<void> removePackage(String package) async {
    LogService.info('Removing package $package …');
    await _runCommand('dart pub remove $package');
  }

  static Future<void> flutterCreate(
    String path,
    String? org,
    String iosLang,
    String androidLang,
  ) async {
    LogService.info('Running `flutter create $path`');
    if (path.isEmpty || org == null || iosLang.isEmpty || androidLang.isEmpty) {
      LogService.error('Invalid parameters for flutter create.');
      return;
    }

    final createCmd =
        '$_flutterCreateCmd -i $iosLang -a $androidLang --org $org "$path"';
    await _runCommand(createCmd);
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
      final cmd = isGit ? _activateCliGitCmd : _activateCliCmd;
      await _runCommand(cmd);
      LogService.success(LocaleKeys.sucess_update_cli.tr);
    } on Exception catch (err) {
      LogService.error('Failed to update refreshed_cli: ${err.toString()}');
    }
  }

  // Helper method to run commands
  static Future<void> _runCommand(String command) async {
    try {
      await run(command, verbose: true);
    } catch (e) {
      LogService.error('Command failed: $command\nError: $e');
    }
  }
}
