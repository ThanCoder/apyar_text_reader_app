import 'dart:io';

import 'package:flutter/material.dart';

import '../constants.dart';
import '../notifiers/app_notifier.dart';

class PathUtil {
  static String getBasename(String path) {
    return path.split('/').last;
  }

  static String getHomePath() {
    return createDir(appRootPathNotifier.value);
  }

  static String getConfigPath() {
    return createDir('${getHomePath()}/config');
  }

  static String getLibaryPath() {
    return createDir('${getHomePath()}/libary');
  }

  static String getDatabasePath() {
    return createDir('${getHomePath()}/database');
  }

  static String getDatabaseSourcePath() {
    return createDir('${getHomePath()}/databaseSource');
  }

  static String getCachePath() {
    String homeDir = createDir(appConfigPathNotifier.value);
    return createDir('$homeDir/cache');
  }

  static String getSourcePath() {
    return createDir('${getHomePath()}/source');
  }

  static String getOutPath() {
    String download = createDir(
        '${appExternalPathNotifier.value}/${Platform.isAndroid ? 'Download' : 'Downloads'}');
    return createDir('$download/$appName');
  }

  static String createDir(String path) {
    try {
      if (path.isEmpty) path;
      final dir = Directory(path);
      if (!dir.existsSync()) {
        dir.createSync();
      }
    } catch (e) {
      debugPrint('createDir: ${e.toString()}');
    }
    return path;
  }
}
