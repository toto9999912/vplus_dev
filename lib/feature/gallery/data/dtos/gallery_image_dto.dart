import 'package:freezed_annotation/freezed_annotation.dart';
import '../../domain/entities/gallery_image.dart';

part 'gallery_image_dto.freezed.dart';
part 'gallery_image_dto.g.dart';

/// 圖片資源模型
@freezed
abstract class GalleryImageDto with _$GalleryImageDto {
  const factory GalleryImageDto({
    /// 圖片id
    required int id,

    /// 小圖路徑
    required String smallAddressUrl,

    /// 中圖路徑
    required String mediumAddressUrl,

    /// 大圖路徑
    required String largeAddressUrl,
  }) = _GalleryImageDto;

  const GalleryImageDto._();

  /// 將DTO轉換為領域模型
  GalleryImage toDomain() {
    return GalleryImage(
      id: id,
      smallAddressUrl: smallAddressUrl,
      mediumAddressUrl: mediumAddressUrl,
      largeAddressUrl: largeAddressUrl,
    );
  }

  factory GalleryImageDto.fromJson(Map<String, dynamic> json) => _$GalleryImageDtoFromJson(json);
}
