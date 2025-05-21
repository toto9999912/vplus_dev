import 'package:flutter/material.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

import '../../domain/entities/project.dart';
import '../../domain/enums/status.dart';
import 'project_role_dto.dart';

part 'project_dto.freezed.dart';
part 'project_dto.g.dart';

@freezed
abstract class ProjectDto with _$ProjectDto {
  const factory ProjectDto({
    required int id,

    ///名稱
    required String pjname,

    ///等級
    int? level,

    ///排序
    @Default(0) int sort,

    ///專案分類
    int? status,

    ///專案色彩
    String? color,

    List<ProjectRoleDto>? roles,
  }) = _ProjectDto;

  factory ProjectDto.fromJson(Map<String, dynamic> json) => _$ProjectDtoFromJson(json);

  const ProjectDto._();

  /// 將DTO轉換為領域模型
  Project toDomain() {
    return Project(id: id, projectName: pjname, sort: sort, status: ProjectStatus.fromInt(status), color: getHexColor);
  }

  Color get getHexColor {
    try {
      return Color(int.parse(color!.substring(2), radix: 16));
    } catch (e) {
      return Colors.white;
    }
  }
}
