import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:vplus_dev/feature/gallery/presentation/providers/gallery_providers.dart';
import 'package:vplus_dev/feature/gallery/presentation/widgets/classifier_tag_screen.dart';
import 'package:vplus_dev/feature/gallery/presentation/widgets/galley_tabbar.dart';
import 'package:vplus_dev/shared/enum/access_mode.dart';

@RoutePage()
class ProjectDiagramPage extends StatelessWidget {
  const ProjectDiagramPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const AutoRouter();
  }
}

@RoutePage()
class DiagramViewScreen extends ConsumerWidget {
  const DiagramViewScreen({super.key});

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
