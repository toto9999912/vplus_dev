import 'package:vplus_dev/feature/gallery/data/dtos/gallery_classifier_dto.dart';

abstract class DiagramDataSource {
  Future<List<ClassifierDto>> getDiagram();

  Future<ClassifierDto> getProjectDiagramClassifierTag(int classifierId, int projectId);
}
