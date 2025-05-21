import '../dtos/project_dto.dart';

abstract class PorjectDataSource {
  Future<List<ProjectDto>> getProjectList();
}
