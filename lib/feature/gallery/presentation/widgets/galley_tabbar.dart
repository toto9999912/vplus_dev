import 'package:flutter/material.dart';
import 'package:vplus_dev/shared/widgets/tabbar/circle_tabbar.dart';

import '../../domain/entities/gallery_classifier.dart';

class GalleryTabBar extends StatelessWidget {
  final List<Classifier> classifiers;
  final TabController? controller;
  final void Function(int) onTap;

  const GalleryTabBar({super.key, required this.classifiers, this.controller, required this.onTap});

  @override
  Widget build(BuildContext context) {
    // 將Classifier轉換為CircleTabItem
    final List<CircleTabItem> tabItems =
        classifiers.map((classifier) {
          return CircleTabItem(title: classifier.titleZhTw, iconUrl: classifier.iconUrl, icon: Icons.image_outlined);
        }).toList();

    // 使用通用CircleTabbar組件
    return CircleTabbar(items: tabItems, controller: controller, onTap: onTap);
  }
}
