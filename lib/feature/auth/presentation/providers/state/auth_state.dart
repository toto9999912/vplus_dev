import '../../../domain/entities/user_profile.dart';
import '../../../domain/enum/auth_status.dart';

// Auth State 類別
class AuthState {
  final AuthStatus status;
  final UserProfile? user;
  final String? errorMessage;

  AuthState({this.status = AuthStatus.initial, this.user, this.errorMessage});

  // 複製方法
  AuthState copyWith({AuthStatus? status, UserProfile? user, String? errorMessage}) {
    return AuthState(status: status ?? this.status, user: user ?? this.user, errorMessage: errorMessage ?? this.errorMessage);
  }
}
