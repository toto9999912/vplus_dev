import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../domain/entities/tag.dart';
import '../../domain/entities/gallery_media.dart';

part 'media_editor_tag_provider.g.dart';

/// 管理媒體編輯時的標籤狀態，與主Gallery頁面的標籤選擇狀態獨立
@riverpod
class MediaEditorTags extends _$MediaEditorTags {
  @override
  List<Tag> build({required GalleryMedia media}) {
    return []; // 初始為空列表，後續可改為從媒體中讀取已有標籤
  }

  /// 切換標籤的選取狀態
  void toggleTag(Tag tag) {
    final isSelected = state.any((t) => t.id == tag.id);

    if (isSelected) {
      // 如果已選取，則移除
      state = state.where((t) => t.id != tag.id).toList();
    } else {
      // 如果未選取，則添加
      state = [...state, tag];
    }
  }

  /// 清除所有選取的標籤
  void clearAll() {
    state = [];
  }

  /// 移除特定標籤
  void removeTag(int tagId) {
    state = state.where((tag) => tag.id != tagId).toList();
  }

  /// 檢查標籤是否被選取
  bool isSelected(int tagId) {
    return state.any((tag) => tag.id == tagId);
  }

  /// 批次設置標籤 (例如從現有媒體載入標籤)
  void setTags(List<Tag> tags) {
    state = tags;
  }
}

/// 提供由媒體編輯器選擇的標籤ID列表
@riverpod
List<int> mediaEditorTagIds(Ref ref, {required GalleryMedia media}) {
  return ref.watch(mediaEditorTagsProvider(media: media)).map((tag) => tag.id).toList();
}
