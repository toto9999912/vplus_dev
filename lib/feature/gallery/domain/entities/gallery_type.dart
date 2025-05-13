import 'package:freezed_annotation/freezed_annotation.dart';
import 'gallery_classifier.dart';

part 'gallery_type.freezed.dart';

@freezed
abstract class GalleryType with _$GalleryType {
  const factory GalleryType({
    ///gallery type id
    required int id,

    ///gallery type 標題
    required String title,
    required List<Classifier> classifiers,
  }) = _GalleryType;
}
