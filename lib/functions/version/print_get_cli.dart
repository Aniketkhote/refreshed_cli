import 'package:ansicolor/ansicolor.dart';

void printRefreshedCli() {
  var pen = AnsiPen()..green();
  print('''
${pen('+-+ +-+ +-+ +-+ +-+ +-+ +-+ +-+ +-+   +-+ +-+ +-+')}
${pen('|R| |E| |F| |R| |E| |S| |H| |E| |D|   |C| |L| |I|')}
${pen('+-+ +-+ +-+ +-+ +-+ +-+ +-+ +-+ +-+   +-+ +-+ +-+')}
''');
}
