import 'package:vplus_dev/feature/gallery/domain/entities/gallery_classifier.dart';

abstract class DiagramRepository {
  Future<List<Classifier>> getDiagram();

  Future<Classifier> getProjectDiagramClassifierTag(int classifierId, int projectId);
}
