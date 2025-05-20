import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import '../button/app_button.dart';

/// 泛型對話框組件
class AppFormDialog<T> extends StatefulWidget {
  /// 對話框標題
  final String title;

  /// 主體構建器，用於創建對話框的主體內容並可接收初始數據
  final Widget Function(BuildContext context, T? initialData, void Function(T? data) onDataChanged) bodyBuilder;

  /// 自定義動作按鈕
  final Widget? customAction;

  /// 初始數據
  final T? initialData;

  /// 表單驗證器
  final String? Function(T? data)? validator;

  /// 確認按鈕文字，預設為「儲存」
  final String saveButtonText;

  /// 取消按鈕文字，預設為「取消」
  final String cancelButtonText;

  const AppFormDialog({
    super.key,
    required this.title,
    required this.bodyBuilder,
    this.customAction,
    this.initialData,
    this.validator,
    this.saveButtonText = '儲存',
    this.cancelButtonText = '取消',
  });

  @override
  State<AppFormDialog<T>> createState() => _AppFormDialogState<T>();

  /// 顯示對話框的靜態便捷方法
  static Future<T?> show<T>({
    required BuildContext context,
    required String title,
    required Widget Function(BuildContext context, T? initialData, void Function(T? data) onDataChanged) bodyBuilder,
    Widget? customAction,
    T? initialData,
    String? Function(T? data)? validator,
    String saveButtonText = '儲存',
    String cancelButtonText = '取消',
  }) {
    return showDialog<T>(
      context: context,
      builder:
          (context) => AppFormDialog<T>(
            title: title,
            bodyBuilder: bodyBuilder,
            customAction: customAction,
            initialData: initialData,
            validator: validator,
            saveButtonText: saveButtonText,
            cancelButtonText: cancelButtonText,
          ),
    );
  }
}

class _AppFormDialogState<T> extends State<AppFormDialog<T>> {
  final _formKey = GlobalKey<FormState>();
  T? _currentData;

  @override
  void initState() {
    super.initState();
    _currentData = widget.initialData;
  }

  void _onDataChanged(T? data) {
    setState(() {
      _currentData = data;
    });
  }

  void _validate() {
    // 檢查表單字段的基本驗證 (TextFormField 等內建驗證)
    if (_formKey.currentState?.validate() ?? false) {
      // 如果有自定義驗證器，執行數據驗證
      if (widget.validator != null) {
        final errorMessage = widget.validator!(_currentData);
        if (errorMessage != null) {
          // 顯示錯誤訊息
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text(errorMessage), backgroundColor: Colors.red, duration: const Duration(seconds: 2)));
          return;
        }
      }

      // 所有驗證通過，返回當前數據
      context.pop(_currentData);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      insetPadding: EdgeInsets.zero,
      titlePadding: EdgeInsets.zero,
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(8.0))),
      title: Stack(
        children: [
          Align(
            alignment: Alignment.center,
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 12),
              child: Text(widget.title, style: const TextStyle(fontSize: 17, fontWeight: FontWeight.bold)),
            ),
          ),
          if (widget.customAction != null) Align(alignment: Alignment.centerRight, child: widget.customAction!),
        ],
      ),
      content: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // 使用bodyBuilder創建主體部分，並傳入初始數據與數據更新回調
            widget.bodyBuilder(context, widget.initialData, _onDataChanged),

            const SizedBox(height: 24),

            // 按鈕行
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                AppButton.outline(child: Text(widget.cancelButtonText), onPressed: () => context.pop()),
                AppButton(onPressed: _validate, child: Text(widget.saveButtonText)),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
