import 'package:flutter_flavor/flutter_flavor.dart';

enum BackendType { csharp, nestjs, core }

extension BackendTypeExtension on BackendType {
  String get url => FlavorConfig.instance.variables[name]?.toString() ?? '';
}
