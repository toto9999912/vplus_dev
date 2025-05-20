import 'package:flutter/material.dart';
import 'package:vplus_dev/feature/gallery/presentation/widgets/color_picker.dart';

import '../../domain/entities/tag.dart';
import 'tag_view.dart';

class TagFormWidget extends StatefulWidget {
  final Tag initialData;
  final Function(Tag) onDataChanged;
  final Color initialColor;

  const TagFormWidget({required this.initialData, required this.onDataChanged, required this.initialColor, super.key});

  @override
  State<TagFormWidget> createState() => _TagFormWidgetState();
}

class _TagFormWidgetState extends State<TagFormWidget> {
  late TextEditingController _textController;
  late Color _selectedColor;
  late Tag _currentData;

  @override
  void initState() {
    super.initState();
    _currentData = widget.initialData;
    _textController = TextEditingController(text: _currentData.title);
    _selectedColor = widget.initialColor;
  }

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          margin: const EdgeInsets.only(top: 15, bottom: 15),
          decoration: BoxDecoration(color: const Color.fromRGBO(0, 0, 0, 0.1), borderRadius: BorderRadius.circular(4)),
          child: TextField(
            controller: _textController,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 18),
            minLines: 1,
            maxLines: 2,
            decoration: const InputDecoration(isDense: true, contentPadding: EdgeInsets.fromLTRB(20.0, 15.0, 10.0, 15.0), border: InputBorder.none),
            onChanged: (value) {
              setState(() {
                _currentData = _currentData.copyWith(title: value);
                widget.onDataChanged(_currentData);
              });
            },
          ),
        ),
        ColorPicker(
          initialColor: _selectedColor,
          onColorChanged: (color) {
            setState(() {
              _selectedColor = color;
              _currentData = _currentData.copyWith(color: defaultColors.indexOf(color));
              widget.onDataChanged(_currentData);
            });
          },
        ),
      ],
    );
  }
}
