import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';
import 'package:vplus_dev/core/router/app_router.gr.dart';
import 'package:vplus_dev/shared/enum/access_mode.dart';

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

  @override
  Widget build(BuildContext context) {
    final ItemScrollController itemScrollController = ItemScrollController();
    final classifierAsync = ref.watch(classifierTagNotifierProvider(widget.classifierId, widget.projectId));

    return classifierAsync.when(
      data:
          (classifier) => SnackbarListener(
            child: Column(
              children: [buildHeader(classifier, itemScrollController), buildSelectedTags(), buildTagView(classifier, itemScrollController)],
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
