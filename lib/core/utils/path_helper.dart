import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;
import 'dart:io';

class PathHelper {
  static Directory? _overrideDir;

  static set overrideDirectory(Directory? dir) => _overrideDir = dir;

  static Future<String> localImagePath(String fileName) async {
    final dir = _overrideDir ?? await getApplicationDocumentsDirectory();
    return p.join(dir.path, fileName);
  }
}
