import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';
import 'package:vplus_dev/core/router/app_router.gr.dart';
import 'package:vplus_dev/shared/enum/media_type.dart';

import '../../domain/enums/media_action.dart';
import '../providers/gallery_media_provider.dart';

@RoutePage()
class GalleryInstagramPage extends ConsumerStatefulWidget {
  final int? initialIndex;

  const GalleryInstagramPage({this.initialIndex, super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _GalleryInstagramPageState();
}

class _GalleryInstagramPageState extends ConsumerState<GalleryInstagramPage> {
  final ItemScrollController itemScrollController = ItemScrollController();
  final ItemPositionsListener itemPositionsListener = ItemPositionsListener.create();

  @override
  void initState() {
    super.initState();
    // 在下一幀等資料載入後滾動到指定位置
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (widget.initialIndex != null && itemScrollController.isAttached) {
        itemScrollController.scrollTo(index: widget.initialIndex!, duration: const Duration(milliseconds: 300), curve: Curves.easeInOut);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final asyncMediaState = ref.watch(galleryMediaNotifierProvider);

    return asyncMediaState.when(
      data: (state) {
        return Scaffold(
          appBar: AppBar(
            leading: IconButton(
              onPressed: () {
                context.pop();
              },
              icon: const Icon(Icons.arrow_back),
            ),
            title: const Text('Image Gallery'),
          ),
          body: ScrollablePositionedList.builder(
            itemCount: state.medias.length,
            itemScrollController: itemScrollController,
            itemPositionsListener: itemPositionsListener,
            itemBuilder: (context, index) {
              final media = state.medias[index];
              return Column(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(border: Border.symmetric(horizontal: BorderSide(color: Colors.grey.withValues(alpha: 0.5)))),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        // AppDropdownButton<MediaAction>(
                        //   customButton: const Icon(Icons.more_horiz_outlined),
                        //   items:
                        //       MediaAction.values
                        //           .map(
                        //             (action) =>
                        //                 DropdownMenuItem<MediaAction>(value: action, child: Text(action.label, style: const TextStyle(fontSize: 16))),
                        //           )
                        //           .toList(),
                        //   onChanged: (action) {
                        //     if (action == null) return;
                        //     _handleActionSelected(action, media);
                        //   },
                        //   showUnderline: false,
                        // ),
                        const SizedBox(width: 8),
                      ],
                    ),
                  ),
                  InkWell(
                    onTap: () {},
                    child: switch (media.mediaType) {
                      MediaType.image => Image(image: NetworkImage(media.image!.mediumAddressUrl)),
                      MediaType.video => const Text('影片'),
                      MediaType.link => const Text('連結'),
                      MediaType.file => const Text('檔案'),
                    },
                  ),
                ],
              );
            },
          ),
        );
      },
      error: (error, stackTrace) => ErrorWidget(error),
      loading: () => const Center(child: CircularProgressIndicator()),
    );
  }

  void _handleActionSelected(MediaAction action, dynamic media) {
    switch (action) {
      case MediaAction.addToQuote:
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('已加入詢價單')));
        break;
      case MediaAction.classify:
        // 直接使用 MediaAction.classify 作為初始標籤
        // context.router.push(GalleryEditorRoute(media: media, initialTab: MediaAction.classify));
        break;
      case MediaAction.note:
        // 直接使用 MediaAction.note 作為初始標籤
        // context.router.push(GalleryEditorRoute(media: media, initialTab: MediaAction.note));
        break;
      case MediaAction.share:
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('分享功能即將推出')));
        break;
      case MediaAction.delete:
        _showDeleteConfirmDialog(media);
        break;
    }
  }

  Future<void> _showDeleteConfirmDialog(dynamic media) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('確認刪除'),
          content: const SingleChildScrollView(child: ListBody(children: <Widget>[Text('您確定要刪除這個項目嗎？'), Text('這個操作無法撤銷。')])),
          actions: <Widget>[
            TextButton(
              child: const Text('取消'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: const Text('刪除'),
              onPressed: () {
                // 執行刪除操作
                Navigator.of(context).pop();
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('項目已刪除')));
              },
            ),
          ],
        );
      },
    );
  }
}
