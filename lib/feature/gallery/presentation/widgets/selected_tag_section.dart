import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/selected_tag_provider.dart';

class SelectedTagSection extends ConsumerWidget {
  const SelectedTagSection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedTags = ref.watch(selectedTagsProvider);
    return Container(
      height: 48,
      padding: const EdgeInsets.all(4),
      margin: const EdgeInsets.all(4),
      child: Row(
        children: [
          Expanded(
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                spacing: 4,
                children: selectedTags.map((tag) {
                  return Chip(
                    padding: EdgeInsets.zero,
                    label: Text(
                      tag.title,
                      style: const TextStyle(color: Colors.white, fontSize: 12),
                    ),
                    backgroundColor: Theme.of(context).colorScheme.primary,
                    labelStyle: TextStyle(
                      color: Theme.of(context).colorScheme.primary,
                    ),
                    deleteIcon: const Icon(Icons.close, size: 14),
                    onDeleted: () {
                      ref.read(selectedTagsProvider.notifier).removeTag(tag.id);
                    },
                  );
                }).toList(),
              ),
            ),
          ),
          InkWell(
            onTap: () {
              ref.read(selectedTagsProvider.notifier).clearAll();
            },
            child: Container(
                height: 24,
                alignment: Alignment.center,
                padding: EdgeInsets.all(4),
                decoration: BoxDecoration(
                  border: Border.all(color: Theme.of(context).colorScheme.primary),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text('clear', style: TextStyle(fontSize: 12, color: Theme.of(context).colorScheme.primary))),
          ),
          const SizedBox(width: 4),
        ],
      ),
    );
  }
}
