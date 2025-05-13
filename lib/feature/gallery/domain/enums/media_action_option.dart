import 'package:flutter/material.dart';

enum MediaActionOption {
  /// 編輯tag分類
  editTagCategory,

  /// 加入詢價單
  addQuotation,

  /// 新增註記
  editNote,

  /// 分享
  share,

  /// 刪除
  delete,

  /// 清空詢價單
  clearQuotation,

  /// 全選
  allSelect,
}

extension MediaActionOptionExtension on MediaActionOption {
  String get title {
    switch (this) {
      case MediaActionOption.editTagCategory:
        return '分類';
      case MediaActionOption.editNote:
        return '註記';
      case MediaActionOption.allSelect:
        return '全選';
      case MediaActionOption.share:
        return '分享';
      case MediaActionOption.delete:
        return '刪除';
      case MediaActionOption.addQuotation:
        return '加入詢價單';
      case MediaActionOption.clearQuotation:
        return '清空詢價單';
    }
  }

  IconData get icon {
    switch (this) {
      case MediaActionOption.editTagCategory:
        return Icons.category_outlined;
      case MediaActionOption.editNote:
        return Icons.edit_note_outlined;
      case MediaActionOption.allSelect:
        return Icons.check_box_outline_blank_outlined;
      case MediaActionOption.share:
        return Icons.share_outlined;
      case MediaActionOption.delete:
        return Icons.delete_outline;
      case MediaActionOption.addQuotation:
        return Icons.add_shopping_cart_outlined;
      case MediaActionOption.clearQuotation:
        return Icons.clear_all_outlined;
    }
  }

  Color get color {
    switch (this) {
      case MediaActionOption.editTagCategory:
      case MediaActionOption.editNote:
      case MediaActionOption.allSelect:
      case MediaActionOption.share:
      case MediaActionOption.addQuotation:
        return Colors.black;
      case MediaActionOption.delete:
      case MediaActionOption.clearQuotation:
        return Colors.redAccent;
    }
  }
}
