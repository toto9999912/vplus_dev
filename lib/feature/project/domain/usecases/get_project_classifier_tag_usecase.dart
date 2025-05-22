import 'package:vplus_dev/feature/gallery/domain/entities/gallery_classifier.dart';

import '../../data/repositories/diagram_repository.dart';

class GetProjectClassifierTagUseCase {
  final DiagramRepository repository;

  GetProjectClassifierTagUseCase(this.repository);

  Future<Classifier> execute(int classifierId, int projectId) async {
    final classifiers = await repository.getProjectDiagramClassifierTag(classifierId, projectId);
    return classifiers;
  }
}
