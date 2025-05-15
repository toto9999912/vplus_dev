// lib/feature/upload/models/upload_progress_state.dart
import 'package:freezed_annotation/freezed_annotation.dart';

part 'upload_progress_state.freezed.dart';
part 'upload_progress_state.g.dart';

@freezed
abstract class UploadProgressState with _$UploadProgressState {
  const factory UploadProgressState({
    @Default(0.0) double overallProgress,
    @Default(0) int totalFiles,
    @Default(0) int completedFiles,
    @Default(0) int failedFiles,
  }) = _UploadProgressState;

  const UploadProgressState._();

  bool get isAllCompleted => completedFiles + failedFiles == totalFiles;
  bool get isUploading => totalFiles > 0 && !isAllCompleted;

  factory UploadProgressState.fromJson(Map<String, dynamic> json) => _$UploadProgressStateFromJson(json);
}
