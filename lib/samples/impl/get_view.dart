import '../../common/utils/pubspec/pubspec_utils.dart';
import '../interface/sample_interface.dart';

/// [Sample] file from Module_View file creation.
class GetViewSample extends Sample {
  final String _controllerDir;
  final String _viewName;
  final String _controller;

  GetViewSample(
      super.path, this._viewName, this._controller, this._controllerDir,
      {super.overwrite});

  String get import => _controllerDir.isNotEmpty
      ? '''import 'package:${PubspecUtils.projectName}/$_controllerDir';'''
      : '';

  String get _controllerName =>
      _controller.isNotEmpty ? 'GetView<$_controller>' : 'GetView';

  String get _flutterView => '''import 'package:flutter/material.dart';
import 'package:refreshed/refreshed.dart'; 
$import

class $_viewName extends $_controllerName {
 const $_viewName({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('$_viewName'),
        centerTitle: true,
      ),
      body:const Center(
        child: Text(
          '$_viewName is working', 
          style: TextStyle(fontSize:20),
        ),
      ),
    );
  }
}
  ''';

  @override
  String get content => _flutterView;
}
