import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/upload_progress_provider.dart';
import '../widgets/upload_progress_dialog.dart';
import 'upload_service.dart';

/// 具體的進度管理器實現，包裝 UploadProgressProvider
class UploadProgressManagerImpl implements UploadProgressManager {
  final UploadProgressNotifier _notifier;
  final BuildContext? _context;
  bool _isDialogShown = false;

  UploadProgressManagerImpl(this._notifier, {BuildContext? context}) : _context = context;

  @override
  void initializeUpload({required List<int> fileSizes, required List<String> fileNames}) {
    // 重置並初始化進度
    _notifier.reset();
    _notifier.initializeUpload(fileSizes: fileSizes, fileNames: fileNames);

    // 顯示進度對話框
    _showProgressDialog();
  }

  @override
  void updateFileProgress({required String fileName, required int uploadedBytes, required int currentFileIndex, required int totalFiles}) {
    _notifier.updateFileProgress(fileName: fileName, uploadedBytes: uploadedBytes, currentFileIndex: currentFileIndex, totalFiles: totalFiles);
  }

  @override
  void markFileCompleted(String fileName) {
    _notifier.markFileCompleted(fileName);
  }

  @override
  void setSuccess({required int successCount, required int totalCount}) {
    _notifier.setSuccess(successCount: successCount, totalCount: totalCount);
  }

  @override
  void setError({required String message, String? fileName}) {
    _notifier.setError(message: message, fileName: fileName);
  }

  /// 顯示進度對話框
  void _showProgressDialog() {
    if (_context != null && !_isDialogShown) {
      _isDialogShown = true;
      UploadProgressDialog.show(_context).then((_) {
        _isDialogShown = false;
      });
    }
  }
}

/// Provider 工廠方法，用於創建 UploadProgressManagerImpl
final uploadProgressManagerProvider = Provider.family<UploadProgressManagerImpl, BuildContext?>((ref, context) {
  final notifier = ref.read(uploadProgressProvider.notifier);
  return UploadProgressManagerImpl(notifier, context: context);
});
