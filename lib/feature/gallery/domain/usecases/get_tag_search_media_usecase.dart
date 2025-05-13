import '../../data/repositories/media_repository.dart';
import '../entities/gallery_media.dart';

class GetTagSearchMediaUsecase {
  final MediaRepository repository;

  GetTagSearchMediaUsecase(this.repository);

  Future<List<GalleryMedia>> execute(List<int> tagIds) async {
    return await repository.getTagSearchMedia(tagIds);
  }
}
