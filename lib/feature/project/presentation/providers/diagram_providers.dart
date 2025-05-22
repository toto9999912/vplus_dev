import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:vplus_dev/core/providers/api_client_providers.dart';
import 'package:vplus_dev/feature/gallery/domain/entities/gallery_type.dart';
import 'package:vplus_dev/feature/project/data/datasources/diagram_data_source.dart';
import 'package:vplus_dev/feature/project/data/datasources/remote_diagram_data_source_impl.dart';
import 'package:vplus_dev/feature/project/data/repositories/diagram_repository.dart';

import '../../data/repositories/diagram_repository_impl.dart';
import '../../domain/usecases/get_diagram_header_usecase.dart';
import '../../domain/usecases/get_project_classifier_tag_usecase.dart';

part 'diagram_providers.g.dart';

//==============================================================================
// 數據源與倉庫 Providers
//==============================================================================

/// 遠程數據源 Provider
/// 提供從後端獲取 Diagram 相關數據的數據源
@riverpod
DiagramDataSource diagramRemoteDataSource(Ref ref) {
  final apiClient = ref.watch(nestjsApiClientProvider);
  return RemoteDiagramDataSourceImpl(apiClient);
}

/// Diagram 倉庫 Provider
/// 提供對 Diagram 數據的訪問和操作
@riverpod
DiagramRepository diagramRepository(Ref ref) {
  final dataSource = ref.watch(diagramRemoteDataSourceProvider);
  return DiagramRepositoryImpl(dataSource);
}

//==============================================================================
// 用例 Providers
//==============================================================================

@riverpod
GetDiagramHeaderUsecase getDiagramHeaderUsecase(Ref ref) {
  final repository = ref.watch(diagramRepositoryProvider);
  return GetDiagramHeaderUsecase(repository);
}

/// 獲取 Classifier 標籤用例 Provider
@riverpod
GetProjectClassifierTagUseCase getProjectClassifierTagUseCase(Ref ref) {
  final repository = ref.watch(diagramRepositoryProvider);
  return GetProjectClassifierTagUseCase(repository);
}

//==============================================================================
// Diagram 類型相關 Providers
//==============================================================================

/// 提供 Diagram 類型列表數據
@riverpod
Future<GalleryType> diagramGalleryType(Ref ref) async {
  final usecase = ref.watch(getDiagramHeaderUsecaseProvider);
  return await usecase.execute();
}
