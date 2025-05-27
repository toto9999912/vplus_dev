import 'package:vplus_dev/feature/upload/enum/upload_type.dart';

enum GalleryUploadType {
  camera('拍攝'),
  image('圖片'),
  video('影片'),
  file('檔案'),
  link('連結'),
  text('文字檔'),
  ai('AI圖像分類');

  final String label;
  const GalleryUploadType(this.label);
}

extension GalleryUploadTypeExtension on GalleryUploadType {
  UploadType get toUploadType {
    switch (this) {
      case GalleryUploadType.camera:
        return UploadType.camera;
      case GalleryUploadType.image:
        return UploadType.image;
      case GalleryUploadType.video:
        return UploadType.video;
      case GalleryUploadType.file:
        return UploadType.file;
      default:
        throw UnimplementedError('Unsupported GalleryUploadType: $this');
    }
  }
}
