import 'package:freezed_annotation/freezed_annotation.dart';
import '../../domain/entities/tag.dart';

part 'tag_response_dto.freezed.dart';
part 'tag_response_dto.g.dart';

@freezed
abstract class TagResponseDto with _$TagResponseDto {
  const factory TagResponseDto({
    required int id,
    required int sort,
    // 其他可能返回的欄位，如果有的話
  }) = _TagResponseDto;

  factory TagResponseDto.fromJson(Map<String, dynamic> json) => _$TagResponseDtoFromJson(json);

  const TagResponseDto._();

  Tag toDomain(String title, int color) {
    return Tag(id: id, title: title, color: color, sort: sort);
  }
}
