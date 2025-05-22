import 'package:vplus_dev/feature/gallery/domain/entities/gallery_type.dart';

import '../../data/repositories/diagram_repository.dart';

class GetDiagramHeaderUsecase {
  final DiagramRepository repository;

  GetDiagramHeaderUsecase(this.repository);

  Future<GalleryType> execute() async {
    final classifiers = await repository.getDiagram();
    return GalleryType(id: 6, title: '專案庫', classifiers: classifiers);
  }
}
