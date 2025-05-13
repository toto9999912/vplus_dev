import 'package:freezed_annotation/freezed_annotation.dart';
import '../../domain/entities/tag_category.dart';
import 'tag_dto.dart';

part 'tag_category_dto.freezed.dart';
part 'tag_category_dto.g.dart';

@freezed
abstract class TagCategoryDto with _$TagCategoryDto {
  const factory TagCategoryDto({
    ///tag主分類 id
    required int id,

    ///標題
    required String title,

    ///顏色
    String? color,

    ///tag主分類排序
    required int sort,

    ///示意圖路徑
    String? iconUrl,
    required List<TagDto> tags,
    int? galleryTagClassifierId,
  }) = _TagCategoryDto;

  factory TagCategoryDto.fromJson(Map<String, dynamic> json) => _$TagCategoryDtoFromJson(json);

  const TagCategoryDto._();

  TagCategory toDomain() {
    return TagCategory(
      id: id,
      title: title,
      sort: sort,
      tags: tags.map((dto) => dto.toDomain()).toList(),
    );
  }
}
