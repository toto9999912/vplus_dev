import 'package:freezed_annotation/freezed_annotation.dart';
import '../../domain/entities/gallery_link.dart';

part 'gallery_link_dto.freezed.dart';
part 'gallery_link_dto.g.dart';

/// 鏈接資源模型
@freezed
abstract class GalleryLinkDto with _$GalleryLinkDto {
  const factory GalleryLinkDto({
    /// 鏈接id
    required int id,

    /// 鏈接網址
    required String addressUrl,

    /// 鏈接縮圖網址
    required String thumbnailUrl,

    /// 鏈接類型
    required String linkType,
  }) = _GalleryLinkDto;

  const GalleryLinkDto._();

  /// 將DTO轉換為領域模型
  GalleryLink toDomain() {
    return GalleryLink(
      id: id,
      addressUrl: addressUrl,
      thumbnailUrl: thumbnailUrl,
      linkType: linkType,
    );
  }

  factory GalleryLinkDto.fromJson(Map<String, dynamic> json) => _$GalleryLinkDtoFromJson(json);
}
