import 'package:package_info_plus/package_info_plus.dart';
import 'package:http/http.dart' as http;
import 'package:logger/logger.dart';
import 'dart:convert';

class UpdateService {
  static const String _versionApiUrl = 'https://api.github.com/repos/martinrojas/control-funcionarios/releases/latest';
  static final Logger _logger = Logger();
  
  static Future<Map<String, dynamic>> checkForUpdates() async {
    try {
      // Get current app version
      final packageInfo = await PackageInfo.fromPlatform();
      final currentVersion = packageInfo.version;
      final currentBuildNumber = packageInfo.buildNumber;
      
      // Get latest version from GitHub API
      final response = await http.get(
        Uri.parse(_versionApiUrl),
        headers: {
          'Accept': 'application/vnd.github.v3+json',
        },
      );
      
      if (response.statusCode == 200) {
        final releaseData = json.decode(response.body);
        final latestVersion = releaseData['tag_name']?.toString().replaceFirst('v', '') ?? '';
        final releaseNotes = releaseData['body'] ?? '';
        final downloadUrl = releaseData['assets']?.first?['browser_download_url'] ?? '';
        
        // Compare versions
        final needsUpdate = _compareVersions(currentVersion, latestVersion) < 0;
        
        return {
          'hasUpdate': needsUpdate,
          'currentVersion': currentVersion,
          'latestVersion': latestVersion,
          'currentBuildNumber': currentBuildNumber,
          'releaseNotes': releaseNotes,
          'downloadUrl': downloadUrl,
          'isForceUpdate': _isForceUpdate(currentVersion, latestVersion),
        };
      }
      
      return {'hasUpdate': false};
    } catch (e) {
      _logger.e('Erro ao verificar atualizações: $e');
      return {'hasUpdate': false};
    }
  }
  
  // Compare version strings (returns -1 if version1 < version2, 0 if equal, 1 if version1 > version2)
  static int _compareVersions(String version1, String version2) {
    final v1Parts = version1.split('.').map((e) => int.tryParse(e) ?? 0).toList();
    final v2Parts = version2.split('.').map((e) => int.tryParse(e) ?? 0).toList();
    
    // Make both lists the same length
    while (v1Parts.length < v2Parts.length) {
      v1Parts.add(0);
    }
    while (v2Parts.length < v1Parts.length) {
      v2Parts.add(0);
    }
    
    for (int i = 0; i < v1Parts.length; i++) {
      if (v1Parts[i] < v2Parts[i]) return -1;
      if (v1Parts[i] > v2Parts[i]) return 1;
    }
    
    return 0;
  }
  
  // Determine if update should be forced (major version change)
  static bool _isForceUpdate(String currentVersion, String latestVersion) {
    final currentMajor = currentVersion.split('.').first;
    final latestMajor = latestVersion.split('.').first;
    return currentMajor != latestMajor;
  }
}
