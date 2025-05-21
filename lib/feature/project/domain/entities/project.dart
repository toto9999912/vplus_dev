import 'package:flutter/material.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

import '../enums/project_status.dart';

part 'project.freezed.dart';

@freezed
abstract class Project with _$Project {
  const factory Project({
    required int id,

    ///名稱
    required String projectName,

    ///排序
    @Default(0) int sort,

    ///專案分類
    required ProjectStatus status,

    ///專案色彩
    required Color color,
  }) = _Project;
}
