import 'dart:io';

void processDirectory(Directory dir) {
  final files = dir.listSync(recursive: true).whereType<File>().where((f) => f.path.endsWith('.dart'));
  
  final regex = RegExp(
    r"r?'''[\s\S]*?'''|" 
    r'r?"""[\s\S]*?"""|'
    r"r?'(?:\\.|[^'\\])*'|" 
    r'r?"(?:\\.|[^"\\])*"|' 
    r'(//.*)|' 
    r'(/\*[\s\S]*?\*/)'
  );

  for (final file in files) {
    String content = file.readAsStringSync();
    
    if (!content.contains('//') && !content.contains('/*')) continue;

    final newContent = content.replaceAllMapped(regex, (match) {
      if (match.group(1) != null || match.group(2) != null) {
        return ''; 
      }
      return match.group(0)!; 
    });

    if (content != newContent) {
      file.writeAsStringSync(newContent);
      print('Removed comments from ${file.path}');
    }
  }
}

void main() {
  final directories = ['lib', 'test'];
  for (var d in directories) {
    final dir = Directory(d);
    if (dir.existsSync()) {
      processDirectory(dir);
    }
  }
}
