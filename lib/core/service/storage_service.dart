import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';

class StorageService {
  final FlutterSecureStorage _secureStorage;
  final SharedPreferences _preferences;

  StorageService(this._preferences, this._secureStorage);

  // 安全存儲方法 - 用於敏感資料
  Future<void> secureWrite(String key, String value) async {
    await _secureStorage.write(key: key, value: value);
  }

  Future<String?> secureRead(String key) async {
    return await _secureStorage.read(key: key);
  }

  Future<void> secureDelete(String key) async {
    await _secureStorage.delete(key: key);
  }

  // 一般存儲方法 - 用於非敏感資料
  Future<void> setString(String key, String value) async {
    await _preferences.setString(key, value);
  }

  String? getString(String key) {
    return _preferences.getString(key);
  }

  Future<void> setBool(String key, bool value) async {
    await _preferences.setBool(key, value);
  }

  bool? getBool(String key) {
    return _preferences.getBool(key);
  }

  Future<void> remove(String key) async {
    await _preferences.remove(key);
  }

  Future<void> clear() async {
    await _preferences.clear();
    await _secureStorage.deleteAll();
  }
}
