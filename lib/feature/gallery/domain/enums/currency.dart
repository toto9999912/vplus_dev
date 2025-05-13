enum CurrencyType {
  rmb,
  eur,
  twd,
  unspecified;

// 從整數轉換為枚舉值
  factory CurrencyType.fromInt(int? value) {
    switch (value) {
      case 0:
        return CurrencyType.rmb;
      case 1:
        return CurrencyType.eur;
      case 2:
        return CurrencyType.twd;
      default:
        return CurrencyType.unspecified;
    }
  }
}
