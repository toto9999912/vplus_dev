import 'package:freezed_annotation/freezed_annotation.dart';
import 'tag_category.dart';

part 'gallery_classifier.freezed.dart';

@freezed
abstract class Classifier with _$Classifier {
  const factory Classifier({
    ///gallery大分類id
    required int id,

    ///中文標題
    required String titleZhTw,

    ///英文標題
    required String titleEn,

    ///示意圖路徑
    String? iconUrl,

    ///同級排序
    required int sort,

    ///子類別
    List<Classifier>? subClassifiers,

    ///該分類包含的tag標籤 通常只有最底層的分類才會有資料
    List<TagCategory>? categories,
  }) = _Classifier;
}
