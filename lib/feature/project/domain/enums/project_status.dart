import 'package:flutter/material.dart';

enum ProjectStatus {
  inProgress, //進行中
  underConstruction, //施工中
  completed, //完工
  onHold, //暫緩
  other, //其他
  archived; //封存

  // 從整數值轉換為枚舉值
  factory ProjectStatus.fromInt(int? value) {
    switch (value) {
      case 0:
        return ProjectStatus.inProgress;
      case 1:
        return ProjectStatus.underConstruction;
      case 2:
        return ProjectStatus.completed;
      case 3:
        return ProjectStatus.onHold;
      case 4:
        return ProjectStatus.other;
      case 99:
        return ProjectStatus.archived;
      default:
        return ProjectStatus.other; // 默認值或錯誤處理
    }
  }

  // 獲取狀態的顯示文本
  String get displayName {
    switch (this) {
      case ProjectStatus.inProgress:
        return '進行中';
      case ProjectStatus.underConstruction:
        return '施工中';
      case ProjectStatus.completed:
        return '已完工';
      case ProjectStatus.onHold:
        return '暫緩';
      case ProjectStatus.other:
        return '其他';
      case ProjectStatus.archived:
        return '封存';
    }
  }

  // 獲取狀態圖標
  IconData get icon {
    switch (this) {
      case ProjectStatus.inProgress:
        return Icons.play_circle_outline;
      case ProjectStatus.underConstruction:
        return Icons.construction;
      case ProjectStatus.completed:
        return Icons.check_circle_outline;
      case ProjectStatus.onHold:
        return Icons.pause_circle_outline;
      case ProjectStatus.other:
        return Icons.help_outline;
      case ProjectStatus.archived:
        return Icons.archive_outlined;
    }
  }
}
