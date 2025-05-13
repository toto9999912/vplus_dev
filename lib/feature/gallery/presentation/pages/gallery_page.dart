import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:vplus_dev/core/router/app_router.gr.dart';
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
