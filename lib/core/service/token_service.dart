import 'package:vplus_dev/core/constants/storage_keys.dart';
import 'package:vplus_dev/core/service/storage_service.dart';

class TokenService {
  final StorageService _storageService;

  // 內存緩存，避免頻繁讀取存儲
  String? _accessToken;
  String? _refreshToken;

  TokenService(this._storageService);

  String? get accessToken => _accessToken;
  String? get refreshToken => _refreshToken;

  // 加載令牌
  Future<void> loadTokens() async {
    _accessToken = await _storageService.secureRead(StorageKeys.accessToken);
    _refreshToken = await _storageService.secureRead(StorageKeys.refreshToken);
  }

  // 保存令牌
  Future<void> saveToken({required String accessToken, required String refreshToken}) async {
    _accessToken = accessToken;
    _refreshToken = refreshToken;

    await _storageService.secureWrite(StorageKeys.accessToken, accessToken);
    await _storageService.secureWrite(StorageKeys.refreshToken, refreshToken);
  }

  // 更新訪問令牌
  Future<void> updateAccessToken(String newAccessToken) async {
    _accessToken = newAccessToken;
    await _storageService.secureWrite(StorageKeys.accessToken, newAccessToken);
  }

  // 檢查是否有令牌
  bool hasToken() {
    return _accessToken != null && _accessToken!.isNotEmpty;
  }

  // 清除令牌
  Future<void> clearTokens() async {
    _accessToken = null;
    _refreshToken = null;

    await _storageService.secureDelete(StorageKeys.accessToken);
    await _storageService.secureDelete(StorageKeys.refreshToken);
  }
}
