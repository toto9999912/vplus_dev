import 'package:dio/dio.dart';
import 'package:vplus_dev/core/network/api_client.dart';

import '../dtos/gallery_media_dto.dart';
import '../dtos/tag_search_request_dto.dart';
import 'media_data_source.dart';

class RemoteMediaDataSourceImpl implements MediaDataSource {
  final ApiClient client;
  RemoteMediaDataSourceImpl(this.client);

  @override
  Future<List<GalleryMediaDto>> getTagSearchMedia(List<int> tagIds) async {
    final response = await client.get(
      'gallery/tag/search',
      params: TagSearchRequestDto.fromIds(tagIds).toJson(),
      fromJsonT: (json) => (json as List).map((item) => GalleryMediaDto.fromJson(item as Map<String, dynamic>)).toList(),
      withToken: true,
    );
    return response.data;
  }

  @override
  Future<void> uploadMedia() async {
    FormData formData = FormData.fromMap({
      // image,video,file
      "uploadType": 'image',
      "file": await MultipartFile.fromFile(file.path, filename: fileName),
      "tagsId": tags.map((e) => e.id).toList(),
    });

    await client.postForm('gallery/tag/$tagId');
  }
}
