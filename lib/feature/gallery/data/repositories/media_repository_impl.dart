import 'dart:io';

import 'package:dio/dio.dart';

import '../../domain/entities/gallery_media.dart';
import '../datasources/media_data_source.dart';
import 'media_repository.dart';

class MediaRepositoryImpl implements MediaRepository {
  final MediaDataSource _dataSource;

  MediaRepositoryImpl(this._dataSource);

  @override
  Future<List<GalleryMedia>> getTagSearchMedia(List<int> tagIds) async {
    final dtos = await _dataSource.getTagSearchMedia(tagIds);

    return dtos.map((dto) => dto.toDomain()).toList();
  }

  @override
  Future<void> uploadGalleryMedia({
    required String uploadType,
    required int galleryTypeId,
    required File file,
    required String fileName,
    required List<int> tagsId,
    ProgressCallback? onSendProgress,
  }) async {
    await _dataSource.uploadGalleryMedia(
      file: file,
      galleryTypeId: galleryTypeId,
      fileName: fileName,
      uploadType: uploadType,
      tagsId: tagsId,
      onSendProgress: onSendProgress,
    );
  }
}
