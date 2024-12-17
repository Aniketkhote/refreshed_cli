import 'package:refreshed_cli/functions/find_file/find_file_by_name.dart';

/// Checks whether the installed version of get supports child routes
bool get supportChildrenRoutes {
  var supportChildren = true;

  var routesFile = findFileByName('app_routes.dart');

  if (routesFile.path.isNotEmpty) {
    supportChildren =
        routesFile.readAsLinesSync().contains('abstract class _Paths {') ||
            routesFile.readAsLinesSync().contains('abstract class _Paths {}');
  }

  return supportChildren;
}
