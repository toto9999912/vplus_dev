import 'package:flutter/material.dart';

class CircleTabItem {
  final String title;
  final String? iconUrl;
  final IconData? icon;

  CircleTabItem({required this.title, this.iconUrl, this.icon}) : assert(iconUrl != null || icon != null, '必須提供iconUrl或icon其中一個');
}

class CircleTabbar extends StatelessWidget {
  /// Tab項目列表
  final List<CircleTabItem> items;

  /// 可選的 Tab 控制器，若為 null 則使用 DefaultTabController 提供的 controller
  final TabController? controller;

  /// 可選的自定義高度，默認為80
  final double height;

  /// 圓形圖標的大小，默認為40
  final double circleSize;

  /// 選中時圓框的額外大小，默認為8
  final double selectedExpandSize;

  /// 選中時的圓框線寬，默認為2.5
  final double selectedBorderWidth;

  /// 圓框與文字間的距離，默認為4
  final double spacing;

  /// 文字字體大小，默認為12
  final double fontSize;

  /// 是否顯示陰影，默認為true
  final bool showShadow;

  /// 背景顏色，默認為白色
  final Color backgroundColor;

  final void Function(int)? onTap;

  /// 圖標默認背景顏色，當使用iconUrl但加載失敗時顯示
  final Color defaultIconBackgroundColor;

  const CircleTabbar({
    super.key,
    required this.items,
    this.controller,
    this.height = 80,
    this.circleSize = 40,
    this.selectedExpandSize = 8,
    this.selectedBorderWidth = 2.5,
    this.spacing = 4,
    this.fontSize = 12,
    this.showShadow = true,
    this.backgroundColor = Colors.white,
    this.defaultIconBackgroundColor = Colors.grey,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    // 如果沒有傳入 controller，就從 DefaultTabController 取得
    final TabController effectiveController = controller ?? DefaultTabController.of(context);
    final primaryColor = Theme.of(context).colorScheme.primary;
    final unselectedColor = Theme.of(context).tabBarTheme.unselectedLabelColor ?? Colors.grey;

    return Container(
      height: height,
      decoration: BoxDecoration(
        color: backgroundColor,
        boxShadow: showShadow ? [BoxShadow(color: Colors.grey.withAlpha(76), spreadRadius: 1, blurRadius: 5, offset: const Offset(0, -1))] : null,
      ),
      child: TabBar(
        controller: effectiveController,
        onTap: onTap,
        indicator: const BoxDecoration(), // 去除默認的下劃線指示器
        labelColor: primaryColor,
        unselectedLabelColor: unselectedColor,
        tabs:
            items.map((item) {
              return Tab(
                height: height - 10, // 留出一些空間，防止過於緊湊
                child: AnimatedBuilder(
                  animation: effectiveController.animation!,
                  builder: (context, child) {
                    final index = items.indexOf(item);
                    final animValue = effectiveController.animation!.value;
                    final isSelected = effectiveController.index == index;
                    // 計算動畫過程中選中的比例
                    final isAnimating =
                        (index == effectiveController.index ||
                            index == (animValue > effectiveController.index ? effectiveController.index + 1 : effectiveController.index - 1));
                    double selectedPercent = 0.0;
                    if (isSelected) {
                      selectedPercent = 1.0 - (animValue - index).abs();
                    } else if (isAnimating) {
                      selectedPercent = 1.0 - (animValue - index).abs();
                    }
                    selectedPercent = selectedPercent.clamp(0.0, 1.0);

                    return Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Stack(
                          alignment: Alignment.center,
                          children: [
                            // 外部圓框
                            Container(
                              width: circleSize + (selectedPercent * selectedExpandSize),
                              height: circleSize + (selectedPercent * selectedExpandSize),
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                border: selectedPercent > 0 ? Border.all(color: primaryColor, width: selectedBorderWidth * selectedPercent) : null,
                              ),
                            ),
                            // 圓形圖標
                            _buildCircleIcon(item, context),
                          ],
                        ),
                        SizedBox(height: spacing),
                        Text(item.title, style: TextStyle(fontSize: fontSize, color: Color.lerp(unselectedColor, primaryColor, selectedPercent))),
                      ],
                    );
                  },
                ),
              );
            }).toList(),
      ),
    );
  }

  Widget _buildCircleIcon(CircleTabItem item, BuildContext context) {
    if (item.iconUrl != null) {
      return SizedBox(
        width: circleSize,
        height: circleSize,
        child: CircleAvatar(backgroundImage: AssetImage('assets/${item.iconUrl}'), backgroundColor: defaultIconBackgroundColor),
      );
    } else {
      return Container(
        width: circleSize,
        height: circleSize,
        decoration: BoxDecoration(shape: BoxShape.circle, color: defaultIconBackgroundColor.withAlpha(51)),
        child: Icon(item.icon, color: Theme.of(context).colorScheme.primary, size: circleSize * 0.5),
      );
    }
  }
}
