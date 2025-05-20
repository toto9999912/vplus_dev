import 'package:freezed_annotation/freezed_annotation.dart';

part 'create_tag_request_dto.freezed.dart';
part 'create_tag_request_dto.g.dart';

/// 建立標籤請求DTO
@freezed
abstract class CreateTagRequestDto with _$CreateTagRequestDto {
  /// 建構子
  const factory CreateTagRequestDto({
    /// 標籤標題
    required String title,

    /// 分類ID
    @JsonKey(name: 'category_id') required int categoryId,

    /// 排序順序
    required int color,
  }) = _CreateTagRequestDto;

  /// 從JSON轉換為物件
  factory CreateTagRequestDto.fromJson(Map<String, dynamic> json) => _$CreateTagRequestDtoFromJson(json);
}
