import 'package:refreshed_cli/commands/interface/command.dart';
import 'package:refreshed_cli/common/utils/logger/log_utils.dart';
import 'package:refreshed_cli/common/utils/pubspec/pubspec_utils.dart';
import 'package:refreshed_cli/common/utils/shell/shell.utils.dart';
import 'package:refreshed_cli/core/internationalization.dart';
import 'package:refreshed_cli/core/locales.g.dart';
import 'package:refreshed_cli/exception_handler/exceptions/cli_exception.dart';

class InstallCommand extends Command {
  @override
  String get commandName => 'install';

  @override
  List<String> get alias => ['-i'];

  @override
  Future<void> execute() async {
    final isDev = containsArg('--dev') || containsArg('-dev');
    bool runPubGet = false;

    for (var element in args) {
      runPubGet = await _installPackage(element, isDev, runPubGet);
    }

    if (runPubGet) await ShellUtils.pubGet();
  }

  // Helper method to install a package
  Future<bool> _installPackage(
      String packageElement, bool isDev, bool runPubGet) async {
    final packageInfo = packageElement.split(':');
    final packageName = packageInfo.first;
    final version = packageInfo.length > 1 ? packageInfo[1] : null;

    LogService.info('Installing package "$packageName" …');
    final success = await PubspecUtils.addDependencies(packageName,
        version: version, isDev: isDev, runPubGet: false);

    return success || runPubGet;
  }

  @override
  String? get hint => Translation(LocaleKeys.hint_install).tr;

  @override
  bool validate() {
    super.validate();

    if (args.isEmpty) {
      throw CliException(
          'Please, enter the name of a package you want to install',
          codeSample: codeSample);
    }
    return true;
  }

  final String? codeSample1 = LogService.code('get install refreshed:2.10.0');
  final String? codeSample2 = LogService.code('get install refreshed');

  @override
  String get codeSample => '''
  $codeSample1
  if you want to install the latest version:
  $codeSample2
''';

  @override
  int get maxParameters => 999;
}
