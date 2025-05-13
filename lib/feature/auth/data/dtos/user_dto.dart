import 'package:freezed_annotation/freezed_annotation.dart';

import '../../domain/entities/user_profile.dart';

part 'user_dto.freezed.dart';
part 'user_dto.g.dart';

@freezed
abstract class UserDto with _$UserDto {
  const factory UserDto({
    required int userid,
    required String username,
    required String fullname,
    required String usernickname,
    required String department,
    required int type,
    required int exp,
    required int iat,
    required String job,
    required String icon,
    required String style,
    required String material,
    required String furniture,
    required String project,
    required String design,
  }) = _UserDto;

  factory UserDto.fromJson(Map<String, dynamic> json) => _$UserDtoFromJson(json);

  const UserDto._();

  UserProfile toDomain() {
    return UserProfile(
      userid: userid,
      username: username,
      fullname: fullname,
      usernickname: usernickname,
      department: department,
      job: job,
      icon: icon,
    );
  }
}
