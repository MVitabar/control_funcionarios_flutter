import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class UpdateDialog extends StatelessWidget {
  final String currentVersion;
  final String latestVersion;
  final String releaseNotes;
  final String downloadUrl;
  final bool isForceUpdate;
  final VoidCallback? onUpdateLater;

  const UpdateDialog({
    super.key,
    required this.currentVersion,
    required this.latestVersion,
    required this.releaseNotes,
    required this.downloadUrl,
    this.isForceUpdate = false,
    this.onUpdateLater,
  });

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: !isForceUpdate,
      child: AlertDialog(
        title: Row(
          children: [
            Icon(
              isForceUpdate ? Icons.system_update_alt : Icons.system_update,
              color: isForceUpdate ? Colors.red : Colors.blue,
              size: 28,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                isForceUpdate ? 'Atualização Obrigatória' : 'Nova Atualização Disponível',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: isForceUpdate ? Colors.red : Colors.blue[800],
                ),
              ),
            ),
          ],
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.blue[50],
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.blue[200]!),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.info_outline,
                      color: Colors.blue[700],
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Versão atual: $currentVersion\nDisponível: $latestVersion',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.blue[700],
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              if (releaseNotes.isNotEmpty) ...[
                Text(
                  'Novidades:',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.grey[800],
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.grey[50],
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.grey[300]!),
                  ),
                  child: Text(
                    releaseNotes,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[700],
                      height: 1.4,
                    ),
                  ),
                ),
                const SizedBox(height: 16),
              ],
              if (isForceUpdate)
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.red[50],
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.red[200]!),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.warning_amber,
                        color: Colors.red[700],
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Esta atualização é obrigatória para continuar usando o aplicativo.',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.red[700],
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
        ),
        actions: [
          if (!isForceUpdate && onUpdateLater != null)
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                onUpdateLater!();
              },
              child: const Text('Mais tarde'),
            ),
          ElevatedButton(
            onPressed: () => _downloadUpdate(context),
            style: ElevatedButton.styleFrom(
              backgroundColor: isForceUpdate ? Colors.red : Colors.blue,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.download),
                const SizedBox(width: 8),
                Text(isForceUpdate ? 'Atualizar Agora' : 'Baixar'),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _downloadUpdate(BuildContext context) async {
    try {
      final uri = Uri.parse(downloadUrl);
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
        if (context.mounted) {
          Navigator.of(context).pop();
        }
      } else {
        if (context.mounted) {
          _showError(context, 'Não é possível abrir o link de download');
        }
      }
    } catch (e) {
      if (context.mounted) {
        _showError(context, 'Erro ao abrir o link: $e');
      }
    }
  }

  void _showError(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
      ),
    );
  }
}
