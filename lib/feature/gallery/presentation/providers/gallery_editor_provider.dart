import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../domain/enums/media_action.dart';

part 'gallery_editor_provider.g.dart';

@riverpod
class SelectedEditorTab extends _$SelectedEditorTab {
  @override
  MediaAction build({required MediaAction initialTab}) {
    // 只接受 classify 或 note 作為初始標籤
    if (initialTab != MediaAction.classify && initialTab != MediaAction.note) {
      return MediaAction.classify; // 默認值
    }
    return initialTab;
  }

  void setTab(MediaAction tab) {
    if (tab == MediaAction.classify || tab == MediaAction.note) {
      state = tab;
    }
  }
}
