import 'package:freezed_annotation/freezed_annotation.dart';

part 'tag_request_dto.freezed.dart';
part 'tag_request_dto.g.dart';

/// 建立標籤請求DTO
@freezed
abstract class TagRequestDto with _$TagRequestDto {
  /// 建構子
  const factory TagRequestDto({
    /// 標籤標題
    required String title,

    /// 分類ID
    @JsonKey(name: 'category_id') required int categoryId,

    /// 排序順序
    required int color,
  }) = _TagRequestDto;

  /// 從JSON轉換為物件
  factory TagRequestDto.fromJson(Map<String, dynamic> json) => _$TagRequestDtoFromJson(json);
}
