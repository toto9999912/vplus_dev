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

import '../providers/gallery_providers.dart';
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
          title: '請選擇操作',
          options: [
            BottomSheetOption(title: '拍攝', icon: Icons.camera_alt, value: UploadType.camera),
            BottomSheetOption(title: '圖片', icon: Icons.camera_alt, value: UploadType.image),
            BottomSheetOption(title: '影片', icon: Icons.photo_library, value: UploadType.video),
            BottomSheetOption(title: '檔案', icon: Icons.folder, value: UploadType.file),
            BottomSheetOption(title: '連結', icon: Icons.qr_code_scanner, value: UploadType.link),
            BottomSheetOption(title: '文字檔', icon: Icons.mic, value: UploadType.text),
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
  void handleMediaResult(WidgetRef ref, List<MediaPickResult> mediaResults) {
    // 初始化上傳進度追蹤
    ref.read(uploadProgressNotifierProvider.notifier).initializeProgress(mediaResults.length);

    // 這裡可以將媒體結果傳遞給您的上傳處理邏輯
    // 例如上傳到伺服器、保存到本地數據庫等
    for (final media in mediaResults) {
      print('處理文件: ${media.fileName}, 大小: ${media.fileSize}, 類型: ${media.mimeType}');
      // TODO: 實現實際的上傳邏輯
    }
  }

  // 處理選擇媒體時的錯誤
  void handlePickError(WidgetRef ref, MediaPickError? error, String? errorMessage) {
    // 顯示錯誤訊息給用戶
    if (error != null) {
      String message = errorMessage ?? '未知錯誤';
      switch (error) {
        case MediaPickError.permissionDenied:
          message = '需要權限才能訪問媒體';
          break;
        case MediaPickError.cancelled:
          // 用戶取消，通常不需要顯示錯誤
          return;
        case MediaPickError.fileNotFound:
          message = '找不到選擇的文件';
          break;
        case MediaPickError.unknownError:
          message = '處理媒體時發生錯誤: $errorMessage';
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
