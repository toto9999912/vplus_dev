import 'package:freezed_annotation/freezed_annotation.dart';

part 'liked_user.freezed.dart';
part 'liked_user.g.dart';

/// LikedUser 實體類
///
/// 用於表示對媒體內容點讚的用戶資訊
@freezed
abstract class LikedUser with _$LikedUser {
  /// 建構子
  ///
  /// [id] - 用戶ID
  /// [usernickname] - 用戶暱稱
  /// [picaddress] - 用戶頭像圖片地址
  const factory LikedUser({
    /// 用戶ID
    required int id,

    /// 用戶暱稱
    String? usernickname,

    /// 用戶頭像圖片地址
    String? picaddress,
  }) = _LikedUser;

  /// 從JSON數據創建LikedUser實體
  factory LikedUser.fromJson(Map<String, dynamic> json) => _$LikedUserFromJson(json);
}
