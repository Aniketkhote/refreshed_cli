import 'package:refreshed_cli/common/utils/pubspec/pubspec_utils.dart';

Future<void> installRefreshed([bool runPubGet = false]) async {
  await PubspecUtils.removeDependencies('refreshed', logger: false);
  await PubspecUtils.addDependencies('refreshed', runPubGet: runPubGet);
}
