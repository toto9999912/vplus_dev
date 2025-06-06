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
      refreshToken: dto.accessToken,
      user: dto.user.toDomain(), // 在這裡轉換
    );
  }
}
