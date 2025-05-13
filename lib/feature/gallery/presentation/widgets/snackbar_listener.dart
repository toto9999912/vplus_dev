import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/snackbar_message_provider.dart';

/// 監聽全局錯誤訊息並顯示 Snackbar 的部件
/// 通常放置在頁面的根 Scaffold 中
class SnackbarListener extends ConsumerWidget {
  final Widget child;

  const SnackbarListener({
    required this.child,
    super.key,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.listen<SnackbarMessage?>(
      snackbarMessageNotifierProvider,
      (previous, current) {
        if (current != null) {
          // 當提供者中的訊息更新時，顯示 Snackbar
          _showSnackbar(context, current);

          // 訊息顯示後清除，防止重複顯示
          Future.delayed(
            const Duration(seconds: 3),
            () => ref.read(snackbarMessageNotifierProvider.notifier).clearMessage(),
          );
        }
      },
    );

    return child;
  }

  void _showSnackbar(BuildContext context, SnackbarMessage message) {
    // 根據訊息類型設置顏色
    Color backgroundColor;
    Color textColor = Colors.white;

    switch (message.type) {
      case MessageType.error:
        backgroundColor = Colors.red;
        break;
      case MessageType.warning:
        backgroundColor = Colors.orange;
        break;
      case MessageType.success:
        backgroundColor = Colors.green;
        break;
      case MessageType.info:
        backgroundColor = Colors.blue;
        break;
    }

    // 顯示 Snackbar
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message.text,
          style: TextStyle(color: textColor),
        ),
        backgroundColor: backgroundColor,
        duration: const Duration(seconds: 3),
        behavior: SnackBarBehavior.floating,
        action: SnackBarAction(
          label: '關閉',
          textColor: textColor,
          onPressed: () {
            ScaffoldMessenger.of(context).hideCurrentSnackBar();
          },
        ),
      ),
    );
  }
}
