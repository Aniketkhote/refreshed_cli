import 'package:recase/recase.dart';
import 'package:refreshed_cli/common/utils/pubspec/pubspec_utils.dart';
import 'package:refreshed_cli/samples/interface/sample_interface.dart';

/// [Sample] file from Module_Binding file creation.
class BindingSample extends Sample {
  final String _fileName;
  final String _controllerDir;
  final String _bindingName;

  BindingSample(
      super.path, this._fileName, this._bindingName, this._controllerDir,
      {super.overwrite});

  String get _import => "import 'package:refreshed/refreshed.dart';";

  @override
  String get content => '''$_import
import 'package:${PubspecUtils.projectName}/$_controllerDir';

class $_bindingName extends Binding {
  @override
  List<Bind> dependencies() {
   return [
     Bind.lazyPut<${_fileName.pascalCase}Controller>(
      () => ${_fileName.pascalCase}Controller(),
    ),
   ];
  }
}
''';
}
