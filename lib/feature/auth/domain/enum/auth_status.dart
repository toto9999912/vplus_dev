/// 身份驗證狀態枚舉
enum AuthStatus {
  /// 初始狀態
  initial,

  /// 載入中狀態
  loading,

  /// 已驗證狀態 (已登入)
  authenticated,

  /// 未驗證狀態 (未登入)
  unauthenticated,

  /// 錯誤狀態
  error,
}
