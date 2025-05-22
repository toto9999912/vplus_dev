import 'package:vplus_dev/core/network/api_client.dart';
import 'package:vplus_dev/feature/gallery/data/dtos/gallery_classifier_dto.dart';

import 'diagram_data_source.dart';

class RemoteDiagramDataSourceImpl implements DiagramDataSource {
  final ApiClient client;

  RemoteDiagramDataSourceImpl(this.client);

  @override
  Future<List<ClassifierDto>> getDiagram() async {
    final response = await client.get(
      'gallery/project/diagram/header',
      fromJsonT: (json) => (json as List).map((item) => ClassifierDto.fromJson(item as Map<String, dynamic>)).toList(),
      withToken: true,
    );
    return response.data;
  }

  @override
  Future<ClassifierDto> getProjectDiagramClassifierTag(int classifierId, int projectId) async {
    final response = await client.get(
      'gallery/project/$projectId/tag/classifier/core/data',
      params: {'classifierId': classifierId},
      fromJsonT: (json) => ClassifierDto.fromJson(json as Map<String, dynamic>),
      withToken: true,
    );
    return response.data;
  }
}
