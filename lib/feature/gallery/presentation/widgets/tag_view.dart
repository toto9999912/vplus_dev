import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:reorderable_grid_view/reorderable_grid_view.dart';
import 'package:vplus_dev/core/constants/app_color.dart';
import 'package:vplus_dev/shared/widgets/button/app_button.dart';
import 'package:vplus_dev/shared/widgets/form/app_form_dialog.dart';

import '../../domain/entities/tag.dart';
import '../../domain/entities/tag_category.dart';
import '../providers/classifier_tag_provider.dart';
import '../providers/selected_tag_provider.dart';
import 'tag_form_widget.dart';

final defaultColors = [
  AppColors.white,
  AppColors.darkGold,
  AppColors.darkPrimary,
  AppColors.danger,
  AppColors.darkGrey,
  AppColors.primary,
  AppColors.brightGreen,
];

class TagView extends ConsumerWidget {
  final int classifierId;
  final int subClassifierIndex;
  final int categoryIndex;
  final TagCategory category;
  const TagView({required this.classifierId, required this.subClassifierIndex, required this.categoryIndex, required this.category, super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
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
      footer: [AppButton.outline(child: const Icon(Icons.add), onPressed: () => _handleAddTag(context, ref))],
      children:
          category.tags.map((tag) {
            final isSelected = selectedTags.any((t) => t.id == tag.id);
            return _buildTagButton(context, ref, tag, isSelected);
          }).toList(),
    );
  }

  // 構建標籤按鈕
  Widget _buildTagButton(BuildContext context, WidgetRef ref, Tag tag, bool isSelected) {
    // 構建子部件
    final buttonChild = _buildTagButtonContent(tag);

    // 根據選中狀態決定按鈕類型
    return isSelected
        ? AppButton(
          key: ValueKey(tag.id),
          child: buttonChild,
          onPressed: () {
            ref.read(selectedTagsProvider.notifier).toggleTag(tag);
          },
          onDoubleTap: () => _handleEditTag(context, ref, tag),
        )
        : AppButton.outline(
          key: ValueKey(tag.id),
          child: buttonChild,
          onPressed: () {
            ref.read(selectedTagsProvider.notifier).toggleTag(tag);
          },
          onDoubleTap: () => _handleEditTag(context, ref, tag),
        );
  }

  // 構建標籤按鈕內容
  Widget _buildTagButtonContent(Tag tag) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(width: 8, height: 8, decoration: BoxDecoration(color: defaultColors[tag.color], shape: BoxShape.circle)),
        const SizedBox(width: 4),
        Flexible(child: Text(tag.title, style: const TextStyle(fontSize: 12), overflow: TextOverflow.ellipsis, maxLines: 2)),
      ],
    );
  }

  // 處理新增標籤
  Future<void> _handleAddTag(BuildContext context, WidgetRef ref) async {
    Tag formData = Tag.empty();

    final result = await AppFormDialog.show<Tag>(
      context: context,
      title: '新增Tag',
      initialData: formData,
      bodyBuilder: (context, initialData, onDataChanged) {
        return TagFormWidget(
          initialData: initialData ?? Tag.empty(),
          initialColor: defaultColors[0],
          onDataChanged: (updatedTag) {
            formData = updatedTag; // 保存最新狀態
            onDataChanged(updatedTag);
          },
        );
      },
    );

    if (result == null) return;

    ref.read(classifierTagNotifierProvider(classifierId).notifier).createTag(subClassifierIndex, categoryIndex, formData.title, formData.color);
  }

  // 處理編輯標籤
  Future<void> _handleEditTag(BuildContext context, WidgetRef ref, Tag tag) async {
    Tag formData = tag;

    final result = await AppFormDialog.show<Tag>(
      context: context,
      title: '編輯標籤',
      initialData: tag,
      customAction: IconButton(
        onPressed: () {
          ref.read(classifierTagNotifierProvider(classifierId).notifier).deleteTag(subClassifierIndex, categoryIndex, tag.id);
          Navigator.of(context, rootNavigator: true).pop();
        },
        icon: const Icon(Icons.delete),
      ),
      bodyBuilder: (context, initialData, onDataChanged) {
        return TagFormWidget(
          initialData: initialData ?? tag,
          initialColor: defaultColors[tag.color],
          onDataChanged: (updatedTag) {
            formData = updatedTag; // 保存最新狀態
            onDataChanged(updatedTag);
          },
        );
      },
    );

    if (result == null) return;

    ref.read(classifierTagNotifierProvider(classifierId).notifier).editTag(subClassifierIndex, categoryIndex, tag.id, formData.title, formData.color);
  }
}
