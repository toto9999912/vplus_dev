import 'dart:io';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'media_pick_result.freezed.dart';

@freezed
abstract class MediaPickResult with _$MediaPickResult {
  const factory MediaPickResult({File? file, required String fileName, required String mimeType, required int fileSize, String? thumbnailPath}) =
      _MediaPickResult;
}
