import 'package:freezed_annotation/freezed_annotation.dart';

part 'gallery_video.freezed.dart';
part 'gallery_video.g.dart';

/// 影片資源實體類
///
/// 用於存儲和管理畫廊中顯示的影片資源
@freezed
abstract class GalleryVideo with _$GalleryVideo {
  /// 影片資源建構子
  ///
  /// [id] - 影片資源ID
  /// [addressUrl] - 影片路徑，用於播放
  /// [thumbnailUrl] - 影片縮圖路徑，用於顯示縮略圖
  const factory GalleryVideo({
    /// 影片ID
    required int id,

    /// 影片路徑，用於播放
    required String addressUrl,

    /// 影片縮圖路徑，用於顯示縮略圖
    required String thumbnailUrl,
  }) = _GalleryVideo;

  /// 從JSON數據創建GalleryVideo實體
  factory GalleryVideo.fromJson(Map<String, dynamic> json) => _$GalleryVideoFromJson(json);
}
