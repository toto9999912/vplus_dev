import 'package:flutter/material.dart';

enum ButtonVariants {
  /// 主要按鈕
  primary,

  /// 次要按鈕
  secondary,

  /// 成功按鈕
  success,

  /// 危險按鈕
  danger,

  /// 警告按鈕
  warning,

  /// 信息按鈕
  info,

  /// 淺色按鈕
  light,

  /// 深色按鈕
  dark,
}

enum ButtonSize {
  /// 小型按鈕
  small,

  /// 正常大小按鈕
  medium,

  /// 大型按鈕
  large,
}

class AppButton extends StatelessWidget {
  /// 按鈕點擊事件
  final void Function()? onPressed;

  /// 按鈕類型
  final ButtonVariants variant;

  /// 按鈕大小
  final ButtonSize size;

  /// 是否為 outline 樣式
  final bool outline;

  /// 是否為全寬按鈕
  final bool block;

  /// 按鈕內容
  final Widget child;

  /// 按鈕是否禁用
  final bool disabled;

  /// 外框線弧度
  final double? borderRadius;

  /// 自訂按鈕高度
  final double? height;

  /// 自訂按鈕寬度
  final double? width;

  /// 自訂按鈕邊距
  final EdgeInsetsGeometry? padding;

  const AppButton({
    super.key,
    required this.child,
    this.onPressed,
    this.variant = ButtonVariants.primary,
    this.size = ButtonSize.medium,
    this.outline = false,
    this.block = false,
    this.disabled = false,
    this.borderRadius,
    this.height,
    this.width,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    // 獲取按鈕顏色
    final Map<ButtonVariants, Color> variantColors = {
      ButtonVariants.primary: theme.primaryColor,
      ButtonVariants.secondary: theme.colorScheme.secondary,
      ButtonVariants.success: Colors.green,
      ButtonVariants.danger: Colors.red,
      ButtonVariants.warning: Colors.orange,
      ButtonVariants.info: Colors.blue,
      ButtonVariants.light: Colors.grey[300]!,
      ButtonVariants.dark: Colors.grey[800]!,
    };

    // 獲取文字顏色
    final Map<ButtonVariants, Color> textColors = {
      ButtonVariants.primary: Colors.white,
      ButtonVariants.secondary: Colors.white,
      ButtonVariants.success: Colors.white,
      ButtonVariants.danger: Colors.white,
      ButtonVariants.warning: Colors.black,
      ButtonVariants.info: Colors.white,
      ButtonVariants.light: Colors.black,
      ButtonVariants.dark: Colors.white,
    };

    // 根據尺寸設定高度和內邊距
    final Map<ButtonSize, double> sizeHeights = {ButtonSize.small: 32.0, ButtonSize.medium: 40.0, ButtonSize.large: 48.0};

    final Map<ButtonSize, EdgeInsetsGeometry> sizePaddings = {
      ButtonSize.small: const EdgeInsets.symmetric(horizontal: 12.0),
      ButtonSize.medium: const EdgeInsets.symmetric(horizontal: 16.0),
      ButtonSize.large: const EdgeInsets.symmetric(horizontal: 24.0),
    };

    final Color backgroundColor = outline ? Colors.transparent : variantColors[variant]!;
    final Color foregroundColor = outline ? variantColors[variant]! : textColors[variant]!;
    final Color borderCol = variantColors[variant]!;
    final double radius = borderRadius ?? 8.0;
    final double btnHeight = height ?? sizeHeights[size]!;
    final EdgeInsetsGeometry btnPadding = padding ?? sizePaddings[size]!;

    return SizedBox(
      width: block ? double.infinity : width,
      height: btnHeight,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          foregroundColor: foregroundColor,
          backgroundColor: backgroundColor,
          disabledBackgroundColor: backgroundColor.withValues(alpha: 0.6),
          disabledForegroundColor: foregroundColor.withValues(alpha: 0.6),
          padding: btnPadding,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(radius), side: BorderSide(color: borderCol, width: outline ? 1 : 0)),
          elevation: outline ? 0 : 2,
          shadowColor: outline ? Colors.transparent : null,
        ),
        onPressed: disabled ? null : onPressed,
        child: child,
      ),
    );
  }

  /// 全寬按鈕
  factory AppButton.block({
    Key? key,
    required Widget child,
    ButtonVariants variant = ButtonVariants.primary,
    ButtonSize size = ButtonSize.medium,
    bool outline = false,
    bool disabled = false,
    void Function()? onPressed,
    double? borderRadius,
  }) {
    return AppButton(
      key: key,
      variant: variant,
      size: size,
      outline: outline,
      block: true,
      disabled: disabled,
      onPressed: onPressed,
      borderRadius: borderRadius,
      child: child,
    );
  }

  /// Outline 輪廓按鈕
  factory AppButton.outline({
    Key? key,
    required Widget child,
    ButtonVariants variant = ButtonVariants.primary,
    ButtonSize size = ButtonSize.medium,
    bool block = false,
    bool disabled = false,
    void Function()? onPressed,
    double? borderRadius,
  }) {
    return AppButton(
      key: key,
      variant: variant,
      size: size,
      outline: true,
      block: block,
      disabled: disabled,
      onPressed: onPressed,
      borderRadius: borderRadius,
      child: child,
    );
  }
}
