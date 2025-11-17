import 'package:flutter/material.dart';
import 'package:logger/logger.dart';
import '../services/update_service.dart';
import '../widgets/update_dialog.dart';

mixin UpdateCheckerMixin<T extends StatefulWidget> on State<T> {
  bool _isCheckingUpdate = false;
  static bool _hasCheckedThisSession = false;
  final Logger _logger = Logger();

  @override
  void initState() {
    super.initState();
    // Check for updates when the widget initializes
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkForUpdates();
    });
  }

  Future<void> _checkForUpdates() async {
    // Don't check multiple times in the same session
    if (_hasCheckedThisSession || _isCheckingUpdate) return;
    
    setState(() {
      _isCheckingUpdate = true;
    });

    try {
      final updateInfo = await UpdateService.checkForUpdates();
      
      if (updateInfo['hasUpdate'] == true && mounted) {
        _hasCheckedThisSession = true;
        _showUpdateDialog(updateInfo);
      }
    } catch (e) {
      _logger.e('Erro ao verificar atualizações: $e');
    } finally {
      if (mounted) {
        setState(() {
          _isCheckingUpdate = false;
        });
      }
    }
  }

  void _showUpdateDialog(Map<String, dynamic> updateInfo) {
    showDialog(
      context: context,
      barrierDismissible: !updateInfo['isForceUpdate'],
      builder: (context) => UpdateDialog(
        currentVersion: updateInfo['currentVersion'],
        latestVersion: updateInfo['latestVersion'],
        releaseNotes: updateInfo['releaseNotes'] ?? '',
        downloadUrl: updateInfo['downloadUrl'] ?? '',
        isForceUpdate: updateInfo['isForceUpdate'] ?? false,
        onUpdateLater: () {
          // Optionally remind user later
          _scheduleReminder();
        },
      ),
    );
  }

  void _scheduleReminder() {
    // Remind user after 30 minutes
    Future.delayed(const Duration(minutes: 30), () {
      _hasCheckedThisSession = false;
      if (mounted) {
        _checkForUpdates();
      }
    });
  }

  // Public method to manually check for updates
  Future<void> checkForUpdatesManually() async {
    _hasCheckedThisSession = false;
    await _checkForUpdates();
  }
}
