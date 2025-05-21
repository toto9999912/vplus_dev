// lib/shared/services/dialog/dialog_service.dart
import 'dart:math' as math;

import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:async';

import 'package:lottie/lottie.dart';
import 'package:vplus_dev/core/constants/app_color.dart';
import 'package:vplus_dev/shared/models/bottom_sheet_option.dart';

enum AppDialogType { success, error, info, warning }

/// 對話框服務，提供各種對話框顯示功能
class DialogService {
  DialogService(this._navigatorKey);
  final GlobalKey<NavigatorState> _navigatorKey;

  BuildContext get _ctx {
    final ctx = _navigatorKey.currentContext;
    if (ctx == null) {
      throw StateError('Navigator 尚未掛載，不能顯示對話框');
    }
    return ctx;
  }

  //=== 封裝主入口 =========================================================
  Future<void> show({required AppDialogType type, required String title, required String message, VoidCallback? onOk, VoidCallback? onCancel}) async {
    return AwesomeDialog(
      context: _ctx,
      dialogType: _mapType(type),
      headerAnimationLoop: false,
      animType: AnimType.scale,
      title: title,
      desc: message,
      btnOkOnPress: onOk,
      btnCancelOnPress: onCancel,
      customHeader: _buildCustomHeader(type),
      btnOkColor: Theme.of(_ctx).colorScheme.primary,
    ).show();
  }

  // sugar API =============================================================
  Future<void> success(String title, String msg, {VoidCallback? onOk}) => show(type: AppDialogType.success, title: title, message: msg, onOk: onOk);

  Future<void> error(String title, String msg, {VoidCallback? onOk}) => show(type: AppDialogType.error, title: title, message: msg, onOk: onOk);

  Future<void> info(String title, String msg, {VoidCallback? onOk}) => show(type: AppDialogType.info, title: title, message: msg, onOk: onOk);

  Future<void> warning(String title, String msg, {VoidCallback? onOk, VoidCallback? onCancel}) =>
      show(type: AppDialogType.warning, title: title, message: msg, onOk: onOk, onCancel: onCancel);

  //=== 私有方法 ===========================================================
  DialogType _mapType(AppDialogType t) => switch (t) {
    AppDialogType.success => DialogType.noHeader, // header 交給 Lottie
    AppDialogType.error => DialogType.error,
    AppDialogType.info => DialogType.info,
    AppDialogType.warning => DialogType.warning,
  };

  /// 只有 success 需要 Lottie；其他回傳 null 代表沿用 AwesomeDialog 內建 header。
  Widget? _buildCustomHeader(AppDialogType type) {
    if (type != AppDialogType.success) return null;

    return Padding(
      padding: const EdgeInsets.only(top: 12.0),
      child: Lottie.asset('assets/animations/success.json', width: 90, height: 90, fit: BoxFit.contain),
    );
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
      btnOkColor: AppColors.danger,
      btnCancelColor: AppColors.grey02,
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
      context: _ctx,
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
      context: _ctx,
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
      context: _ctx,
      dialogType: dialogType,
      animType: AnimType.bottomSlide,
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

  /// 顯示底部選項網格視窗
  Future<T?> showGridBottomSheet<T>({
    required String title,
    required List<BottomSheetOption<T>> options,
    double minCellWidth = 100, // 每個網格的最小寬度
    double? maxHeight, // 最大高度，如果為null則自動計算
    bool isDismissible = true,
    bool enableDrag = true,
    Color? backgroundColor,
    BorderRadius? borderRadius,
  }) async {
    final result = await showModalBottomSheet<T>(
      context: _ctx,
      isScrollControlled: true,
      isDismissible: isDismissible,
      enableDrag: enableDrag,
      backgroundColor: backgroundColor ?? Colors.white,
      shape: RoundedRectangleBorder(borderRadius: borderRadius ?? const BorderRadius.vertical(top: Radius.circular(16))),
      builder: (context) {
        final screenWidth = MediaQuery.of(context).size.width;
        final crossAxisCount = (screenWidth / (minCellWidth)).floor();

        // 動態計算高度
        double calculatedHeight;
        final rowCount = (options.length / crossAxisCount).ceil();
        final rowHeight = minCellWidth; // 每行高度
        final headerHeight = 60.0; // 標題區域高度
        calculatedHeight = headerHeight + (rowCount * rowHeight); // 20 是額外間距

        // 限制最大高度為屏幕高度的 70%
        final screenHeight = MediaQuery.of(context).size.height;
        final finalHeight = maxHeight != null ? math.min(maxHeight, calculatedHeight) : math.min(screenHeight * 0.7, calculatedHeight);

        return Container(
          height: finalHeight,
          decoration: BoxDecoration(
            color: backgroundColor ?? Colors.white,
            borderRadius: borderRadius ?? const BorderRadius.vertical(top: Radius.circular(16)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // 標題區域
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Text(title, style: Theme.of(context).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold)),
              ),

              const Divider(height: 1),

              // 網格選項區域
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8.0),
                  child: GridView.builder(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: crossAxisCount,
                      childAspectRatio: 1.4,
                      crossAxisSpacing: 4,
                      mainAxisSpacing: 16,
                    ),
                    itemCount: options.length,
                    itemBuilder: (context, index) {
                      final option = options[index];
                      return InkWell(
                        onTap: () => Navigator.of(context).pop(option.value),
                        borderRadius: BorderRadius.circular(8),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(option.icon, size: 32, color: option.iconColor ?? Theme.of(context).colorScheme.primary),
                            const SizedBox(height: 8),
                            Text(
                              option.title,
                              textAlign: TextAlign.center,
                              style: TextStyle(fontSize: 14, color: option.textColor ?? Colors.black87, fontWeight: FontWeight.w500),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );

    return result;
  }
}
