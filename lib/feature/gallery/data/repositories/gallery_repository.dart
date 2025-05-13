import '../../domain/entities/gallery_classifier.dart';
import '../../domain/entities/gallery_type.dart';
import '../dtos/reorder_request_dto.dart';

abstract class GalleryRepository {
  Future<List<GalleryType>> getGalleryTypes();

  Future<Classifier> getGalleryClassifierTag(int classifierId);

  Future<void> reorderTagCategory(ReorderRequestDto request);

  Future<void> reorderTag(ReorderRequestDto request);
}
