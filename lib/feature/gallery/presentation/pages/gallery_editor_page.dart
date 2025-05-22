import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:vplus_dev/shared/enum/media_type.dart';

import '../../domain/entities/gallery_media.dart';
import '../../domain/enums/media_action.dart';
import '../providers/gallery_editor_provider.dart';
import '../providers/gallery_providers.dart';
import '../widgets/galley_tabbar.dart';
import '../widgets/media_classifier_tag_screen.dart';

@RoutePage()
class GalleryEditorPage extends ConsumerStatefulWidget {
  final int projectId;
  final GalleryMedia media;
  final MediaAction initialTab;

  const GalleryEditorPage({super.key, required this.projectId, required this.media, required this.initialTab});

  @override
  ConsumerState<GalleryEditorPage> createState() => _GalleryEditorPageState();
}

class _GalleryEditorPageState extends ConsumerState<GalleryEditorPage> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    // 0: classify, 1: note
    final initialIndex = widget.initialTab == MediaAction.note ? 1 : 0;
    _tabController = TabController(
      length: 2, // 只有兩個標籤頁
      vsync: this,
      initialIndex: initialIndex,
    );

    // 監聽標籤變更
    _tabController.addListener(_handleTabChange);
  }

  void _handleTabChange() {
    if (!_tabController.indexIsChanging) {
      // 更新標籤狀態
      final newTab = _tabController.index == 0 ? MediaAction.classify : MediaAction.note;

      ref.read(selectedEditorTabProvider(initialTab: widget.initialTab).notifier).setTab(newTab);
    }
  }

  @override
  void dispose() {
    _tabController.removeListener(_handleTabChange);
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // 讀取當前選擇的標籤
    final selectedTab = ref.watch(selectedEditorTabProvider(initialTab: widget.initialTab));

    return Scaffold(
      appBar: AppBar(
        title: Text('編輯 - ${selectedTab == MediaAction.classify ? '分類' : '註記'}'),
        leading: IconButton(icon: const Icon(Icons.arrow_back), onPressed: () => context.router.pop()),
        bottom: TabBar(controller: _tabController, tabs: const [Tab(text: '分類'), Tab(text: '註記')]),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          Column(
            children: [
              SizedBox(
                height: 200,
                child: Center(
                  child:
                      widget.media.mediaType == MediaType.image
                          ? Image.network(
                            widget.media.image?.mediumAddressUrl ?? '',
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) => const Icon(Icons.broken_image, size: 100),
                          )
                          : const Icon(Icons.perm_media, size: 100),
                ),
              ),
              Expanded(child: ClassifyMediaScreen(projectId: widget.projectId, media: widget.media)),
            ],
          ),
          _buildNoteTab(),
        ],
      ),
    );
  }

  Widget _buildNoteTab() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 16),
          // 顯示媒體縮圖
          SizedBox(
            height: 200,
            child: Center(
              child:
                  widget.media.mediaType.name == 'image'
                      ? Image.network(
                        widget.media.image?.mediumAddressUrl ?? '',
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => const Icon(Icons.broken_image, size: 100),
                      )
                      : const Icon(Icons.perm_media, size: 100),
            ),
          ),
          const SizedBox(height: 24),
          const Text('註記內容:'),
          const SizedBox(height: 8),
          const TextField(maxLines: 5, decoration: InputDecoration(hintText: '輸入您的註記...', border: OutlineInputBorder())),
          const Spacer(),
          ElevatedButton(
            onPressed: () {
              // 儲存註記更改
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('註記已更新')));
              context.router.pop();
            },
            style: ElevatedButton.styleFrom(minimumSize: const Size.fromHeight(50)),
            child: const Text('儲存註記'),
          ),
        ],
      ),
    );
  }
}

class ClassifyMediaScreen extends ConsumerWidget {
  final int projectId;
  final GalleryMedia media;

  const ClassifyMediaScreen({required this.projectId, required this.media, super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final activeGalleryTypeAsync = ref.watch(selectedGalleryTypeProvider);
    return activeGalleryTypeAsync.when(
      data: (galleryType) {
        return DefaultTabController(
          length: galleryType.classifiers.length,
          child: Column(
            children: [
              GalleryTabBar(
                classifiers: galleryType.classifiers,
                onTap: (index) {
                  ref.watch(selectedGalleryClassifierIndexProvider.notifier).setIndex(index);
                },
              ),
              Expanded(
                child: TabBarView(
                  children:
                      galleryType.classifiers.map((classifier) {
                        return MediaClassifierTagScreen(projectId: projectId, classifierId: classifier.id, media: media);
                      }).toList(),
                ),
              ),
            ],
          ),
        );
      },
      error: (error, stackTrace) => ErrorWidget(error),
      loading: () {
        return const Center(child: CircularProgressIndicator());
      },
    );
  }
}
