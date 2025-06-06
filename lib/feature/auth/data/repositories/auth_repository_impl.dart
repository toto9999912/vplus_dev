import '../../domain/entities/login_result.dart';

import '../datasources/auth_data_source.dart';
import 'auth_repository.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthDataSource _dataSource;

  AuthRepositoryImpl(this._dataSource);

  @override
  Future<LoginResult> login(String mobile, String password) async {
    final dto = await _dataSource.login(mobile, password);

    // Repository 負責轉換
    return LoginResult(
      accessToken: dto.accessToken,
      refreshToken: dto.refreshToken, // 修復: 使用正確的 refreshToken
      user: dto.user.toDomain(), // 在這裡轉換
    );
  }

  @override
  Future<LoginResult?> refreshToken() async {
    try {
      final dto = await _dataSource.refreshToken();
      
      return LoginResult(
        accessToken: dto.accessToken,
        refreshToken: dto.refreshToken,
        user: dto.user.toDomain(),
      );
    } catch (e) {
      // Token 刷新失敗，返回 null
      return null;
    }
  }
}
