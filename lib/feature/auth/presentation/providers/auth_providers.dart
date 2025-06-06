import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:vplus_dev/core/providers/api_client_providers.dart';
import 'package:vplus_dev/feature/auth/data/datasources/remote_auth_data_source_impl.dart';
import 'package:vplus_dev/feature/auth/data/repositories/auth_repository_impl.dart';
import 'package:vplus_dev/feature/auth/domain/usecases/login_usecase.dart';
import 'package:vplus_dev/feature/auth/domain/usecases/refresh_token_usecase.dart';

import 'package:vplus_dev/core/providers/service_providers.dart';

import '../../domain/enum/auth_status.dart';
import 'state/auth_state.dart';

part 'auth_providers.g.dart';

// Auth Data Source 提供者
@riverpod
RemoteAuthDataSourceImpl authDataSource(Ref ref) {
  final apiClient = ref.watch(csharpApiClientProvider);
  return RemoteAuthDataSourceImpl(apiClient);
}

// Auth Repository 提供者
@riverpod
AuthRepositoryImpl authRepository(Ref ref) {
  final dataSource = ref.watch(authDataSourceProvider);
  return AuthRepositoryImpl(dataSource);
}

// Login UseCase 提供者
@riverpod
LoginUsecase loginUsecase(Ref ref) {
  final repository = ref.watch(authRepositoryProvider);
  final tokenService = ref.watch(tokenServiceProvider);
  final userService = ref.watch(userServiceProvider);
  return LoginUsecase(repository, tokenService, userService);
}

// Refresh Token UseCase 提供者
@riverpod
RefreshTokenUsecase refreshTokenUsecase(Ref ref) {
  final repository = ref.watch(authRepositoryProvider);
  return RefreshTokenUsecase(repository);
}

/// 認證狀態 Notifier
@riverpod
class AuthNotifier extends _$AuthNotifier {
  @override
  AuthState build() {
    // 初始化時檢查是否已有 token
    _checkInitialAuthState();
    return AuthState(status: AuthStatus.initial);
  }

  /// 檢查初始認證狀態
  Future<void> _checkInitialAuthState() async {
    final tokenService = ref.read(tokenServiceProvider);
    final userService = ref.read(userServiceProvider);
    
    await tokenService.loadTokens();
    
    if (tokenService.hasToken()) {
      // 載入用戶資料
      final user = await userService.getCurrentUser();
      if (user != null) {
        state = state.copyWith(status: AuthStatus.authenticated, user: user);
      } else {
        // Token 存在但無法載入用戶資料，可能 token 已過期
        await tokenService.clearTokens();
        state = state.copyWith(status: AuthStatus.unauthenticated, user: null);
      }
    } else {
      state = state.copyWith(status: AuthStatus.unauthenticated, user: null);
    }
  }

  /// 登入
  Future<void> login(String mobile, String password) async {
    try {
      state = state.copyWith(status: AuthStatus.loading, errorMessage: null);
      
      final loginUsecase = ref.read(loginUsecaseProvider);
      
      // 執行登入 (LoginUsecase 已經處理 token 和用戶資料的儲存)
      final user = await loginUsecase.execute(mobile, password);
      
      // 更新狀態
      state = state.copyWith(status: AuthStatus.authenticated, user: user, errorMessage: null);
      
    } catch (e) {
      state = state.copyWith(status: AuthStatus.error, errorMessage: e.toString());
    }
  }

  /// 登出
  Future<void> logout() async {
    try {
      final tokenService = ref.read(tokenServiceProvider);
      final userService = ref.read(userServiceProvider);
      
      // 清除 token 和用戶資料
      await tokenService.clearTokens();
      await userService.clearCurrentUser();
      
      // 更新狀態
      state = state.copyWith(status: AuthStatus.unauthenticated, user: null, errorMessage: null);
      
    } catch (e) {
      // 即使清除失敗，也應該設為未認證狀態
      state = state.copyWith(status: AuthStatus.unauthenticated, user: null, errorMessage: null);
    }
  }

  /// 刷新 Token
  Future<bool> refreshToken() async {
    try {
      final refreshTokenUsecase = ref.read(refreshTokenUsecaseProvider);
      final tokenService = ref.read(tokenServiceProvider);
      
      final result = await refreshTokenUsecase.execute();
      
      if (result != null) {
        // 更新 access token
        await tokenService.updateAccessToken(result.accessToken);
        return true;
      }
      
      // Token 刷新失敗，登出用戶
      await logout();
      return false;
      
    } catch (e) {
      // Token 刷新失敗，登出用戶
      await logout();
      return false;
    }
  }

  /// 檢查認證狀態
  bool get isAuthenticated => state.status == AuthStatus.authenticated;

  /// 檢查是否正在載入
  bool get isLoading => state.status == AuthStatus.loading;

  /// 獲取當前用戶名稱
  String? get currentUserName => state.user?.fullname;
}

/// 認證狀態監聽器提供者
@riverpod
AuthState authState(Ref ref) {
  return ref.watch(authNotifierProvider);
}

/// 是否已認證提供者
@riverpod
bool isAuthenticated(Ref ref) {
  return ref.watch(authNotifierProvider.notifier).isAuthenticated;
}

/// 是否正在載入提供者
@riverpod
bool isAuthLoading(Ref ref) {
  return ref.watch(authNotifierProvider.notifier).isLoading;
}
