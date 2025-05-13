enum MediaType {
  image,
  video,
  file,
  link;

  // 從字符串轉換為枚舉值
  static MediaType fromString(String? value) {
    switch (value?.toLowerCase()) {
      case 'image':
        return MediaType.image;
      case 'video':
        return MediaType.video;
      case 'link':
        return MediaType.link;
      case 'file':
        return MediaType.file;
      default:
        throw ArgumentError('Invalid media type: $value');
    }
  }
}
