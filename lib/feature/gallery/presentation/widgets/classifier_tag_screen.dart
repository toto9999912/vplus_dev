import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';
import 'package:vplus_dev/core/constants/app_color.dart';
import 'package:vplus_dev/core/providers/service_providers.dart';
import 'package:vplus_dev/core/router/app_router.gr.dart';
import 'package:vplus_dev/feature/upload/enum/upload_type.dart';
import 'package:vplus_dev/feature/upload/providers/upload_service_provider.dart';
import 'package:vplus_dev/shared/enum/access_mode.dart';
import 'package:vplus_dev/shared/models/bottom_sheet_option.dart';

import '../../domain/entities/gallery_classifier.dart';
import '../providers/classifier_tag_provider.dart';

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
        .showGridBottomSheet<UploadType>(
          title: '選擇上傳方式',
          options: [
            BottomSheetOption(title: UploadType.camera.label, icon: Icons.camera_alt, value: UploadType.camera),
            BottomSheetOption(title: UploadType.image.label, icon: Icons.image_rounded, value: UploadType.image),
            BottomSheetOption(title: UploadType.video.label, icon: Icons.play_circle_rounded, value: UploadType.video),
            BottomSheetOption(title: UploadType.file.label, icon: Icons.folder, value: UploadType.file),
            BottomSheetOption(title: UploadType.link.label, icon: Icons.link, value: UploadType.link),
            BottomSheetOption(title: UploadType.text.label, icon: Icons.text_fields, value: UploadType.text),
            BottomSheetOption(title: UploadType.ai.label, icon: FontAwesomeIcons.lightbulb, value: UploadType.ai),
          ],
        );

    if (result != null) {
      await _handleUploadType(result);
    }
  }

  /// 處理不同的上傳類型
  Future<void> _handleUploadType(UploadType uploadType) async {
    final uploadService = ref.read(uploadServiceProvider);

    switch (uploadType) {
      case UploadType.camera:
        final result = await uploadService.pickImageFromCamera(maxWidth: 1080, maxHeight: 1080, imageQuality: 80);

        // await result.map(
        //   success: (s) async => await _uploadMediaFiles(context, ref, s.data),
        //   failure: (f) => _showPickError(context, ref, f.error, f.errorMessage),
        // );
        break;

      case UploadType.image:
      case UploadType.video:
      case UploadType.file:
        break;

      case UploadType.link:
        break;

      case UploadType.text:
        break;

      case UploadType.ai:
        break;
    }
  }

  // 處理選擇的媒體結果
  /// 處理選擇的媒體結果並上傳到伺服器
  /// 處理選擇的媒體結果並上傳到伺服器
  // Future<void> handleMediaResult(WidgetRef ref, List<MediaPickResult> mediaResults) async {
  //   try {
  //     // 取得當前選中的 Gallery Type
  //     final selectedTypeAsync = await ref.read(selectedGalleryTypeProvider.future);
  //     final galleryTypeId = selectedTypeAsync.id;

  //     // 取得當前選中的標籤 IDs
  //     final selectedTagIds = ref.read(selectedTagIdsProvider);

  //     if (selectedTagIds.isEmpty) {
  //       // 如果沒有選擇標籤，顯示警告
  //       ref.read(dialogServiceProvider).warning('缺少標籤', '請先選擇至少一個標籤以便分類上傳的檔案', onOk: () {});
  //       return;
  //     }

  //     // 取得媒體資料來源
  //     final mediaDataSource = await ref.read(remoteMediaDataSourceProvider.future);

  //     int successCount = 0;
  //     int failCount = 0;

  //     // 上傳所有檔案
  //     for (int i = 0; i < mediaResults.length; i++) {
  //       final media = mediaResults[i];
  //       try {
  //         // 上傳檔案
  //         await mediaDataSource.uploadGalleryMedia(
  //           uploadType: uploadType,
  //           galleryTypeId: galleryTypeId,
  //           file: media.file!,
  //           fileName: media.fileName,
  //           tagsId: selectedTagIds,
  //           onSendProgress: (sent, total) {
  //             // 更新單個檔案進度
  //             final fileProgress = sent / total;

  //             // 更新總體進度
  //             // (已完成的檔案 + 當前檔案進度) / 總檔案數
  //             final overallProgress = (successCount + failCount + fileProgress) / mediaResults.length;
  //           },
  //         );

  //         successCount++;

  //         // 記錄成功
  //         debugPrint('檔案 ${media.fileName} 上傳成功');
  //       } catch (e) {
  //         failCount++;

  //         // 記錄錯誤
  //         debugPrint('檔案 ${media.fileName} 上傳失敗: ${e.toString()}');

  //         // 短暫延遲，使用戶能看到錯誤訊息
  //         await Future.delayed(const Duration(milliseconds: 800));
  //       }
  //     }
  //   } catch (e) {
  //     // 處理整體錯誤
  //     ref.read(dialogServiceProvider).error('上傳過程中出錯', e.toString());
  //   } finally {}
  // }

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
