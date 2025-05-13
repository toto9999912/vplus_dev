import '../../data/repositories/auth_repository.dart';
import '../../domain/entities/user_profile.dart';

class LoginUseCase {
  final AuthRepository repository;

  LoginUseCase(this.repository);

  Future<UserProfile> execute(String mobile, String password) async {
    return await repository.login(mobile, password);
  }
}
