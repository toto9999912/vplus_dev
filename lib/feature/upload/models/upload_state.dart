import 'package:freezed_annotation/freezed_annotation.dart';

part 'upload_state.freezed.dart';

@freezed
sealed class UploadState with _$UploadState {
  const factory UploadState.idle() = _Idle;

  const factory UploadState.uploading({
    required double overallProgress, // 整體進度 (0.0 - 1.0)
    required int totalBytes, // 總字節數
    required int uploadedBytes, // 已上傳字節數
    required String currentFileName, // 當前上傳的檔案名
    required int currentFileIndex, // 當前檔案索引
    required int totalFiles, // 總檔案數
    required int completedFiles, // 已完成的檔案數
  }) = _Uploading;

  const factory UploadState.success({required int successCount, required int totalCount}) = _Success;

  const factory UploadState.error({required String message, String? fileName}) = _Error;
}

// 擴展方法，用於手動實現（如果 freezed 代碼生成失敗）
extension UploadStateExtension on UploadState {
  T when<T>({
    required T Function() idle,
    required T Function(
      double overallProgress,
      int totalBytes,
      int uploadedBytes,
      String currentFileName,
      int currentFileIndex,
      int totalFiles,
      int completedFiles,
    )
    uploading,
    required T Function(int successCount, int totalCount) success,
    required T Function(String message, String? fileName) error,
  }) {
    switch (this) {
      case _Idle():
        return idle();
      case _Uploading(
        :final overallProgress,
        :final totalBytes,
        :final uploadedBytes,
        :final currentFileName,
        :final currentFileIndex,
        :final totalFiles,
        :final completedFiles,
      ):
        return uploading(overallProgress, totalBytes, uploadedBytes, currentFileName, currentFileIndex, totalFiles, completedFiles);
      case _Success(:final successCount, :final totalCount):
        return success(successCount, totalCount);
      case _Error(:final message, :final fileName):
        return error(message, fileName);
    }
  }
}
