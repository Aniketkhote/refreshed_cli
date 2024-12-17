import 'dart:io';

import 'package:recase/recase.dart';
import 'package:refreshed_cli/commands/interface/command.dart';
import 'package:refreshed_cli/common/menu/menu.dart';
import 'package:refreshed_cli/common/utils/pubspec/pubspec_utils.dart';
import 'package:refreshed_cli/core/generator.dart';
import 'package:refreshed_cli/core/internationalization.dart';
import 'package:refreshed_cli/core/locales.g.dart';
import 'package:refreshed_cli/core/structure.dart';
import 'package:refreshed_cli/functions/create/create_single_file.dart';
import 'package:refreshed_cli/functions/exports_files/add_export.dart';
import 'package:refreshed_cli/functions/routes/arc_add_route.dart';
import 'package:refreshed_cli/samples/impl/get_binding.dart';
import 'package:refreshed_cli/samples/impl/get_controller.dart';
import 'package:refreshed_cli/samples/impl/get_view.dart';

class CreateScreenCommand extends Command {
  @override
  String get commandName => 'screen';

  @override
  Future<void> execute() async {
    var isProject = false;
    if (GetCli.arguments[0] == 'create') {
      isProject = GetCli.arguments[1].split(':').first == 'project';
    }
    var name = this.name;
    if (name.isEmpty || isProject) {
      name = 'home';
    }

    var newFileModel =
        Structure.model(name, 'screen', true, on: onCommand, folderName: name);
    var pathSplit = Structure.safeSplitPath(newFileModel.path!);

    pathSplit.removeLast();
    var path = pathSplit.join('/');
    path = Structure.replaceAsExpected(path: path);
    if (Directory(path).existsSync()) {
      final menu = Menu([
        LocaleKeys.options_yes.tr,
        LocaleKeys.options_no.tr,
      ], title: LocaleKeys.ask_existing_page.trArgs([name]).toString());
      final result = menu.choose();
      if (result.index == 0) {
        _writeFiles(path, name, overwrite: true);
      }
    } else {
      Directory(path).createSync(recursive: true);
      _writeFiles(path, name);
    }
  }

  @override
  String? get hint => Translation(LocaleKeys.hint_create_screen).tr;

  @override
  bool validate() {
    return true;
  }

  void _writeFiles(String path, String name, {bool overwrite = false}) {
    var controller = handleFileCreate(name, 'controller', path, true,
        ControllerSample('', name), 'controllers', '.');

    var controllerImport = Structure.pathToDirImport(controller.path);

    var view = handleFileCreate(
        name,
        'screen',
        path,
        false,
        GetViewSample(
          '',
          '${name.pascalCase}Screen',
          '${name.pascalCase}Controller',
          controllerImport,
        ),
        '',
        '.');
    var binding = handleFileCreate(
        name,
        'controller.binding',
        '',
        true,
        BindingSample(
          '',
          name,
          '${name.pascalCase}ControllerBinding',
          controllerImport,
        ),
        'controllers',
        '.');

    var exportView = 'package:${PubspecUtils.projectName}/'
        '${Structure.pathToDirImport(view.path)}';
    addExport('lib/presentation/screens.dart', "export '$exportView';");

    addExport(
        'lib/infrastructure/navigation/bindings/controllers/controllers_bindings.dart',
        "export 'package:${PubspecUtils.projectName}/${Structure.pathToDirImport(binding.path)}'; ");
    arcAddRoute(name);
  }

  @override
  String get codeSample => 'get create screen:name';

  @override
  int get maxParameters => 0;
}
