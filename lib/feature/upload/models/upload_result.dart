import 'package:freezed_annotation/freezed_annotation.dart';
import '../enum/media_pick_error.dart';

part 'upload_result.freezed.dart';

@freezed
abstract class UploadResult<T> with _$UploadResult<T> {
  const factory UploadResult.success({required T data}) = _UploadSuccess<T>;

  const factory UploadResult.failure({required MediaPickError error, String? errorMessage}) = _UploadFailure<T>;

  const UploadResult._();

  bool get isSuccess => this is _UploadSuccess<T>;
  bool get isFailure => this is _UploadFailure<T>;
  T? get data => switch (this) {
    _UploadSuccess(:final data) => data,
    _ => null,
  };

  MediaPickError? get error => switch (this) {
    _UploadFailure(:final error) => error,
    _ => null,
  };

  String? get errorMessage => switch (this) {
    _UploadFailure(:final errorMessage) => errorMessage,
    _ => null,
  };
}
