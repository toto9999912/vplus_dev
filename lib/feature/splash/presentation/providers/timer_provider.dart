import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// 為倒數計時器創建一個狀態提供者
final splashTimerProvider = StateNotifierProvider<SplashTimerNotifier, int>((ref) {
  return SplashTimerNotifier();
});

/// 倒數計時器的狀態管理器
class SplashTimerNotifier extends StateNotifier<int> {
  Timer? _timer;
  static const int defaultDuration = 10;

  SplashTimerNotifier() : super(defaultDuration) {
    // 初始化狀態為預設倒數時間
  }

  /// 開始倒數計時
  void startCountdown() {
    _cancelTimer(); // 確保沒有其他計時器在運行

    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (state > 0) {
        state = state - 1;
      } else {
        _cancelTimer();
      }
    });
  }

  /// 手動跳過倒數計時
  void skipCountdown() {
    _cancelTimer();
    state = 0;
  }

  /// 取消計時器
  void _cancelTimer() {
    _timer?.cancel();
    _timer = null;
  }

  /// 判斷計時是否已結束
  bool get isFinished => state <= 0;

  @override
  void dispose() {
    _cancelTimer();
    super.dispose();
  }
}
