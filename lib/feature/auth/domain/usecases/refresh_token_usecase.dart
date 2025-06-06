import '../entities/login_result.dart';
import '../../data/repositories/auth_repository.dart';

class RefreshTokenUsecase {
  final AuthRepository _authRepository;

  RefreshTokenUsecase(this._authRepository);

  /// 執行 Token 刷新
  /// 
  /// 返回新的 LoginResult 如果成功，否則返回 null
  Future<LoginResult?> execute() async {
    try {
      return await _authRepository.refreshToken();
    } catch (e) {
      return null;
    }
  }
}
