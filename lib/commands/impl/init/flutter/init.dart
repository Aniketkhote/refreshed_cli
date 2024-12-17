import 'package:refreshed_cli/commands/impl/init/flutter/init_getx_pattern.dart';
import 'package:refreshed_cli/commands/impl/init/flutter/init_katteko.dart';
import 'package:refreshed_cli/commands/interface/command.dart';
import 'package:refreshed_cli/common/menu/menu.dart';
import 'package:refreshed_cli/common/utils/logger/log_utils.dart';
import 'package:refreshed_cli/common/utils/shell/shel.utils.dart';
import 'package:refreshed_cli/core/internationalization.dart';
import 'package:refreshed_cli/core/locales.g.dart';

class InitCommand extends Command {
  @override
  String get commandName => 'init';

  @override
  Future<void> execute() async {
    final menu = Menu([
      'GetX Pattern',
      'CLEAN',
    ], title: 'Which architecture do you want to use?');
    final result = menu.choose();

    result.index == 0
        ? await createInitGetxPattern()
        : await createInitKatekko();
    await ShellUtils.pubGet();
    return;
  }

  @override
  String? get hint => Translation(LocaleKeys.hint_init).tr;

  @override
  bool validate() {
    super.validate();
    return true;
  }

  @override
  String? get codeSample => LogService.code('get init');

  @override
  int get maxParameters => 0;
}
