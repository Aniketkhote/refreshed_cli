import 'dart:io';

import 'package:dcli/dcli.dart';
import 'package:path/path.dart' as p;
import 'package:refreshed_cli/functions/version/print_get_cli.dart';

import '../../../../common/menu/menu.dart';
import '../../../../common/utils/pubspec/pubspec_utils.dart';
import '../../../../common/utils/shell/shel.utils.dart';
import '../../../../core/internationalization.dart';
import '../../../../core/locales.g.dart';
import '../../../../core/structure.dart';
import '../../../../samples/impl/analysis_options.dart';
import '../../../interface/command.dart';
import '../../init/flutter/init.dart';

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
    final name = await getValidProjectName();
    final org = await getCompanyDomain();
    final iosLang = await getIosLanguage();
    final androidLang = await getAndroidLanguage();
    final useLinter = await askUseLinter();

    return ProjectDetails(name, org, iosLang, androidLang, useLinter);
  }

  Future<String> getValidProjectName() async {
    if (args.isNotEmpty && isValidName(args.first.toLowerCase())) {
      return args.first.toLowerCase();
    }
    return await askForValidName();
  }

  Future<String> askForValidName() async {
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
    final iosLangMenu = Menu(['Swift', 'Objective-C'],
        title: Translation(LocaleKeys.ask_ios_lang).tr);
    final iosResult = iosLangMenu.choose();
    return iosResult.index == 0 ? 'swift' : 'objc';
  }

  Future<String> getAndroidLanguage() async {
    final androidLangMenu = Menu(['Kotlin', 'Java'],
        title: Translation(LocaleKeys.ask_android_lang).tr);
    final androidResult = androidLangMenu.choose();
    return androidResult.index == 0 ? 'kotlin' : 'java';
  }

  Future<bool> askUseLinter() async {
    final linterMenu =
        Menu(['yes', 'no'], title: Translation(LocaleKeys.ask_use_linter).tr);
    final linterResult = linterMenu.choose();
    return linterResult.index == 0;
  }

  Future<void> createProjectStructure(ProjectDetails details) async {
    final path = Structure.replaceAsExpected(
      path: p.join(Directory.current.path, details.name),
    );
    await Directory(path).create(recursive: true);
    Directory.current = path;

    await ShellUtils.flutterCreate(
        path, details.org, details.iosLang, details.androidLang);
    await File('test/widget_test.dart').writeAsString('');
  }

  Future<void> configureDevelopmentEnvironment(ProjectDetails details) async {
    if (details.useLinter) {
      await PubspecUtils.addDependencies('flutter_lints',
          isDev: true, runPubGet: true);
      AnalysisOptionsSample(
              include: 'include: package:flutter_lints/flutter.yaml')
          .create();
    } else {
      AnalysisOptionsSample().create();
    }
  }

  Future<void> initializeProject() async {
    await InitCommand().execute();
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
