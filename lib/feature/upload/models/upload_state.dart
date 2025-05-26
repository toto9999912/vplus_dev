import 'package:freezed_annotation/freezed_annotation.dart';

part 'upload_state.freezed.dart';

@freezed
sealed class UploadState with _$UploadState {
  const factory UploadState.idle() = _Idle;
  const factory UploadState.uploading({required double progress, required String fileName, required int currentIndex, required int totalFiles}) =
      _Uploading;
  const factory UploadState.success({required int successCount, required int totalCount}) = _Success;
  const factory UploadState.error({required String message, String? fileName}) = _Error;
}

// 手動實現的擴展方法，直到 freezed 文件生成
extension UploadStateExtension on UploadState {
  T when<T>({
    required T Function() idle,
    required T Function(double progress, String fileName, int currentIndex, int totalFiles) uploading,
    required T Function(int successCount, int totalCount) success,
    required T Function(String message, String? fileName) error,
  }) {
    switch (this) {
      case _Idle():
        return idle();
      case _Uploading(:final progress, :final fileName, :final currentIndex, :final totalFiles):
        return uploading(progress, fileName, currentIndex, totalFiles);
      case _Success(:final successCount, :final totalCount):
        return success(successCount, totalCount);
      case _Error(:final message, :final fileName):
        return error(message, fileName);
    }
  }
}
