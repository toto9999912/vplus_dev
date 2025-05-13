import 'package:freezed_annotation/freezed_annotation.dart';

part 'tag.freezed.dart';

///gallery type是最上級的Tab標籤
@freezed
abstract class Tag with _$Tag {
  const factory Tag({
    ///tag分類 id
    required int id,

    ///標題
    required String title,

    ///顏色
    required int color,

    ///tag分類排序
    required int sort,
  }) = _Tag;
}
