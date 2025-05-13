import 'package:flutter/material.dart';

/// 自適應媒體網格項目元件
/// 用於在網格視圖中顯示媒體項目，支援選擇、編號顯示等功能
class MediaGridItem extends StatelessWidget {
  final Widget child;
  final int index;
  final bool selected;
  final bool displayNumber;

  const MediaGridItem({
    super.key,
    required this.child,
    required this.index,
    required this.selected,
    this.displayNumber = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey[200],
      ),
      child: Stack(
        fit: StackFit.expand,
        children: [
          _buildFilteredContent(),
          if (displayNumber) _buildNumberDisplay(),
          if (selected) _buildSelectionIndicator(),
        ],
      ),
    );
  }

  /// 構建帶有濾鏡效果的內容
  Widget _buildFilteredContent() {
    return ColorFiltered(
      colorFilter: selected
          ? ColorFilter.mode(
              Colors.black.withValues(alpha: 0.5),
              BlendMode.darken,
            )
          : const ColorFilter.mode(
              Colors.transparent,
              BlendMode.multiply,
            ),
      child: child,
    );
  }

  /// 構建編號顯示
  Widget _buildNumberDisplay() {
    return Positioned.fill(
      child: Container(
        decoration: BoxDecoration(color: Colors.grey.shade800.withValues(alpha: 0.5)),
        alignment: Alignment.center,
        child: Text(
          (index + 1).toString(),
          style: const TextStyle(
            color: Color.fromRGBO(255, 255, 255, 0.5),
            fontSize: 48,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  /// 構建選擇指示器
  Widget _buildSelectionIndicator() {
    return const Positioned(
      bottom: 8,
      right: 8,
      child: Icon(
        Icons.check_circle,
        color: Colors.white,
        size: 28,
      ),
    );
  }
}
