import '../dtos/login_response_dto.dart';

abstract class AuthDataSource {
  Future<LoginResponseDto> login(String account, String password);
}
