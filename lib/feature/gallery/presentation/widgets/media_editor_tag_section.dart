import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/entities/gallery_media.dart';
import '../providers/media_editor_tag_provider.dart';

class MediaEditorTagSection extends ConsumerWidget {
  final GalleryMedia media;

  const MediaEditorTagSection({required this.media, super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedTags = ref.watch(mediaEditorTagsProvider(media: media));
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
                children: selectedTags.map((tag) {
                  return Padding(
                    padding: const EdgeInsets.only(right: 4),
                    child: Chip(
                      padding: EdgeInsets.zero,
                      label: Text(
                        tag.title,
                        style: const TextStyle(color: Colors.white, fontSize: 12),
                      ),
                      backgroundColor: Color(tag.color),
                      deleteIcon: const Icon(Icons.close, size: 14, color: Colors.white),
                      onDeleted: () {
                        ref.read(mediaEditorTagsProvider(media: media).notifier).removeTag(tag.id);
                      },
                    ),
                  );
                }).toList(),
              ),
            ),
          ),
          if (selectedTags.isNotEmpty)
            InkWell(
              onTap: () {
                ref.read(mediaEditorTagsProvider(media: media).notifier).clearAll();
              },
              child: Container(
                  height: 24,
                  alignment: Alignment.center,
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    border: Border.all(color: Theme.of(context).colorScheme.primary),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text('清空', style: TextStyle(fontSize: 12, color: Theme.of(context).colorScheme.primary))),
            ),
          const SizedBox(width: 4),
        ],
      ),
    );
  }
}
