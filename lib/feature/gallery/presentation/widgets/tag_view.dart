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
      footer: [
        AppButton.outline(
          child: Icon(Icons.add),
          onPressed: () async {
            final result = await AppFormDialog.show<Tag>(
              context: context,
              title: '新增Tag',
              initialData: Tag.empty(),
              bodyBuilder: (context, initialData, onDataChanged) {
                // 創建表單元素
                return Column(
                  children: [
                    Container(
                      margin: const EdgeInsets.only(top: 15, bottom: 15),
                      decoration: BoxDecoration(color: const Color.fromRGBO(0, 0, 0, 0.1), borderRadius: BorderRadius.circular(4)),
                      child: TextFormField(
                        textAlign: TextAlign.center,
                        style: const TextStyle(fontSize: 18),
                        minLines: 1,
                        maxLines: 2,
                        decoration: const InputDecoration(
                          isDense: true,
                          contentPadding: EdgeInsets.fromLTRB(20.0, 15.0, 10.0, 15.0),
                          border: InputBorder.none,
                        ),
                        initialValue: initialData?.title,
                        onChanged: (value) {
                          // 即時更新數據
                          final newData = initialData?.copyWith(title: value);
                          onDataChanged(newData);
                        },
                      ),
                    ),

                    ColorPicker(
                      initialColor: AppColors.white,
                      onColorChanged: (color) {
                        final newData = initialData?.copyWith(color: defaultColors.indexOf(color));
                        onDataChanged(newData);
                      },
                    ),
                  ],
                );
              },
            );
            if (result == null) return;

            ref.read(classifierTagNotifierProvider(classifierId).notifier).createTag(subClassifierIndex, categoryIndex, result.title, result.color);
          },
        ),
      ],
      children:
          category.tags.map((tag) {
            final isSelected = selectedTags.any((t) => t.id == tag.id);
            return isSelected
                ? AppButton(
                  key: ValueKey(tag.id),
                  child: Row(
                    mainAxisSize: MainAxisSize.min, // 設置為緊湊模式
                    children: [
                      Container(width: 8, height: 8, decoration: BoxDecoration(color: defaultColors[tag.color], shape: BoxShape.circle)),
                      SizedBox(width: 4),
                      Flexible(
                        child: Text(
                          tag.title,
                          style: TextStyle(fontSize: 12),
                          overflow: TextOverflow.ellipsis, // 文字過長時顯示省略號
                          maxLines: 2, // 限制一行
                        ),
                      ),
                    ],
                  ),
                  onPressed: () {
                    selectedTagsNotifier.toggleTag(tag);
                  },
                  onDoubleTap: () async {
                    // 編輯現有標籤
                    final result = await AppFormDialog.show<Tag>(
                      context: context,
                      title: '編輯標籤',
                      initialData: tag, // 使用現有標籤作為初始數據
                      bodyBuilder: (context, initialData, onDataChanged) {
                        return Column(
                          children: [
                            Container(
                              margin: const EdgeInsets.only(top: 15, bottom: 15),
                              decoration: BoxDecoration(color: const Color.fromRGBO(0, 0, 0, 0.1), borderRadius: BorderRadius.circular(4)),
                              child: TextFormField(
                                textAlign: TextAlign.center,
                                style: const TextStyle(fontSize: 18),
                                minLines: 1,
                                maxLines: 2,
                                decoration: const InputDecoration(
                                  isDense: true,
                                  contentPadding: EdgeInsets.fromLTRB(20.0, 15.0, 10.0, 15.0),
                                  border: InputBorder.none,
                                ),
                                initialValue: initialData?.title,
                                onChanged: (value) {
                                  final newData = initialData?.copyWith(title: value);
                                  onDataChanged(newData);
                                },
                              ),
                            ),

                            ColorPicker(
                              initialColor: defaultColors[initialData?.color ?? 0],
                              onColorChanged: (color) {
                                final newData = initialData?.copyWith(color: defaultColors.indexOf(color));
                                onDataChanged(newData);
                              },
                            ),
                          ],
                        );
                      },
                    );
                    if (result == null) return;

                    // 呼叫編輯標籤方法
                    ref
                        .read(classifierTagNotifierProvider(classifierId).notifier)
                        .editTag(subClassifierIndex, categoryIndex, tag.id, result.title, result.color);
                  },
                )
                : AppButton.outline(
                  key: ValueKey(tag.id),
                  child: Row(
                    mainAxisSize: MainAxisSize.min, // 設置為緊湊模式
                    children: [
                      Container(width: 8, height: 8, decoration: BoxDecoration(color: defaultColors[tag.color], shape: BoxShape.circle)),
                      SizedBox(width: 4),
                      Flexible(
                        child: Text(
                          tag.title,
                          style: TextStyle(fontSize: 12),
                          overflow: TextOverflow.ellipsis, // 文字過長時顯示省略號
                          maxLines: 2, // 限制一行
                        ),
                      ),
                    ],
                  ),
                  onPressed: () {
                    selectedTagsNotifier.toggleTag(tag);
                  },
                  onDoubleTap: () async {
                    // 編輯現有標籤
                    final result = await AppFormDialog.show<Tag>(
                      context: context,
                      title: '編輯標籤',
                      initialData: tag, // 使用現有標籤作為初始數據
                      bodyBuilder: (context, initialData, onDataChanged) {
                        return Column(
                          children: [
                            Container(
                              margin: const EdgeInsets.only(top: 15, bottom: 15),
                              decoration: BoxDecoration(color: const Color.fromRGBO(0, 0, 0, 0.1), borderRadius: BorderRadius.circular(4)),
                              child: TextFormField(
                                textAlign: TextAlign.center,
                                style: const TextStyle(fontSize: 18),
                                minLines: 1,
                                maxLines: 2,
                                decoration: const InputDecoration(
                                  isDense: true,
                                  contentPadding: EdgeInsets.fromLTRB(20.0, 15.0, 10.0, 15.0),
                                  border: InputBorder.none,
                                ),
                                initialValue: initialData?.title,
                                onChanged: (value) {
                                  final newData = initialData?.copyWith(title: value);
                                  onDataChanged(newData);
                                },
                              ),
                            ),

                            ColorPicker(
                              initialColor: defaultColors[initialData?.color ?? 0],
                              onColorChanged: (color) {
                                final newData = initialData?.copyWith(color: defaultColors.indexOf(color));
                                onDataChanged(newData);
                              },
                            ),
                          ],
                        );
                      },
                    );
                    if (result == null) return;

                    // 呼叫編輯標籤方法
                    ref
                        .read(classifierTagNotifierProvider(classifierId).notifier)
                        .editTag(subClassifierIndex, categoryIndex, tag.id, result.title, result.color);
                  },
                );
          }).toList(),
    );
  }
}

class ColorPicker extends StatefulWidget {
  final Color initialColor;
  final Function(Color) onColorChanged;

  const ColorPicker({required this.initialColor, required this.onColorChanged, super.key});

  @override
  State<ColorPicker> createState() => _ColorPickerState();
}

class _ColorPickerState extends State<ColorPicker> {
  late Color _selectedColor;

  @override
  void initState() {
    super.initState();
    _selectedColor = widget.initialColor;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Wrap(
          children:
              defaultColors
                  .map(
                    (color) => GestureDetector(
                      onTap: () {
                        setState(() => _selectedColor = color);
                        widget.onColorChanged(color);
                      },
                      child: Container(
                        margin: EdgeInsets.all(5),
                        padding: EdgeInsets.all(3),
                        decoration: BoxDecoration(
                          color: color,
                          shape: BoxShape.circle,
                          border: Border.all(color: _selectedColor == color ? AppColors.textGrey : Colors.transparent),
                          boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.1), blurRadius: 2, offset: const Offset(0, 1))],
                        ),
                        child:
                            _selectedColor == color
                                ? Icon(Icons.check, size: 20, color: _selectedColor == AppColors.white ? Colors.black : Colors.white)
                                : SizedBox(height: 20, width: 20),
                      ),
                    ),
                  )
                  .toList(),
        ),
      ],
    );
  }
}
