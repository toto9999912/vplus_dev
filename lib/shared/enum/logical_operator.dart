import 'package:json_annotation/json_annotation.dart';

/// 邏輯運算符枚舉，用於查詢和過濾條件
enum LogicalOperator {
  /// 使用 OR 邏輯，任一條件匹配即可
  @JsonValue("OR")
  or,

  /// 使用 AND 邏輯，必須同時匹配所有條件
  @JsonValue("AND")
  and
}
