import 'package:vplus_dev/core/network/api_client.dart';

import '../dtos/login_response_dto.dart';
import 'auth_data_source.dart';

class RemoteAuthDataSourceImpl implements AuthDataSource {
  final ApiClient _apiClient;

  RemoteAuthDataSourceImpl(this._apiClient);

  @override
  Future<LoginResponseDto> login(String account, String password) async {
    final response = await _apiClient.post(
      'login',
      body: {'mobile': account, 'password': password, 'countryId': 1},
      fromJsonT: (json) => LoginResponseDto.fromJson(json as Map<String, dynamic>),
    );
    return response.data;
  }
}
