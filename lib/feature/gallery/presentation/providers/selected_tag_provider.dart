import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../domain/entities/tag.dart';

part 'selected_tag_provider.g.dart';

@riverpod
class SelectedTags extends _$SelectedTags {
  @override
  List<Tag> build() {
    return []; // 初始為空列表
  }

  /// 切換標籤的選取狀態
  void toggleTag(Tag tag) {
    // 檢查標籤是否已被選取
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
}

@riverpod
List<int> selectedTagIds(Ref ref) {
  return ref.watch(selectedTagsProvider).map((tag) => tag.id).toList();
}
