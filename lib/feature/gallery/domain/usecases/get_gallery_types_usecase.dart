import '../../data/repositories/gallery_repository.dart';
import '../entities/gallery_type.dart';

class GetGalleryTypesUseCase {
  final GalleryRepository repository;

  GetGalleryTypesUseCase(this.repository);

  Future<List<GalleryType>> execute() async {
    return await repository.getGalleryTypes();
  }
}
