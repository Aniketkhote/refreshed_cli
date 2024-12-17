import 'dart:io';

import 'package:refreshed_cli/commands/impl/commads_export.dart';
import 'package:refreshed_cli/commands/impl/install/install_refreshed.dart';
import 'package:refreshed_cli/common/utils/logger/log_utils.dart';
import 'package:refreshed_cli/core/internationalization.dart';
import 'package:refreshed_cli/core/locales.g.dart';
import 'package:refreshed_cli/core/structure.dart';
import 'package:refreshed_cli/functions/create/create_list_directory.dart';
import 'package:refreshed_cli/functions/create/create_main.dart';
import 'package:refreshed_cli/samples/impl/arctekko/arc_main.dart';
import 'package:refreshed_cli/samples/impl/arctekko/config_example.dart';

Future<void> createInitKatekko() async {
  var canContinue = await createMain();
  if (!canContinue) return;
  await installRefreshed();
  var initialDirs = [
    Directory(Structure.replaceAsExpected(path: 'lib/domain/core/interfaces/')),
    Directory(Structure.replaceAsExpected(
        path: 'lib/infrastructure/navigation/bindings/controllers/')),
    Directory(Structure.replaceAsExpected(
        path: 'lib/infrastructure/navigation/bindings/domains/')),
    Directory(
        Structure.replaceAsExpected(path: 'lib/infrastructure/dal/daos/')),
    Directory(
        Structure.replaceAsExpected(path: 'lib/infrastructure/dal/services/')),
    Directory(Structure.replaceAsExpected(path: 'lib/presentation/')),
    Directory(Structure.replaceAsExpected(path: 'lib/infrastructure/theme/')),
  ];

  ArcMainSample().create();
  ConfigExampleSample().create();

  await Future.wait([
    CreateScreenCommand().execute(),
  ]);

  createListDirectory(initialDirs);

  LogService.success(Translation(LocaleKeys.sucess_clean_Pattern_generated).tr);
}
