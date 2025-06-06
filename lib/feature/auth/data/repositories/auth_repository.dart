import '../../domain/entities/login_result.dart';

abstract class AuthRepository {
  Future<LoginResult> login(String mobile, String password); // 改這裡
}
