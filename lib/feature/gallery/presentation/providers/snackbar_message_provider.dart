import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'snackbar_message_provider.g.dart';

/// 消息類型
enum MessageType {
  info,
  success,
  error,
  warning,
}

/// 消息數據
class SnackbarMessage {
  final String text;
  final MessageType type;
  final DateTime timestamp;

  SnackbarMessage({
    required this.text,
    required this.type,
    DateTime? timestamp,
  }) : timestamp = timestamp ?? DateTime.now();
}

/// 管理應用內通知消息的提供者
@riverpod
class SnackbarMessageNotifier extends _$SnackbarMessageNotifier {
  @override
  SnackbarMessage? build() {
    return null; // 初始沒有消息
  }

  /// 顯示一般信息
  void showInfo(String message) {
    state = SnackbarMessage(text: message, type: MessageType.info);
  }

  /// 顯示成功消息
  void showSuccess(String message) {
    state = SnackbarMessage(text: message, type: MessageType.success);
  }

  /// 顯示錯誤消息
  void showError(String message) {
    state = SnackbarMessage(text: message, type: MessageType.error);
  }

  /// 顯示警告消息
  void showWarning(String message) {
    state = SnackbarMessage(text: message, type: MessageType.warning);
  }

  /// 清除當前消息
  void clearMessage() {
    state = null;
  }
}
