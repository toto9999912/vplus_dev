// 新增：lib/feature/auth/domain/entities/login_result.dart
import 'package:freezed_annotation/freezed_annotation.dart';

import 'user_profile.dart';

part 'login_result.freezed.dart';

@freezed
abstract class LoginResult with _$LoginResult {
  const factory LoginResult({required String accessToken, required String refreshToken, required UserProfile user}) = _LoginResult;
}
