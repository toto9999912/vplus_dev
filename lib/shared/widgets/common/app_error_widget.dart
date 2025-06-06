import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:vplus_dev/core/constants/app_color.dart';
import '../button/app_button.dart';

/// 美化的錯誤顯示組件
/// 用於統一顯示錯誤狀態，提供友善的視覺效果和用戶體驗
class AppErrorWidget extends StatelessWidget {
  /// 錯誤標題
  final String? title;

  /// 錯誤描述
  final String? message;

  /// 錯誤圖標
  final IconData? icon;

  /// 重試按鈕文字
  final String? retryButtonText;

  /// 重試回調函數
  final VoidCallback? onRetry;

  /// 是否顯示詳細資訊按鈕
  final bool showDetails;

  /// 詳細錯誤資訊
  final String? details;

  /// 自定義圖標顏色
  final Color? iconColor;

  /// 自定義背景顏色
  final Color? backgroundColor;

  /// 是否為精簡模式（較小的尺寸）
  final bool compact;

  const AppErrorWidget({
    super.key,
    this.title,
    this.message,
    this.icon,
    this.retryButtonText,
    this.onRetry,
    this.showDetails = false,
    this.details,
    this.iconColor,
    this.backgroundColor,
    this.compact = false,
  });

  /// 網絡錯誤的預設構造函數
  factory AppErrorWidget.network({String? title, String? message, VoidCallback? onRetry, String? retryButtonText, bool compact = false}) {
    return AppErrorWidget(
      title: title ?? '網絡連接失敗',
      message: message ?? '請檢查您的網絡連接並重試',
      icon: FontAwesomeIcons.wifi,
      iconColor: AppColors.warning,
      onRetry: onRetry,
      retryButtonText: retryButtonText ?? '重試',
      compact: compact,
    );
  }

  /// 伺服器錯誤的預設構造函數
  factory AppErrorWidget.server({String? title, String? message, VoidCallback? onRetry, String? retryButtonText, bool compact = false}) {
    return AppErrorWidget(
      title: title ?? '伺服器錯誤',
      message: message ?? '伺服器出現問題，請稍後再試',
      icon: FontAwesomeIcons.server,
      iconColor: AppColors.danger,
      onRetry: onRetry,
      retryButtonText: retryButtonText ?? '重試',
      compact: compact,
    );
  }

  /// 沒有資料的預設構造函數
  factory AppErrorWidget.noData({String? title, String? message, VoidCallback? onRetry, String? retryButtonText, bool compact = false}) {
    return AppErrorWidget(
      title: title ?? '沒有資料',
      message: message ?? '目前沒有可顯示的內容',
      icon: FontAwesomeIcons.folderOpen,
      iconColor: AppColors.grey03,
      onRetry: onRetry,
      retryButtonText: retryButtonText ?? '重新載入',
      compact: compact,
    );
  }

  /// 未知錯誤的預設構造函數
  factory AppErrorWidget.unknown({
    String? title,
    String? message,
    VoidCallback? onRetry,
    String? retryButtonText,
    String? details,
    bool compact = false,
  }) {
    return AppErrorWidget(
      title: title ?? '出現問題',
      message: message ?? '發生未知錯誤，請聯繫技術支援',
      icon: FontAwesomeIcons.triangleExclamation,
      iconColor: AppColors.warning,
      onRetry: onRetry,
      retryButtonText: retryButtonText ?? '重試',
      showDetails: details != null,
      details: details,
      compact: compact,
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final size = compact ? 0.7 : 1.0;

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(compact ? 16.0 : 24.0),
      decoration: BoxDecoration(
        color: backgroundColor ?? theme.scaffoldBackgroundColor,
        borderRadius: BorderRadius.circular(12.0),
        border: Border.all(color: AppColors.grey07.withOpacity(0.3), width: 1.0),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // 錯誤圖標
          _buildErrorIcon(size),

          SizedBox(height: compact ? 12.0 : 16.0),

          // 錯誤標題
          if (title != null) _buildTitle(theme, size),

          if (title != null) SizedBox(height: compact ? 6.0 : 8.0),

          // 錯誤描述
          if (message != null) _buildMessage(theme, size),

          SizedBox(height: compact ? 16.0 : 24.0),

          // 操作按鈕區域
          _buildActionButtons(size),
        ],
      ),
    );
  }

  Widget _buildErrorIcon(double scale) {
    return Container(
      width: (80.0 * scale),
      height: (80.0 * scale),
      decoration: BoxDecoration(color: (iconColor ?? AppColors.danger).withOpacity(0.1), shape: BoxShape.circle),
      child: Icon(icon ?? FontAwesomeIcons.triangleExclamation, size: (40.0 * scale), color: iconColor ?? AppColors.danger),
    );
  }

  Widget _buildTitle(ThemeData theme, double scale) {
    return Text(
      title!,
      style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold, fontSize: (18.0 * scale), color: AppColors.grey01),
      textAlign: TextAlign.center,
      maxLines: 2,
      overflow: TextOverflow.ellipsis,
    );
  }

  Widget _buildMessage(ThemeData theme, double scale) {
    return Text(
      message!,
      style: theme.textTheme.bodyMedium?.copyWith(fontSize: (14.0 * scale), color: AppColors.grey02, height: 1.4),
      textAlign: TextAlign.center,
      maxLines: 3,
      overflow: TextOverflow.ellipsis,
    );
  }

  Widget _buildActionButtons(double scale) {
    final List<Widget> buttons = [];

    // 重試按鈕
    if (onRetry != null) {
      buttons.add(
        AppButton(
          variant: ButtonVariants.primary,
          size: compact ? ButtonSize.small : ButtonSize.medium,
          onPressed: onRetry,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [Icon(FontAwesomeIcons.arrowRotateRight, size: (14.0 * scale)), SizedBox(width: (6.0 * scale)), Text(retryButtonText ?? '重試')],
          ),
        ),
      );
    }

    // 詳細資訊按鈕
    if (showDetails && details != null) {
      buttons.add(
        AppButton.outline(
          variant: ButtonVariants.secondary,
          size: compact ? ButtonSize.small : ButtonSize.medium,
          onPressed: () => _showDetailsDialog(),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [Icon(FontAwesomeIcons.circleInfo, size: (14.0 * scale)), SizedBox(width: (6.0 * scale)), const Text('詳細資訊')],
          ),
        ),
      );
    }

    if (buttons.isEmpty) {
      return const SizedBox.shrink();
    }

    if (buttons.length == 1) {
      return buttons.first;
    }

    return Wrap(spacing: 12.0, runSpacing: 8.0, alignment: WrapAlignment.center, children: buttons);
  }

  void _showDetailsDialog() {
    // 這裡可以根據項目需要實現詳細資訊的顯示邏輯
    // 例如使用 DialogService 或直接顯示 AlertDialog
  }
}
