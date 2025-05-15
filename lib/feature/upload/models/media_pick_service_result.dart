import '../enums/media_pick_error.dart';

/// 媒體選擇結果
class MediaPickServiceResult<T> {
  final T? data;
  final MediaPickError? error;
  final String? errorMessage;

  bool get isSuccess => error == null && data != null;

  MediaPickServiceResult.success(this.data) : error = null, errorMessage = null;

  MediaPickServiceResult.error(this.error, [this.errorMessage]) : data = null;
}
