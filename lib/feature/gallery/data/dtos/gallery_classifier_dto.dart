import 'package:freezed_annotation/freezed_annotation.dart';
import '../../domain/entities/gallery_classifier.dart';
import 'tag_category_dto.dart';

part 'gallery_classifier_dto.freezed.dart';
part 'gallery_classifier_dto.g.dart';

@freezed
abstract class ClassifierDto with _$ClassifierDto {
  const factory ClassifierDto({
    ///gallery大分類id
    required int id,

    ///分類父級id，最上級為null
    int? parentId,

    /// 最上層庫的分類 gallery type的id
    required int galleryTypeId,

    ///中文標題
    required String titleZhTw,

    ///英文標題
    required String titleEn,

    ///示意圖路徑
    String? iconUrl,

    ///同級排序
    required int sort,

    ///子類別
    List<ClassifierDto>? subClassifiers,

    ///該分類包含的tag標籤 通常只有最底層的分類才會有資料
    List<TagCategoryDto>? categories,
  }) = _ClassifierDto;

  factory ClassifierDto.fromJson(Map<String, dynamic> json) => _$ClassifierDtoFromJson(json);

  const ClassifierDto._();

  // DTO轉換為領域實體
  Classifier toDomain() {
    return Classifier(
      id: id,
      titleZhTw: titleZhTw,
      titleEn: titleEn,
      iconUrl: iconUrl,
      sort: sort,
      categories: categories?.map((dto) => dto.toDomain()).toList(),
      subClassifiers: subClassifiers?.map((dto) => dto.toDomain()).toList(),
    );
  }
}
