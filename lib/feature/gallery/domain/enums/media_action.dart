enum MediaAction {
  addToQuote('加入詢價單'),
  classify('分類'),
  note('註記'),
  share('分享'),
  delete('刪除');

  final String label;
  const MediaAction(this.label);
}
