enum UploadType {
  camera('拍攝'),
  image('圖片'),
  video('影片'),
  file('檔案'),
  link('連結'),
  text('文字檔'),
  ai('AI圖像分類');

  final String label;
  const UploadType(this.label);
}
