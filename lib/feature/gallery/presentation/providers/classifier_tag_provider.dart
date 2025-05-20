import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../data/dtos/create_tag_request_dto.dart';
import '../../data/dtos/reorder_request_dto.dart';
import '../../domain/entities/gallery_classifier.dart';
import 'gallery_providers.dart';
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
    // 方式1: 使用全局通知服務 (推薦)
    // ref.read(notificationServiceProvider).showError(message);

    // 方式2: 更新本地錯誤狀態讓視圖層處理
    ref.read(snackbarMessageNotifierProvider.notifier).showError(message);
  }

  // ...existing code...

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
        final request = CreateTagRequestDto(categoryId: category.id, title: title, color: color);

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

  void editTag() {}

  void deleteTag() {}

  void addTagCategory() {}

  void editTagCategory() {}

  void deleteTagCategory() {}
}
