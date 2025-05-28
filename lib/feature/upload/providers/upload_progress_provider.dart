import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/upload_state.dart';

final uploadProgressProvider = StateNotifierProvider<UploadProgressNotifier, UploadState>((ref) {
  return UploadProgressNotifier();
});

class UploadProgressNotifier extends StateNotifier<UploadState> {
  UploadProgressNotifier() : super(const UploadState.idle());

  // 用於追蹤每個檔案的上傳進度
  final Map<String, int> _fileUploadedBytes = {};
  final Map<String, int> _fileTotalBytes = {};
  int _totalBytes = 0;
  int _completedFiles = 0;

  // 初始化上傳，設定總大小
  void initializeUpload({required List<int> fileSizes, required List<String> fileNames}) {
    _fileUploadedBytes.clear();
    _fileTotalBytes.clear();
    _completedFiles = 0;
    _totalBytes = 0;

    // 計算總字節數並初始化每個檔案的進度
    for (int i = 0; i < fileSizes.length; i++) {
      _totalBytes += fileSizes[i];
      _fileTotalBytes[fileNames[i]] = fileSizes[i];
      _fileUploadedBytes[fileNames[i]] = 0;
    }

    debugPrint('UploadProgress.initializeUpload: 總大小 = $_totalBytes bytes');
  }

  // 更新特定檔案的上傳進度
  void updateFileProgress({required String fileName, required int uploadedBytes, required int currentFileIndex, required int totalFiles}) {
    _fileUploadedBytes[fileName] = uploadedBytes;

    // 計算總已上傳字節數
    int totalUploadedBytes = 0;
    _fileUploadedBytes.forEach((key, value) {
      totalUploadedBytes += value;
    });

    // 計算整體進度
    double overallProgress = _totalBytes > 0 ? totalUploadedBytes / _totalBytes : 0.0;

    debugPrint('UploadProgress.updateFileProgress: $fileName - 已上傳 $uploadedBytes bytes');
    debugPrint('UploadProgress.updateFileProgress: 總進度 = ${(overallProgress * 100).toInt()}% ($totalUploadedBytes/$_totalBytes)');

    state = UploadState.uploading(
      overallProgress: overallProgress,
      totalBytes: _totalBytes,
      uploadedBytes: totalUploadedBytes,
      currentFileName: fileName,
      currentFileIndex: currentFileIndex,
      totalFiles: totalFiles,
      completedFiles: _completedFiles,
    );
  }

  // 標記檔案上傳完成
  void markFileCompleted(String fileName) {
    _completedFiles++;
    // 確保檔案的上傳字節數設為總大小
    if (_fileTotalBytes.containsKey(fileName)) {
      _fileUploadedBytes[fileName] = _fileTotalBytes[fileName]!;
    }
    debugPrint('UploadProgress.markFileCompleted: $fileName - 已完成 $_completedFiles 個檔案');
  }

  void setSuccess({required int successCount, required int totalCount}) {
    debugPrint('UploadProgress.setSuccess: $successCount/$totalCount');
    state = UploadState.success(successCount: successCount, totalCount: totalCount);
  }

  void setError({required String message, String? fileName}) {
    debugPrint('UploadProgress.setError: $message, fileName: $fileName');
    state = UploadState.error(message: message, fileName: fileName);
  }

  void reset() {
    debugPrint('UploadProgress.reset: 重置為 idle 狀態');
    _fileUploadedBytes.clear();
    _fileTotalBytes.clear();
    _totalBytes = 0;
    _completedFiles = 0;
    state = const UploadState.idle();
  }
}
