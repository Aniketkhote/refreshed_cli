import 'dart:io';

import 'package:intl/intl.dart';
import 'package:path/path.dart';

class CliConfig {
  static final DateFormat _formatter = DateFormat('yyyy-MM-dd');

  // Get the path to the config file
  static File getFileConfig() {
    var scriptFile = Platform.script.toFilePath();
    var path = join(dirname(scriptFile), '.refreshed_cli.yaml');
    var configFile = File(path);
    // Ensure the file exists, create if not
    configFile.createSync(recursive: true);
    return configFile;
  }

  // Set today's date as the last update check
  static void setUpdateCheckToday() {
    final now = DateTime.now();
    final formatted = _formatter.format(now);
    var configFile = getFileConfig();

    try {
      // Read lines and modify in memory
      var lines = configFile.readAsLinesSync();
      var lastUpdateIndex = lines
          .indexWhere((element) => element.startsWith('last_update_check:'));

      // Remove previous last_update_check entry if exists
      if (lastUpdateIndex != -1) {
        lines.removeAt(lastUpdateIndex);
      }

      // Add new entry
      lines.add('last_update_check: $formatted');
      // Write updated content back to file
      configFile.writeAsStringSync(lines.join('\n'), mode: FileMode.writeOnly);
    } catch (e) {
      print('Error updating the config file: $e');
    }
  }

  // Check if the update check was done today
  static bool updateIsCheckingToday() {
    var configFile = getFileConfig();

    try {
      var lines = configFile.readAsLinesSync();
      var lastUpdateIndex = lines
          .indexWhere((element) => element.startsWith('last_update_check:'));

      // If no last update entry, return false
      if (lastUpdateIndex == -1) {
        return false;
      }

      var dateLastUpdate = lines[lastUpdateIndex].split(':').last.trim();
      var now = _formatter.parse(_formatter.format(DateTime.now()));

      return _formatter.parse(dateLastUpdate) == now;
    } catch (e) {
      print('Error reading the config file: $e');
      return false;
    }
  }
}
