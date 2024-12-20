import 'dart:io';

import 'package:recase/recase.dart';
import 'package:refreshed_cli/common/utils/logger/log_utils.dart';
import 'package:refreshed_cli/common/utils/pubspec/pubspec_utils.dart';
import 'package:refreshed_cli/core/locales.g.dart';
import 'package:refreshed_cli/extensions.dart';
import 'package:refreshed_cli/functions/find_file/find_file_by_name.dart';
import 'package:refreshed_cli/functions/routes/get_app_pages.dart';
import 'package:refreshed_cli/functions/routes/get_support_children.dart';
import 'package:refreshed_cli/samples/impl/get_route.dart';

/// This command will create the route to the new page
void addRoute(String nameRoute, String bindingDir, String viewDir) {
  var routesFile = findFileByName('app_routes.dart');

  if (routesFile.path.isEmpty) {
    RouteSample().create();
    routesFile = File(RouteSample().path);
  }
  var pathSplit = viewDir.split('/');

  ///remove file
  pathSplit.removeLast();

  ///remove view folder
  if (PubspecUtils.extraFolder ?? true) {
    pathSplit.removeLast();
  }

  pathSplit.removeWhere((element) => element == 'app' || element == 'modules');

  for (var i = 0; i < pathSplit.length; i++) {
    pathSplit[i] = pathSplit[i].snakeCase.toLowerCase().replaceAll('_', '-');
  }
  var route = pathSplit.join('/');

  var declareRoute = 'static const ${nameRoute.camelCase} =';
  var line = "$declareRoute '/$route';";
  if (supportChildrenRoutes) {
    line = '$declareRoute ${_pathsToRoute(pathSplit)};';
    var linePath = "$declareRoute '/${pathSplit.last}';";
    routesFile.appendClassContent('_Paths', linePath);
  }
  routesFile.appendClassContent('Routes', line);

  addAppPage(nameRoute, bindingDir, viewDir);

  LogService.success(
      Translation(LocaleKeys.sucess_route_created).trArgs([nameRoute]));
}

/// Create routes from the path
String _pathsToRoute(List<String> pathSplit) {
  var sb = StringBuffer();
  for (var e in pathSplit) {
    sb.write('_Paths.');
    sb.write(e.camelCase);
    if (e != pathSplit.last) {
      sb.write(' + ');
    }
  }
  return sb.toString();
}
