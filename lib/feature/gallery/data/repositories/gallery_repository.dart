import 'package:vplus_dev/feature/gallery/data/dtos/tag_request_dto.dart';
import 'package:vplus_dev/feature/gallery/domain/entities/tag.dart';

import '../../domain/entities/gallery_classifier.dart';
import '../../domain/entities/gallery_type.dart';
import '../dtos/reorder_request_dto.dart';

abstract class GalleryRepository {
  Future<List<GalleryType>> getGalleryTypes();

  Future<Classifier> getGalleryClassifierTag(int classifierId);

  Future<void> reorderTagCategory(ReorderRequestDto request);

  Future<void> reorderTag(ReorderRequestDto request);

  Future<Tag> createTag(TagRequestDto request);

  Future<void> editTag(int tagId, TagRequestDto request);
}
