import 'package:freezed_annotation/freezed_annotation.dart';
import 'tag.dart';

part 'tag_category.freezed.dart';

@freezed
abstract class TagCategory with _$TagCategory {
  const factory TagCategory({
    ///tag主分類 id
    required int id,

    ///標題
    required String title,

    ///tag主分類排序
    required int sort,
    required List<Tag> tags,
  }) = _TagCategory;
}
