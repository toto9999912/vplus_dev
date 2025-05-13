import 'package:freezed_annotation/freezed_annotation.dart';
import '../../domain/entities/gallery_video.dart';

part 'gallery_video_dto.freezed.dart';
part 'gallery_video_dto.g.dart';

/// 影片資源模型
@freezed
abstract class GalleryVideoDto with _$GalleryVideoDto {
  const factory GalleryVideoDto({
    /// 影片id
    required int id,

    /// 影片路徑
    required String addressUrl,

    ///影片縮圖路徑
    required String thumbnailUrl,
  }) = _GalleryVideoDto;

  const GalleryVideoDto._();

  /// 將DTO轉換為領域模型
  GalleryVideo toDomain() {
    return GalleryVideo(
      id: id,
      addressUrl: addressUrl,
      thumbnailUrl: thumbnailUrl,
    );
  }

  factory GalleryVideoDto.fromJson(Map<String, dynamic> json) => _$GalleryVideoDtoFromJson(json);
}
