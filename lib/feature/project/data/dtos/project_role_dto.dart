import 'package:freezed_annotation/freezed_annotation.dart';

part 'project_role_dto.freezed.dart';
part 'project_role_dto.g.dart';

@freezed
abstract class ProjectRoleDto with _$ProjectRoleDto {
  const factory ProjectRoleDto({
    ///專案角色id
    required int id,

    ///專案角色名稱
    required String name,

    ///專案角色描述
    String? describe,

    ///專案角色代表色
    required String color,
  }) = _ProjectRoleDto;

  factory ProjectRoleDto.fromJson(Map<String, dynamic> json) => _$ProjectRoleDtoFromJson(json);
}
