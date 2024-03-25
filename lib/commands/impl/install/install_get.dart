import '../../../common/utils/pubspec/pubspec_utils.dart';

Future<void> installGet([bool runPubGet = false]) async {
  PubspecUtils.removeDependencies('refreshed', logger: false);
  await PubspecUtils.addDependencies('refreshed', runPubGet: runPubGet);
}
