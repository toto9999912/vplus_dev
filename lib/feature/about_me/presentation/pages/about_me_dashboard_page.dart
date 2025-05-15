import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http_parser/http_parser.dart';
import 'package:vplus_dev/core/network/api_client.dart';
import 'package:vplus_dev/core/providers/api_client_providers.dart';
import 'package:vplus_dev/feature/upload/models/media_pick_result.dart';
import 'package:vplus_dev/feature/upload/providers/upload_progress_provider.dart';
import 'package:vplus_dev/feature/upload/providers/upload_service_provider.dart';
import 'package:vplus_dev/feature/upload/widgets/upload_progress_widget.dart';

@RoutePage()
class AboutMeDashboardPage extends StatelessWidget {
  const AboutMeDashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const GalleryPage();
  }
}

class GalleryPage extends ConsumerWidget {
  const GalleryPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('圖庫'),
        actions: [IconButton(icon: const Icon(Icons.cloud_upload), onPressed: () => _showUploadOptions(context, ref))],
      ),
      body: Stack(
        children: [
          // 您的主要圖庫內容
          ListView(
            // 圖庫內容...
          ),

          // 上傳進度指示器
          Positioned(
            bottom: 16,
            left: 16,
            right: 16,
            child: UploadProgressWidget(
              onClose: () {
                ref.read(uploadProgressNotifierProvider.notifier).reset();
              },
            ),
          ),
        ],
      ),
    );
  }

  /// 顯示上傳選項
  Future<void> _showUploadOptions(BuildContext context, WidgetRef ref) async {
    final uploadService = ref.read(uploadServiceProvider);

    final uploadType = await uploadService.showUploadOptionsBottomSheet(context);

    if (uploadType != null) {
      final result = await uploadService.handleUploadOptionSelection(
        uploadType,
        maxWidth: 1920,
        maxHeight: 1080,
        imageQuality: 85,
        allowMultiple: true,
      );

      if (result.isSuccess && result.data != null) {
        final files = result.data!;

        // 初始化上傳進度
        ref.read(uploadProgressNotifierProvider.notifier).initializeProgress(files.length);

        // 開始上傳文件 - 這裡的邏輯由Gallery自己決定
        _uploadFilesToGallery(context, ref, files);
      } else if (result.error != null) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('選擇失敗: ${result.errorMessage ?? '未知錯誤'}'), backgroundColor: Colors.red));
        }
      }
    }
  }

  /// 上傳多個文件到Gallery (此方法由Gallery功能自行實現)
  Future<void> _uploadFilesToGallery(BuildContext context, WidgetRef ref, List<MediaPickResult> files) async {
    final progressNotifier = ref.read(uploadProgressNotifierProvider.notifier);
    final apiClient = ref.read(nestjsApiClientProvider);

    // 計算每個文件完成後對總進度的貢獻
    final progressIncrement = 1.0 / files.length;

    // 創建上傳任務列表
    final List<Future<void>> uploadTasks = [];

    for (final file in files) {
      uploadTasks.add(_uploadSingleFileToGallery(apiClient, file, progressNotifier, progressIncrement));
    }

    // 並行上傳所有文件
    await Future.wait(uploadTasks);

    // 完成後顯示通知
    if (context.mounted) {
      final progressState = ref.read(uploadProgressNotifierProvider);
      final hasFailures = progressState.failedFiles > 0;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(hasFailures ? '上傳完成，有 ${progressState.failedFiles} 個文件失敗' : '所有文件上傳成功！'),
          backgroundColor: hasFailures ? Colors.orange : Colors.green,
        ),
      );
    }
  }

  /// 上傳單個文件到Gallery (此方法由Gallery功能自行實現)
  Future<void> _uploadSingleFileToGallery(
    ApiClient apiClient,
    MediaPickResult file,
    UploadProgressNotifier progressNotifier,
    double progressIncrement,
  ) async {
    try {
      // Gallery特定的URL和formData屬性
      const String galleryUploadUrl = 'upload/1';

      final formData = FormData.fromMap({
        'file': MultipartFile.fromBytes(
          file.bytes!,
          filename: file.fileName,
          contentType: MediaType.parse(file.mimeType ?? 'application/octet-stream'),
        ),
        // Gallery特定的參數
        'tagsId': [450],
        'uploadType': 'image',
      });

      // 使用dio上傳文件
      await apiClient.postForm(
        galleryUploadUrl,
        data: formData,
        onSendProgress: (sent, total) {
          if (total != 0) {
            // 更新進度
            final progress = sent / total;
            progressNotifier.updateOverallProgress(progress * progressIncrement);
          }
        },
      );

      // 標記文件成功完成
      progressNotifier.fileCompleted(isSuccess: true);
    } catch (e) {
      // 標記文件上傳失敗
      progressNotifier.fileCompleted(isSuccess: false);

      print('上傳失敗: ${file.fileName} - ${e.toString()}');
    }
  }
}
