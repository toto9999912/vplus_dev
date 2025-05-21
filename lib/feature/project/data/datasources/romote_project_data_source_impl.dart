import 'package:vplus_dev/core/network/api_client.dart';

import '../dtos/project_dto.dart';
import 'project_data_source.dart';

class RomoteProjectDataSourceImpl implements PorjectDataSource {
  final ApiClient client;
  RomoteProjectDataSourceImpl(this.client);
  @override
  Future<List<ProjectDto>> getProjectList() async {
    final response = await client.get(
      'project/list',
      fromJsonT: (json) => (json as List).map((item) => ProjectDto.fromJson(item as Map<String, dynamic>)).toList(),
      withToken: true,
    );
    return response.data;
  }
}
