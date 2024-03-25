import 'package:recase/recase.dart';

import '../interface/sample_interface.dart';

/// [Sample] file from Module_Controller file creation.
class ControllerSample extends Sample {
  final String _fileName;
  ControllerSample(super.path, this._fileName, {super.overwrite});

  @override
  String get content => flutterController;

  String get flutterController => '''import 'package:refreshed/refreshed.dart';

class ${_fileName.pascalCase}Controller extends GetxController {
  //TODO: Implement ${_fileName.pascalCase}Controller
  
  final count = 0.obs;

  @override
  void onInit() {
    super.onInit();
  }
  
  void increment() => count.value++;
}
''';
}
