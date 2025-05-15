// lib/feature/upload/providers/upload_progress_provider.dart
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'state/upload_progress_state.dart';

part 'upload_progress_provider.g.dart';

@riverpod
class UploadProgressNotifier extends _$UploadProgressNotifier {
  @override
  UploadProgressState build() {
    return const UploadProgressState();
  }

  /// 初始化上傳進度
  void initializeProgress(int totalFiles) {
    state = UploadProgressState(overallProgress: 0.0, totalFiles: totalFiles, completedFiles: 0, failedFiles: 0);
  }

  /// 更新整體上傳進度
  void updateOverallProgress(double increment) {
    final newProgress = (state.overallProgress + increment).clamp(0.0, 1.0);

    state = state.copyWith(overallProgress: newProgress);
  }

  /// 設置整體上傳進度為特定值
  void setOverallProgress(double progress) {
    state = state.copyWith(overallProgress: progress.clamp(0.0, 1.0));
  }

  /// 標記文件完成
  void fileCompleted({bool isSuccess = true}) {
    if (isSuccess) {
      state = state.copyWith(completedFiles: state.completedFiles + 1);
    } else {
      state = state.copyWith(failedFiles: state.failedFiles + 1);
    }
  }

  /// 重置進度
  void reset() {
    state = const UploadProgressState();
  }
}
