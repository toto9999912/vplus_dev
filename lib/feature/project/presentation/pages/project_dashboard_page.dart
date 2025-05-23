import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:vplus_dev/core/router/app_router.gr.dart';

@RoutePage()
class ProjectDashboardPage extends ConsumerWidget {
  final int projectId;
  const ProjectDashboardPage(this.projectId, {super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return AutoTabsRouter.tabBar(
      routes: [ProjectDiagramRoute(projectId: projectId)],
      builder: (context, child, tabController) {
        return Scaffold(
          appBar: AppBar(
            title: const Text('Project Dashboard'),
            bottom: TabBar(
              controller: tabController,
              tabs: const [
                Tab(text: 'Diagram'),
                // Add more tabs here if needed
              ],
            ),
          ),
          body: child,
          floatingActionButton: FloatingActionButton(onPressed: () {}),
        );
      },
    );
  }
}
