import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:vplus_dev/core/providers/api_client_providers.dart';
import 'package:vplus_dev/feature/auth/data/datasources/remote_auth_data_source_impl.dart';
import 'package:vplus_dev/feature/auth/data/repositories/auth_repository_impl.dart';
import 'package:vplus_dev/feature/auth/domain/usecases/login_usecase.dart';

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
  final tokenService = ref.watch(tokenServiceProvider);
  final userService = ref.watch(userServiceProvider);
  return AuthRepositoryImpl(dataSource, tokenService, userService);
}

// Login UseCase 提供者
@riverpod
LoginUseCase loginUseCase(Ref ref) {
  final repository = ref.watch(authRepositoryProvider);
  return LoginUseCase(repository);
}

// Auth State 定義

// Auth Notifier
@riverpod
class AuthNotifier extends _$AuthNotifier {
  @override
  AuthState build() {
    return AuthState();
  }

  // 登入方法
  Future<void> login(String username, String password) async {
    try {
      state = state.copyWith(status: AuthStatus.loading);

      final loginUseCase = ref.read(loginUseCaseProvider);
      final user = await loginUseCase.execute(username, password);

      state = state.copyWith(status: AuthStatus.authenticated, user: user, errorMessage: null);
    } catch (e) {
      state = state.copyWith(status: AuthStatus.error, errorMessage: e.toString());
    }
  }

  // 登出方法
  void logout() {
    state = state.copyWith(status: AuthStatus.unauthenticated, user: null);
  }
}
