import 'package:flutter/material.dart';
import 'package:shiftly/l10n/app_localizations.dart';
import 'package:shiftly/services/update_service.dart';
import 'package:shiftly/theme/app_theme.dart';

class UpdateDialog extends StatefulWidget {
  final AppUpdateInfo updateInfo;
  final bool isForceUpdate;

  const UpdateDialog({
    super.key,
    required this.updateInfo,
    this.isForceUpdate = true,
  });

  /// Helper static method to display the update dialog.
  static Future<void> show(
    BuildContext context,
    AppUpdateInfo updateInfo, {
    bool isForceUpdate = true,
  }) {
    return showDialog<void>(
      context: context,
      barrierDismissible: !isForceUpdate,
      builder: (context) =>
          UpdateDialog(updateInfo: updateInfo, isForceUpdate: isForceUpdate),
    );
  }

  @override
  State<UpdateDialog> createState() => _UpdateDialogState();
}

class _UpdateDialogState extends State<UpdateDialog> {
  bool _isDownloading = false;
  double _downloadProgress = 0.0;
  String? _errorMessage;

  Future<void> _startDownload() async {
    final downloadUrl = widget.updateInfo.downloadUrl;
    if (downloadUrl == null || downloadUrl.isEmpty) {
      // Fallback to browser if no direct APK asset found
      await UpdateService.openReleaseInBrowser(widget.updateInfo.releaseUrl);
      if (!widget.isForceUpdate && mounted) {
        Navigator.of(context).pop();
      }
      return;
    }

    final l = AppLocalizations.of(context);

    setState(() {
      _isDownloading = true;
      _downloadProgress = 0.0;
      _errorMessage = null;
    });

    await UpdateService.downloadAndInstallApk(
      downloadUrl: downloadUrl,
      l: l,
      onProgress: (progress) {
        if (mounted) {
          setState(() {
            _downloadProgress = progress;
          });
        }
      },
      onCompleted: (filePath) {
        if (mounted) {
          setState(() {
            _isDownloading = false;
          });
        }
      },
      onError: (error) {
        if (mounted) {
          setState(() {
            _isDownloading = false;
            _errorMessage = error;
          });
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final l = AppLocalizations.of(context)!;

    return PopScope(
      canPop: !widget.isForceUpdate,
      child: Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        child: Container(
          constraints: const BoxConstraints(maxWidth: 450),
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header Icon & Title
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: widget.isForceUpdate
                          ? AppTheme.expense.withValues(alpha: 0.15)
                          : AppTheme.primary.withValues(alpha: 0.15),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.system_update_rounded,
                      color: widget.isForceUpdate
                          ? AppTheme.expense
                          : AppTheme.primaryDark,
                      size: 28,
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          l.update_dialog_title,
                          style: theme.textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          l.update_dialog_version_available(
                            widget.updateInfo.tagName,
                          ),
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: isDark ? Colors.grey[400] : Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              if (widget.isForceUpdate) ...[
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 10,
                  ),
                  decoration: BoxDecoration(
                    color: AppTheme.expense.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: AppTheme.expense.withValues(alpha: 0.3),
                    ),
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.error_outline_rounded,
                        color: AppTheme.expense,
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          l.update_dialog_mandatory_notice,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: AppTheme.expense,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
              ],

              // Badges section (Current vs New)
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 10,
                ),
                decoration: BoxDecoration(
                  color: isDark ? AppTheme.darkCard : AppTheme.lightBackground,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: isDark
                        ? AppTheme.darkBorder
                        : Colors.grey.withValues(alpha: 0.2),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      l.update_dialog_installed_version(
                        widget.updateInfo.currentVersion,
                      ),
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: isDark ? Colors.grey[400] : Colors.grey[700],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: AppTheme.profit.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        l.update_dialog_new_version(
                          widget.updateInfo.versionName,
                        ),
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: AppTheme.profit,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // Changelog / Release Notes
              Text(
                l.update_dialog_whats_new,
                style: theme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Container(
                constraints: const BoxConstraints(maxHeight: 180),
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: isDark ? Colors.black26 : Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: SingleChildScrollView(
                  child: Text(
                    widget.updateInfo.changelog,
                    style: theme.textTheme.bodySmall?.copyWith(height: 1.4),
                  ),
                ),
              ),

              if (_errorMessage != null) ...[
                const SizedBox(height: 12),
                Text(
                  _errorMessage!,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.error,
                  ),
                ),
              ],

              if (_isDownloading) ...[
                const SizedBox(height: 20),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(l.update_dialog_downloading),
                        Text(
                          '${(_downloadProgress * 100).toStringAsFixed(0)}%',
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    LinearProgressIndicator(
                      value: _downloadProgress > 0 ? _downloadProgress : null,
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ],
                ),
              ],

              const SizedBox(height: 24),

              // Actions
              if (!_isDownloading) ...[
                Wrap(
                  spacing: 12,
                  runSpacing: 12,
                  alignment: WrapAlignment.spaceBetween,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    if (!widget.isForceUpdate)
                      TextButton(
                        onPressed: () => Navigator.of(context).pop(),
                        child: Text(l.update_dialog_later),
                      )
                    else
                      TextButton.icon(
                        onPressed: () {
                          UpdateService.openReleaseInBrowser(
                            widget.updateInfo.releaseUrl,
                          );
                        },
                        icon: const Icon(Icons.open_in_browser, size: 18),
                        label: Text(l.update_dialog_open_browser),
                      ),

                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (!widget.isForceUpdate) ...[
                          TextButton.icon(
                            onPressed: () {
                              UpdateService.openReleaseInBrowser(
                                widget.updateInfo.releaseUrl,
                              );
                            },
                            icon: const Icon(Icons.open_in_browser, size: 18),
                            label: Text(l.update_dialog_open_browser),
                          ),
                          const SizedBox(width: 8),
                        ],
                        ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: widget.isForceUpdate
                                ? AppTheme.expense
                                : AppTheme.primaryDark,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 12,
                            ),
                          ),
                          onPressed: _startDownload,
                          icon: const Icon(Icons.download_rounded, size: 20),
                          label: Text(
                            widget.updateInfo.downloadUrl != null
                                ? l.update_dialog_update_now
                                : l.update_dialog_open_download,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
