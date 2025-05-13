import 'package:freezed_annotation/freezed_annotation.dart';
import '../../../domain/entities/gallery_media.dart';
import '../../../domain/enums/view_mode.dart';

part 'gallery_media_state.freezed.dart';
part 'gallery_media_state.g.dart';

@freezed
abstract class GalleryMediaState with _$GalleryMediaState {
  const factory GalleryMediaState({
    @Default([]) List<GalleryMedia> medias,
    @Default([]) List<int> filterUserIds,
    @Default([]) List<int> selectedIndices,
    @Default(false) bool displayNumber,
    @Default(ViewMode.normal) ViewMode viewMode,
    @Default(false) bool isLoading,
    String? errorMessage,
  }) = _GalleryMediaState;

  factory GalleryMediaState.fromJson(Map<String, dynamic> json) => _$GalleryMediaStateFromJson(json);
}
