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
}
