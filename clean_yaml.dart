import 'dart:io';

void main() {
  final files = ['pubspec.yaml', 'analysis_options.yaml'];
  for (final f in files) {
    var file = File(f);
    if (!file.existsSync()) continue;
    var lines = file.readAsLinesSync();
    var newLines = <String>[];
    for (var line in lines) {
      if (line.trim().startsWith('#')) {
        continue; // full line comment
      }
      var hashIndex = line.indexOf(' #');
      if (hashIndex != -1) {
        newLines.add(line.substring(0, hashIndex));
      } else {
        newLines.add(line);
      }
    }
    file.writeAsStringSync(newLines.join('\n') + '\n');
    print('Cleaned ${file.path}');
  }
}
