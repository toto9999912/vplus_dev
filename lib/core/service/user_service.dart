import 'dart:convert';
import 'package:vplus_dev/core/constants/storage_keys.dart';
import 'package:vplus_dev/core/service/storage_service.dart';
import 'package:vplus_dev/feature/auth/domain/entities/user_profile.dart';

class UserService {
  final StorageService _storageService;

  UserProfile? _userProfile;

  UserService(this._storageService);

  UserProfile? get userProfile => _userProfile;

  // 加載用戶資料
  Future<void> loadUserProfile() async {
    final userJson = _storageService.getString(StorageKeys.userProfile);
    if (userJson != null) {
      final Map<String, dynamic> userMap = jsonDecode(userJson);
      _userProfile = UserProfile.fromJson(userMap);
    }
  }

  // 保存用戶資料
  Future<void> saveUserProfile({required UserProfile userProfile}) async {
    _userProfile = userProfile;
    final userJson = jsonEncode(userProfile.toJson());
    await _storageService.setString(StorageKeys.userProfile, userJson);
    await _storageService.setBool(StorageKeys.isLoggedIn, true);
  }

  // 更新用戶資料
  Future<void> updateUserProfile({required UserProfile userProfile}) async {
    await saveUserProfile(userProfile: userProfile);
  }

  // 檢查用戶是否登入
  bool isLoggedIn() {
    return _storageService.getBool(StorageKeys.isLoggedIn) ?? false;
  }

  // 清除用戶資料
  Future<void> clearUserProfile() async {
    _userProfile = null;
    await _storageService.remove(StorageKeys.userProfile);
    await _storageService.setBool(StorageKeys.isLoggedIn, false);
  }
}
