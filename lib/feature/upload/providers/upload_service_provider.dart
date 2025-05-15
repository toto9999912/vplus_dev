// lib/feature/upload/providers/upload_service_provider.dart
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:file_picker/file_picker.dart';
import 'package:path/path.dart' as path;
import 'package:mime/mime.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../enums/media_pick_error.dart';
import '../enums/upload_type.dart';
import '../models/media_pick_result.dart';
import '../models/media_pick_service_result.dart';

part 'upload_service_provider.g.dart';

@riverpod
UploadService uploadService(Ref ref) {
  return UploadService();
}

/// 處理裝置媒體存取的上傳服務
class UploadService {
  final ImagePicker _imagePicker = ImagePicker();

  /// 檢查並請求相機權限
  Future<bool> _checkCameraPermission() async {
    if (kIsWeb) return true;

    var status = await Permission.camera.status;
    if (status.isDenied) {
      status = await Permission.camera.request();
    }

    return status.isGranted;
  }

  /// 檢查並請求相冊權限
  Future<bool> _checkPhotosPermission() async {
    if (kIsWeb) return true;

    var status = await Permission.photos.status;
    if (status.isDenied) {
      status = await Permission.photos.request();
    }

    return status.isGranted;
  }

  /// 顯示底部彈跳視窗選擇上傳類型
  Future<UploadType?> showUploadOptionsBottomSheet(BuildContext context) async {
    return await showModalBottomSheet<UploadType>(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(16))),
      builder:
          (context) => SafeArea(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 16),
                  child: Text('選擇上傳類型', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                ),
                const Divider(height: 1),
                _buildOptionTile(context, icon: Icons.photo, title: '圖片', onTap: () => Navigator.pop(context, UploadType.image)),
                const Divider(height: 1),
                _buildOptionTile(context, icon: Icons.videocam, title: '影片', onTap: () => Navigator.pop(context, UploadType.video)),
                const Divider(height: 1),
                _buildOptionTile(context, icon: Icons.insert_drive_file, title: '檔案', onTap: () => Navigator.pop(context, UploadType.file)),
                Container(height: 8, color: Colors.grey.shade200),
                _buildOptionTile(context, icon: Icons.close, title: '取消', onTap: () => Navigator.pop(context)),
              ],
            ),
          ),
    );
  }

  /// 構建選項列表項
  Widget _buildOptionTile(BuildContext context, {required IconData icon, required String title, required VoidCallback onTap}) {
    return ListTile(leading: Icon(icon), title: Text(title), onTap: onTap);
  }

  /// 處理上傳選項的選擇
  Future<MediaPickServiceResult<List<MediaPickResult>>> handleUploadOptionSelection(
    UploadType? uploadType, {
    int maxWidth = 1080,
    int maxHeight = 1080,
    int imageQuality = 80,
    bool allowMultiple = true,
    List<String>? allowedExtensions,
  }) async {
    switch (uploadType) {
      case UploadType.image:
        return pickMultipleImagesFromGallery(maxWidth: maxWidth, maxHeight: maxHeight, imageQuality: imageQuality);
      case UploadType.video:
        return pickMultipleVideosFromGallery();
      case UploadType.file:
        return pickFiles(allowedExtensions: allowedExtensions, allowMultiple: allowMultiple);
      default:
        return MediaPickServiceResult.error(MediaPickError.cancelled, '未選擇上傳類型');
    }
  }

  /// 從相冊選擇多張圖片
  Future<MediaPickServiceResult<List<MediaPickResult>>> pickMultipleImagesFromGallery({
    required int maxWidth,
    required int maxHeight,
    int imageQuality = 80,
  }) async {
    try {
      final hasPermission = await _checkPhotosPermission();
      if (!hasPermission) {
        return MediaPickServiceResult.error(MediaPickError.permissionDenied, '相冊權限被拒絕');
      }

      final pickedFiles = await _imagePicker.pickMultiImage(
        maxWidth: maxWidth.toDouble(),
        maxHeight: maxHeight.toDouble(),
        imageQuality: imageQuality,
      );

      if (pickedFiles.isEmpty) {
        return MediaPickServiceResult.error(MediaPickError.cancelled, '使用者取消了操作');
      }

      final mediaResults = <MediaPickResult>[];

      for (final file in pickedFiles) {
        final result = await _processPickedImage(file);
        if (result.isSuccess && result.data != null) {
          mediaResults.add(result.data!);
        }
      }

      if (mediaResults.isEmpty) {
        return MediaPickServiceResult.error(MediaPickError.fileNotFound, '沒有選擇任何圖片或處理失敗');
      }

      return MediaPickServiceResult.success(mediaResults);
    } catch (e) {
      return MediaPickServiceResult.error(MediaPickError.unknownError, e.toString());
    }
  }

  /// 從相機拍攝圖片
  Future<MediaPickServiceResult<MediaPickResult>> pickImageFromCamera({required int maxWidth, required int maxHeight, int imageQuality = 80}) async {
    try {
      final hasPermission = await _checkCameraPermission();
      if (!hasPermission) {
        return MediaPickServiceResult.error(MediaPickError.permissionDenied, '相機權限被拒絕');
      }

      final pickedFile = await _imagePicker.pickImage(
        source: ImageSource.camera,
        maxWidth: maxWidth.toDouble(),
        maxHeight: maxHeight.toDouble(),
        imageQuality: imageQuality,
      );

      if (pickedFile == null) {
        return MediaPickServiceResult.error(MediaPickError.cancelled, '使用者取消了操作');
      }

      return _processPickedImage(pickedFile);
    } catch (e) {
      return MediaPickServiceResult.error(MediaPickError.unknownError, e.toString());
    }
  }

  /// 從相冊選擇圖片
  Future<MediaPickServiceResult<MediaPickResult>> pickImageFromGallery({required int maxWidth, required int maxHeight, int imageQuality = 80}) async {
    try {
      final hasPermission = await _checkPhotosPermission();
      if (!hasPermission) {
        return MediaPickServiceResult.error(MediaPickError.permissionDenied, '相冊權限被拒絕');
      }

      final pickedFile = await _imagePicker.pickImage(
        source: ImageSource.gallery,
        maxWidth: maxWidth.toDouble(),
        maxHeight: maxHeight.toDouble(),
        imageQuality: imageQuality,
      );

      if (pickedFile == null) {
        return MediaPickServiceResult.error(MediaPickError.cancelled, '使用者取消了操作');
      }

      return _processPickedImage(pickedFile);
    } catch (e) {
      return MediaPickServiceResult.error(MediaPickError.unknownError, e.toString());
    }
  }

  /// 處理選擇的圖片
  Future<MediaPickServiceResult<MediaPickResult>> _processPickedImage(XFile pickedFile) async {
    try {
      File? file;
      Uint8List? bytes;

      if (kIsWeb) {
        bytes = await pickedFile.readAsBytes();
      } else {
        file = File(pickedFile.path);
        bytes = await file.readAsBytes();
      }

      final fileName = path.basename(pickedFile.path);
      final mimeType = lookupMimeType(fileName) ?? 'image/jpeg';
      final fileSize = bytes.length;
      final localId = '${DateTime.now().millisecondsSinceEpoch}_$fileName';

      final result = MediaPickResult(file: file, bytes: bytes, fileName: fileName, mimeType: mimeType, fileSize: fileSize, localId: localId);

      return MediaPickServiceResult.success(result);
    } catch (e) {
      return MediaPickServiceResult.error(MediaPickError.unknownError, e.toString());
    }
  }

  /// 從相冊選擇多個影片
  Future<MediaPickServiceResult<List<MediaPickResult>>> pickMultipleVideosFromGallery() async {
    try {
      final hasPermission = await _checkPhotosPermission();
      if (!hasPermission) {
        return MediaPickServiceResult.error(MediaPickError.permissionDenied, '相冊權限被拒絕');
      }

      final result = await FilePicker.platform.pickFiles(type: FileType.video, allowMultiple: true);

      if (result == null || result.files.isEmpty) {
        return MediaPickServiceResult.error(MediaPickError.cancelled, '使用者取消了操作');
      }

      final mediaResults = <MediaPickResult>[];

      for (final platformFile in result.files) {
        File? file;
        Uint8List? bytes;

        if (kIsWeb) {
          bytes = platformFile.bytes;
        } else if (platformFile.path != null) {
          file = File(platformFile.path!);
          bytes = await file.readAsBytes();
        } else {
          continue; // 跳過無法處理的檔案
        }

        if (bytes == null) {
          continue;
        }

        final fileName = platformFile.name;
        final mimeType = lookupMimeType(fileName) ?? 'video/mp4';
        final fileSize = bytes.length;
        final localId = '${DateTime.now().millisecondsSinceEpoch}_$fileName';

        mediaResults.add(MediaPickResult(file: file, bytes: bytes, fileName: fileName, mimeType: mimeType, fileSize: fileSize, localId: localId));
      }

      if (mediaResults.isEmpty) {
        return MediaPickServiceResult.error(MediaPickError.fileNotFound, '沒有選擇任何影片或處理失敗');
      }

      return MediaPickServiceResult.success(mediaResults);
    } catch (e) {
      return MediaPickServiceResult.error(MediaPickError.unknownError, e.toString());
    }
  }

  /// 選擇檔案
  Future<MediaPickServiceResult<List<MediaPickResult>>> pickFiles({List<String>? allowedExtensions, bool allowMultiple = false}) async {
    try {
      FileType fileType = FileType.any;
      if (allowedExtensions != null && allowedExtensions.isNotEmpty) {
        fileType = FileType.custom;
      }

      final result = await FilePicker.platform.pickFiles(type: fileType, allowedExtensions: allowedExtensions, allowMultiple: allowMultiple);

      if (result == null || result.files.isEmpty) {
        return MediaPickServiceResult.error(MediaPickError.cancelled, '使用者取消了操作');
      }

      final mediaResults = <MediaPickResult>[];

      for (final platformFile in result.files) {
        File? file;
        Uint8List? bytes;

        if (kIsWeb) {
          bytes = platformFile.bytes;
        } else if (platformFile.path != null) {
          file = File(platformFile.path!);
          bytes = await file.readAsBytes();
        } else {
          continue; // 跳過無法處理的檔案
        }

        if (bytes == null) {
          continue;
        }

        final fileName = platformFile.name;
        final mimeType = lookupMimeType(fileName);
        final fileSize = bytes.length;
        final localId = '${DateTime.now().millisecondsSinceEpoch}_$fileName';

        mediaResults.add(MediaPickResult(file: file, bytes: bytes, fileName: fileName, mimeType: mimeType, fileSize: fileSize, localId: localId));
      }

      if (mediaResults.isEmpty) {
        return MediaPickServiceResult.error(MediaPickError.fileNotFound, '沒有選擇任何檔案或處理失敗');
      }

      return MediaPickServiceResult.success(mediaResults);
    } catch (e) {
      return MediaPickServiceResult.error(MediaPickError.unknownError, e.toString());
    }
  }

  /// 獲取檔案資訊
  static Map<String, dynamic> getFileInfo(MediaPickResult media) {
    return {
      'fileName': media.fileName,
      'mimeType': media.mimeType ?? 'application/octet-stream',
      'fileSize': media.fileSize,
      'localId': media.localId,
    };
  }
}
