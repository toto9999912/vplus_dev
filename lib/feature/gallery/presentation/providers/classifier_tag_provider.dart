import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../data/dtos/tag_request_dto.dart';
import '../../data/dtos/reorder_request_dto.dart';
import '../../domain/entities/gallery_classifier.dart';
import '../../domain/entities/tag.dart';
import 'gallery_providers.dart';
import 'selected_tag_provider.dart';
import 'snackbar_message_provider.dart';

part 'classifier_tag_provider.g.dart';

@riverpod
class ClassifierTagNotifier extends _$ClassifierTagNotifier {
  @override
  FutureOr<Classifier> build(int classifierId) async {
    return getClassifier(classifierId);
  }

  // 初始加載 classifier 數據
  Future<Classifier> getClassifier(int classifierId) {
    final useCase = ref.watch(getClassifierTagUseCaseProvider);
    final classifier = useCase.execute(classifierId);
    return classifier;
  }

  // 重新排序分類目錄
  void reorderCategories(int subClassifierIndex, int oldIndex, int newIndex) async {
    final currentState = state;
    if (currentState is AsyncData<Classifier>) {
      // 保存原始數據用於錯誤恢復
      final originalClassifier = currentState.value;

      if (originalClassifier.subClassifiers == null ||
          originalClassifier.subClassifiers!.isEmpty ||
          subClassifierIndex >= originalClassifier.subClassifiers!.length) {
        return;
      }

      final subClassifier = originalClassifier.subClassifiers![subClassifierIndex];
      if (subClassifier.categories == null || subClassifier.categories!.isEmpty) {
        return;
      }

      // 調整 newIndex
      if (oldIndex < newIndex) {
        newIndex -= 1;
      }

      // 創建新的類別列表並重新排序
      final categories = List.of(subClassifier.categories!);
      final item = categories.removeAt(oldIndex);
      categories.insert(newIndex, item);

      // 更新排序字段
      final updatedCategories = categories.asMap().map((index, category) => MapEntry(index, category.copyWith(sort: index))).values.toList();

      // 創建新的 subClassifier 和完整的 classifier
      final updatedSubClassifier = subClassifier.copyWith(categories: updatedCategories);
      final updatedSubClassifiers = List.of(originalClassifier.subClassifiers!);
      updatedSubClassifiers[subClassifierIndex] = updatedSubClassifier;

      // 先更新狀態顯示給使用者
      final updatedClassifier = originalClassifier.copyWith(subClassifiers: updatedSubClassifiers);
      state = AsyncValue.data(updatedClassifier);

      // 將變更保存到後端
      try {
        final repository = ref.read(galleryRepositoryProvider);
        final request = ReorderRequestDto.fromItemList(updatedCategories);
        await repository.reorderTagCategory(request);
        // 成功後無需再次更新UI
      } catch (e) {
        // 錯誤處理 - 還原狀態並顯示錯誤

        // 還原到原始狀態
        state = AsyncValue.data(originalClassifier);

        // 通知用戶排序失敗
        showErrorMessage('分類目錄排序失敗，已還原順序。請稍後再試。');
      }
    }
  }

  // 重新排序標籤
  void reorderTags(int subClassifierIndex, int categoryIndex, int oldIndex, int newIndex) async {
    final currentState = state;
    if (currentState is AsyncData<Classifier>) {
      // 保存原始數據用於錯誤恢復
      final originalClassifier = currentState.value;

      if (originalClassifier.subClassifiers == null ||
          originalClassifier.subClassifiers!.isEmpty ||
          subClassifierIndex >= originalClassifier.subClassifiers!.length) {
        return;
      }

      final subClassifier = originalClassifier.subClassifiers![subClassifierIndex];
      if (subClassifier.categories == null || subClassifier.categories!.isEmpty || categoryIndex >= subClassifier.categories!.length) {
        return;
      }

      final category = subClassifier.categories![categoryIndex];
      if (category.tags.isEmpty) {
        return;
      }

      // 創建新的標籤列表並重新排序 (遵循 Flutter 官方排序邏輯)
      final tags = List.of(category.tags);
      final item = tags.removeAt(oldIndex);
      tags.insert(newIndex, item);

      // 更新排序字段
      final updatedTags = tags.asMap().map((index, tag) => MapEntry(index, tag.copyWith(sort: index))).values.toList();

      // 創建新的 category、subClassifier 和完整的 classifier
      final updatedCategory = category.copyWith(tags: updatedTags);
      final updatedCategories = List.of(subClassifier.categories!);
      updatedCategories[categoryIndex] = updatedCategory;

      final updatedSubClassifier = subClassifier.copyWith(categories: updatedCategories);
      final updatedSubClassifiers = List.of(originalClassifier.subClassifiers!);
      updatedSubClassifiers[subClassifierIndex] = updatedSubClassifier;

      // 先更新狀態顯示給使用者
      final updatedClassifier = originalClassifier.copyWith(subClassifiers: updatedSubClassifiers);
      state = AsyncValue.data(updatedClassifier);

      // 將變更保存到後端
      try {
        final repository = ref.read(galleryRepositoryProvider);
        final request = ReorderRequestDto.fromItemList(updatedTags);
        await repository.reorderTag(request);
        // 成功排序後更新
      } catch (e) {
        // 還原到原始狀態
        state = AsyncValue.data(originalClassifier);

        // 通知用戶排序失敗
        showErrorMessage('標籤排序失敗，已還原順序。請稍後再試。');
      }
    }
  }

  // 顯示錯誤訊息，根據你的應用架構，選擇一種適合的方式
  void showErrorMessage(String message) {
    // 方式2: 更新本地錯誤狀態讓視圖層處理
    ref.read(snackbarMessageNotifierProvider.notifier).showError(message);
  }

  // 新增標籤
  void createTag(int subClassifierIndex, int categoryIndex, String title, int color) async {
    final currentState = state;
    if (currentState is AsyncData<Classifier>) {
      final originalClassifier = currentState.value;

      // 檢查索引有效性
      if (originalClassifier.subClassifiers == null ||
          subClassifierIndex >= originalClassifier.subClassifiers!.length ||
          originalClassifier.subClassifiers![subClassifierIndex].categories == null ||
          categoryIndex >= originalClassifier.subClassifiers![subClassifierIndex].categories!.length) {
        showErrorMessage('無法新增標籤: 索引無效');
        return;
      }

      final category = originalClassifier.subClassifiers![subClassifierIndex].categories![categoryIndex];

      try {
        // 創建請求DTO
        final request = TagRequestDto(categoryId: category.id, title: title, color: color);

        // 從 repository 添加標籤
        final repository = ref.read(galleryRepositoryProvider);
        final newTag = await repository.createTag(request);

        // 更新本地 UI 狀態
        // 1. 更新標籤列表
        final updatedTags = [...category.tags, newTag];

        // 2. 更新分類
        final updatedCategory = category.copyWith(tags: updatedTags);
        final updatedCategories = List.of(originalClassifier.subClassifiers![subClassifierIndex].categories!);
        updatedCategories[categoryIndex] = updatedCategory;

        // 3. 更新子分類器
        final updatedSubClassifier = originalClassifier.subClassifiers![subClassifierIndex].copyWith(categories: updatedCategories);
        final updatedSubClassifiers = List.of(originalClassifier.subClassifiers!);
        updatedSubClassifiers[subClassifierIndex] = updatedSubClassifier;

        // 4. 更新整個分類器
        final updatedClassifier = originalClassifier.copyWith(subClassifiers: updatedSubClassifiers);
        state = AsyncData(updatedClassifier);
      } catch (e) {
        // 發生錯誤時通知用戶
        showErrorMessage('新增標籤失敗: ${e.toString()}');
      }
    }
  }

  // 編輯標籤（樂觀更新模式）
  void editTag(int subClassifierIndex, int categoryIndex, int tagId, String title, int color) async {
    final currentState = state;
    if (currentState is AsyncData<Classifier>) {
      final originalClassifier = currentState.value;

      // 檢查索引有效性
      if (originalClassifier.subClassifiers == null ||
          subClassifierIndex >= originalClassifier.subClassifiers!.length ||
          originalClassifier.subClassifiers![subClassifierIndex].categories == null ||
          categoryIndex >= originalClassifier.subClassifiers![subClassifierIndex].categories!.length) {
        showErrorMessage('無法編輯標籤: 索引無效');
        return;
      }

      final category = originalClassifier.subClassifiers![subClassifierIndex].categories![categoryIndex];
      final tagIndex = category.tags.indexWhere((tag) => tag.id == tagId);

      if (tagIndex == -1) {
        showErrorMessage('無法編輯標籤: 找不到標籤');
        return;
      }

      // 獲取原始標籤對象
      final originalTag = category.tags[tagIndex];

      // 創建更新後的標籤對象（在本地直接創建，不依賴伺服器返回）
      final updatedTag = originalTag.copyWith(title: title, color: color);

      try {
        // 先進行本地狀態更新（樂觀更新）
        // 1. 更新標籤列表
        final updatedTags = List.of(category.tags);
        updatedTags[tagIndex] = updatedTag;

        // 2. 更新分類
        final updatedCategory = category.copyWith(tags: updatedTags);
        final updatedCategories = List.of(originalClassifier.subClassifiers![subClassifierIndex].categories!);
        updatedCategories[categoryIndex] = updatedCategory;

        // 3. 更新子分類器
        final updatedSubClassifier = originalClassifier.subClassifiers![subClassifierIndex].copyWith(categories: updatedCategories);
        final updatedSubClassifiers = List.of(originalClassifier.subClassifiers!);
        updatedSubClassifiers[subClassifierIndex] = updatedSubClassifier;

        // 4. 更新整個分類器
        final updatedClassifier = originalClassifier.copyWith(subClassifiers: updatedSubClassifiers);
        state = AsyncData(updatedClassifier);

        // 5. 如果有選中的標籤也需要更新
        _updateSelectedTags(tagId, updatedTag);

        // 創建請求DTO
        final request = TagRequestDto(categoryId: category.id, title: title, color: color);

        // 非同步發送請求到後端
        final repository = ref.read(galleryRepositoryProvider);
        await repository.editTag(tagId, request);

        // 請求成功，不需要額外處理（已經更新了UI）
      } catch (e) {
        // 發生錯誤時通知用戶並回滾
        showErrorMessage('編輯標籤失敗: ${e.toString()}');

        // 回滾狀態到原始狀態
        state = AsyncData(originalClassifier);

        // 如果在更新選中標籤時出錯，也需要回滾
        final selectedTags = ref.read(selectedTagsProvider);
        final tagIsSelected = selectedTags.any((t) => t.id == tagId);
        if (tagIsSelected) {
          // 回滾選中標籤狀態
          final selectedTagsNotifier = ref.read(selectedTagsProvider.notifier);
          selectedTagsNotifier.removeTag(tagId);
          selectedTagsNotifier.toggleTag(originalTag);
        }
      }
    }
  }

  // 更新所選標籤的輔助方法
  void _updateSelectedTags(int tagId, Tag updatedTag) {
    // 獲取selectedTags提供者
    final selectedTagsNotifier = ref.read(selectedTagsProvider.notifier);
    final selectedTags = ref.read(selectedTagsProvider);

    // 檢查編輯的標籤是否在選定列表中
    final tagIsSelected = selectedTags.any((tag) => tag.id == tagId);
    if (tagIsSelected) {
      // 如果是，更新選定的標籤列表
      selectedTagsNotifier.removeTag(tagId);
      selectedTagsNotifier.toggleTag(updatedTag);
    }
  }

  // 刪除標籤（樂觀更新模式）
  void deleteTag(int subClassifierIndex, int categoryIndex, int tagId) async {
    final currentState = state;
    if (currentState is AsyncData<Classifier>) {
      final originalClassifier = currentState.value;

      // 檢查索引有效性
      if (originalClassifier.subClassifiers == null ||
          subClassifierIndex >= originalClassifier.subClassifiers!.length ||
          originalClassifier.subClassifiers![subClassifierIndex].categories == null ||
          categoryIndex >= originalClassifier.subClassifiers![subClassifierIndex].categories!.length) {
        showErrorMessage('無法刪除標籤: 索引無效');
        return;
      }

      final category = originalClassifier.subClassifiers![subClassifierIndex].categories![categoryIndex];
      final tagIndex = category.tags.indexWhere((tag) => tag.id == tagId);

      if (tagIndex == -1) {
        showErrorMessage('無法刪除標籤: 找不到標籤');
        return;
      }

      // 獲取原始標籤對象（用於可能的回滾）

      try {
        // 樂觀更新 UI
        // 1. 更新標籤列表（移除目標標籤）
        final updatedTags = List.of(category.tags);
        updatedTags.removeAt(tagIndex);

        // 2. 更新分類
        final updatedCategory = category.copyWith(tags: updatedTags);
        final updatedCategories = List.of(originalClassifier.subClassifiers![subClassifierIndex].categories!);
        updatedCategories[categoryIndex] = updatedCategory;

        // 3. 更新子分類器
        final updatedSubClassifier = originalClassifier.subClassifiers![subClassifierIndex].copyWith(categories: updatedCategories);
        final updatedSubClassifiers = List.of(originalClassifier.subClassifiers!);
        updatedSubClassifiers[subClassifierIndex] = updatedSubClassifier;

        // 4. 更新整個分類器
        final updatedClassifier = originalClassifier.copyWith(subClassifiers: updatedSubClassifiers);
        state = AsyncData(updatedClassifier);

        // 5. 如果有選中的標籤也需要移除
        final selectedTagsNotifier = ref.read(selectedTagsProvider.notifier);
        if (selectedTagsNotifier.isSelected(tagId)) {
          selectedTagsNotifier.removeTag(tagId);
        }

        // 發送請求到後端
        final repository = ref.read(galleryRepositoryProvider);
        await repository.deleteTag(tagId);

        // 成功刪除，無需額外處理（已經更新了UI）
      } catch (e) {
        // 發生錯誤時通知用戶並回滾
        showErrorMessage('刪除標籤失敗: ${e.toString()}');

        // 回滾狀態到原始狀態
        state = AsyncData(originalClassifier);
      }
    }
  }

  void addTagCategory() {}

  void editTagCategory() {}

  void deleteTagCategory() {}
}
