// dart format width=80
// GENERATED CODE - DO NOT MODIFY BY HAND

// **************************************************************************
// AutoRouterGenerator
// **************************************************************************

// ignore_for_file: type=lint
// coverage:ignore-file

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'package:auto_route/auto_route.dart' as _i13;
import 'package:flutter/material.dart' as _i14;
import 'package:vplus_dev/feature/about_me/presentation/pages/about_me_dashboard_page.dart'
    as _i1;
import 'package:vplus_dev/feature/about_me/presentation/pages/about_me_page.dart'
    as _i2;
import 'package:vplus_dev/feature/auth/presentation/pages/login_page.dart'
    as _i9;
import 'package:vplus_dev/feature/gallery/domain/entities/gallery_media.dart'
    as _i15;
import 'package:vplus_dev/feature/gallery/domain/enums/media_action.dart'
    as _i16;
import 'package:vplus_dev/feature/gallery/presentation/pages/gallery_editor_page.dart'
    as _i4;
import 'package:vplus_dev/feature/gallery/presentation/pages/gallery_instagram_page.dart'
    as _i6;
import 'package:vplus_dev/feature/gallery/presentation/pages/gallery_media_page.dart'
    as _i7;
import 'package:vplus_dev/feature/gallery/presentation/pages/gallery_page.dart'
    as _i5;
import 'package:vplus_dev/feature/home/presentation/pages/home_page.dart'
    as _i8;
import 'package:vplus_dev/feature/project/presentation/pages/project_dashboard_page.dart'
    as _i10;
import 'package:vplus_dev/feature/project/presentation/pages/project_diagram_page.dart'
    as _i3;
import 'package:vplus_dev/feature/project/presentation/pages/project_page.dart'
    as _i11;
import 'package:vplus_dev/feature/splash/presentation/pages/splash_page.dart'
    as _i12;

/// generated route for
/// [_i1.AboutMeDashboardPage]
class AboutMeDashboardRoute extends _i13.PageRouteInfo<void> {
  const AboutMeDashboardRoute({List<_i13.PageRouteInfo>? children})
    : super(AboutMeDashboardRoute.name, initialChildren: children);

  static const String name = 'AboutMeDashboardRoute';

  static _i13.PageInfo page = _i13.PageInfo(
    name,
    builder: (data) {
      return const _i1.AboutMeDashboardPage();
    },
  );
}

/// generated route for
/// [_i2.AboutMePage]
class AboutMeRoute extends _i13.PageRouteInfo<void> {
  const AboutMeRoute({List<_i13.PageRouteInfo>? children})
    : super(AboutMeRoute.name, initialChildren: children);

  static const String name = 'AboutMeRoute';

  static _i13.PageInfo page = _i13.PageInfo(
    name,
    builder: (data) {
      return const _i2.AboutMePage();
    },
  );
}

/// generated route for
/// [_i3.DiagramViewScreen]
class DiagramViewRoute extends _i13.PageRouteInfo<DiagramViewRouteArgs> {
  DiagramViewRoute({_i14.Key? key, List<_i13.PageRouteInfo>? children})
    : super(
        DiagramViewRoute.name,
        args: DiagramViewRouteArgs(key: key),
        initialChildren: children,
      );

  static const String name = 'DiagramViewRoute';

  static _i13.PageInfo page = _i13.PageInfo(
    name,
    builder: (data) {
      final pathParams = data.inheritedPathParams;
      final args = data.argsAs<DiagramViewRouteArgs>(
        orElse: () => DiagramViewRouteArgs(),
      );
      return _i3.DiagramViewScreen(
        key: args.key,
        projectId: pathParams.getInt('projectId'),
      );
    },
  );
}

class DiagramViewRouteArgs {
  const DiagramViewRouteArgs({this.key});

  final _i14.Key? key;

  @override
  String toString() {
    return 'DiagramViewRouteArgs{key: $key}';
  }
}

/// generated route for
/// [_i4.GalleryEditorPage]
class GalleryEditorRoute extends _i13.PageRouteInfo<GalleryEditorRouteArgs> {
  GalleryEditorRoute({
    _i14.Key? key,
    required int projectId,
    required _i15.GalleryMedia media,
    required _i16.MediaAction initialTab,
    List<_i13.PageRouteInfo>? children,
  }) : super(
         GalleryEditorRoute.name,
         args: GalleryEditorRouteArgs(
           key: key,
           projectId: projectId,
           media: media,
           initialTab: initialTab,
         ),
         initialChildren: children,
       );

  static const String name = 'GalleryEditorRoute';

  static _i13.PageInfo page = _i13.PageInfo(
    name,
    builder: (data) {
      final args = data.argsAs<GalleryEditorRouteArgs>();
      return _i4.GalleryEditorPage(
        key: args.key,
        projectId: args.projectId,
        media: args.media,
        initialTab: args.initialTab,
      );
    },
  );
}

class GalleryEditorRouteArgs {
  const GalleryEditorRouteArgs({
    this.key,
    required this.projectId,
    required this.media,
    required this.initialTab,
  });

  final _i14.Key? key;

  final int projectId;

  final _i15.GalleryMedia media;

  final _i16.MediaAction initialTab;

  @override
  String toString() {
    return 'GalleryEditorRouteArgs{key: $key, projectId: $projectId, media: $media, initialTab: $initialTab}';
  }
}

/// generated route for
/// [_i5.GalleryHeaderPage]
class GalleryHeaderRoute extends _i13.PageRouteInfo<void> {
  const GalleryHeaderRoute({List<_i13.PageRouteInfo>? children})
    : super(GalleryHeaderRoute.name, initialChildren: children);

  static const String name = 'GalleryHeaderRoute';

  static _i13.PageInfo page = _i13.PageInfo(
    name,
    builder: (data) {
      return const _i5.GalleryHeaderPage();
    },
  );
}

/// generated route for
/// [_i6.GalleryInstagramPage]
class GalleryInstagramRoute
    extends _i13.PageRouteInfo<GalleryInstagramRouteArgs> {
  GalleryInstagramRoute({
    int? initialIndex,
    _i14.Key? key,
    List<_i13.PageRouteInfo>? children,
  }) : super(
         GalleryInstagramRoute.name,
         args: GalleryInstagramRouteArgs(initialIndex: initialIndex, key: key),
         initialChildren: children,
       );

  static const String name = 'GalleryInstagramRoute';

  static _i13.PageInfo page = _i13.PageInfo(
    name,
    builder: (data) {
      final args = data.argsAs<GalleryInstagramRouteArgs>(
        orElse: () => const GalleryInstagramRouteArgs(),
      );
      return _i6.GalleryInstagramPage(
        initialIndex: args.initialIndex,
        key: args.key,
      );
    },
  );
}

class GalleryInstagramRouteArgs {
  const GalleryInstagramRouteArgs({this.initialIndex, this.key});

  final int? initialIndex;

  final _i14.Key? key;

  @override
  String toString() {
    return 'GalleryInstagramRouteArgs{initialIndex: $initialIndex, key: $key}';
  }
}

/// generated route for
/// [_i7.GalleryMediaPage]
class GalleryMediaRoute extends _i13.PageRouteInfo<void> {
  const GalleryMediaRoute({List<_i13.PageRouteInfo>? children})
    : super(GalleryMediaRoute.name, initialChildren: children);

  static const String name = 'GalleryMediaRoute';

  static _i13.PageInfo page = _i13.PageInfo(
    name,
    builder: (data) {
      return const _i7.GalleryMediaPage();
    },
  );
}

/// generated route for
/// [_i5.GalleryPage]
class GalleryRoute extends _i13.PageRouteInfo<void> {
  const GalleryRoute({List<_i13.PageRouteInfo>? children})
    : super(GalleryRoute.name, initialChildren: children);

  static const String name = 'GalleryRoute';

  static _i13.PageInfo page = _i13.PageInfo(
    name,
    builder: (data) {
      return const _i5.GalleryPage();
    },
  );
}

/// generated route for
/// [_i5.GalleryViewScreen]
class GalleryViewRoute extends _i13.PageRouteInfo<void> {
  const GalleryViewRoute({List<_i13.PageRouteInfo>? children})
    : super(GalleryViewRoute.name, initialChildren: children);

  static const String name = 'GalleryViewRoute';

  static _i13.PageInfo page = _i13.PageInfo(
    name,
    builder: (data) {
      return const _i5.GalleryViewScreen();
    },
  );
}

/// generated route for
/// [_i5.GalleryWrapperScreen]
class GalleryWrapperRoute extends _i13.PageRouteInfo<void> {
  const GalleryWrapperRoute({List<_i13.PageRouteInfo>? children})
    : super(GalleryWrapperRoute.name, initialChildren: children);

  static const String name = 'GalleryWrapperRoute';

  static _i13.PageInfo page = _i13.PageInfo(
    name,
    builder: (data) {
      return const _i5.GalleryWrapperScreen();
    },
  );
}

/// generated route for
/// [_i8.HomePage]
class HomeRoute extends _i13.PageRouteInfo<void> {
  const HomeRoute({List<_i13.PageRouteInfo>? children})
    : super(HomeRoute.name, initialChildren: children);

  static const String name = 'HomeRoute';

  static _i13.PageInfo page = _i13.PageInfo(
    name,
    builder: (data) {
      return const _i8.HomePage();
    },
  );
}

/// generated route for
/// [_i9.LoginPage]
class LoginRoute extends _i13.PageRouteInfo<void> {
  const LoginRoute({List<_i13.PageRouteInfo>? children})
    : super(LoginRoute.name, initialChildren: children);

  static const String name = 'LoginRoute';

  static _i13.PageInfo page = _i13.PageInfo(
    name,
    builder: (data) {
      return const _i9.LoginPage();
    },
  );
}

/// generated route for
/// [_i10.ProjectDashboardPage]
class ProjectDashboardRoute
    extends _i13.PageRouteInfo<ProjectDashboardRouteArgs> {
  ProjectDashboardRoute({
    required int projectId,
    _i14.Key? key,
    List<_i13.PageRouteInfo>? children,
  }) : super(
         ProjectDashboardRoute.name,
         args: ProjectDashboardRouteArgs(projectId: projectId, key: key),
         initialChildren: children,
       );

  static const String name = 'ProjectDashboardRoute';

  static _i13.PageInfo page = _i13.PageInfo(
    name,
    builder: (data) {
      final args = data.argsAs<ProjectDashboardRouteArgs>();
      return _i10.ProjectDashboardPage(args.projectId, key: args.key);
    },
  );
}

class ProjectDashboardRouteArgs {
  const ProjectDashboardRouteArgs({required this.projectId, this.key});

  final int projectId;

  final _i14.Key? key;

  @override
  String toString() {
    return 'ProjectDashboardRouteArgs{projectId: $projectId, key: $key}';
  }
}

/// generated route for
/// [_i3.ProjectDiagramPage]
class ProjectDiagramRoute extends _i13.PageRouteInfo<ProjectDiagramRouteArgs> {
  ProjectDiagramRoute({
    _i14.Key? key,
    required int projectId,
    List<_i13.PageRouteInfo>? children,
  }) : super(
         ProjectDiagramRoute.name,
         args: ProjectDiagramRouteArgs(key: key, projectId: projectId),
         rawPathParams: {'projectId': projectId},
         initialChildren: children,
       );

  static const String name = 'ProjectDiagramRoute';

  static _i13.PageInfo page = _i13.PageInfo(
    name,
    builder: (data) {
      final pathParams = data.inheritedPathParams;
      final args = data.argsAs<ProjectDiagramRouteArgs>(
        orElse:
            () => ProjectDiagramRouteArgs(
              projectId: pathParams.getInt('projectId'),
            ),
      );
      return _i3.ProjectDiagramPage(key: args.key, projectId: args.projectId);
    },
  );
}

class ProjectDiagramRouteArgs {
  const ProjectDiagramRouteArgs({this.key, required this.projectId});

  final _i14.Key? key;

  final int projectId;

  @override
  String toString() {
    return 'ProjectDiagramRouteArgs{key: $key, projectId: $projectId}';
  }
}

/// generated route for
/// [_i11.ProjectListPage]
class ProjectListRoute extends _i13.PageRouteInfo<void> {
  const ProjectListRoute({List<_i13.PageRouteInfo>? children})
    : super(ProjectListRoute.name, initialChildren: children);

  static const String name = 'ProjectListRoute';

  static _i13.PageInfo page = _i13.PageInfo(
    name,
    builder: (data) {
      return const _i11.ProjectListPage();
    },
  );
}

/// generated route for
/// [_i11.ProjectPage]
class ProjectRoute extends _i13.PageRouteInfo<void> {
  const ProjectRoute({List<_i13.PageRouteInfo>? children})
    : super(ProjectRoute.name, initialChildren: children);

  static const String name = 'ProjectRoute';

  static _i13.PageInfo page = _i13.PageInfo(
    name,
    builder: (data) {
      return const _i11.ProjectPage();
    },
  );
}

/// generated route for
/// [_i12.SplashPage]
class SplashRoute extends _i13.PageRouteInfo<void> {
  const SplashRoute({List<_i13.PageRouteInfo>? children})
    : super(SplashRoute.name, initialChildren: children);

  static const String name = 'SplashRoute';

  static _i13.PageInfo page = _i13.PageInfo(
    name,
    builder: (data) {
      return const _i12.SplashPage();
    },
  );
}
