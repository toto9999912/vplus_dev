import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:vplus_dev/core/router/app_router.gr.dart';

@RoutePage()
class HomePage extends ConsumerWidget {
  const HomePage({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return AutoTabsScaffold(
      floatingActionButton: IconButton(onPressed: () {}, icon: const Icon(Icons.change_circle)),
      routes: const [AboutMeRoute(), GalleryRoute()],
      bottomNavigationBuilder: (_, tabsRouter) {
        return BottomNavigationBar(
          currentIndex: tabsRouter.activeIndex,
          onTap: tabsRouter.setActiveIndex,
          selectedItemColor: Colors.black,
          type: BottomNavigationBarType.fixed,
          unselectedItemColor: Colors.grey,
          items: const [
            BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Me'),
            BottomNavigationBarItem(icon: Icon(Icons.photo_library), label: 'Gallery'),
            // BottomNavigationBarItem(icon: Icon(FontAwesomeIcons.file), label: 'project'),
            // BottomNavigationBarItem(icon: Icon(FontAwesomeIcons.book), label: '元件庫'),
          ],
        );
      },
    );
  }
}
