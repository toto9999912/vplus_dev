import 'package:flutter/foundation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../models/upload_state.dart';

part 'upload_progress_provider.g.dart';

@riverpod
class UploadProgress extends _$UploadProgress {
  @override
  UploadState build() => const UploadState.idle();
  void updateProgress({required double progress, required String fileName, required int currentIndex, required int totalFiles}) {
    debugPrint('UploadProgress.updateProgress: $fileName - ${(progress * 100).toInt()}% ($currentIndex/$totalFiles)');
    final newState = UploadState.uploading(progress: progress, fileName: fileName, currentIndex: currentIndex, totalFiles: totalFiles);
    debugPrint('UploadProgress.updateProgress: 設置新狀態為 uploading');
    state = newState;
    debugPrint('UploadProgress.updateProgress: 狀態已更新，當前狀態類型 = ${state.runtimeType}');
  }

  void setSuccess({required int successCount, required int totalCount}) {
    debugPrint('UploadProgress.setSuccess: $successCount/$totalCount');
    state = UploadState.success(successCount: successCount, totalCount: totalCount);
    debugPrint('UploadProgress.setSuccess: 狀態已更新為 success');
  }

  void setError({required String message, String? fileName}) {
    debugPrint('UploadProgress.setError: $message, fileName: $fileName');
    state = UploadState.error(message: message, fileName: fileName);
    debugPrint('UploadProgress.setError: 狀態已更新為 error');
  }

  void reset() {
    debugPrint('UploadProgress.reset: 重置為 idle 狀態');
    state = const UploadState.idle();
  }
}
