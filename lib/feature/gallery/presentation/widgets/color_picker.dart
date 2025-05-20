import 'package:flutter/material.dart';
import 'package:vplus_dev/core/constants/app_color.dart';

import 'tag_view.dart';

class ColorPicker extends StatefulWidget {
  final Color initialColor;
  final Function(Color) onColorChanged;

  const ColorPicker({required this.initialColor, required this.onColorChanged, super.key});

  @override
  State<ColorPicker> createState() => _ColorPickerState();
}

class _ColorPickerState extends State<ColorPicker> {
  late Color _selectedColor;

  @override
  void initState() {
    super.initState();
    _selectedColor = widget.initialColor;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Wrap(
          children:
              defaultColors
                  .map(
                    (color) => GestureDetector(
                      onTap: () {
                        setState(() => _selectedColor = color);
                        widget.onColorChanged(color);
                      },
                      child: Container(
                        margin: const EdgeInsets.all(5),
                        padding: const EdgeInsets.all(3),
                        decoration: BoxDecoration(
                          color: color,
                          shape: BoxShape.circle,
                          border: Border.all(color: _selectedColor == color ? AppColors.textGrey : Colors.transparent),
                          boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.1), blurRadius: 2, offset: const Offset(0, 1))],
                        ),
                        child:
                            _selectedColor == color
                                ? Icon(Icons.check, size: 20, color: _selectedColor == AppColors.white ? Colors.black : Colors.white)
                                : const SizedBox(height: 20, width: 20),
                      ),
                    ),
                  )
                  .toList(),
        ),
      ],
    );
  }
}
