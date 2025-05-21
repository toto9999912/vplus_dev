import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:vplus_dev/core/providers/api_client_providers.dart';
import 'package:vplus_dev/feature/project/domain/entities/project.dart';
import 'package:vplus_dev/feature/project/domain/enums/project_status.dart';
import 'package:vplus_dev/feature/project/domain/usecases/group_projects_usecase.dart';

import '../../data/datasources/project_data_source.dart';
import '../../data/datasources/remote_project_data_source_impl.dart';
import '../../data/repositories/project_repository.dart';
import '../../data/repositories/project_repository_impl.dart';

part 'project_providers.g.dart';

//==============================================================================
// 數據源與倉庫 Providers
//==============================================================================

/// 遠程數據源 Provider
/// 提供從後端獲取 Gallery 相關數據的數據源
@riverpod
ProjectDataSource remoteProjectDataSource(Ref ref) {
  final apiClient = ref.watch(nestjsApiClientProvider);
  return RemoteProjectDataSourceImpl(apiClient);
}

/// Gallery 倉庫 Provider
/// 提供對 Gallery 數據的訪問和操作
@riverpod
ProjectRepository projectRepository(Ref ref) {
  final dataSource = ref.watch(remoteProjectDataSourceProvider);
  return ProjectRepositoryImpl(dataSource);
}

/// 獲取分組專案的 UseCase Provider
@riverpod
GetGroupedProjectsUseCase getGroupedProjectsUseCase(Ref ref) {
  final repository = ref.watch(projectRepositoryProvider);
  return GetGroupedProjectsUseCase(repository);
}

/// 直接提供分組專案資料的 Provider
@riverpod
Future<Map<ProjectStatus, List<Project>>> groupedProjects(Ref ref, {bool includeArchived = false, bool includeEmpty = false}) async {
  final useCase = ref.watch(getGroupedProjectsUseCaseProvider);
  return useCase.execute(includeArchived: includeArchived, includeEmpty: includeEmpty);
}
