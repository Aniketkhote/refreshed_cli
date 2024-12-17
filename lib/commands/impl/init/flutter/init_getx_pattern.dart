import 'dart:io';

import 'package:refreshed_cli/commands/impl/commads_export.dart';
import 'package:refreshed_cli/commands/impl/install/install_refreshed.dart';
import 'package:refreshed_cli/common/utils/logger/log_utils.dart';
import 'package:refreshed_cli/core/internationalization.dart';
import 'package:refreshed_cli/core/locales.g.dart';
import 'package:refreshed_cli/core/structure.dart';
import 'package:refreshed_cli/functions/create/create_list_directory.dart';
import 'package:refreshed_cli/functions/create/create_main.dart';
import 'package:refreshed_cli/samples/impl/getx_pattern/get_main.dart';

Future<void> createInitGetxPattern() async {
  var canContinue = await createMain();
  if (!canContinue) return;

  await installRefreshed();

  var initialDirs = [
    Directory(Structure.replaceAsExpected(path: 'lib/app/data/')),
  ];
  GetXMainSample().create();
  await Future.wait([
    CreatePageCommand().execute(),
  ]);
  createListDirectory(initialDirs);

  LogService.success(Translation(LocaleKeys.sucess_getx_pattern_generated));
}
