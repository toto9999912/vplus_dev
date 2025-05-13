import 'package:auto_route/auto_route.dart';
import 'package:drag_select_grid_view/drag_select_grid_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:reorderable_grid_view/reorderable_grid_view.dart';
import 'package:vplus_dev/core/router/app_router.gr.dart';
import 'package:vplus_dev/shared/models/option_item.dart';

import '../../domain/enums/media_action_option.dart';
import '../../domain/enums/view_mode.dart';
import '../providers/gallery_media_provider.dart';
import '../providers/state/gallery_media_state.dart';
import '../widgets/media_display_widget.dart';
import '../widgets/media_grid_item.dart';
import '../widgets/selected_tag_section.dart';

/// 媒體庫顯示頁面，支持拖曳選擇和重新排序功能
@RoutePage()
class GalleryMediaPage extends ConsumerStatefulWidget {
  const GalleryMediaPage({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _GalleryMediaPageState();
}

class _GalleryMediaPageState extends ConsumerState<GalleryMediaPage> {
  final DragSelectGridViewController controller = DragSelectGridViewController();
  List<OptionItem<MediaActionOption>> _actionOptions = [];

  // 將監聽器函數存儲為成員變量以確保正確移除
  void _onSelectionChanged() {
    if (mounted) {
      setState(() {});
    }
  }

  @override
  void initState() {
    super.initState();
    _initializeActionOptions();
    controller.addListener(_onSelectionChanged);
  }

  /// 初始化操作選項列表
  void _initializeActionOptions() {
    _actionOptions =
        MediaActionOption.values
            .map((option) => OptionItem<MediaActionOption>(title: option.title, value: option, icon: option.icon, color: option.color))
            .toList();
  }

  @override
  void dispose() {
    controller.removeListener(_onSelectionChanged);
    controller.dispose();

    super.dispose();
  }

  void showBottomDialog() {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return Container(
          height: 200,
          padding: const EdgeInsets.all(16),
          child: GridView.builder(
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 4, // 每行顯示4個項目
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
              childAspectRatio: 1, // 正方形項目
            ),
            itemCount: _actionOptions.length,
            itemBuilder: (context, index) {
              final option = _actionOptions[index];
              return InkWell(
                onTap: () {
                  Navigator.pop(context);
                  _handleOptionSelected();
                },
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(option.icon, color: option.color, size: 30),
                    const SizedBox(height: 8),
                    Text(option.title, textAlign: TextAlign.center, style: TextStyle(fontSize: 12, color: option.color)),
                  ],
                ),
              );
            },
          ),
        );
      },
    );
  }

  Future<void> _handleOptionSelected() async {
    // 待實作功能
  }

  @override
  Widget build(BuildContext context) {
    final asyncMediaState = ref.watch(galleryMediaNotifierProvider);
    return asyncMediaState.when(
      data: (state) => _buildScaffold(state),
      error: (error, stackTrace) => ErrorWidget(error),
      loading: () => const Center(child: CircularProgressIndicator()),
    );
  }

  /// 構建主要界面Scaffold
  Widget _buildScaffold(GalleryMediaState state) {
    final medias = state.medias;
    return Scaffold(
      appBar: AppBar(
        title: Text('搜尋結果(${medias.length})'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            context.pop();
            if (controller.value.isSelecting) {
              context.pop();
            }
          },
        ),
        actions: [
          switch (state.viewMode) {
            ViewMode.selection => Row(
              children: [
                TextButton(onPressed: () => ref.read(galleryMediaNotifierProvider.notifier).toggleViewMode(), child: const Text('取消')),
                TextButton(onPressed: showBottomDialog, child: const Icon(Icons.more_horiz_outlined)),
              ],
            ),
            ViewMode.normal => TextButton(onPressed: () => ref.read(galleryMediaNotifierProvider.notifier).toggleViewMode(), child: const Text('選取')),
          },
        ],
      ),
      body: Column(
        children: [
          _buildControlsRow(state),
          switch (state.viewMode) {
            ViewMode.normal => buildReorderableGridView(state),
            ViewMode.selection => buildDragSelectGridView(state),
          },
        ],
      ),
    );
  }

  /// 構建控制選項行
  Widget _buildControlsRow(GalleryMediaState state) {
    return Row(
      children: [
        const Expanded(child: SelectedTagSection()),
        IconButton(onPressed: () => ref.read(galleryMediaNotifierProvider.notifier).toggleDisplayNumbers(), icon: const Icon(FontAwesomeIcons.eye)),
      ],
    );
  }

  /// 構建可重排序網格視圖（普通模式）
  Widget buildReorderableGridView(GalleryMediaState state) {
    return Expanded(
      child: ReorderableGridView.count(
        onReorder: (oldIndex, newIndex) async {
          // 待實作重新排序功能
        },
        childAspectRatio: 1.0,
        crossAxisSpacing: 2,
        mainAxisSpacing: 2,
        crossAxisCount: 3,
        children: List.generate(
          state.medias.length,
          (index) => GestureDetector(
            key: ValueKey(state.medias[index].id),
            onTap: () {
              context.pushRoute(GalleryInstagramRoute(initialIndex: index));
            },
            child: MediaGridItem(
              selected: false,
              displayNumber: state.displayNumber,
              index: index,
              child: MediaDisplayWidget(media: state.medias[index]),
            ),
          ),
        ),
      ),
    );
  }

  /// 構建可拖曳選擇網格視圖（選擇模式）
  Widget buildDragSelectGridView(GalleryMediaState state) {
    return Expanded(
      child: DragSelectGridView(
        triggerSelectionOnTap: true,
        gridController: controller,
        itemCount: state.medias.length,
        itemBuilder: (context, index, selected) {
          return MediaGridItem(
            selected: selected,
            index: index,
            displayNumber: state.displayNumber,
            child: MediaDisplayWidget(media: state.medias[index]),
          );
        },
        gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(maxCrossAxisExtent: 150, crossAxisSpacing: 2, mainAxisSpacing: 2),
      ),
    );
  }
}
