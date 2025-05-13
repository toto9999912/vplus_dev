import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:vplus_dev/shared/enum/media_type.dart';

import '../enums/currency.dart';
import 'chat_message.dart';
import 'gallery_file.dart';
import 'gallery_image.dart';
import 'gallery_link.dart';
import 'gallery_video.dart';
import 'liked_user.dart';

part 'gallery_media.freezed.dart';
part 'gallery_media.g.dart';

@freezed
abstract class GalleryMedia with _$GalleryMedia {
  const factory GalleryMedia({
    required int id,
    required String title,
    required MediaType mediaType,
    required int galleryTypeId,
    required int uploaderId,
    String? uploaderName,
    double? price,
    CurrencyType? currency,
    String? imageName,
    required DateTime createdAt,
    required DateTime updatedAt,
    required List<LikedUser> likedUsers,
    required List<ChatMessage> messages,
    GalleryImage? image,
    GalleryVideo? video,
    GalleryLink? link,
    GalleryFile? file,
  }) = _GalleryMedia;

  factory GalleryMedia.fromJson(Map<String, dynamic> json) => _$GalleryMediaFromJson(json);
}
