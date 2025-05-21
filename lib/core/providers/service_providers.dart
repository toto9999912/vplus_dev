import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:vplus_dev/core/service/storage_service.dart';
import 'package:vplus_dev/core/service/token_service.dart';
import 'package:vplus_dev/core/service/user_service.dart';

import '../router/app_router.dart';
import '../service/dialog_service.dart';

// 這將生成對應的 .g.dart 檔案
part 'service_providers.g.dart';

/// StorageService 提供者
/// 由於需要在外部初始化，所以使用 @Riverpod(keepAlive: true) 並保持為未實現狀態
@Riverpod(keepAlive: true)
StorageService storageService(Ref ref) {
  throw UnimplementedError('需要在ProviderScope.overrides中覆寫此提供者');
}

/// TokenService 提供者
@Riverpod(keepAlive: true)
TokenService tokenService(Ref ref) {
  final storageService = ref.watch(storageServiceProvider);
  return TokenService(storageService);
}

/// UserService 提供者
@Riverpod(keepAlive: true)
UserService userService(Ref ref) {
  final storageService = ref.watch(storageServiceProvider);
  return UserService(storageService);
}

@Riverpod(keepAlive: true)
DialogService dialogService(Ref ref) => DialogService(rootNavigatorKey);

/// 初始化服務提供者的方法
/// 返回一個 Override 列表，用於覆蓋 ProviderScope
Future<List<Override>> initializeServiceProviders() async {
  final preferences = await SharedPreferences.getInstance();
  const secureStorage = FlutterSecureStorage();

  return [storageServiceProvider.overrideWith((ref) => StorageService(preferences, secureStorage))];
}
