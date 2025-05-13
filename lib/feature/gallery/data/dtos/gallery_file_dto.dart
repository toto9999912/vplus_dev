import 'package:freezed_annotation/freezed_annotation.dart';
import '../../domain/entities/gallery_file.dart';

part 'gallery_file_dto.freezed.dart';
part 'gallery_file_dto.g.dart';

/// 文件資源模型
@freezed
abstract class GalleryFileDto with _$GalleryFileDto {
  const factory GalleryFileDto({
    /// 文件id
    required int id,

    /// 文件路徑
    required String addressUrl,
  }) = _GalleryFileDto;

  const GalleryFileDto._();

  /// 將DTO轉換為領域模型
  GalleryFile toDomain() {
    return GalleryFile(
      id: id,
      addressUrl: addressUrl,
    );
  }

  factory GalleryFileDto.fromJson(Map<String, dynamic> json) => _$GalleryFileDtoFromJson(json);
}
