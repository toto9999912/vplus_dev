import 'package:freezed_annotation/freezed_annotation.dart';
import 'user_dto.dart';

part 'login_response_dto.freezed.dart';
part 'login_response_dto.g.dart';

@freezed
abstract class LoginResponseDto with _$LoginResponseDto {
  const factory LoginResponseDto({
    required String accessToken,
    required UserDto user,
  }) = _LoginResponseDto;

  factory LoginResponseDto.fromJson(Map<String, dynamic> json) => _$LoginResponseDtoFromJson(json);
}
