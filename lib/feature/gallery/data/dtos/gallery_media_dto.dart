import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:vplus_dev/shared/enum/media_type.dart';
import '../../domain/entities/gallery_media.dart';
import '../../domain/enums/currency.dart';
import 'chat_message_dto.dart';
import 'gallery_file_dto.dart';
import 'gallery_image_dto.dart';
import 'gallery_link_dto.dart';
import 'gallery_video_dto.dart';
import 'liked_user_dto.dart';

part 'gallery_media_dto.freezed.dart';
part 'gallery_media_dto.g.dart';

@freezed
abstract class GalleryMediaDto with _$GalleryMediaDto {
  const factory GalleryMediaDto({
    required int id,
    required String title,
    required String mediaType,
    required int galleryTypeId,
    required int uploaderId,
    String? uploaderName,
    double? price,
    int? currency, // null=尚未選擇 0=人民幣 1=歐元,2=台幣
    String? imageName,
    required String createdAt,
    required String updatedAt,
    required List<LikedUserDto> likedUsers,
    required List<ChatMessageDto> messages,
    GalleryImageDto? image,
    GalleryVideoDto? video,
    GalleryLinkDto? link,
    GalleryFileDto? file,
  }) = _GalleryMediaDto;

  const GalleryMediaDto._();

  /// 將DTO轉換為領域模型
  GalleryMedia toDomain() {
    return GalleryMedia(
      id: id,
      title: title,
      mediaType: _getMediaType(mediaType),
      galleryTypeId: galleryTypeId,
      uploaderId: uploaderId,
      uploaderName: uploaderName,
      price: price,
      currency: CurrencyType.fromInt(currency),
      imageName: imageName,
      createdAt: DateTime.parse(createdAt),
      updatedAt: DateTime.parse(updatedAt),
      likedUsers: likedUsers.map((dto) => dto.toDomain()).toList(),
      messages: messages.map((dto) => dto.toDomain()).toList(),
      image: image?.toDomain(),
      video: video?.toDomain(),
      link: link?.toDomain(),
      file: file?.toDomain(),
    );
  }

  /// 將mediaType字符串轉換為MediaType枚舉
  MediaType _getMediaType(String type) {
    switch (type.toLowerCase()) {
      case 'image':
        return MediaType.image;
      case 'video':
        return MediaType.video;
      case 'file':
        return MediaType.file;
      case 'link':
        return MediaType.link;
      default:
        return MediaType.image;
    }
  }

  factory GalleryMediaDto.fromJson(Map<String, dynamic> json) => _$GalleryMediaDtoFromJson(json);
}
