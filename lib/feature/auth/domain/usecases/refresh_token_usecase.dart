import '../../data/repositories/auth_repository.dart';

abstract class RefreshTokenUseCase {
  final AuthRepository _authRepository;

  RefreshTokenUseCase(this._authRepository);

  Future<void> call() async {
    await _authRepository.refreshToken();
  }
}
