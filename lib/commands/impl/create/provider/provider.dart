import 'package:refreshed_cli/commands/interface/command.dart';
import 'package:refreshed_cli/core/internationalization.dart';
import 'package:refreshed_cli/core/locales.g.dart';
import 'package:refreshed_cli/functions/create/create_single_file.dart';
import 'package:refreshed_cli/samples/impl/get_provider.dart';

class CreateProviderCommand extends Command {
  @override
  String get commandName => 'provider';
  @override
  Future<void> execute() async {
    var name = this.name;
    handleFileCreate(name, 'provider', onCommand, onCommand.isNotEmpty,
        ProviderSample(name), onCommand.isNotEmpty ? 'providers' : '');
  }

  @override
  String? get hint => Translation(LocaleKeys.hint_create_provider).tr;

  @override
  String get codeSample => 'get create provider:user on data';

  @override
  int get maxParameters => 0;
}
