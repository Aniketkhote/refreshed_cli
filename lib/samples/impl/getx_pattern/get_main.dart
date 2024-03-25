import '../../interface/sample_interface.dart';

class GetXMainSample extends Sample {
  GetXMainSample() : super('lib/main.dart', overwrite: true);

  String get _flutterMain => '''import 'package:flutter/material.dart';
import 'package:refreshed/refreshed.dart';

import 'app/routes/app_pages.dart';

void main() {
  runApp(
    GetMaterialApp(
      title: "Application",
      initialRoute: AppPages.INITIAL,
      getPages: AppPages.routes,
    ),
  );
}
  ''';

  @override
  String get content => _flutterMain;
}
