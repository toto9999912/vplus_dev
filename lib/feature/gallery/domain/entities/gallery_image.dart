import 'package:freezed_annotation/freezed_annotation.dart';

part 'gallery_image.freezed.dart';
part 'gallery_image.g.dart';

/// 圖片資源實體類
///
/// 用於存儲和管理畫廊中顯示的圖片資源
@freezed
abstract class GalleryImage with _$GalleryImage {
  /// 圖片資源建構子
  ///
  /// [id] - 圖片資源ID
  /// [smallAddressUrl] - 小圖路徑，通常用於縮略圖顯示
  /// [mediumAddressUrl] - 中圖路徑，用於一般預覽
  /// [largeAddressUrl] - 大圖路徑，用於高清顯示
  const factory GalleryImage({
    /// 圖片ID
    required int id,

    /// 小圖路徑，通常用於縮略圖顯示
    required String smallAddressUrl,

    /// 中圖路徑，用於一般預覽
    required String mediumAddressUrl,

    /// 大圖路徑，用於高清顯示
    required String largeAddressUrl,
  }) = _GalleryImage;

  /// 從JSON數據創建GalleryImage實體
  factory GalleryImage.fromJson(Map<String, dynamic> json) => _$GalleryImageFromJson(json);
}
