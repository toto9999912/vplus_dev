import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:vplus_dev/shared/widgets/button/app_button.dart';

import '../../domain/entities/gallery_media.dart';
import '../../domain/entities/tag_category.dart';
import '../providers/media_editor_tag_provider.dart';

/// 媒體編輯器專用的標籤視圖
class MediaEditorTagView extends ConsumerWidget {
  final GalleryMedia media;
  final int classifierId;
  final int subClassifierIndex;
  final int categoryIndex;
  final TagCategory category;

  const MediaEditorTagView({
    required this.media,
    required this.classifierId,
    required this.subClassifierIndex,
    required this.categoryIndex,
    required this.category,
    super.key,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedTagsNotifier = ref.watch(mediaEditorTagsProvider(media: media).notifier);
    final selectedTags = ref.watch(mediaEditorTagsProvider(media: media));

    return GridView.builder(
      padding: const EdgeInsets.all(8),
      physics: const NeverScrollableScrollPhysics(),
      shrinkWrap: true,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 4, childAspectRatio: 2, crossAxisSpacing: 4, mainAxisSpacing: 4),
      itemCount: category.tags.length,
      itemBuilder: (context, index) {
        final tag = category.tags[index];
        final isSelected = selectedTags.any((t) => t.id == tag.id);

        return isSelected
            ? AppButton(
              key: ValueKey(tag.id),

              child: Text(tag.title, style: TextStyle(fontSize: 12, fontWeight: isSelected ? FontWeight.bold : FontWeight.normal)),
              onPressed: () {
                selectedTagsNotifier.toggleTag(tag);
              },
            )
            : AppButton.outline(
              key: ValueKey(tag.id),
              child: Text(tag.title, style: TextStyle(fontSize: 12, fontWeight: isSelected ? FontWeight.bold : FontWeight.normal)),
              onPressed: () {
                selectedTagsNotifier.toggleTag(tag);
              },
            );
      },
    );
  }
}
