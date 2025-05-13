import 'package:freezed_annotation/freezed_annotation.dart';
import '../../domain/entities/liked_user.dart';

part 'liked_user_dto.freezed.dart';
part 'liked_user_dto.g.dart';

@freezed
abstract class LikedUserDto with _$LikedUserDto {
  const factory LikedUserDto({
    required int id,
    String? usernickname,
    String? picaddress,
  }) = _LikedUserDto;

  const LikedUserDto._();

  /// 將DTO轉換為領域模型
  LikedUser toDomain() {
    return LikedUser(
      id: id,
      usernickname: usernickname,
      picaddress: picaddress,
    );
  }

  factory LikedUserDto.fromJson(Map<String, dynamic> json) => _$LikedUserDtoFromJson(json);
}
