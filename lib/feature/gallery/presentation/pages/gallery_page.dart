import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:vplus_dev/core/constants/app_color.dart';
import 'package:vplus_dev/core/providers/service_providers.dart';
import 'package:vplus_dev/core/router/app_router.gr.dart';
import 'package:vplus_dev/feature/upload/enums/media_pick_error.dart';
import 'package:vplus_dev/feature/upload/enums/upload_type.dart';
import 'package:vplus_dev/feature/upload/models/media_pick_result.dart';
import 'package:vplus_dev/feature/upload/providers/upload_progress_provider.dart';
import 'package:vplus_dev/feature/upload/providers/upload_service_provider.dart';
import 'package:vplus_dev/shared/enum/access_mode.dart';
import 'package:vplus_dev/shared/models/bottom_sheet_option.dart';

import '../providers/gallery_media_provider.dart';
import '../providers/gallery_providers.dart';
import '../providers/selected_tag_provider.dart';
import '../widgets/classifier_tag_screen.dart';
import '../widgets/galley_tabbar.dart';

@RoutePage()
class GalleryPage extends StatelessWidget {
  const GalleryPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const AutoRouter();
  }
}

@RoutePage()
class GalleryHeaderPage extends ConsumerWidget {
  const GalleryHeaderPage({super.key});

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
    if (mediaResults.isEmpty) return;

    // 初始化上傳進度追蹤
    final progressNotifier = ref.read(uploadProgressNotifierProvider.notifier);
    progressNotifier.initializeProgress(mediaResults.length);

    try {
      // 取得當前選中的 Gallery Type
      final selectedTypeAsync = await ref.read(selectedGalleryTypeProvider.future);
      final galleryTypeId = selectedTypeAsync.id;

      // 取得當前選中的標籤 IDs
      final selectedTagIds = ref.read(selectedTagIdsProvider);

      if (selectedTagIds.isEmpty) {
        // 如果沒有選擇標籤，顯示警告
        ref
            .read(dialogServiceProvider)
            .warning(
              '缺少標籤',
              '請先選擇至少一個標籤以便分類上傳的檔案',
              onOk: () {
                // 重置上傳進度
                progressNotifier.reset();
              },
            );
        return;
      }

      // 取得媒體資料來源
      final mediaDataSource = await ref.read(remoteMediaDataSourceProvider.future);

      // 取得對話框服務
      final dialogService = ref.read(dialogServiceProvider);

      // 顯示上傳進度對話框 (使用圓形進度條)
      final progressController = dialogService.showMediaUploadDialog(
        title: '上傳媒體檔案',
        initialMessage: '正在準備上傳...',
        totalFiles: mediaResults.length,
        showCancelButton: true,
        onCancel: () {
          // TODO: 實作取消上傳功能
          debugPrint('上傳已被使用者取消');
        },
      );

      int successCount = 0;
      int failCount = 0;

      // 上傳所有檔案
      for (int i = 0; i < mediaResults.length; i++) {
        final media = mediaResults[i];
        try {
          // 更新進度訊息，顯示正在處理的檔案
          progressController.updateMessage('上傳中: ${media.fileName}');

          // 確定上傳類型
          String uploadType;
          if (media.mimeType?.startsWith('image/') ?? false) {
            uploadType = 'image';
          } else if (media.mimeType?.startsWith('video/') ?? false) {
            uploadType = 'video';
          } else {
            uploadType = 'file';
          }

          // 確保有可上傳的檔案
          if (media.file == null) {
            throw Exception('無法上傳：檔案物件不可用');
          }

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

              // 更新進度條
              progressController.updateProgress(overallProgress);

              // 更新狀態提供者 (如果需要在其他UI元素顯示進度)
              progressNotifier.setOverallProgress(overallProgress);
            },
          );

          // 標記檔案上傳成功
          progressNotifier.fileCompleted(isSuccess: true);
          successCount++;
          progressController.incrementCompletedFiles();

          // 更新進度條訊息
          progressController.updateMessage('${media.fileName} 上傳成功');

          // 記錄成功
          debugPrint('檔案 ${media.fileName} 上傳成功');
        } catch (e) {
          // 標記檔案上傳失敗
          progressNotifier.fileCompleted(isSuccess: false);
          failCount++;
          progressController.incrementCompletedFiles();

          // 更新進度條訊息
          progressController.updateMessage('${media.fileName} 上傳失敗: ${e.toString()}');

          // 記錄錯誤
          debugPrint('檔案 ${media.fileName} 上傳失敗: ${e.toString()}');

          // 短暫延遲，使用戶能看到錯誤訊息
          await Future.delayed(const Duration(milliseconds: 800));
        }
      }

      // 更新最終訊息
      if (failCount == 0) {
        progressController.updateMessage('全部 $successCount 個檔案上傳成功!');
      } else if (successCount == 0) {
        progressController.updateMessage('全部 $failCount 個檔案上傳失敗!');
      } else {
        progressController.updateMessage('上傳結果: $successCount 成功, $failCount 失敗');
      }

      // 設置進度為100%
      progressController.updateProgress(1.0);

      // 延遲關閉進度對話框，讓用戶有時間看到最終結果
      await Future.delayed(const Duration(seconds: 2));
      progressController.close();

      // 顯示上傳結果
      if (failCount == 0) {
        dialogService.success('上傳成功', '全部 $successCount 個檔案已成功上傳');
      } else if (successCount == 0) {
        dialogService.error('上傳失敗', '全部 $failCount 個檔案上傳失敗');
      } else {
        dialogService.warning('部分上傳成功', '成功: $successCount 個檔案, 失敗: $failCount 個檔案');
      }

      // 上傳完成後重新載入媒體列表
      if (successCount > 0) {
        ref.invalidate(galleryMediaNotifierProvider);
      }
    } catch (e) {
      // 處理整體錯誤
      ref.read(dialogServiceProvider).error('上傳過程中出錯', e.toString());
    } finally {
      // 重置進度狀態
      progressNotifier.reset();
    }
  }

  // 處理選擇媒體時的錯誤
  void handlePickError(WidgetRef ref, MediaPickError? error, String? errorMessage) {
    // 顯示錯誤訊息給用戶
    if (error != null) {
      switch (error) {
        case MediaPickError.permissionDenied:
          break;
        case MediaPickError.cancelled:
          // 用戶取消，通常不需要顯示錯誤
          return;
        case MediaPickError.fileNotFound:
          break;
        case MediaPickError.unknownError:
          break;
      }
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final galleryTypesAsync = ref.watch(galleryTypesProvider);
    return galleryTypesAsync.when(
      data: (galleryTypes) {
        return AutoTabsRouter.tabBar(
          routes: galleryTypes.map((type) => const GalleryWrapperRoute()).toList(),
          builder: (context, child, tabController) {
            return Scaffold(
              floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
              floatingActionButton: FloatingActionButton(
                shape: const CircleBorder(),
                onPressed: () => showOptionsExample(ref),
                backgroundColor: AppColors.darkGold, // 使用你應用中的主題顏色
                foregroundColor: Colors.white,
                child: const Icon(Icons.upload),
              ),
              appBar: AppBar(
                automaticallyImplyLeading: false,
                title: TabBar(
                  onTap: (index) => ref.watch(selectedGalleryTypeIndexProvider.notifier).setIndex(index),
                  controller: tabController,
                  isScrollable: true,
                  indicatorPadding: const EdgeInsets.only(bottom: 6),
                  indicatorSize: TabBarIndicatorSize.label,
                  tabs: galleryTypes.map((type) => Tab(text: type.title)).toList(),
                ),
              ),
              body: child,
            );
          },
        );
      },
      error: (error, stackTrace) {
        return Text(error.toString());
      },
      loading: () => const Center(child: CircularProgressIndicator()),
    );
  }
}

@RoutePage()
class GalleryWrapperScreen extends StatelessWidget {
  const GalleryWrapperScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const AutoRouter();
  }
}

@RoutePage()
class GalleryViewScreen extends ConsumerWidget {
  const GalleryViewScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final activeGalleryTypeAsync = ref.watch(selectedGalleryTypeProvider);
    return activeGalleryTypeAsync.when(
      data: (galleryType) {
        return DefaultTabController(
          length: galleryType.classifiers.length,
          child: Column(
            children: [
              GalleryTabBar(
                classifiers: galleryType.classifiers,
                onTap: (index) {
                  ref.watch(selectedGalleryClassifierIndexProvider.notifier).setIndex(index);
                },
              ),
              Expanded(
                child: TabBarView(
                  children:
                      galleryType.classifiers.map((classifier) {
                        return ClassifierTagScreen(accessMode: AccessMode.readWrite, classifierId: classifier.id);
                      }).toList(),
                ),
              ),
            ],
          ),
        );
      },
      error: (error, stackTrace) => ErrorWidget(error),
      loading: () {
        return const Text("loading");
      },
    );
  }
}
