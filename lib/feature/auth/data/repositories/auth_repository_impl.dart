import 'package:vplus_dev/core/service/token_service.dart';
import 'package:vplus_dev/core/service/user_service.dart';
import '../../domain/entities/user_profile.dart';
import '../datasources/auth_data_source.dart';

import 'auth_repository.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthDataSource _dataSource;
  final TokenService _tokenService;
  final UserService _userService;
  AuthRepositoryImpl(this._dataSource, this._tokenService, this._userService);

  @override
  Future<UserProfile> login(String mobile, String password) async {
    final response = await _dataSource.login(mobile, password);
    UserProfile userProfile = response.user.toDomain();
    await _tokenService.saveToken(accessToken: response.accessToken, refreshToken: response.accessToken);
    await _userService.saveUserProfile(userProfile: userProfile);
    return userProfile;
  }
}
