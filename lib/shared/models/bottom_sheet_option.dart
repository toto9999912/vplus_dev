import 'package:flutter/material.dart';

class BottomSheetOption<T> {
  final String title;
  final IconData icon;
  final Color? iconColor;
  final Color? textColor;
  final T value;

  BottomSheetOption({required this.title, required this.icon, required this.value, this.iconColor, this.textColor});
}
