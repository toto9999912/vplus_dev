import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';
import 'package:vplus_dev/core/constants/app_color.dart';
import 'package:vplus_dev/core/providers/service_providers.dart';
import 'package:vplus_dev/core/router/app_router.gr.dart';
import 'package:vplus_dev/feature/upload/enum/media_pick_error.dart';
import 'package:vplus_dev/feature/upload/models/media_pick_result.dart';
import 'package:vplus_dev/feature/upload/providers/upload_progress_provider.dart';
import 'package:vplus_dev/feature/upload/providers/upload_service_provider.dart';
import 'package:vplus_dev/feature/upload/widgets/upload_progress_dialog.dart';
import 'package:vplus_dev/shared/enum/access_mode.dart';
import 'package:vplus_dev/shared/models/bottom_sheet_option.dart';

import '../../domain/entities/gallery_classifier.dart';
import '../../domain/enums/gallery_upload_type.dart';
import '../providers/classifier_tag_provider.dart';

import '../providers/gallery_providers.dart';
import '../providers/selected_tag_provider.dart';
import 'selected_tag_section.dart';
import 'tag_categroy_view.dart';
import 'snackbar_listener.dart';

class ClassifierTagScreen extends ConsumerStatefulWidget {
  final int classifierId;
  final int? projectId;
  final AccessMode accessMode;
  const ClassifierTagScreen({required this.classifierId, required this.accessMode, this.projectId, super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _ClassifierTagScreenState();
}

class _ClassifierTagScreenState extends ConsumerState<ClassifierTagScreen> {
  void scrollToIndex(int index, ItemScrollController controller) {
    controller.scrollTo(index: index, duration: const Duration(milliseconds: 100));
  }

  /// 顯示上傳選項底部彈窗
  Future<void> showUploadOptions() async {
    final result = await ref
        .read(dialogServiceProvider)
        .showGridBottomSheet<GalleryUploadType>(
          title: '選擇上傳方式',
          options: [
            BottomSheetOption(title: GalleryUploadType.camera.label, icon: Icons.camera_alt, value: GalleryUploadType.camera),
            BottomSheetOption(title: GalleryUploadType.image.label, icon: Icons.image_rounded, value: GalleryUploadType.image),
            BottomSheetOption(title: GalleryUploadType.video.label, icon: Icons.play_circle_rounded, value: GalleryUploadType.video),
            BottomSheetOption(title: GalleryUploadType.file.label, icon: Icons.folder, value: GalleryUploadType.file),
            BottomSheetOption(title: GalleryUploadType.link.label, icon: Icons.link, value: GalleryUploadType.link),
            BottomSheetOption(title: GalleryUploadType.text.label, icon: Icons.text_fields, value: GalleryUploadType.text),
            BottomSheetOption(title: GalleryUploadType.ai.label, icon: FontAwesomeIcons.lightbulb, value: GalleryUploadType.ai),
          ],
        );

    if (result != null) {
      await _handleUploadType(result);
    }
  }

  /// 處理不同的上傳類型
  Future<void> _handleUploadType(GalleryUploadType uploadType) async {
    final uploadService = ref.read(uploadServiceProvider);

    switch (uploadType) {
      case GalleryUploadType.camera:
        final result = await uploadService.pickImageFromCamera(maxWidth: 1080, maxHeight: 1080, imageQuality: 80);

        if (result.isSuccess && result.data != null) {
          await handleMediaResult(ref, result.data!, uploadType);
        } else if (result.isFailure) {
          _showPickError(ref, result.error, result.errorMessage);
        }
        break;

      case GalleryUploadType.image:
      case GalleryUploadType.video:
      case GalleryUploadType.file:
        final result = await uploadService.handleUploadOptionSelection(
          uploadType.toUploadType,
          allowMultiple: true,
          maxWidth: 1080,
          maxHeight: 1080,
          imageQuality: 80,
        );

        if (result.isSuccess && result.data != null) {
          await handleMediaResult(ref, result.data!, uploadType);
        } else if (result.isFailure) {
          _showPickError(ref, result.error, result.errorMessage);
        }
        break;

      case GalleryUploadType.link:
        break;

      case GalleryUploadType.text:
        break;

      case GalleryUploadType.ai:
        break;
    }
  }

  /// 顯示選擇媒體時的錯誤
  void _showPickError(WidgetRef ref, MediaPickError? error, String? errorMessage) {
    final dialogService = ref.read(dialogServiceProvider);
    String message = errorMessage ?? '選擇媒體時發生未知錯誤';

    // 根據不同的錯誤類型顯示適當的訊息
    if (error == MediaPickError.permissionDenied) {
      message = '無法取得權限，請到系統設定中允許應用程式存取媒體。';
    } else if (error == MediaPickError.cancelled) {
      // 用戶取消操作，不顯示錯誤
      return;
    }

    dialogService.error('上傳失敗', message);
  }

  // 處理選擇的媒體結果並上傳到伺服器
  Future<void> handleMediaResult(WidgetRef ref, List<MediaPickResult> mediaResults, GalleryUploadType uploadType) async {
    debugPrint('handleMediaResult: 開始處理 ${mediaResults.length} 個媒體檔案');
    try {
      // 取得當前選中的 Gallery Type
      final selectedTypeAsync = await ref.read(selectedGalleryTypeProvider.future);
      final galleryTypeId = selectedTypeAsync.id;

      // 取得當前選中的標籤 IDs
      final selectedTagIds = ref.read(selectedTagIdsProvider);

      if (selectedTagIds.isEmpty) {
        // 如果沒有選擇標籤，顯示警告
        ref.read(dialogServiceProvider).warning('缺少標籤', '請先選擇至少一個標籤以便分類上傳的檔案', onOk: () {});
        return;
      }

      // 取得媒體資料來源
      final mediaDataSource = await ref.read(remoteMediaDataSourceProvider.future); // 取得上傳進度通知器
      final uploadProgress = ref.read(uploadProgressProvider.notifier); // 重置上傳進度狀態
      debugPrint('重置上傳進度狀態');
      uploadProgress.reset(); // 顯示上傳進度對話框
      debugPrint('顯示上傳進度對話框');
      if (context.mounted) {
        UploadProgressDialog.show(context);
      }

      // 短暫延遲確保對話框顯示
      debugPrint('等待對話框顯示...');
      await Future.delayed(const Duration(milliseconds: 500));

      int successCount = 0;
      int failCount = 0;

      // 決定上傳類型字串
      final String uploadTypeStr =
          uploadType == GalleryUploadType.image
              ? 'image'
              : uploadType == GalleryUploadType.video
              ? 'video'
              : 'file';

      // 上傳所有檔案
      for (int i = 0; i < mediaResults.length; i++) {
        final media = mediaResults[i];
        try {
          if (media.file == null) {
            debugPrint('檔案 ${media.fileName} 無效，跳過');
            failCount++;
            uploadProgress.setError(message: '檔案 ${media.fileName} 無效', fileName: media.fileName);
            await Future.delayed(const Duration(milliseconds: 800));
            continue;
          }

          // 更新上傳進度（開始上傳）
          debugPrint('開始上傳檔案: ${media.fileName} (${i + 1}/${mediaResults.length})');
          uploadProgress.updateProgress(progress: 0.0, fileName: media.fileName, currentIndex: i + 1, totalFiles: mediaResults.length);
          debugPrint('已調用 updateProgress，狀態應該是 uploading');

          // 上傳檔案
          debugPrint('調用 uploadGalleryMedia...');
          await mediaDataSource.uploadGalleryMedia(
            uploadType: uploadTypeStr,
            galleryTypeId: galleryTypeId,
            file: media.file!,
            fileName: media.fileName,
            tagsId: selectedTagIds,
            onSendProgress: (sent, total) {
              // 更新單個檔案進度
              final fileProgress = sent / total;
              debugPrint('上傳進度: ${media.fileName} - ${(fileProgress * 100).toInt()}% ($sent/$total)');

              // 更新進度
              uploadProgress.updateProgress(progress: fileProgress, fileName: media.fileName, currentIndex: i + 1, totalFiles: mediaResults.length);
            },
          );

          // 確保上傳完成後設置為 100%
          debugPrint('檔案上傳完成: ${media.fileName}');
          uploadProgress.updateProgress(progress: 1.0, fileName: media.fileName, currentIndex: i + 1, totalFiles: mediaResults.length);

          successCount++;

          // 記錄成功
          debugPrint('檔案 ${media.fileName} 上傳成功');
        } catch (e) {
          failCount++;

          // 設置錯誤狀態
          uploadProgress.setError(message: '檔案 ${media.fileName} 上傳失敗: ${e.toString()}', fileName: media.fileName);

          // 記錄錯誤
          debugPrint('檔案 ${media.fileName} 上傳失敗: ${e.toString()}');

          // 短暫延遲，使用戶能看到錯誤訊息
          await Future.delayed(const Duration(milliseconds: 800));
        }
      } // 設置最終結果
      if (failCount == 0 && successCount > 0) {
        debugPrint('所有檔案上傳成功，設置成功狀態');
        uploadProgress.setSuccess(successCount: successCount, totalCount: mediaResults.length);
      } else if (failCount > 0) {
        debugPrint('上傳完成但有失敗，設置錯誤狀態');
        uploadProgress.setError(message: '上傳完成：成功 $successCount 個，失敗 $failCount 個', fileName: null);
      }
    } catch (e) {
      // 處理整體錯誤
      debugPrint('handleMediaResult: 整體錯誤 - $e');

      // 設置錯誤狀態
      ref.read(uploadProgressProvider.notifier).setError(message: '上傳過程中出錯: ${e.toString()}', fileName: null);

      // 顯示錯誤對話框
      ref.read(dialogServiceProvider).error('上傳過程中出錯', e.toString());
    }
  }

  @override
  Widget build(BuildContext context) {
    final ItemScrollController itemScrollController = ItemScrollController();
    final classifierAsync = ref.watch(classifierTagNotifierProvider(widget.classifierId, widget.projectId));

    return classifierAsync.when(
      data:
          (classifier) => Scaffold(
            floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
            floatingActionButton: FloatingActionButton(
              shape: const CircleBorder(),
              onPressed: () {
                showUploadOptions();
              },
              backgroundColor: AppColors.darkGold, // 使用你應用中的主題顏色
              foregroundColor: Colors.white,
              child: const Icon(Icons.upload),
            ),
            body: SnackbarListener(
              child: Column(
                children: [buildHeader(classifier, itemScrollController), buildSelectedTags(), buildTagView(classifier, itemScrollController)],
              ),
            ),
          ),
      error: (error, stackTrace) => ErrorWidget(error),
      loading: () => const CircularProgressIndicator(),
    );
  }

  Widget buildSelectedTags() {
    return SizedBox(
      height: 48,
      child: Row(
        children: [
          const Expanded(child: SelectedTagSection()),
          TextButton(
            onPressed: () {
              context.pushRoute(const GalleryMediaRoute());
            },
            child: const Text('搜尋'),
          ),
        ],
      ),
    );
  }

  /// 頂部標籤欄
  Widget buildHeader(Classifier classifier, ItemScrollController itemScrollController) {
    return SizedBox(
      height: 48,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        shrinkWrap: true,
        itemBuilder: (context, index) {
          Classifier subClassifier = classifier.subClassifiers![index];
          return TextButton(
            key: ValueKey(index),
            onPressed: () => scrollToIndex(index, itemScrollController),
            style: const ButtonStyle(),
            child: Text(subClassifier.titleZhTw),
          );
        },
        itemCount: classifier.subClassifiers!.length,
      ),
    );
  }

  Widget buildTagView(Classifier classifier, ItemScrollController itemScrollController) {
    return Expanded(
      child: ScrollablePositionedList.builder(
        itemCount: classifier.subClassifiers!.length,
        itemScrollController: itemScrollController,
        shrinkWrap: true,
        itemBuilder: (context, subClassifierIndex) {
          Classifier subClassifier = classifier.subClassifiers![subClassifierIndex];
          return Column(
            children: [
              Padding(padding: const EdgeInsets.only(bottom: 8), child: Text(subClassifier.titleZhTw, style: const TextStyle(fontSize: 12))),
              TagCategroyView(
                projectId: widget.projectId,
                categories: subClassifier.categories!,
                subClassifierIndex: subClassifierIndex,
                classifierId: widget.classifierId,
              ),
            ],
          );
        },
      ),
    );
  }
}
