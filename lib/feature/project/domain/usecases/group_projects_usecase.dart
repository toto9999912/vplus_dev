// domain/usecases/get_grouped_projects_usecase.dart
import 'package:vplus_dev/feature/project/domain/entities/project.dart';
import 'package:vplus_dev/feature/project/domain/enums/project_status.dart';
import 'package:vplus_dev/feature/project/data/repositories/project_repository.dart';

class GetGroupedProjectsUseCase {
  final ProjectRepository repository;

  GetGroupedProjectsUseCase(this.repository);

  /// 獲取並返回按狀態分組的專案資料
  ///
  /// [includeArchived] 是否包含封存的專案
  /// [includeEmpty] 是否包含沒有專案的狀態分組
  Future<Map<ProjectStatus, List<Project>>> execute({bool includeArchived = false, bool includeEmpty = false}) async {
    // 1. 從倉庫獲取所有專案
    final allProjects = await repository.getProjectList();

    // 2. 將專案分組
    final Map<ProjectStatus, List<Project>> grouped = {};

    // 初始化所有需要的狀態分組
    for (final status in ProjectStatus.values) {
      if (includeArchived || status != ProjectStatus.archived) {
        grouped[status] = [];
      }
    }

    // 將專案分配到對應的狀態組
    for (final project in allProjects) {
      if ((includeArchived || project.status != ProjectStatus.archived) && grouped.containsKey(project.status)) {
        grouped[project.status]!.add(project);
      }
    }

    // 根據需要過濾空的狀態分組
    if (!includeEmpty) {
      return Map.fromEntries(grouped.entries.where((entry) => entry.value.isNotEmpty));
    }

    return grouped;
  }
}
