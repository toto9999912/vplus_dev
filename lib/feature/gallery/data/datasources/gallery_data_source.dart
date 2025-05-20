import '../dtos/tag_request_dto.dart';
import '../dtos/gallery_classifier_dto.dart';
import '../dtos/gallery_type_dto.dart';
import '../dtos/reorder_request_dto.dart';
import '../dtos/tag_response_dto.dart';

abstract class GalleryDataSource {
  Future<List<GalleryTypeDto>> getGalleryTypes();

  Future<ClassifierDto> getGalleryClassifierTag(int classifierId);

  Future<void> reorderTagCategory(ReorderRequestDto request);

  Future<void> reorderTag(ReorderRequestDto request);

  Future<TagResponseDto> createTag(TagRequestDto request);

  Future<void> editTag(int tagId, TagRequestDto request);

  Future<void> deleteTag(int tagId);
}
