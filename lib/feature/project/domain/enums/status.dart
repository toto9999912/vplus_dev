enum ProjectStatus {
  inProgress, //進行中
  underConstruction, //施工中
  completed, //完工
  onHold, //暫緩
  other, //其他
  archived; //封存

  // 從整數值轉換為枚舉值
  factory ProjectStatus.fromInt(int? value) {
    switch (value) {
      case 0:
        return ProjectStatus.inProgress;
      case 1:
        return ProjectStatus.underConstruction;
      case 2:
        return ProjectStatus.completed;
      case 3:
        return ProjectStatus.onHold;
      case 4:
        return ProjectStatus.other;
      case 99:
        return ProjectStatus.archived;
      default:
        return ProjectStatus.other; // 默認值或錯誤處理
    }
  }
}
