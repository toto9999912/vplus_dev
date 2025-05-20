// lib/shared/services/dialog/dialog_service.dart
import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:async';

/// 對話框服務，提供各種對話框顯示功能
class DialogService {
  BuildContext? _context;

  /// 設置當前上下文
  void setContext(BuildContext context) {
    _context = context;
  }

  /// 獲取當前上下文，如果未設置則拋出異常
  BuildContext get context {
    if (_context == null) {
      throw Exception('DialogService: 必須首先設置上下文');
    }
    return _context!;
  }

  /// 顯示成功對話框
  Future<void> showSuccessDialog({
    required String title,
    required String desc,
    String? btnOkText,
    String? btnCancelText,
    Function()? onOkPress,
    Function()? onCancelPress,
    bool dismissOnTouchOutside = true,
    bool showCloseIcon = false,
    Duration? autoHide,
  }) async {
    return _showDialog(
      dialogType: DialogType.success,
      title: title,
      desc: desc,
      btnOkText: btnOkText,
      btnCancelText: btnCancelText,
      onOkPress: onOkPress,
      onCancelPress: onCancelPress,
      dismissOnTouchOutside: dismissOnTouchOutside,
      showCloseIcon: showCloseIcon,
      autoHide: autoHide,
    );
  }

  /// 顯示錯誤對話框
  Future<void> showErrorDialog({
    required String title,
    required String desc,
    String? btnOkText,
    Function()? onOkPress,
    bool dismissOnTouchOutside = true,
    bool showCloseIcon = false,
    Duration? autoHide,
  }) async {
    return _showDialog(
      dialogType: DialogType.error,
      title: title,
      desc: desc,
      btnOkText: btnOkText,
      onOkPress: onOkPress,
      dismissOnTouchOutside: dismissOnTouchOutside,
      showCloseIcon: showCloseIcon,
      autoHide: autoHide,
    );
  }

  /// 顯示警告對話框
  Future<void> showWarningDialog({
    required String title,
    required String desc,
    String? btnOkText,
    String? btnCancelText,
    Function()? onOkPress,
    Function()? onCancelPress,
    bool dismissOnTouchOutside = true,
    bool showCloseIcon = false,
    Duration? autoHide,
  }) async {
    return _showDialog(
      dialogType: DialogType.warning,
      title: title,
      desc: desc,
      btnOkText: btnOkText,
      btnCancelText: btnCancelText,
      onOkPress: onOkPress,
      onCancelPress: onCancelPress,
      dismissOnTouchOutside: dismissOnTouchOutside,
      showCloseIcon: showCloseIcon,
      autoHide: autoHide,
    );
  }

  /// 顯示確認刪除對話框
  Future<void> showDeleteConfirmDialog({
    String title = '確認刪除',
    String desc = '您確定要刪除此項目嗎？此操作無法撤銷。',
    String btnOkText = '刪除',
    String btnCancelText = '取消',
    required Function() onConfirmDelete,
    Function()? onCancelPress,
    bool dismissOnTouchOutside = true,
  }) async {
    return _showDialog(
      dialogType: DialogType.warning,
      title: title,
      desc: desc,
      btnOkText: btnOkText,
      btnCancelText: btnCancelText,
      btnOkColor: Colors.red,
      onOkPress: onConfirmDelete,
      onCancelPress: onCancelPress,
      dismissOnTouchOutside: dismissOnTouchOutside,
      showCloseIcon: false,
    );
  }

  /// 顯示自定義內容對話框
  Future<void> showCustomDialog({
    DialogType dialogType = DialogType.info,
    String? title,
    required Widget body,
    String? btnOkText,
    String? btnCancelText,
    Function()? onOkPress,
    Function()? onCancelPress,
    Color? btnOkColor,
    Color? btnCancelColor,
    bool dismissOnTouchOutside = true,
    bool showCloseIcon = false,
    Duration? autoHide,
  }) async {
    final dialog = AwesomeDialog(
      context: context,
      dialogType: dialogType,
      animType: AnimType.scale,
      title: title,
      body: body,
      btnOkText: btnOkText,
      btnCancelText: btnCancelText,
      btnOkColor: btnOkColor,
      btnCancelColor: btnCancelColor,
      btnOkOnPress: onOkPress,
      btnCancelOnPress: onCancelPress,
      dismissOnTouchOutside: dismissOnTouchOutside,
      dismissOnBackKeyPress: dismissOnTouchOutside,
      showCloseIcon: showCloseIcon,
      autoHide: autoHide,
    );

    return dialog.show();
  }

  /// 顯示輸入對話框
  Future<String?> showInputDialog({
    required String title,
    String? desc,
    String? hintText,
    String? initialValue,
    String btnOkText = '確定',
    String btnCancelText = '取消',
    bool obscureText = false,
    int? maxLength,
    TextInputType keyboardType = TextInputType.text,
    List<TextInputFormatter>? inputFormatters,
    bool Function(String)? validator,
  }) async {
    final textController = TextEditingController(text: initialValue);
    String? errorText;
    bool isValid = true;

    final completer = Completer<String?>();

    showCustomDialog(
      dialogType: DialogType.question,
      title: title,
      body: StatefulBuilder(
        builder: (context, setState) {
          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (desc != null)
                  Padding(padding: const EdgeInsets.only(bottom: 16.0), child: Text(desc, style: Theme.of(context).textTheme.bodyLarge)),
                TextField(
                  controller: textController,
                  decoration: InputDecoration(
                    hintText: hintText,
                    errorText: errorText,
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(8.0)),
                  ),
                  obscureText: obscureText,
                  maxLength: maxLength,
                  keyboardType: keyboardType,
                  inputFormatters: inputFormatters,
                  onChanged: (value) {
                    if (validator != null) {
                      setState(() {
                        isValid = validator(value);
                        errorText = isValid ? null : '請輸入有效內容';
                      });
                    }
                  },
                ),
              ],
            ),
          );
        },
      ),
      btnOkText: btnOkText,
      btnCancelText: btnCancelText,
      onOkPress: () {
        final text = textController.text;
        if (validator != null && !validator(text)) {
          return;
        }
        completer.complete(text);
      },
      onCancelPress: () {
        completer.complete(null);
      },
    );

    return completer.future;
  }

  /// 顯示加載對話框
  AwesomeDialog showLoadingDialog({String title = '請稍候', String desc = '正在處理...', bool dismissOnTouchOutside = false}) {
    final dialog = AwesomeDialog(
      context: context,
      dialogType: DialogType.noHeader,
      animType: AnimType.scale,
      title: title,
      desc: desc,
      dismissOnTouchOutside: dismissOnTouchOutside,
      dismissOnBackKeyPress: dismissOnTouchOutside,
      body: const Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(mainAxisSize: MainAxisSize.min, children: [CircularProgressIndicator(), SizedBox(height: 16), Text('處理中，請稍候...')]),
      ),
    );

    dialog.show();
    return dialog;
  }

  /// 內部方法，用於顯示通用對話框
  Future<void> _showDialog({
    required DialogType dialogType,
    required String title,
    required String desc,
    String? btnOkText,
    String? btnCancelText,
    Function()? onOkPress,
    Function()? onCancelPress,
    Color? btnOkColor,
    Color? btnCancelColor,
    bool dismissOnTouchOutside = true,
    bool showCloseIcon = false,
    Duration? autoHide,
  }) async {
    final dialog = AwesomeDialog(
      context: context,
      dialogType: dialogType,
      animType: AnimType.scale,
      title: title,
      desc: desc,
      btnOkText: btnOkText,
      btnCancelText: btnCancelText,
      btnOkColor: btnOkColor,
      btnCancelColor: btnCancelColor,
      btnOkOnPress: onOkPress,
      btnCancelOnPress: onCancelPress,
      dismissOnTouchOutside: dismissOnTouchOutside,
      dismissOnBackKeyPress: dismissOnTouchOutside,
      showCloseIcon: showCloseIcon,
      autoHide: autoHide,
    );

    return dialog.show();
  }
}
