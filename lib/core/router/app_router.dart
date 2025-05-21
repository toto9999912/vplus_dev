import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';

import 'app_router.gr.dart';

final rootNavigatorKey = GlobalKey<NavigatorState>();

@AutoRouterConfig(replaceInRouteName: 'Screen|Page|Widget,Route')
class AppRouter extends RootStackRouter {
  AppRouter() : super(navigatorKey: rootNavigatorKey);
  @override
  List<AutoRoute> get routes => [
    AutoRoute(path: '/', page: SplashRoute.page, initial: true),
    AutoRoute(path: '/login', page: LoginRoute.page),

    AutoRoute(
      path: '/home',
      page: HomeRoute.page,
      children: [
        AutoRoute(
          path: 'aboutMe',
          page: AboutMeRoute.page,
          children: [AutoRoute(path: 'dashboard', page: AboutMeDashboardRoute.page, initial: true)],
        ),
        AutoRoute(
          path: 'gallery',
          page: GalleryRoute.page,
          maintainState: false,
          children: [
            AutoRoute(
              path: 'header',
              page: GalleryHeaderRoute.page,
              initial: true,
              children: [
                AutoRoute(
                  path: 'wrapper',
                  page: GalleryWrapperRoute.page,
                  maintainState: true,
                  children: [
                    AutoRoute(path: 'view', initial: true, page: GalleryViewRoute.page),
                    AutoRoute(path: 'media', page: GalleryMediaRoute.page),
                  ],
                ),
              ],
            ),
            AutoRoute(path: 'instagram', page: GalleryInstagramRoute.page),
            AutoRoute(path: 'editor', page: GalleryEditorRoute.page),
          ],
        ),

        AutoRoute(
          path: 'project',
          page: ProjectRoute.page,
          children: [
            AutoRoute(path: 'list', page: ProjectListRoute.page, initial: true),
            AutoRoute(
              path: 'dashboard',
              page: ProjectDashboardRoute.page,
              children: [AutoRoute(path: 'diagram', page: ProjectDiagramRoute.page, children: [])],
            ),
          ],
        ),
      ],
    ),
  ];
}
