import 'package:flutter/material.dart';

class OptionItem<T> {
  final String title;
  final Color color;
  final IconData icon;
  final T value;

  OptionItem({required this.title, required this.color, required this.icon, required this.value});

  // @override
  // String toString() {
  //   return 'OptionItem{name: $name, value: $value}';
  // }
}
