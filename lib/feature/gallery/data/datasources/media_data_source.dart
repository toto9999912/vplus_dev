import '../dtos/gallery_media_dto.dart';

abstract class MediaDataSource {
  Future<List<GalleryMediaDto>> getTagSearchMedia(List<int> tagIds);

  Future<void> uploadMedia();
}
