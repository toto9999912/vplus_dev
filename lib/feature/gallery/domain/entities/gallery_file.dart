import 'package:freezed_annotation/freezed_annotation.dart';

part 'gallery_file.freezed.dart';
part 'gallery_file.g.dart';

/// 檔案資源實體類
///
/// 用於存儲和管理畫廊中顯示的檔案資源
@freezed
abstract class GalleryFile with _$GalleryFile {
  /// 檔案資源建構子
  ///
  /// [id] - 檔案資源ID
  /// [addressUrl] - 檔案路徑，用於下載或訪問
  const factory GalleryFile({
    /// 檔案ID
    required int id,

    /// 檔案路徑，用於下載或訪問
    required String addressUrl,
  }) = _GalleryFile;

  /// 從JSON數據創建GalleryFile實體
  factory GalleryFile.fromJson(Map<String, dynamic> json) => _$GalleryFileFromJson(json);
}
