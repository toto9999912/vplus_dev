import '../../domain/entities/gallery_media.dart';

abstract class MediaRepository {
  /// 獲取相簿分類的圖片
  Future<List<GalleryMedia>> getTagSearchMedia(List<int> tagIds);
}
