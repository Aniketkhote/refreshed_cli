import 'package:refreshed_cli/commands/interface/command.dart';
import 'package:refreshed_cli/common/utils/shell/shel.utils.dart';
import 'package:refreshed_cli/core/internationalization.dart';
import 'package:refreshed_cli/core/locales.g.dart';

class UpdateCommand extends Command {
  @override
  String get commandName => 'update';
  @override
  List<String> get acceptedFlags => ['-f', '--git'];

  @override
  Future<void> execute() async {
    await ShellUtils.update();
  }

  @override
  String? get hint => Translation(LocaleKeys.hint_update).tr;

  @override
  List<String> get alias => ['upgrade'];

  @override
  bool validate() {
    super.validate();
    return true;
  }

  @override
  String get codeSample => 'get update';

  @override
  int get maxParameters => 0;
}
