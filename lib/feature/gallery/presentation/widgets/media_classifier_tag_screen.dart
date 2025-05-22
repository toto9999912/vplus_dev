import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';

import '../../domain/entities/gallery_classifier.dart';
import '../../domain/entities/gallery_media.dart';
import '../providers/classifier_tag_provider.dart';
import 'media_editor_tag_category_view.dart';
import 'media_editor_tag_section.dart';

/// 媒體編輯器專用的分類標籤界面
class MediaClassifierTagScreen extends ConsumerStatefulWidget {
  final int? projectId;
  final int classifierId;
  final GalleryMedia media;

  const MediaClassifierTagScreen({required this.projectId, required this.classifierId, required this.media, super.key});

  @override
  ConsumerState<MediaClassifierTagScreen> createState() => _MediaClassifierTagScreenState();
}

class _MediaClassifierTagScreenState extends ConsumerState<MediaClassifierTagScreen> {
  void scrollToIndex(int index, ItemScrollController controller) {
    controller.scrollTo(index: index, duration: const Duration(milliseconds: 100));
  }

  @override
  Widget build(BuildContext context) {
    final ItemScrollController itemScrollController = ItemScrollController();
    final classifierAsync = ref.watch(classifierTagNotifierProvider(widget.classifierId, widget.projectId));

    return classifierAsync.when(
      data:
          (classifier) => Column(
            children: [
              buildHeader(classifier, itemScrollController),
              buildSelectedTags(),
              buildTagView(classifier, itemScrollController),
              buildSaveButton(context),
            ],
          ),
      error: (error, stackTrace) => ErrorWidget(error),
      loading: () => const Center(child: CircularProgressIndicator()),
    );
  }

  Widget buildSelectedTags() {
    return MediaEditorTagSection(media: widget.media);
  }

  /// 頂部子分類標籤欄
  Widget buildHeader(Classifier classifier, ItemScrollController itemScrollController) {
    if (classifier.subClassifiers == null || classifier.subClassifiers!.isEmpty) {
      return const SizedBox.shrink();
    }

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

  /// 標籤分類視圖
  Widget buildTagView(Classifier classifier, ItemScrollController itemScrollController) {
    if (classifier.subClassifiers == null || classifier.subClassifiers!.isEmpty) {
      return const Center(child: Text('沒有可用的子分類'));
    }

    return Expanded(
      child: ScrollablePositionedList.builder(
        itemCount: classifier.subClassifiers!.length,
        itemScrollController: itemScrollController,
        shrinkWrap: true,
        itemBuilder: (context, subClassifierIndex) {
          Classifier subClassifier = classifier.subClassifiers![subClassifierIndex];
          if (subClassifier.categories == null || subClassifier.categories!.isEmpty) {
            return const Center(child: Text('此分類沒有標籤'));
          }

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.only(left: 8, top: 16, bottom: 8),
                child: Text(subClassifier.titleZhTw, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              ),
              MediaEditorTagCategoryView(
                media: widget.media,
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

  /// 儲存按鈕
  Widget buildSaveButton(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: ElevatedButton(
        onPressed: () {
          // 儲存媒體標籤邏輯
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('標籤已更新')));
          context.router.pop();
        },
        style: ElevatedButton.styleFrom(minimumSize: const Size.fromHeight(50)),
        child: const Text('儲存分類'),
      ),
    );
  }
}
