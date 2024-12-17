import 'dart:io';

import 'package:dcli/dcli.dart';
import 'package:path/path.dart' as p;
import 'package:refreshed_cli/commands/impl/init/flutter/init.dart';
import 'package:refreshed_cli/commands/interface/command.dart';
import 'package:refreshed_cli/common/menu/menu.dart';
import 'package:refreshed_cli/common/utils/pubspec/pubspec_utils.dart';
import 'package:refreshed_cli/common/utils/shell/shell.utils.dart';
import 'package:refreshed_cli/core/internationalization.dart';
import 'package:refreshed_cli/core/locales.g.dart';
import 'package:refreshed_cli/core/structure.dart';
import 'package:refreshed_cli/functions/version/print_get_cli.dart';
import 'package:refreshed_cli/samples/impl/analysis_options.dart';

class CreateProjectCommand extends Command {
  @override
  String get commandName => 'new';

  @override
  Future<void> execute() async {
    print('\n');
    printRefreshedCli();

    final projectDetails = await gatherProjectDetails();
    await createProjectStructure(projectDetails);
    await configureDevelopmentEnvironment(projectDetails);
    await initializeProject();

    print("Project created successfully.");
  }

  Future<ProjectDetails> gatherProjectDetails() async {
    final name = await getProjectName();
    final org = await getCompanyDomain();
    final iosLang = await getIosLanguage();
    final androidLang = await getAndroidLanguage();
    final useLinter = await askUseLinter();

    return ProjectDetails(name, org, iosLang, androidLang, useLinter);
  }

  Future<String> getProjectName() async {
    if (args.isNotEmpty && isValidName(args.first.toLowerCase())) {
      return args.first.toLowerCase();
    }
    return await promptForValidName();
  }

  Future<String> promptForValidName() async {
    String? name;
    do {
      name = ask(Translation(LocaleKeys.ask_name_to_project).tr);
      if (!isValidName(name)) {
        print("Invalid project name");
      }
    } while (!isValidName(name));
    return name.toLowerCase();
  }

  bool isValidName(String? name) {
    return name != null && RegExp(r'^[a-zA-Z0-9_]+$').hasMatch(name);
  }

  Future<String> getCompanyDomain() async {
    return ask(
      '${Translation(LocaleKeys.ask_company_domain).tr} \x1B[33m '
      '${Translation(LocaleKeys.example).tr} com.yourcompany \x1B[0m',
      toLower: true,
    );
  }

  Future<String> getIosLanguage() async {
    return _chooseLanguage(
      ['Swift', 'Objective-C'],
      Translation(LocaleKeys.ask_ios_lang).tr,
    );
  }

  Future<String> getAndroidLanguage() async {
    return _chooseLanguage(
      ['Kotlin', 'Java'],
      Translation(LocaleKeys.ask_android_lang).tr,
    );
  }

  Future<String> _chooseLanguage(List<String> languages, String title) async {
    final languageMenu = Menu(languages, title: title);
    final result = languageMenu.choose();
    return result.index == 0
        ? languages[0].toLowerCase()
        : languages[1].toLowerCase();
  }

  Future<bool> askUseLinter() async {
    final linterMenu =
        Menu(['yes', 'no'], title: Translation(LocaleKeys.ask_use_linter).tr);
    final linterResult = linterMenu.choose();
    return linterResult.index == 0;
  }

  Future<void> createProjectStructure(ProjectDetails details) async {
    final projectPath = p.join(Directory.current.path, details.name);
    final path = Structure.replaceAsExpected(path: projectPath);

    try {
      await Directory(path).create(recursive: true);
      Directory.current = path;

      await ShellUtils.flutterCreate(
          path, details.org, details.iosLang, details.androidLang);
      await File('test/widget_test.dart').writeAsString('');
    } catch (e) {
      print("Error creating project structure: $e");
      rethrow;
    }
  }

  Future<void> configureDevelopmentEnvironment(ProjectDetails details) async {
    try {
      if (details.useLinter) {
        await PubspecUtils.addDependencies('flutter_lints',
            isDev: true, runPubGet: true);
        AnalysisOptionsSample(
                include: 'include: package:flutter_lints/flutter.yaml')
            .create();
      } else {
        AnalysisOptionsSample().create();
      }
    } catch (e) {
      print("Error configuring development environment: $e");
      rethrow;
    }
  }

  Future<void> initializeProject() async {
    try {
      await InitCommand().execute();
    } catch (e) {
      print("Error initializing project: $e");
      rethrow;
    }
  }

  @override
  String? get hint => Translation(LocaleKeys.hint_create_project).tr;

  @override
  bool validate() => true;

  @override
  String get codeSample => 'get new';

  @override
  int get maxParameters => 0;
}

class ProjectDetails {
  final String name;
  final String org;
  final String iosLang;
  final String androidLang;
  final bool useLinter;

  ProjectDetails(
      this.name, this.org, this.iosLang, this.androidLang, this.useLinter);
}
