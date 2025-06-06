import 'package:auto_route/auto_route.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:vplus_dev/core/router/app_router.gr.dart';
import 'package:vplus_dev/shared/widgets/common/app_error_widget.dart';

import 'package:vplus_dev/shared/enum/access_mode.dart';

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

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final galleryTypesAsync = ref.watch(galleryTypesProvider);
    return galleryTypesAsync.when(
      data: (galleryTypes) {
        return AutoTabsRouter.tabBar(
          routes: galleryTypes.map((type) => const GalleryWrapperRoute()).toList(),
          builder: (context, child, tabController) {
            return Scaffold(
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
        if (error is DioException) {
          // 使用美化的錯誤組件處理網絡錯誤
          return AppErrorWidget.network(
            message: '無法載入圖庫，可能的原因是網路不穩或是伺服器忙碌中，請稍後再重新試試吧',
            onRetry: () {
              ref.invalidate(galleryTypesProvider);
            },
          );
        }
        return AppErrorWidget.unknown(
          message: '載入圖庫時發生未知錯誤',
          details: error.toString(),
          onRetry: () {
            ref.invalidate(galleryTypesProvider);
          },
        );
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
      error:
          (error, stackTrace) => AppErrorWidget.unknown(
            message: '載入分類資料時發生錯誤',
            details: error.toString(),
            onRetry: () {
              ref.invalidate(selectedGalleryTypeProvider);
            },
            compact: true,
          ),
      loading: () {
        return const Text("loading");
      },
    );
  }
}
