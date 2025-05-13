import 'package:freezed_annotation/freezed_annotation.dart';

part 'gallery_link.freezed.dart';
part 'gallery_link.g.dart';

/// 連結資源實體類
///
/// 用於存儲和管理畫廊中顯示的外部連結資源
@freezed
abstract class GalleryLink with _$GalleryLink {
  /// 連結資源建構子
  ///
  /// [id] - 連結資源ID
  /// [addressUrl] - 連結網址
  /// [thumbnailUrl] - 連結縮圖網址
  /// [linkType] - 連結類型
  const factory GalleryLink({
    /// 連結ID
    required int id,

    /// 連結網址
    required String addressUrl,

    /// 連結縮圖網址
    required String thumbnailUrl,

    /// 連結類型
    required String linkType,
  }) = _GalleryLink;

  /// 從JSON數據創建GalleryLink實體
  factory GalleryLink.fromJson(Map<String, dynamic> json) => _$GalleryLinkFromJson(json);
}
