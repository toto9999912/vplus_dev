import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:vplus_dev/core/providers/api_client_providers.dart';

import '../../data/datasources/gallery_data_source.dart';
import '../../data/datasources/media_data_source.dart';
import '../../data/datasources/remote_gallery_data_source_impl.dart';
import '../../data/datasources/remote_media_data_source_impl.dart';
import '../../data/repositories/gallery_repository.dart';
import '../../data/repositories/gallery_repository_impl.dart';
import '../../data/repositories/media_repository.dart';
import '../../data/repositories/media_repository_impl.dart';
import '../../domain/entities/gallery_type.dart';
import '../../domain/usecases/get_classifier_tag_usecase.dart';
import '../../domain/usecases/get_gallery_types_usecase.dart';

part 'gallery_providers.g.dart';

//==============================================================================
// 數據源與倉庫 Providers
//==============================================================================

/// 遠程數據源 Provider
/// 提供從後端獲取 Gallery 相關數據的數據源
@riverpod
GalleryDataSource galleryRemoteDataSource(Ref ref) {
  final apiClient = ref.watch(nestjsApiClientProvider);
  return RemoteGalleryDataSourceImpl(apiClient);
}

/// Gallery 倉庫 Provider
/// 提供對 Gallery 數據的訪問和操作
@riverpod
GalleryRepository galleryRepository(Ref ref) {
  final dataSource = ref.watch(galleryRemoteDataSourceProvider);
  return GalleryRepositoryImpl(dataSource);
}

/// 媒體遠程數據源 Provider
/// 提供從後端獲取媒體相關數據的數據源
@riverpod
Future<MediaDataSource> remoteMediaDataSource(Ref ref) async {
  final apiClient = ref.watch(nestjsApiClientProvider);
  return RemoteMediaDataSourceImpl(apiClient);
}

/// 媒體倉庫 Provider
/// 提供對媒體數據的訪問和操作
@riverpod
Future<MediaRepository> mediaRepository(Ref ref) async {
  final dataSource = await ref.watch(remoteMediaDataSourceProvider.future);
  return MediaRepositoryImpl(dataSource);
}

//==============================================================================
// 用例 Providers
//==============================================================================

/// 獲取 Gallery 類型列表用例 Provider
@riverpod
GetGalleryTypesUseCase getGalleryTypesUseCase(Ref ref) {
  final repository = ref.watch(galleryRepositoryProvider);
  return GetGalleryTypesUseCase(repository);
}

/// 獲取 Classifier 標籤用例 Provider
@riverpod
GetClassifierTagUseCase getClassifierTagUseCase(Ref ref) {
  final repository = ref.watch(galleryRepositoryProvider);
  return GetClassifierTagUseCase(repository);
}

//==============================================================================
// Gallery 類型相關 Providers
//==============================================================================

/// 提供 Gallery 類型列表數據
@riverpod
Future<List<GalleryType>> galleryTypes(Ref ref) async {
  final usecase = ref.watch(getGalleryTypesUseCaseProvider);
  return await usecase.execute();
}

/// 當前選中的 Gallery 類型索引
@riverpod
class SelectedGalleryTypeIndex extends _$SelectedGalleryTypeIndex {
  @override
  int build() => 0; // 默認選中第一個

  /// 設置當前選中的 Gallery 類型索引
  void setIndex(int index) => state = index;
}

/// 當前選中的 Gallery 類型
@riverpod
Future<GalleryType> selectedGalleryType(Ref ref) async {
  final types = await ref.watch(galleryTypesProvider.future);
  final selectedIndex = ref.watch(selectedGalleryTypeIndexProvider);
  return types[selectedIndex];
}

//==============================================================================
// Classifier 相關 Providers
//==============================================================================

/// 當前選中的 Classifier 索引
@riverpod
class SelectedGalleryClassifierIndex extends _$SelectedGalleryClassifierIndex {
  @override
  int build() => 0; // 默認選中第一個

  /// 設置當前選中的 Classifier 索引
  void setIndex(int index) => state = index;
}

/// 當前選中的 Classifier id
@riverpod
Future<int> selectedClassifierId(Ref ref) async {
  final selectedGalleryType = await ref.watch(selectedGalleryTypeProvider.future);
  final selectedIndex = ref.watch(selectedGalleryClassifierIndexProvider);
  return selectedGalleryType.classifiers[selectedIndex].id;
}
