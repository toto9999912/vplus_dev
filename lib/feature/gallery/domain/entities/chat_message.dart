import 'package:freezed_annotation/freezed_annotation.dart';

part 'chat_message.freezed.dart';
part 'chat_message.g.dart';

/// ChatMessage 實體類
///
/// 用於表示媒體內容的留言訊息
@freezed
abstract class ChatMessage with _$ChatMessage {
  /// 建構子
  ///
  /// [id] - 留言ID
  /// [mainId] - 主內容ID，連結到相關的媒體內容
  /// [message] - 留言訊息內容
  /// [createdAt] - 留言建立時間
  /// [updatedAt] - 留言更新時間
  /// [commenterId] - 留言者ID
  /// [fullname] - 留言者全名
  /// [department] - 留言者部門
  /// [usernickname] - 留言者暱稱
  /// [picaddress] - 留言者頭像圖片地址
  const factory ChatMessage({
    /// 留言ID
    int? id,

    /// 主內容ID，連結到相關的媒體內容
    int? mainId,

    /// 留言訊息內容
    String? message,

    /// 留言建立時間
    required DateTime createdAt,

    /// 留言更新時間
    required DateTime updatedAt,

    /// 留言者ID
    int? commenterId,

    /// 留言者全名
    String? fullname,

    /// 留言者部門
    String? department,

    /// 留言者暱稱
    String? usernickname,

    /// 留言者頭像圖片地址
    String? picaddress,
  }) = _ChatMessage;

  /// 從JSON數據創建ChatMessage實體
  factory ChatMessage.fromJson(Map<String, dynamic> json) => _$ChatMessageFromJson(json);
}
