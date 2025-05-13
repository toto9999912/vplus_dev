import 'package:freezed_annotation/freezed_annotation.dart';
import '../../domain/entities/tag.dart';

part 'tag_dto.freezed.dart';
part 'tag_dto.g.dart';

///gallery type是最上級的Tab標籤
@freezed
abstract class TagDto with _$TagDto {
  const factory TagDto({
    ///tag分類 id
    required int id,

    ///標題
    required String title,

    ///顏色
    required int color,

    ///tag分類排序
    required int sort,
  }) = _TagDto;

  factory TagDto.fromJson(Map<String, dynamic> json) => _$TagDtoFromJson(json);
  const TagDto._();

  Tag toDomain() {
    return Tag(
      id: id,
      title: title,
      color: color,
      sort: sort,
    );
  }
}
