import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:reorderable_grid_view/reorderable_grid_view.dart';
import 'package:vplus_dev/shared/widgets/button/app_button.dart';

import '../../domain/entities/tag_category.dart';
import '../providers/classifier_tag_provider.dart';
import '../providers/selected_tag_provider.dart';

class TagView extends ConsumerWidget {
  final int classifierId;
  final int subClassifierIndex;
  final int categoryIndex;
  final TagCategory category;
  const TagView({required this.classifierId, required this.subClassifierIndex, required this.categoryIndex, required this.category, super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedTagsNotifier = ref.watch(selectedTagsProvider.notifier);
    final selectedTags = ref.watch(selectedTagsProvider);
    return ReorderableGridView.count(
      padding: const EdgeInsets.all(8),
      physics: const NeverScrollableScrollPhysics(),
      shrinkWrap: true,
      crossAxisSpacing: 4,
      mainAxisSpacing: 4,
      crossAxisCount: 4,
      childAspectRatio: 2,
      onReorder: (int oldIndex, int newIndex) {
        ref.read(classifierTagNotifierProvider(classifierId).notifier).reorderTags(subClassifierIndex, categoryIndex, oldIndex, newIndex);
      },
      footer: [AppButton.outline(child: Icon(Icons.add), onPressed: () {})],
      children:
          category.tags.map((tag) {
            final isSelected = selectedTags.any((t) => t.id == tag.id);
            return isSelected
                ? AppButton(
                  key: ValueKey(tag.id),
                  child: Text(tag.title),
                  onPressed: () {
                    selectedTagsNotifier.toggleTag(tag);
                  },
                )
                : AppButton.outline(
                  key: ValueKey(tag.id),
                  child: Text(tag.title),
                  onPressed: () {
                    selectedTagsNotifier.toggleTag(tag);
                  },
                );
          }).toList(),
    );
  }
}
