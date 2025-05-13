import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/entities/gallery_media.dart';
import '../../domain/entities/tag_category.dart';
import 'media_editor_tag_view.dart';

/// 媒體編輯器標籤類別視圖
class MediaEditorTagCategoryView extends ConsumerWidget {
  final GalleryMedia media;
  final List<TagCategory> categories;
  final int subClassifierIndex;
  final int classifierId;

  const MediaEditorTagCategoryView({
    required this.media,
    required this.categories,
    required this.subClassifierIndex,
    required this.classifierId,
    super.key,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: categories.length,
      itemBuilder: (context, categoryIndex) {
        final category = categories[categoryIndex];

        // 如果該類別沒有標籤，則不顯示
        if (category.tags.isEmpty) {
          return const SizedBox.shrink();
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.only(left: 8.0, top: 12.0, bottom: 4.0),
              child: Text(
                category.title,
                style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
              ),
            ),
            MediaEditorTagView(
              media: media,
              classifierId: classifierId,
              subClassifierIndex: subClassifierIndex,
              categoryIndex: categoryIndex,
              category: category,
            ),
          ],
        );
      },
    );
  }
}
