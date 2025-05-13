import 'package:freezed_annotation/freezed_annotation.dart';
import '../../domain/entities/chat_message.dart';

part 'chat_message_dto.freezed.dart';
part 'chat_message_dto.g.dart';

@freezed
abstract class ChatMessageDto with _$ChatMessageDto {
  const factory ChatMessageDto({
    ///留言id
    required int id,

    /// 主內容id
    required int mainId,

    /// 留言訊息
    required String message,

    ///創建日期
    required String createdAt,

    ///更新日期
    required String updatedAt,

    ///留言者id
    required int commenterId,

    ///留言者全名
    required String fullname,

    ///留言者部門
    required String department,

    ///留言者暱稱
    required String usernickname,

    ///留言者大頭貼
    String? picaddress,
  }) = _ChatMessageDto;

  const ChatMessageDto._();

  /// 將DTO轉換為領域模型
  ChatMessage toDomain() {
    return ChatMessage(
      id: id,
      mainId: mainId,
      message: message,
      createdAt: DateTime.parse(createdAt),
      updatedAt: DateTime.parse(updatedAt),
      commenterId: commenterId,
      fullname: fullname,
      department: department,
      usernickname: usernickname,
      picaddress: picaddress,
    );
  }

  factory ChatMessageDto.fromJson(Map<String, dynamic> json) => _$ChatMessageDtoFromJson(json);
}
