// ignore_for_file: avoid_print
import 'dart:io';

void main() async {
  try {
    // Find project root by looking for pubspec.yaml (traverse upwards if in a subdirectory)
    Directory currentDir = Directory.current;
    File? pubspecFile;
    Directory? rootDir;

    while (true) {
      final potentialPubspec = File('${currentDir.path}/pubspec.yaml');
      if (potentialPubspec.existsSync()) {
        pubspecFile = potentialPubspec;
        rootDir = currentDir;
        break;
      }
      final parent = currentDir.parent;
      if (parent.path == currentDir.path) break;
      currentDir = parent;
    }

    if (pubspecFile == null || rootDir == null) {
      print('Error: Could not find project root (pubspec.yaml not found).');
      exit(1);
    }

    final lines = await pubspecFile.readAsLines();
    String? versionLine;
    for (var line in lines) {
      if (line.trim().startsWith('version:')) {
        versionLine = line.trim();
        break;
      }
    }

    if (versionLine == null) {
      print('Error: version not found in pubspec.yaml.');
      exit(1);
    }

    // e.g. "version: 0.1.8+1" -> "0.1.8"
    final rawVersion = versionLine.split(':')[1].trim().split('+')[0];
    final fullVersion = 'v$rawVersion';

    print('Extracted version from pubspec.yaml: $fullVersion');

    final indexFile = File('${rootDir.path}/index.html');
    if (!indexFile.existsSync()) {
      print('Error: index.html not found at ${indexFile.path}');
      exit(1);
    }

    String indexContent = await indexFile.readAsString();

    // Replace vX.Y.Z with new version
    final versionRegex = RegExp(r'v[0-9]+\.[0-9]+\.[0-9]+');
    if (versionRegex.hasMatch(indexContent)) {
      indexContent = indexContent.replaceAll(versionRegex, fullVersion);
      await indexFile.writeAsString(indexContent);
      print('Successfully updated index.html to $fullVersion');
    } else {
      print('Warning: No existing version pattern found in index.html to replace.');
    }
  } catch (e) {
    print('Error updating web version: $e');
    exit(1);
  }
}
