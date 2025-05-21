import '../dtos/project_dto.dart';

abstract class ProjectDataSource {
  Future<List<ProjectDto>> getProjectList();
}
