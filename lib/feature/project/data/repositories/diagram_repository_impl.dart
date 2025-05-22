import 'package:vplus_dev/feature/gallery/domain/entities/gallery_classifier.dart';

import '../datasources/diagram_data_source.dart';
import 'diagram_repository.dart';

class DiagramRepositoryImpl implements DiagramRepository {
  final DiagramDataSource _dataSource;

  DiagramRepositoryImpl(this._dataSource);
  @override
  Future<List<Classifier>> getDiagram() async {
    final dtos = await _dataSource.getDiagram();
    return dtos.map((dto) => dto.toDomain()).toList();
  }

  @override
  Future<Classifier> getProjectDiagramClassifierTag(int classifierId, int projectId) async {
    final dto = await _dataSource.getProjectDiagramClassifierTag(classifierId, projectId);
    return dto.toDomain();
  }
}
