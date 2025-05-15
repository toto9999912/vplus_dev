// lib/feature/upload/models/media_pick_result.dart
import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'media_pick_result.freezed.dart';
part 'media_pick_result.g.dart';

/// 自定義 File 類型轉換器
class FileConverter implements JsonConverter<File?, String?> {
  const FileConverter();

  @override
  File? fromJson(String? json) {
    return json != null ? File(json) : null;
  }

  @override
  String? toJson(File? file) {
    return file?.path;
  }
}

/// 自定義 Uint8List 類型轉換器
class Uint8ListConverter implements JsonConverter<Uint8List?, String?> {
  const Uint8ListConverter();

  @override
  Uint8List? fromJson(String? json) {
    return json != null ? base64Decode(json) : null;
  }

  @override
  String? toJson(Uint8List? bytes) {
    return bytes != null ? base64Encode(bytes) : null;
  }
}

@freezed
abstract class MediaPickResult with _$MediaPickResult {
  const factory MediaPickResult({
    @FileConverter() File? file,
    @Uint8ListConverter() Uint8List? bytes,
    required String fileName,
    String? mimeType,
    required int fileSize,
    String? localId,
  }) = _MediaPickResult;

  factory MediaPickResult.fromJson(Map<String, dynamic> json) => _$MediaPickResultFromJson(json);
}
