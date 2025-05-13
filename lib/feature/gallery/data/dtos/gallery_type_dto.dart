import 'package:freezed_annotation/freezed_annotation.dart';
import '../../domain/entities/gallery_type.dart';
import 'gallery_classifier_dto.dart';

part 'gallery_type_dto.freezed.dart';
part 'gallery_type_dto.g.dart';

@freezed
abstract class GalleryTypeDto with _$GalleryTypeDto {
  const factory GalleryTypeDto({
    ///gallery type id
    required int id,

    ///gallery type 標題
    required String title,

    ///gallery type 標題
    String? describe,
    required List<ClassifierDto> classifiers,
  }) = _GalleryTypeDto;

  factory GalleryTypeDto.fromJson(Map<String, dynamic> json) => _$GalleryTypeDtoFromJson(json);

  const GalleryTypeDto._();

  GalleryType toDomain() {
    return GalleryType(
      id: id,
      title: title.toString(),
      classifiers: classifiers.map((dto) => dto.toDomain()).toList(),
    );
  }
}
