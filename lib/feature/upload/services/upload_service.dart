// lib/feature/upload/services/upload_service.dart
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:image_picker/image_picker.dart';
import 'package:file_picker/file_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import '../enum/media_pick_error.dart';
import '../enum/upload_type.dart';
import '../models/media_pick_result.dart';
import '../models/upload_result.dart';

class UploadService {
  final ImagePicker _imagePicker = ImagePicker();

  /// 處理上傳選項選擇
  Future<UploadResult<List<MediaPickResult>>> handleUploadOptionSelection(
    UploadType uploadType, {
    bool allowMultiple = false,
    double? maxWidth,
    double? maxHeight,
    int? imageQuality,
    int? maxFileSize, // in MB
  }) async {
    switch (uploadType) {
      case UploadType.camera:
        return pickImageFromCamera(maxWidth: maxWidth, maxHeight: maxHeight, imageQuality: imageQuality);

      case UploadType.image:
        return pickImages(allowMultiple: allowMultiple, maxWidth: maxWidth, maxHeight: maxHeight, imageQuality: imageQuality);

      case UploadType.video:
        return pickVideos(allowMultiple: allowMultiple);

      case UploadType.file:
        return pickFiles(allowMultiple: allowMultiple, maxFileSize: maxFileSize);
    }
  }

  /// 從相機拍攝圖片
  Future<UploadResult<List<MediaPickResult>>> pickImageFromCamera({double? maxWidth, double? maxHeight, int? imageQuality}) async {
    try {
      // 檢查相機權限
      final cameraStatus = await Permission.camera.request();
      if (!cameraStatus.isGranted) {
        return const UploadResult.failure(error: MediaPickError.permissionDenied, errorMessage: '相機權限被拒絕');
      }

      final XFile? photo = await _imagePicker.pickImage(
        source: ImageSource.camera,
        maxWidth: maxWidth,
        maxHeight: maxHeight,
        imageQuality: imageQuality,
      );

      if (photo == null) {
        return const UploadResult.failure(error: MediaPickError.cancelled, errorMessage: '用戶取消了拍攝');
      }

      final file = File(photo.path);
      final fileSize = await file.length();

      return UploadResult.success(data: [MediaPickResult(file: file, fileName: photo.name, mimeType: 'image/jpeg', fileSize: fileSize)]);
    } catch (e) {
      return UploadResult.failure(error: MediaPickError.unknown, errorMessage: e.toString());
    }
  }

  /// 選擇圖片
  Future<UploadResult<List<MediaPickResult>>> pickImages({bool allowMultiple = false, double? maxWidth, double? maxHeight, int? imageQuality}) async {
    try {
      // 檢查圖片庫權限
      final Permission permission =
          kIsWeb
              ? Permission.photos
              : Platform.isAndroid
              ? Permission.photos
              : Permission.photos;

      final status = await permission.request();
      if (!status.isGranted && !kIsWeb) {
        return const UploadResult.failure(error: MediaPickError.permissionDenied, errorMessage: '相簿權限被拒絕');
      }

      final List<XFile> images;
      if (allowMultiple) {
        images = await _imagePicker.pickMultiImage(maxWidth: maxWidth, maxHeight: maxHeight, imageQuality: imageQuality);
      } else {
        final image = await _imagePicker.pickImage(source: ImageSource.gallery, maxWidth: maxWidth, maxHeight: maxHeight, imageQuality: imageQuality);
        images = image != null ? [image] : [];
      }

      if (images.isEmpty) {
        return const UploadResult.failure(error: MediaPickError.cancelled, errorMessage: '用戶取消了選擇');
      }

      final results = <MediaPickResult>[];
      for (final image in images) {
        final file = File(image.path);
        final fileSize = await file.length();

        results.add(MediaPickResult(file: file, fileName: image.name, mimeType: image.mimeType ?? 'image/jpeg', fileSize: fileSize));
      }

      return UploadResult.success(data: results);
    } catch (e) {
      return UploadResult.failure(error: MediaPickError.unknown, errorMessage: e.toString());
    }
  }

  /// 選擇影片
  Future<UploadResult<List<MediaPickResult>>> pickVideos({bool allowMultiple = false}) async {
    try {
      if (allowMultiple) {
        // 使用 file_picker 選擇多個影片
        return pickFiles(allowMultiple: true, allowedExtensions: ['mp4', 'avi', 'mov', 'wmv', 'flv', 'mkv'], fileType: FileType.custom);
      } else {
        // 使用 image_picker 選擇單個影片
        final XFile? video = await _imagePicker.pickVideo(source: ImageSource.gallery);

        if (video == null) {
          return const UploadResult.failure(error: MediaPickError.cancelled, errorMessage: '用戶取消了選擇');
        }

        final file = File(video.path);
        final fileSize = await file.length();

        return UploadResult.success(
          data: [MediaPickResult(file: file, fileName: video.name, mimeType: video.mimeType ?? 'video/mp4', fileSize: fileSize)],
        );
      }
    } catch (e) {
      return UploadResult.failure(error: MediaPickError.unknown, errorMessage: e.toString());
    }
  }

  /// 選擇檔案
  Future<UploadResult<List<MediaPickResult>>> pickFiles({
    bool allowMultiple = false,
    FileType fileType = FileType.any,
    List<String>? allowedExtensions,
    int? maxFileSize, // in MB
  }) async {
    try {
      final result = await FilePicker.platform.pickFiles(allowMultiple: allowMultiple, type: fileType, allowedExtensions: allowedExtensions);

      if (result == null || result.files.isEmpty) {
        return const UploadResult.failure(error: MediaPickError.cancelled, errorMessage: '用戶取消了選擇');
      }

      final results = <MediaPickResult>[];
      for (final platformFile in result.files) {
        // 檢查檔案大小
        if (maxFileSize != null && platformFile.size > maxFileSize * 1024 * 1024) {
          return UploadResult.failure(error: MediaPickError.fileSizeExceeded, errorMessage: '檔案 ${platformFile.name} 超過大小限制 ($maxFileSize MB)');
        }

        File? file;
        if (platformFile.path != null) {
          file = File(platformFile.path!);
        } else if (!kIsWeb) {
          // 如果是非 web 平台但沒有路徑，跳過此檔案
          continue;
        }

        results.add(
          MediaPickResult(file: file, fileName: platformFile.name, mimeType: _getMimeType(platformFile.extension ?? ''), fileSize: platformFile.size),
        );
      }

      if (results.isEmpty) {
        return const UploadResult.failure(error: MediaPickError.unknown, errorMessage: '無法處理選擇的檔案');
      }

      return UploadResult.success(data: results);
    } catch (e) {
      return UploadResult.failure(error: MediaPickError.unknown, errorMessage: e.toString());
    }
  }

  /// 根據檔案副檔名獲取 MIME 類型
  String _getMimeType(String extension) {
    final ext = extension.toLowerCase();

    // 圖片
    if (['jpg', 'jpeg', 'png', 'gif', 'webp', 'bmp'].contains(ext)) {
      return 'image/$ext';
    }

    // 影片
    if (['mp4', 'avi', 'mov', 'wmv', 'flv', 'mkv'].contains(ext)) {
      return 'video/$ext';
    }

    // 文件
    if (ext == 'pdf') return 'application/pdf';
    if (['doc', 'docx'].contains(ext)) return 'application/msword';
    if (['xls', 'xlsx'].contains(ext)) return 'application/vnd.ms-excel';
    if (['ppt', 'pptx'].contains(ext)) return 'application/vnd.ms-powerpoint';
    if (ext == 'txt') return 'text/plain';
    if (ext == 'zip') return 'application/zip';
    if (ext == 'rar') return 'application/x-rar-compressed';

    return 'application/octet-stream';
  }

  /// 獲取檔案的上傳類型
  String getUploadTypeFromMimeType(String mimeType) {
    if (mimeType.startsWith('image/')) return 'image';
    if (mimeType.startsWith('video/')) return 'video';
    return 'file';
  }
}
