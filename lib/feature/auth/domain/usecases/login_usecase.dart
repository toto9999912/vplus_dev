import 'package:vplus_dev/core/service/token_service.dart';
import 'package:vplus_dev/core/service/user_service.dart';
import '../../data/repositories/auth_repository.dart';
import '../../domain/entities/user_profile.dart';

class LoginUseCase {
  final AuthRepository repository;
  final TokenService tokenService;
  final UserService userService;

  LoginUseCase(this.repository, this.tokenService, this.userService);

  Future<UserProfile> execute(String mobile, String password) async {
    final result = await repository.login(mobile, password);

    // 將 user DTO 轉換為 domain entity
    UserProfile userProfile = result.user;

    // 保存 token (注意：這裡假設 refresh token 也是 access token，如果 API 有提供真正的 refresh token 請修正)
    await tokenService.saveToken(accessToken: result.accessToken, refreshToken: result.refreshToken);

    // 保存 user profile
    await userService.saveUserProfile(userProfile: userProfile);

    return userProfile;
  }
}
