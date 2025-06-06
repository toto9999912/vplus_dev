import 'package:flutter/material.dart';

/// BuildContext 擴展方法
extension BuildContextExtensions on BuildContext? {
  /// 安全地執行需要 BuildContext 的操作
  T? let<T>(T Function(BuildContext context) operation) {
    final context = this;
    if (context != null) {
      return operation(context);
    }
    return null;
  }
}