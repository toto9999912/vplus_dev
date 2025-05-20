import 'package:vplus_dev/core/network/api_client.dart';

import '../dtos/tag_request_dto.dart';
import '../dtos/gallery_classifier_dto.dart';
import '../dtos/gallery_type_dto.dart';
import '../dtos/reorder_request_dto.dart';
import '../dtos/tag_response_dto.dart';
import 'gallery_data_source.dart';

class RemoteGalleryDataSourceImpl implements GalleryDataSource {
  final ApiClient client;
  RemoteGalleryDataSourceImpl(this.client);

  @override
  Future<List<GalleryTypeDto>> getGalleryTypes() async {
    final response = await client.get(
      'gallery/type',
      fromJsonT: (json) => (json as List).map((item) => GalleryTypeDto.fromJson(item as Map<String, dynamic>)).toList(),
      withToken: true,
    );
    return response.data;
  }

  @override
  Future<ClassifierDto> getGalleryClassifierTag(int classifierId) async {
    final response = await client.get(
      'gallery/tag/classifier/core/data',
      params: {'classifierId': classifierId},
      fromJsonT: (json) => ClassifierDto.fromJson(json as Map<String, dynamic>),
      withToken: true,
    );
    return response.data;
  }

  @override
  Future<void> reorderTagCategory(ReorderRequestDto request) async {
    await client.put('gallery/tagCategory/sort', withToken: true, body: request.toJson(), fromJsonT: (json) {});
  }

  @override
  Future<void> reorderTag(ReorderRequestDto request) async {
    await client.put('gallery/tag/sort', withToken: true, body: request.toJson(), fromJsonT: (json) {});
  }

  @override
  Future<TagResponseDto> createTag(TagRequestDto request) async {
    final response = await client.post(
      'gallery/tag',
      withToken: true,
      body: request.toJson(),
      fromJsonT: (json) => TagResponseDto.fromJson(json as Map<String, dynamic>),
    );
    return response.data;
  }

  @override
  Future<void> editTag(int tagId, TagRequestDto request) async {
    await client.put(
      'gallery/tag/$tagId',
      withToken: true,
      body: request.toJson(),
      fromJsonT: (json) => TagResponseDto.fromJson(json as Map<String, dynamic>),
    );
  }
}
