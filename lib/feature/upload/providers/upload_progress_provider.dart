import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../models/upload_state.dart';

part 'upload_progress_provider.g.dart';

@riverpod
class UploadProgress extends _$UploadProgress {
  @override
  UploadState build() => const UploadState.idle();

  void updateProgress({required double progress, required String fileName, required int currentIndex, required int totalFiles}) {
    state = UploadState.uploading(progress: progress, fileName: fileName, currentIndex: currentIndex, totalFiles: totalFiles);
  }

  void setSuccess({required int successCount, required int totalCount}) {
    state = UploadState.success(successCount: successCount, totalCount: totalCount);
  }

  void setError({required String message, String? fileName}) {
    state = UploadState.error(message: message, fileName: fileName);
  }

  void reset() {
    state = const UploadState.idle();
  }
}
