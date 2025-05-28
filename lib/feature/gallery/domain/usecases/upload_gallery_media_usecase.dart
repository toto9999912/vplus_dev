import 'dart:io';

import 'package:dio/dio.dart';

import '../../data/repositories/media_repository.dart';

class UploadGalleryMediaUsecase {
  final MediaRepository repository;

  UploadGalleryMediaUsecase(this.repository);

  Future<void> execute({
    required String uploadType,
    required int galleryTypeId,
    required File file,
    required String fileName,
    required List<int> tagsId,
    ProgressCallback? onSendProgress,
  }) async {
    return await repository.uploadGalleryMedia(
      uploadType: uploadType,
      galleryTypeId: galleryTypeId,
      file: file,
      fileName: fileName,
      tagsId: tagsId,
      onSendProgress: onSendProgress,
    );
  }
}
