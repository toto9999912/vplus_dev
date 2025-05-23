import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';
import 'package:vplus_dev/core/constants/app_color.dart';
import 'package:vplus_dev/core/providers/service_providers.dart';
import 'package:vplus_dev/core/router/app_router.gr.dart';
import 'package:vplus_dev/shared/enum/access_mode.dart';
import 'package:vplus_dev/shared/models/bottom_sheet_option.dart';

import '../../domain/entities/gallery_classifier.dart';
import '../providers/classifier_tag_provider.dart';
import '../providers/gallery_media_provider.dart';
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

  // 使用範例
  Future<void> showOptionsExample(WidgetRef ref) async {
    final uploadService = ref.read(uploadServiceProvider);
    final result = await ref
        .read(dialogServiceProvider)
        .showGridBottomSheet<UploadType>(
          title: '選項',
          options: [
            BottomSheetOption(title: '拍攝', icon: Icons.camera_alt, value: UploadType.camera),
            BottomSheetOption(title: '圖片', icon: Icons.image_rounded, value: UploadType.image),
            BottomSheetOption(title: '影片', icon: Icons.play_circle_rounded, value: UploadType.video),
            BottomSheetOption(title: '檔案', icon: Icons.folder, value: UploadType.file),
            BottomSheetOption(title: '連結', icon: Icons.link, value: UploadType.link),
            BottomSheetOption(title: '文字檔', icon: Icons.text_fields, value: UploadType.text),
            BottomSheetOption(title: 'Ai圖像分類', icon: FontAwesomeIcons.lightbulb, value: UploadType.ai),
          ],
        );

    if (result != null) {
      // 處理用戶選擇
      print('用戶選擇了: $result');

      // 根據選擇執行不同操作
      switch (result) {
        case UploadType.camera:
          final cameraResult = await uploadService.pickImageFromCamera(maxWidth: 1080, maxHeight: 1080, imageQuality: 80);

          // 開啟相機
          break;
        // 開啟圖片選擇器
        case UploadType.image:
        // 開啟影片選擇器
        case UploadType.video:
        // 開啟檔案選擇器
        case UploadType.file:
          final pickResult = await uploadService.handleUploadOptionSelection(
            result,
            maxWidth: 1080,
            maxHeight: 1080,
            imageQuality: 80,
            allowMultiple: true,
          );
          if (pickResult.isSuccess && pickResult.data != null) {
            // 處理選擇的媒體文件
            handleMediaResult(ref, pickResult.data!);
          } else {
            // 處理錯誤
            handlePickError(ref, pickResult.error, pickResult.errorMessage);
          }
          break;

        case UploadType.link:
          // 開啟連結掃描器
          break;

        case UploadType.text:
          // 開啟文字檔編輯器
          break;

        case UploadType.ai:
          // 開啟AI圖像分類器
          break;
      }
    }
  }

  // 處理選擇的媒體結果
  /// 處理選擇的媒體結果並上傳到伺服器
  /// 處理選擇的媒體結果並上傳到伺服器
  Future<void> handleMediaResult(WidgetRef ref, List<MediaPickResult> mediaResults) async {
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
      final mediaDataSource = await ref.read(remoteMediaDataSourceProvider.future);

      int successCount = 0;
      int failCount = 0;

      // 上傳所有檔案
      for (int i = 0; i < mediaResults.length; i++) {
        final media = mediaResults[i];
        try {
          // 上傳檔案
          await mediaDataSource.uploadGalleryMedia(
            uploadType: uploadType,
            galleryTypeId: galleryTypeId,
            file: media.file!,
            fileName: media.fileName,
            tagsId: selectedTagIds,
            onSendProgress: (sent, total) {
              // 更新單個檔案進度
              final fileProgress = sent / total;

              // 更新總體進度
              // (已完成的檔案 + 當前檔案進度) / 總檔案數
              final overallProgress = (successCount + failCount + fileProgress) / mediaResults.length;
            },
          );

          successCount++;

          // 記錄成功
          debugPrint('檔案 ${media.fileName} 上傳成功');
        } catch (e) {
          failCount++;

          // 記錄錯誤
          debugPrint('檔案 ${media.fileName} 上傳失敗: ${e.toString()}');

          // 短暫延遲，使用戶能看到錯誤訊息
          await Future.delayed(const Duration(milliseconds: 800));
        }
      }
    } catch (e) {
      // 處理整體錯誤
      ref.read(dialogServiceProvider).error('上傳過程中出錯', e.toString());
    } finally {}
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
              onPressed: () {},
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
