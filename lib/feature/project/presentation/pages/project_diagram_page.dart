import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:vplus_dev/feature/gallery/presentation/providers/gallery_providers.dart';
import 'package:vplus_dev/feature/gallery/presentation/widgets/classifier_tag_screen.dart';
import 'package:vplus_dev/feature/gallery/presentation/widgets/galley_tabbar.dart';
import 'package:vplus_dev/shared/enum/access_mode.dart';

import '../providers/diagram_providers.dart';

@RoutePage()
class ProjectDiagramPage extends StatelessWidget {
  final int projectId;
  const ProjectDiagramPage({super.key, @PathParam('projectId') required this.projectId});

  @override
  Widget build(BuildContext context) => const AutoRouter();
}

@RoutePage()
class DiagramViewScreen extends ConsumerWidget {
  const DiagramViewScreen({super.key, @PathParam.inherit('projectId') required this.projectId});
  final int projectId;
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final diagramGalleryTypeAsync = ref.watch(diagramGalleryTypeProvider);
    return diagramGalleryTypeAsync.when(
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
                        return ClassifierTagScreen(accessMode: AccessMode.readWrite, classifierId: classifier.id, projectId: projectId);
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
