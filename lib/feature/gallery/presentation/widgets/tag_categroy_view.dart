import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/entities/tag_category.dart';
import '../providers/classifier_tag_provider.dart';
import 'tag_view.dart';

class TagCategroyView extends ConsumerWidget {
  final List<TagCategory> categories;
  final int subClassifierIndex;
  final int classifierId;
  const TagCategroyView({required this.categories, required this.subClassifierIndex, required this.classifierId, super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ReorderableListView.builder(
      shrinkWrap: true,
      itemBuilder: (context, categoryIndex) {
        final category = categories[categoryIndex];
        return Container(
          key: ValueKey(category.id),
          decoration: BoxDecoration(
            border: categoryIndex == 0
                ? Border.symmetric(horizontal: BorderSide(color: Theme.of(context).colorScheme.outlineVariant))
                : Border(bottom: BorderSide(color: Theme.of(context).colorScheme.outlineVariant)),
          ),
          child: ExpansionPanelList(
            expandIconColor: Colors.transparent,
            elevation: 0,
            expandedHeaderPadding: EdgeInsets.zero,
            expansionCallback: (panelIndex, isExpanded) {},
            children: [
              ExpansionPanel(
                  canTapOnHeader: true,
                  isExpanded: true,
                  headerBuilder: (context, isExpanded) => ListTile(
                        title: Text(
                          "${categoryIndex + 1}. ${category.title}",
                          strutStyle: const StrutStyle(forceStrutHeight: true, leading: 0.5),
                        ),
                      ),
                  body: TagView(
                    classifierId: classifierId,
                    subClassifierIndex: subClassifierIndex,
                    categoryIndex: categoryIndex,
                    category: category,
                  )),
            ],
          ),
        );
      },
      itemCount: categories.length,
      onReorder: (oldIndex, newIndex) {
        ref.read(classifierTagNotifierProvider(classifierId).notifier).reorderCategories(subClassifierIndex, oldIndex, newIndex);
      },
    );
  }
}
