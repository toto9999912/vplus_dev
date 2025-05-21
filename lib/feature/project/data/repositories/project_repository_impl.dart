import 'package:vplus_dev/feature/project/domain/entities/project.dart';

import '../datasources/project_data_source.dart';
import 'project_repository.dart';

class ProjectRepositoryImpl implements ProjectRepository {
  final PorjectDataSource _dataSource;

  ProjectRepositoryImpl(this._dataSource);
  @override
  Future<List<Project>> getProjectList() async {
    final dtos = await _dataSource.getProjectList();

    return dtos.map((dto) => dto.toDomain()).toList();
  }
}
