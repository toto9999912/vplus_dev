import 'package:freezed_annotation/freezed_annotation.dart';

part 'reorder_request_dto.freezed.dart';
part 'reorder_request_dto.g.dart';

/// 用於請求排序順序的項目
@freezed
abstract class ReorderItemDto with _$ReorderItemDto {
  const factory ReorderItemDto({
    required int id,
    required int sort,
  }) = _ReorderItemDto;

  factory ReorderItemDto.fromJson(Map<String, dynamic> json) => _$ReorderItemDtoFromJson(json);
}

/// 用於重新排序請求的DTO
@freezed
abstract class ReorderRequestDto with _$ReorderRequestDto {
  const factory ReorderRequestDto({
    required List<ReorderItemDto> items,
  }) = _ReorderRequestDto;

  factory ReorderRequestDto.fromJson(Map<String, dynamic> json) => _$ReorderRequestDtoFromJson(json);

  /// 從一般物件列表創建排序請求
  /// 每個物件必須有id屬性
  static ReorderRequestDto fromItemList<T>(List<T> items) {
    final reorderItems = items.asMap().entries.map((entry) {
      final item = entry.value as dynamic;
      return ReorderItemDto(id: item.id, sort: entry.key);
    }).toList();

    return ReorderRequestDto(items: reorderItems);
  }
}
