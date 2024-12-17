import 'package:refreshed_cli/samples/interface/sample_interface.dart';

class GetXMainSample extends Sample {
  GetXMainSample() : super('lib/main.dart', overwrite: true);

  String get _flutterMain => '''import 'package:flutter/material.dart';
import 'package:refreshed/refreshed.dart';

import 'app/routes/app_pages.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: "Refreshed",
      initialRoute: AppPages.initial,
      getPages: AppPages.routes,
    );
  }
}
  ''';

  @override
  String get content => _flutterMain;
}
