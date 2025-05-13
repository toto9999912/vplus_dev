import '../../data/repositories/gallery_repository.dart';
import '../entities/gallery_classifier.dart';

class GetClassifierTagUseCase {
  final GalleryRepository repository;

  GetClassifierTagUseCase(this.repository);

  Future<Classifier> execute(int classifierId) async {
    return await repository.getGalleryClassifierTag(classifierId);
  }
}
