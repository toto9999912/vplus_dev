import '../../domain/entities/gallery_classifier.dart';
import '../../domain/entities/gallery_type.dart';
import '../datasources/gallery_data_source.dart';
import '../dtos/reorder_request_dto.dart';
import 'gallery_repository.dart';

class GalleryRepositoryImpl implements GalleryRepository {
  final GalleryDataSource _dataSource;

  GalleryRepositoryImpl(this._dataSource);

  @override
  Future<List<GalleryType>> getGalleryTypes() async {
    final dtos = await _dataSource.getGalleryTypes();
    // 使用DTO的擴展方法轉換為實體
    return dtos.map((dto) => dto.toDomain()).toList();
  }

  @override
  Future<Classifier> getGalleryClassifierTag(int classifierId) async {
    final dto = await _dataSource.getGalleryClassifierTag(classifierId);
    return dto.toDomain();
  }

  @override
  Future<void> reorderTagCategory(ReorderRequestDto request) async {
    await _dataSource.reorderTagCategory(request);
  }

  @override
  Future<void> reorderTag(ReorderRequestDto request) async {
    await _dataSource.reorderTag(request);
  }
}
