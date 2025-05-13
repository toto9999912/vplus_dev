import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../domain/enums/view_mode.dart';
import '../../domain/usecases/get_tag_search_media_usecase.dart';
import 'gallery_providers.dart';
import 'selected_tag_provider.dart';
import 'state/gallery_media_state.dart';

part 'gallery_media_provider.g.dart';

/// 標籤搜尋媒體用例 Provider
@riverpod
Future<GetTagSearchMediaUsecase> getTagSearchMediaUsecase(Ref ref) async {
  final mediaRepository = await ref.watch(mediaRepositoryProvider.future);
  return GetTagSearchMediaUsecase(mediaRepository);
}

/// 圖庫媒體狀態 Notifier
@riverpod
class GalleryMediaNotifier extends _$GalleryMediaNotifier {
  @override
  FutureOr<GalleryMediaState> build() async {
    // 獲取當前選擇的標籤 ID 列表
    final tagIds = ref.watch(selectedTagIdsProvider);

    // 如果有選定的標籤 ID，則立即載入相關媒體
    if (tagIds.isNotEmpty) {
      await _loadMediasByTagIds(tagIds);
      return state.value!; // 返回已更新的狀態
    }

    // 如果沒有標籤 ID，則返回空狀態
    return const GalleryMediaState();
  }

  /// 根據標籤 ID 載入媒體資料 (內部方法)
  Future<void> _loadMediasByTagIds(List<int> tagIds) async {
    try {
      state = AsyncValue.data(state.valueOrNull?.copyWith(isLoading: true) ?? const GalleryMediaState(isLoading: true));

      // 獲取 usecase
      final usecase = await ref.read(getTagSearchMediaUsecaseProvider.future);

      // 執行用例獲取媒體資料
      final medias = await usecase.execute(tagIds);

      // 更新狀態
      state = AsyncValue.data(state.value!.copyWith(medias: medias, isLoading: false, errorMessage: null));
    } catch (e, stackTrace) {
      // 處理錯誤
      state = AsyncValue.error(e, stackTrace);
      state = AsyncValue.data(state.value!.copyWith(isLoading: false, errorMessage: "載入媒體資料失敗: ${e.toString()}"));
    }
  }

  /// 切換顯示模式
  void toggleViewMode() {
    final currentMode = state.value!.viewMode;
    final newMode = currentMode == ViewMode.normal ? ViewMode.selection : ViewMode.normal;
    state = AsyncValue.data(state.value!.copyWith(viewMode: newMode));
  }

  /// 切換是否顯示數字
  void toggleDisplayNumbers() {
    final currentValue = state.value!.displayNumber;
    state = AsyncValue.data(state.value!.copyWith(displayNumber: !currentValue));
  }

  /// 設置選中的項目索引
  void setSelectedIndices(List<int> indices) {
    state = AsyncValue.data(state.value!.copyWith(selectedIndices: indices));
  }

  /// 清除選中的項目
  void clearSelection() {
    state = AsyncValue.data(state.value!.copyWith(selectedIndices: []));
  }

  /// 按用戶 ID 過濾媒體
  void filterByUserId(int userId) {
    final currentFilters = List<int>.from(state.value!.filterUserIds);
    if (currentFilters.contains(userId)) {
      currentFilters.remove(userId);
    } else {
      currentFilters.add(userId);
    }
    state = AsyncValue.data(state.value!.copyWith(filterUserIds: currentFilters));
  }

  /// 清除用戶 ID 過濾
  void clearUserFilter() {
    state = AsyncValue.data(state.value!.copyWith(filterUserIds: []));
  }
}
