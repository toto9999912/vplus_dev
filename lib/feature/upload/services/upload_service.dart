// lib/feature/upload/services/upload_service.dart
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:image_picker/image_picker.dart';
import 'package:file_picker/file_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:image/image.dart' as img;
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';
import '../enum/media_pick_error.dart';
import '../enum/upload_type.dart';
import '../models/media_pick_result.dart';
import '../models/upload_result.dart';
import 'upload_progress_manager_impl.dart';

class UploadService {
  final ImagePicker _imagePicker = ImagePicker();
  
  // 預設的圖片壓縮設定
  static const int _defaultMaxWidth = 1920;
  static const int _defaultMaxHeight = 1920;
  static const int _defaultImageQuality = 85;
  static const int _defaultMaxFileSize = 10; // MB

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

      File file = File(photo.path);
      
      // 自動壓縮圖片
      final compressedFile = await compressImage(
        file,
        maxWidth: maxWidth?.toInt(),
        maxHeight: maxHeight?.toInt(),
        quality: imageQuality,
      );
      
      if (compressedFile != null) {
        file = compressedFile;
      }
      
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
        File file = File(image.path);
        
        // 自動壓縮圖片
        final compressedFile = await compressImage(
          file,
          maxWidth: maxWidth?.toInt(),
          maxHeight: maxHeight?.toInt(),
          quality: imageQuality,
        );
        
        if (compressedFile != null) {
          file = compressedFile;
        }
        
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

  /// 壓縮圖片檔案
  Future<File?> compressImage(
    File imageFile, {
    int? maxWidth,
    int? maxHeight,
    int? quality,
    int? maxFileSizeKB,
  }) async {
    try {
      // 讀取圖片
      final imageBytes = await imageFile.readAsBytes();
      img.Image? image = img.decodeImage(imageBytes);
      
      if (image == null) return null;
      
      // 設定壓縮參數
      final targetWidth = maxWidth ?? _defaultMaxWidth;
      final targetHeight = maxHeight ?? _defaultMaxHeight;
      final targetQuality = quality ?? _defaultImageQuality;
      final maxSizeKB = maxFileSizeKB ?? (_defaultMaxFileSize * 1024);
      
      // 計算縮放比例
      double scale = 1.0;
      if (image.width > targetWidth || image.height > targetHeight) {
        final scaleX = targetWidth / image.width;
        final scaleY = targetHeight / image.height;
        scale = scaleX < scaleY ? scaleX : scaleY;
      }
      
      // 縮放圖片
      if (scale < 1.0) {
        final newWidth = (image.width * scale).round();
        final newHeight = (image.height * scale).round();
        image = img.copyResize(image, width: newWidth, height: newHeight);
      }
      
      // 壓縮並保存
      List<int> compressedBytes;
      final extension = path.extension(imageFile.path).toLowerCase();
      
      if (extension == '.png') {
        compressedBytes = img.encodePng(image);
      } else {
        compressedBytes = img.encodeJpg(image, quality: targetQuality);
      }
      
      // 如果壓縮後檔案仍然太大，進一步降低品質
      if (compressedBytes.length > maxSizeKB * 1024) {
        int adjustedQuality = targetQuality;
        while (compressedBytes.length > maxSizeKB * 1024 && adjustedQuality > 20) {
          adjustedQuality -= 10;
          if (extension == '.png') {
            // PNG 沒有品質參數，轉換為 JPEG
            compressedBytes = img.encodeJpg(image, quality: adjustedQuality);
          } else {
            compressedBytes = img.encodeJpg(image, quality: adjustedQuality);
          }
        }
      }
      
      // 建立暫存檔案
      final tempDir = await getTemporaryDirectory();
      final tempFile = File(path.join(tempDir.path, 
          'compressed_${DateTime.now().millisecondsSinceEpoch}.jpg'));
      
      await tempFile.writeAsBytes(compressedBytes);
      return tempFile;
      
    } catch (e) {
      debugPrint('圖片壓縮失敗: $e');
      return null;
    }
  }

  /// 驗證檔案類型
  bool isValidFileType(String fileName, List<String> allowedExtensions) {
    final extension = path.extension(fileName).toLowerCase().replaceFirst('.', '');
    return allowedExtensions.contains(extension);
  }

  /// 驗證檔案大小
  bool isValidFileSize(int fileSize, int maxSizeMB) {
    return fileSize <= maxSizeMB * 1024 * 1024;
  }

  /// 產生唯一檔案名稱
  String generateUniqueFileName(String originalName) {
    final extension = path.extension(originalName);
    final baseName = path.basenameWithoutExtension(originalName);
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    return '${baseName}_$timestamp$extension';
  }

  /// 清理暫存檔案
  Future<void> cleanupTempFiles() async {
    try {
      final tempDir = await getTemporaryDirectory();
      final tempFiles = tempDir.listSync()
          .whereType<File>()
          .where((file) => path.basename(file.path).startsWith('compressed_'));
      
      for (final file in tempFiles) {
        try {
          // 只刪除 1 小時前的暫存檔
          final fileAge = DateTime.now().millisecondsSinceEpoch - file.statSync().modified.millisecondsSinceEpoch;
          if (fileAge > 3600000) { // 1 小時 = 3600000 毫秒
            await file.delete();
          }
        } catch (e) {
          debugPrint('刪除暫存檔案失敗: $e');
        }
      }
    } catch (e) {
      debugPrint('清理暫存檔案失敗: $e');
    }
  }

  /// 處理多檔案上傳流程
  /// 該方法會管理整個上傳流程，包括進度管理
  /// [mediaResults] 要上傳的媒體檔案列表
  /// [uploadCallback] 實際執行上傳的回調函數，接收媒體檔案和進度回調
  /// [progressManager] 進度管理器
  /// [onSuccess] 上傳成功後的回調
  /// [onError] 上傳失敗後的回調
  Future<void> uploadMediaFiles({
    required List<MediaPickResult> mediaResults,
    required Future<void> Function(MediaPickResult media, Function(int sent, int total) onSendProgress) uploadCallback,
    required UploadProgressManager progressManager,
    VoidCallback? onSuccess,
    Function(String error)? onError,
  }) async {
    // 過濾有效的檔案並收集檔案資訊
    final validMediaResults = <MediaPickResult>[];
    final fileSizes = <int>[];
    final fileNames = <String>[];

    for (final media in mediaResults) {
      if (media.file != null) {
        fileSizes.add(media.fileSize);
        fileNames.add(media.fileName);
        validMediaResults.add(media);
      }
    }

    if (validMediaResults.isEmpty) {
      onError?.call('所選檔案都無效，無法上傳');
      return;
    }

    int successCount = 0;
    int failCount = 0;

    try {
      // 初始化並顯示進度
      progressManager.initializeUpload(fileSizes: fileSizes, fileNames: fileNames);

      // 上傳所有檔案
      for (int i = 0; i < validMediaResults.length; i++) {
        final media = validMediaResults[i];

        try {
          // 設定當前檔案的初始進度
          progressManager.updateFileProgress(
            fileName: media.fileName,
            uploadedBytes: 0,
            currentFileIndex: i + 1,
            totalFiles: validMediaResults.length,
          );

          // 執行實際上傳
          await uploadCallback(media, (sent, total) {
            progressManager.updateFileProgress(
              fileName: media.fileName,
              uploadedBytes: sent,
              currentFileIndex: i + 1,
              totalFiles: validMediaResults.length,
            );
          });

          // 標記檔案完成
          progressManager.markFileCompleted(media.fileName);
          successCount++;
        } catch (e) {
          failCount++;

          if (i == validMediaResults.length - 1 || failCount == validMediaResults.length) {
            progressManager.setError(message: '檔案 ${media.fileName} 上傳失敗: ${e.toString()}', fileName: media.fileName);
            await Future.delayed(const Duration(milliseconds: 800));
          }
        }
      }

      // 設置最終結果
      if (failCount == 0 && successCount > 0) {
        progressManager.setSuccess(successCount: successCount, totalCount: validMediaResults.length);
        onSuccess?.call();
      } else if (failCount > 0) {
        progressManager.setError(message: '上傳完成：成功 $successCount 個，失敗 $failCount 個', fileName: null);
      }
    } catch (e) {
      progressManager.setError(message: '上傳過程中出錯: ${e.toString()}', fileName: null);
      onError?.call(e.toString());
    }
  }
}
