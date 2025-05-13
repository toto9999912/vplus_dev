import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:vplus_dev/shared/enum/logical_operator.dart';

part 'tag_search_request_dto.freezed.dart';
part 'tag_search_request_dto.g.dart';

@freezed
abstract class TagSearchRequestDto with _$TagSearchRequestDto {
  const TagSearchRequestDto._(); // 這個私有構造函數允許我們在類中添加方法

  const factory TagSearchRequestDto({
    /// 標籤ID列表，用逗號分隔
    required String tagIds,

    /// 搜尋條件，可能的值為 AND 或 OR
    @Default(LogicalOperator.or) LogicalOperator condition,
  }) = _TagSearchRequestDto;

  /// 從標籤對象列表創建請求
  /// [tags] 標籤對象列表，需要有 id 屬性
  /// [condition] 搜索條件（默認為 OR）
  factory TagSearchRequestDto.fromTags(List<dynamic> tags, {LogicalOperator condition = LogicalOperator.or}) {
    final tagIdsString = tags.map((tag) => tag.id.toString()).join(',');
    return TagSearchRequestDto(tagIds: tagIdsString, condition: condition);
  }

  /// 從ID列表創建請求
  /// [ids] 標籤ID列表
  /// [condition] 搜索條件（默認為 OR）
  factory TagSearchRequestDto.fromIds(List<int> ids, {LogicalOperator condition = LogicalOperator.or}) {
    return TagSearchRequestDto(tagIds: ids.join(','), condition: condition);
  }

  factory TagSearchRequestDto.fromJson(Map<String, dynamic> json) => _$TagSearchRequestDtoFromJson(json);
}
